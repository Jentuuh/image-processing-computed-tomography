% Generates a sinogram given an input slice image and `ang_range`, the 
% amount of projections that should be used. The offset between each 
% projection is 1 degree. 
function sinogram_construct(input_image, ang_range)
    img = imread(input_image);
    % Make sure we have a 2D image (radon function needs this as input)
    img=rgb2gray(img);
    img = double(img)/255;
    size(img)

    % Calculate radon transform of the input image (slice)
    img_radon_transform = radon(img, 0:1:ang_range - 1);

    % Normalization to prevent oversaturation
    img_radon_transform = img_radon_transform - min(min(img_radon_transform));
    img_radon_transform = img_radon_transform / max(max(img_radon_transform));
    
    % Show the resulting sinogram
    imshow(img_radon_transform);
    imwrite(img_radon_transform, "./data/witcher_sin.png")

end

