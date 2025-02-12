# PiGS : COLMAP-free Gaussian Splatting Using Prior Gaussians
This personal project is implemented for the Research Project 1 (CSED499I) course at POSTECH.
#### PiGS is a model that performs Gaussian Splatting without requiring any prior information(focal length, position etc..) except the RGB image set for the scene.

## Motivation
This is based on [InstantSplat](https://github.com/NVlabs/InstantSplat) and aims to overcome its limitation where the training time increases by O(n^2) as the number of input images grows, despite InstantSplat offering fast training speeds. This also applies to GPU memory usage. (24 images exceed 16GB)
<p align="center">
  <img src="https://github.com/user-attachments/assets/0c25ca30-d1e1-4ee9-8747-e30085320a16" width="400" height="400"/>
</p>

## Progress
Instead of applying instantSplat to the entire images, we first run it on a subset of the images to obtain the prior Gaussian scene. Then, we simultaneously train the camera positions and Gaussian primitives for the entire images.

<p align="center">
  <img src="https://github.com/user-attachments/assets/5de57b82-ad28-4a01-8bce-d69556f4eb11" width="550" height="350"/>
</p>

## Evauluation
After training each model on the 6 scenes from the [Tanks and Temples](https://www.tanksandtemples.org) dataset, we achieved high performance relative to the training time, as reflected by the averaged evaluation metrics.

<p align="center">
  <img src ="https://github.com/user-attachments/assets/9dcae274-70a5-4286-96af-c5bfd6ab90de" width="750" height="130"/>
</p>

<p align="center">
  <img src ="https://github.com/user-attachments/assets/14e85019-d594-4874-b705-f7ae19ea6877" width="700" height="250"/>
</p>

<p align="center">
  <img src ="https://github.com/user-attachments/assets/0f8262a8-b7f9-4861-8b2d-0b463ca11e40" width="750" height="200"/>
</p>

## Discussion
PiGS demonstrates high performance along with fast training speed; however, there are still several limitations that need to be addressed. Currently, PiGS simultaneously updates the Gaussian and estimates the camera position using the RGB loss function. However, the RGB loss function shows limitations in position estimation when the difference between the initial camera position and the ground truth (GT) position becomes too large. To address this, a loss function that extends beyond 2D image-based losses and can provide directionality in 3D space may be necessary. Since the positions of the Gaussians are known, utilizing depth values could be a potential solution.

## Reference
[1] Bernhard Kerbl, Georgios Kopanas, Thomas Leimk¨ uhler, and George Drettakis. 3d gaussian splatting for real-time radiance field rendering. ACM Transactions on Graphics (ToG), 42(4):1–14, 2023.\
[2] Yalda Foroutan, Daniel Rebain, Kwang Moo Yi and Andrea Tagliasacchi. Evaluating Alternatives to SFM Point Cloud Initialization for Gaussian Splatting. arXiv preprint arXiv: 2404.12547, 2024.\
[3] Wenjing Bian, Zirui Wang, Kejie Li, Jia-Wang Bian, and Victor Adrian Prisacariu. Nope-nerf: Optimising neural radiance field with no pose prior. In Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition, pages 4160–4169, 2023.\
[4] Yang Fu, Sifei Liu, Amey Kulkarni, Jan Kautz, Alexei A Efros, and Xiaolong Wang. Colmap-free 3d gaussian splatting. arXiv preprint arXiv:2312.07504, 2023.\
[5] Z. Fan, W. Cong, K. Wen, K. Wang, J. Zhang, X. Ding, D. Xu, B. Ivanovic, M. Pavone, G. Pavlakos et al., InstantSplat: Sparse-view SfM-free Gaussian Splatting in Seconds. arXiv preprint arXiv:2403.20309, 2024.\
[6] Zirui Wang, Shangzhe Wu, Weidi Xie, Min Chen, and Victor Adrian Prisacariu. Nerf–: Neural radiance f ields without known camera parameters. arXiv preprint arXiv:2102.07064, 2021.
[7] Shuzhe Wang, Vincent Leroy, Yohann Cabon, Boris Chidlovskii, and Jerome Revaud. Dust3r: Geometric 3d vision made easy. arXiv preprint arXiv:2312.14132, 2023.\
[8] Johannes L Schonberger and Jan-Michael Frahm. Structurefrom-motion revisited. In Proceedings of the IEEE conference on computer vision and pattern recognition, pages 4104–4113, 2016.
[9] Ben Mildenhall, Pratul P Srinivasan, Matthew Tancik, Jonathan T Barron, Ravi Ramamoorthi, and Ren Ng. Nerf: Representing Scenes As Neural Radiance Fields for View Synthesis. Communications of the ACM, 65(1):99–106, 2021.\
[10] Zirui Wang, Shangzhe Wu, Weidi Xie, Min Chen, and Victor Adrian Prisacariu. Nerf–: Neural radiance f ields without known camera parameters. arXiv preprint arXiv:2102.07064, 2021.\
[11] Arno Knapitsch, Jaesik Park, Qian-Yi Zhou, and Vladlen Koltun. Tanks and temples: Benchmarking large-scale scene reconstruction. ACM Transactions on Graphics (ToG), 36 (4):1–13, 2017.\
[12] Jonathan T. Barron, Ben Mildenhall, Dor Verbin, Pratul P. Srinivasan, and Peter Hedman. Mip-NeRF 360: Unbounded Anti-Aliased Neural Radiance Fields. 2022 IEEE/CVF Conference on Computer Vision and Pattern Recognition (CVPR), pages 5460–5469, 2022.

