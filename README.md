# Computed Tomography Reconstruction
A project for my Image Processing course. It involves image reconstruction from a sinogram by making use of the Fourier Slice Theorem, Filtered Backprojection and Sinogram Generation.

# Summary
`direct_fourier_reconstruct(img_file, ang_range)`: Reconstructs CT slice image via Fourier Slice Theorem using nearest neighbour interpolation. `img_file`represents the path to the input sinogram. `ang_range` is the angular range (in degrees) that that the sinogram covers (either 180 or 360).

`direct_fourier_interpolated(img_file, ang_range)`: Reconstructs CT slice image via Fourier Slice Theorem using bilinear interpolation. The parameters have been explained above.

`filtered_backprojection(img_file, filter, ang_range)`: Reconstructs CT slice image via Filtered Backprojection. `filter` represents the high-pass filter that is used in the algorithm. Should be equal to either `"gauss"` or `"ramlak"`. The other parameters have been explained above.

`sinogram_construct(input_image, ang_range)`: Generates a sinogram given an input slice image. `input_image` represents the path to the input slice image. `ang_range` represents the amount of projections that should be used.


# Running the programs
The easiest way to run the program is by simply typing `PROGRAM_FILE_NAME(func_params...)` in the MATLAB command prompt.

