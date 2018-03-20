# Spring 2018 CS543/ECE549
# Assignment 3: Robust estimation and geometric vision
The goal of this assignment is to implement robust homography and fundamental matrix estimation to register pairs of images, as well as attempt triangulation and single-view 3D measurements.

### Contents
* [Part 1: Stitching pairs of images](# part 1)
* Part 2: Fundamental matrix estimation and triangulation
* Part 3: Single-view geometry
* Grading checklist and submission instructions


## [Part 1: Stitching pairs of images](# part 1)
Python code here and in Part 2 by Lavisha Aggarwal

The first step is to write code to stitch together a single pair of images. For this part, you will be working with the following pair (click on the images to download the high-resolution versions):

| ![](http://slazebni.cs.illinois.edu/spring18/assignment3/uttower_left.JPG) | ![](http://slazebni.cs.illinois.edu/spring18/assignment3/uttower_right.JPG) |
|----------------------------------------------------------------------------|-----------------------------------------------------------------------------|


1. Load both images, convert to double and to grayscale.
2. Detect feature points in both images. We provide Harris detector code you can use (MATLAB, Python) or feel free to use the blob detector you wrote for Assignment 2.
3. Extract local neighborhoods around every keypoint in both images, and form descriptors simply by "flattening" the pixel values in each neighborhood to one-dimensional vectors. Experiment with different neighborhood sizes to see which one works the best. If you're using your Laplacian detector, use the detected feature scales to define the neighborhood scales.  
Optionally, feel free to experiment with SIFT descriptors.
	- MATLAB: Here is some basic code for computing SIFT descriptors of circular regions, such as the ones returned by the detector from Assignment 2.
	- Python: You can use the OpenCV library to extract keypoints through the function `cv2.xfeatures2D.SIFT_create().detect` and compute descripters through the function `cv2.xfeatures2D.SIFT_create().compute`. This tutorial provides details about using SIFT in OpenCV.
4. Compute distances between every descriptor in one image and every descriptor in the other image. In MATLAB, you can use this code for fast computation of Euclidean distance. In Python, you can use `scipy.spatial.distance.cdist(X,Y,'sqeuclidean')` for fast computation of Euclidean distance. If you are not using SIFT descriptors, you should experiment with computing normalized correlation, or Euclidean distance after normalizing all descriptors to have zero mean and unit standard deviation.
5. Select putative matches based on the matrix of pairwise descriptor distances obtained above. You can select all pairs whose descriptor distances are below a specified threshold, or select the top few hundred descriptor pairs with the smallest pairwise distances.
6. Run RANSAC to estimate a homography mapping one image onto the other. Report the number of inliers and the average residual for the inliers (squared distance between the point coordinates in one image and the transformed coordinates of the matching point in the other image). Also, display the locations of inlier matches in both images.
7. Warp one image onto the other using the estimated transformation. To do this in MATLAB, you will need to learn about maketform and imtransform functions. In Python, use skimage.transform.ProjectiveTransform and skimage.transform.warp. 
8. Create a new image big enough to hold the panorama and composite the two images into it. You can composite by simply averaging the pixel values where the two images overlap. Your result should look something like this (but hopefully with a more precise alignment):
![](http://slazebni.cs.illinois.edu/spring18/assignment3/sample_panorama.jpg)
You should create color panoramas by applying the same compositing step to each of the color channels separately (for estimating the transformation, it is sufficient to use grayscale images).

### Tips and Details
* For RANSAC, a very simple implementation is sufficient. Use four matches to initialize the homography in each iteration. You should output a single transformation that gets the most inliers in the course of all the iterations. For the various RANSAC parameters (number of iterations, inlier threshold), play around with a few "reasonable" values and pick the ones that work best. Refer to this lecture for details on RANSAC. For randomly sampling matches, you can use the randperm or randsample functions.
* For details of homography fitting, you should review this lecture.
* Homography fitting calls for homogeneous least squares. The solution to the homogeneous least squares system AX=0 is obtained from the SVD of A by the singular vector corresponding to the smallest singular value. In MATLAB, use `[U,S,V]=svd(A); X = V(:,end)`;
* In Python, `U, s, V = numpy.linalg.svd(A)` performs the singular value decomposition and V[len(V)-1] gives the smallest singular value. 







