% Generates a sinogram given an input slice image and `ang_range`, the 
% amountof projections that should be used. The offset between each 
% projection is 1 degree. 
function sinogram_construct(input_image, ang_range)
    input_image = double(input_image)/255;

    % Calculate radon transform of the input image (slice)
    img_radon_transform = radon(input_image, 0:1:ang_range - 1);

    % Normalization to prevent oversaturation
    img_radon_transform = img_radon_transform - min(min(img_radon_transform));
    img_radon_transform = img_radon_transform / max(max(img_radon_transform));
    
    % Show the resulting sinogram
    imshow(img_radon_transform);
end

