#! /bin/bash

GPU_ID=0
DATA_ROOT_DIR="/mnt/c/Users/user/documents/study/wsl/instantsplat/data"
DATASETS=(
    # TT
    # sora
    # mars
    #Mipnerf
    # MVimgNet
    Tanks
    # university
    )

SCENES=(
    
    # Family
    # Barn
    # Francis
    # Horse
    # Museum
    # Ballroom
    # Ignatius
    # santorini
    # flowers
    # Church
    # ponix
    # garden
    # bicycle
    # bench
    # christmas
    )

PRIOR_VIEWS=(
    # 3
    # 5
    9
    # 12
    # 15
    # 18
    # 21
    # 23
    # 24
    )

# increase iteration to get better metrics (e.g. gs_train_iter=5000)
gs_prior_train_iter=1000
gs_full_train_iter=100
gs_pos_estimate_iter=100
pose_lr=1x
full_views=100

for DATASET in "${DATASETS[@]}"; do
    for SCENE in "${SCENES[@]}"; do
        for N_VIEW in "${PRIOR_VIEWS[@]}"; do

            # SOURCE_PATH must be Absolute path
            SOURCE_PATH=${DATA_ROOT_DIR}/${DATASET}/${SCENE}/${N_VIEW}_views
            MODEL_PATH=./output/infer/${DATASET}/${SCENE}/${N_VIEW}_views_${gs_prior_train_iter}Iter_${pose_lr}PoseLR/

            # # ----- (1) Dust3r_coarse_geometric_initialization -----
            CMD_D1="CUDA_VISIBLE_DEVICES=${GPU_ID} python -W ignore ./coarse_init_infer.py \
            --img_base_path ${SOURCE_PATH} \
            --n_views ${N_VIEW}  \
            --focal_avg \
            "

            # # ----- (2) Train: jointly optimize pose -----
            CMD_T="CUDA_VISIBLE_DEVICES=${GPU_ID} python -W ignore ./train_joint.py \
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
            "

            # ----- (3) Render interpolated pose & output video -----
            CMD_RI="CUDA_VISIBLE_DEVICES=${GPU_ID} python -W ignore ./render_by_interp.py \
            -s ${SOURCE_PATH} \
            -m ${MODEL_PATH}  \
            --n_views ${N_VIEW}  \
            --scene ${SCENE} \
            --iter ${gs_prior_train_iter} \
            --eval \
            --get_video \
            "

            # ----- (3-1) Render interpolated pose & output video (PIGS)-----
            CMD_RI2="CUDA_VISIBLE_DEVICES=${GPU_ID} python -W ignore ./render_by_interp.py \
            -s ${SOURCE_PATH} \
            -m ${MODEL_PATH}  \
            --n_views ${N_VIEW}  \
            --scene ${SCENE} \
            --iter ${gs_full_train_iter} \
            --eval \
            --get_video \
            --expand_train \
            "


            echo "========= ${SCENE}: Dust3r_coarse_geometric_initialization ========="
            #eval $CMD_D1
            echo "========= ${SCENE}: Train: jointly optimize pose ========="
            #eval $CMD_T
            echo "========= ${SCENE}: Render interpolated pose & output video ========="
            #eval $CMD_RI
            echo "========= ${SCENE}: Train 2: jointly optimize pose (PiGS) ========="
            eval $CMD_T2
            echo "========= ${SCENE}: Render interpolated pose & output video (PIGS) ========="
            eval $CMD_RI2
            done
        done
    done