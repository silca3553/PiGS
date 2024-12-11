import os
import numpy as np
import sys
from typing import NamedTuple
from utils.camera_utils import generate_interpolated_path
from utils.camera_utils import visualizer
from utils.graphics_utils import getWorld2View2, focal2fov, fov2focal
from PIL import Image, ImageOps
import json

class CameraInfo(NamedTuple):
    uid: int
    R: np.array
    T: np.array
    FovY: np.array
    FovX: np.array
    image: np.array
    image_path: str
    image_name: str
    width: int
    height: int

def get_jpg_files(path):
    return sorted(f for f in os.listdir(path) if f.lower().endswith('.jpg'))


def interpolate_pose(prior_path, expand_path,model_path,iter, is_eval_train, test_path):
    print("prior_path :",prior_path)
    prior_img_list = get_jpg_files(prior_path)
    expand_img_list = get_jpg_files(expand_path)

    org_pose = np.load(model_path + f"pose/pose_{iter}.npy")
    visualizer(org_pose, ["green" for _ in org_pose], model_path + "pose/poses_origin.png")
    
    print("total image : ",len(expand_img_list))
    all_inter_pose = []
    name_list = []
    start = expand_img_list.index(prior_img_list[0])
    for i in range(len(prior_img_list)-1):
        end =  expand_img_list.index(prior_img_list[i+1])
        print(start,end)
        tmp_inter_pose = generate_interpolated_path(poses=org_pose[i:i+2], n_interp=end-start)
        all_inter_pose.append(org_pose[i][0:3])
        all_inter_pose.extend(tmp_inter_pose[1:])
        name_list.extend([name[:-4] for name in expand_img_list[start:end]])
        start = end
    all_inter_pose.append(org_pose[i+1][0:3])

    name_list.append(expand_img_list[start][:-4])

    if is_eval_train:
        test_img_list = get_jpg_files(test_path)[1::2]
        for test_name in test_img_list:
            if test_name in name_list:
                

    with open(model_path + "full_train_images_PIGS.json", "w", encoding="utf-8") as file:
        json.dump({"image_name": name_list}, file, ensure_ascii=False, indent=4)

    all_inter_pose = np.array(all_inter_pose)#.reshape(-1, 3, 4)
    print("total pose : ",all_inter_pose.shape)
    inter_pose_list = []
    for p in all_inter_pose:
        tmp_view = np.eye(4)
        tmp_view[:3, :3] = p[:3, :3]
        tmp_view[:3, 3] = p[:3, 3]
        inter_pose_list.append(tmp_view)
    inter_pose = np.stack(inter_pose_list, 0)
    visualizer(inter_pose, ["blue" for _ in inter_pose], model_path + "pose/poses_orgin_PIGS.png")

    np.save(model_path + "pose/pose_origin_PIGS.npy", inter_pose)



# For interpolated video, open when only render interpolated video
def readColmapCamerasExpand(cam_extrinsics, cam_intrinsics, images_folder, model_path):
    
    pose_interpolated_path = model_path + 'pose/pose_origin_PIGS.npy'
    pose_interpolated = np.load(pose_interpolated_path)
    intr = cam_intrinsics[1]
    print(images_folder)
    images_list = get_jpg_files(images_folder)
    print("!!",len(images_list),pose_interpolated.shape)
    cam_infos = []
    poses=[]
    for idx, pose_npy in enumerate(pose_interpolated):
        sys.stdout.write('\r')
        sys.stdout.write("Reading camera {}/{}".format(idx+1, pose_interpolated.shape[0]))
        sys.stdout.flush()

        extr = pose_npy
        intr = intr
        height = intr.height
        width = intr.width

        uid = idx+1
        R = extr[:3, :3].transpose()
        T = extr[:3, 3]
        pose =  np.vstack((np.hstack((R, T.reshape(3,-1))),np.array([[0, 0, 0, 1]])))
        # print(uid)
        # print(pose.shape)
        # pose = np.linalg.inv(pose)
        poses.append(pose)
        if intr.model=="SIMPLE_PINHOLE":
            focal_length_x = intr.params[0]
            FovY = focal2fov(focal_length_x, height)
            FovX = focal2fov(focal_length_x, width)
        elif intr.model=="PINHOLE":
            focal_length_x = intr.params[0]
            focal_length_y = intr.params[1]
            FovY = focal2fov(focal_length_y, height)
            FovX = focal2fov(focal_length_x, width)
        else:
            assert False, "Colmap camera model not handled: only undistorted datasets (PINHOLE or SIMPLE_PINHOLE cameras) supported!"

        image_name = str(idx).zfill(4)
        image = ImageOps.exif_transpose(Image.open(images_folder + '/' + images_list[idx]))

        cam_info = CameraInfo(uid=uid, R=R, T=T, FovY=FovY, FovX=FovX, image=image,
                              image_path=images_folder, image_name=image_name, width=width, height=height)
        cam_infos.append(cam_info)

    sys.stdout.write('\n')
    return cam_infos, poses