#! /bin/bash

GPU_ID=0
DATA_ROOT_DIR="/mnt/c/Users/user/documents/study/wsl/instantsplat/data"
DATASETS=(
    Tanks
    # Mipnerf
    # TT
    # MVimgNet
    # university
    )

SCENES=(
    #Barn
    #Church
    #Museum
    Horse
    #Family
    #Ballroom
    # bicycle
    # Francis
    # Ignatius
    # ponix
    )

N_VIEWS=(
    # 3
    # 5
    9
    # 12
    # 24
    )

# increase iteration to get better metrics (e.g. gs_train_iter=5000)
gs_prior_train_iter=1000
gs_full_train_iter=5000
gs_pos_estimate_iter=3000
full_views=108

for DATASET in "${DATASETS[@]}"; do
    for SCENE in "${SCENES[@]}"; do
        for N_VIEW in "${N_VIEWS[@]}"; do

            # Sparse_image_folder must be Absolute path
            Sparse_image_folder=${DATA_ROOT_DIR}/${DATASET}/${SCENE}/24_views
            SOURCE_PATH=${Sparse_image_folder}/dust3r_${N_VIEW}_views
            MODEL_PATH=./output/eval/${DATASET}/${SCENE}/${N_VIEW}_views/
            GT_POSE_PATH=${DATA_ROOT_DIR}/${DATASET}/${SCENE}

            # ----- (1) Dust3r_coarse_geometric_initialization -----
            CMD_D1="CUDA_VISIBLE_DEVICES=${GPU_ID} python ./coarse_init_eval.py \
            --img_base_path ${Sparse_image_folder} \
            --n_views ${N_VIEW}  \
            --focal_avg \
            "

            # ----- (2) Train: jointly optimize pose -----
            CMD_T="CUDA_VISIBLE_DEVICES=${GPU_ID} python ./train_joint.py \
            -s ${SOURCE_PATH} \
            -m ${MODEL_PATH}  \
            --n_views ${N_VIEW}  \
            --scene ${SCENE} \
            --iter ${gs_prior_train_iter} \
            --optim_pose \
            "

            # # ----- (2-1) Train: jointly optimize pose (PiGS) -----
            CMD_T2="CUDA_VISIBLE_DEVICES=${GPU_ID} python -W ignore ./train_joint.py \
            -s ${SOURCE_PATH} \
            -m ${MODEL_PATH}  \
            --n_views ${N_VIEW}  \
            --full_views ${full_views} \
            --scene ${SCENE} \
            --iter ${gs_prior_train_iter} \
            --full_iter ${gs_full_train_iter} \
            --pos_est_iter ${gs_pos_estimate_iter} \
            --optim_pose \
            --expand_train \
            --for_eval_train \
            "
            
            # ----- (3) Dust3r_test_pose_initialization -----
            CMD_D2="CUDA_VISIBLE_DEVICES=${GPU_ID} python ./init_test_pose.py \
            --img_base_path ${Sparse_image_folder} \
            --n_views ${N_VIEW}  \
            --focal_avg \
            "

            # ----- (4) Render -----
            CMD_R="CUDA_VISIBLE_DEVICES=${GPU_ID} python ./render.py \
            -s ${SOURCE_PATH} \
            -m ${MODEL_PATH}  \
            --n_views ${N_VIEW}  \
            --scene ${SCENE} \
            --optim_test_pose_iter 500 \
            --iter ${gs_prior_train_iter} \
            --eval \
            "
            
            # ----- (4-1) Render (PIGS) -----
            CMD_R2="CUDA_VISIBLE_DEVICES=${GPU_ID} python ./render.py \
            -s ${SOURCE_PATH} \
            -m ${MODEL_PATH}  \
            --n_views ${N_VIEW}  \
            --scene ${SCENE} \
            --optim_test_pose_iter 500 \
            --iter ${gs_full_train_iter} \
            --eval \
            --expand_train \
            "

            # ----- (5) Metrics -----
            CMD_M="CUDA_VISIBLE_DEVICES=${GPU_ID} python ./metrics.py \
            -m ${MODEL_PATH}  \
            --gt_pose_path ${GT_POSE_PATH} \
            --iter ${gs_prior_train_iter} \
            --n_views ${N_VIEW}  \
            "

            
            # ----- (5-1) Metrics (PIGS) -----
            CMD_M2="CUDA_VISIBLE_DEVICES=${GPU_ID} python ./metrics.py \
            -m ${MODEL_PATH}  \
            --gt_pose_path ${GT_POSE_PATH} \
            --iter ${gs_full_train_iter} \
            --expand_train \
            --n_views ${N_VIEW}  \
            "

            echo "========= ${SCENE}: Dust3r_coarse_geometric_initialization ========="
            #eval $CMD_D1
            echo "========= ${SCENE}: Train: jointly optimize pose ========="
            #eval $CMD_T
            echo "========= ${SCENE}: Train: jointly optimize pose (PIGS) ========="
            eval $CMD_T2
            echo "========= ${SCENE}: Dust3r_test_pose_initialization ========="
            #eval $CMD_D2

            echo "========= ${SCENE}: Render ========="
            #eval $CMD_R
            echo "========= ${SCENE}: Metric ========="
            #eval $CMD_M
            echo "========= ${SCENE}: Render (PIGS) ========="
            eval $CMD_R2
            echo "========= ${SCENE}: Metric (PIGS) ========="
            eval $CMD_M2
            done
        done
    done