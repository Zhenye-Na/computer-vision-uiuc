# Spring 2018 CS543/ECE549
# Assignment 1: Shape from Shading

![](http://slazebni.cs.illinois.edu/spring18/assignment1/shape_from_shading.jpg)

## Instructions

**The goal of this assignment is to implement shape from shading as described in Lecture 4 (see also Section 2.2.4 of Forsyth & Ponce 2nd edition).**

1. Download the sample code and data. The data, in the croppedyale directory, consists of 64 images each of four subjects from the Yale Face database. The light source directions are encoded in the file names. The code consists of several .m functions. Your task will be to add some code to the top-level script, run_me.m, and to fill in the code in `photometric_stereo.m` and `get_surface.m`, as explained below. The remaining files are utilities to load the input data and display the output.

2. For each subject (subdirectory in croppedyale), read in the images and light source directions. This is accomplished by the function LoadFaceImages.m provided in the zip file (which, in turn, calls getpgmraw.m to read the PGM files). LoadFaceImages returns the images for the 64 light source directions and an ambient image (i.e., image taken with all the light sources turned off). 

3. Preprocess the data: subtract the ambient image from each image in the light source stack, set any negative values to zero, rescale the resulting intensities to between `0` and `1` (they are originally between `0` and `255`).

4. Estimate the albedo and surface normals. For this, you need to fill in code in `photometric_stereo.m`, which is a function taking as input the image stack corresponding to the different light source directions and the matrix of of the light source directions, and returning an albedo image and surface normal estimates. The latter should be stored in a three-dimensional matrix. That is, if your original image dimensions are h x w, the surface normal matrix should be h x w x 3, where the third dimension corresponds to the x-, y-, and z-components of the normals. To solve for the albedo and the normals, you will need to set up a linear system as shown in slide 20 of Lecture 4.


5. Compute the surface height map by integration. The method is shown in slide 23 of Lecture 4, except that instead of continuous integration of the partial derivatives over a path, you will simply be summing their discrete values. Your code implementing the integration should go in the get_surface.m file. As stated in the slide, to get the best results, you should compute integrals over multiple paths and average the results. You should implement the following variants of integration:
Integrating first the rows, then the columns. That is, your path first goes along the same row as the pixel along the top, and then goes vertically down to the pixel. It is possible to implement this without nested loops using the cumsum function.
Integrating first along the columns, then the rows.
Average of the first two options.
Average of multiple random paths. For this, it is fine to use nested loops. You should determine the number of paths experimentally.

6. Display the results using functions `display_output` and `plot_surface_normals` included in the zip archive. 


**Hint for No.3:** these operations can be done without using any loops whatsoever. You may want to look into MATLAB's `bsxfun` function.

**Hints for No.4:**

- To get the least-squares solution of a linear system, use MATLAB's backslash operator. That is, the solution to Ax = b is given by x = A\b.
- If you directly implement the formulation of slide 20 of the lecture, you will have to loop over every image pixel and separately solve a linear system in each iteration. There is a way to get all the solutions at once by stacking the unknown g vectors for every pixel into a 3 x npix matrix and getting all the solutions with a single application of the backslash operator.
- You will most likely need to reshape your data in various ways before and after solving the linear system. Useful MATLAB functions for this include reshape and cat.
- You may also need to use element-wise operations. For example, for two equal-size matrices X and Y, X .* Y multiplies corresponding elements, and X.^2 squares every element. As before, bsxfun can also be a very useful function here.

### Extra Credit
On this assignment, there are not too many opportunities for "easy" extra credit. This said, here are some ideas for exploration:

* Generate synthetic input data using a 3D model and a graphics renderer and run your method on this data. Do you get better results than on the face data? How close do you get to the ground truth (i.e., the true surface shape and albedo)?
* Investigate more advanced methods for shape from shading or surface reconstruction from normal fields.
* Try to detect and/or correct misalignment problems in the initial images and see if you can improve the solution.
* Using your initial solution, try to detect areas of the original images that do not meet the assumptions of the method (shadows, specularities, etc.). Then try to recompute the solution without that data and see if you can improve the quality of the solution.

If you complete any work for extra credit, be sure to clearly mark that work in your report.