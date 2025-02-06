# PiGS : COLMAP-free Gaussian Splatting Using Prior Gaussians
This personal project is implemented for the Research Project 1 (CSED499I-01) course at POSTECH.
#### PiGS is a model that performs Gaussian Splatting without requiring any prior information(focal length, position etc..) except the RGB image set for the scene.

## Progress
This is based on [InstantSplat](https://github.com/NVlabs/InstantSplat) and aims to overcome its limitation where the training time increases by O(n^2) as the number of input images grows, despite InstantSplat offering fast training speeds. Instead of applying instantSplat to the entire images, we first run it on a subset of the images to obtain the prior Gaussian scene. Then, we simultaneously train the camera positions and Gaussian primitives for the entire images.

<p align="center">
  <img src="https://github.com/user-attachments/assets/5de57b82-ad28-4a01-8bce-d69556f4eb11" width="550" height="350"/>
</p>

## Evauluation
After training each model on the 6 scenes from the [Tanks and Temples](https://www.tanksandtemples.org) dataset, we achieved high performance relative to the training time, as reflected by the averaged evaluation metrics.

<p align="center">
  <img src ="https://github.com/user-attachments/assets/9dcae274-70a5-4286-96af-c5bfd6ab90de" width="750" height="130"/>
</p>
<p align="center">
  <img src ="https://github.com/user-attachments/assets/0f8262a8-b7f9-4861-8b2d-0b463ca11e40" width="750" height="200"/>
</p>

## Discussion
PiGS demonstrates high performance along with fast training speed; however, there are still several limitations that need to be addressed. Currently, PiGS simultaneously updates the Gaussian and estimates the camera position using the RGB loss function. However, the RGB loss function shows limitations in position estimation when the difference between the initial camera position and the ground truth (GT) position becomes too large. To address this, a loss function that extends beyond 2D image-based losses and can provide directionality in 3D space may be necessary. Since the positions of the Gaussians are known, utilizing depth values could be a potential solution.
