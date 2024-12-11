import matplotlib.pyplot as plt
import numpy as np

# 데이터
input_image_counts = [3, 5, 9, 12, 15, 18, 21, 23]
dust3r_times = [0, 1, 4, 7, 12, 18, 23, 30]  # 각 이미지 개수에 대한 학습 시간 (예: 분 단위)
alignment_times = [3, 3, 9, 16, 21, 32, 43, 50]
max_allocated_memory = [2.46, 2.65, 3.88, 5.29, 7.12, 9.36, 12.02, 14.02]
training_time = [i + j for i, j in zip(dust3r_times, alignment_times)]

# 그래프 설정
fig, ax1 = plt.subplots(figsize=(10, 6))

# training_time 그래프 (ax1)
ax1.plot(input_image_counts, training_time, marker='o', color='b', label='Training Time (s)')
ax1.set_xlabel('Image Counts', fontsize=14)
ax1.set_ylabel('Training Time (s)', color='b', fontsize=14)
ax1.tick_params(axis='y', labelcolor='b', labelsize=12)
ax1.tick_params(axis='x', labelsize=12)

# x축 눈금 설정
ax1.set_xticks(input_image_counts)

# x축 범위 설정 (0~25로 설정)
ax1.set_xlim(0, 25)

# 두 번째 y축 생성 (ax2)
ax2 = ax1.twinx()
ax2.plot(input_image_counts, max_allocated_memory, marker='x', color='r', label='Max Allocated Memory (GB)')
ax2.set_ylabel('Max Allocated Memory (GB)', color='r', fontsize=14)
ax2.tick_params(axis='y', labelcolor='r', labelsize=12)

# 제목과 그래프의 그리드
plt.title('Training Time and Max Allocated Memory vs. Image Counts', fontsize=16)
ax1.grid(True)

# 범례 추가
ax1.legend(loc='upper left', fontsize=12)
ax2.legend(loc='upper right', fontsize=12)

# 그래프 표시
plt.show()
