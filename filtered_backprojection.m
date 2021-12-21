% Read in image and normalize
img = imread("./data/Parallel Projection/SheppLoganPhantom.png");
img = double(img)/255;
CT_radon(img);

% Reconstructs the CT slice image using Filtered Backprojection,
% given a sinogram image.
function CT_radon(sinogram)

    first_row = sinogram(1, :);
    first_col = sinogram(:, 1);
    
    % Check whether we need to transpose the sinogram
    if sum(first_row)/length(first_row) > sum(first_col)/length(first_col)
        sinogram = pagetranspose(sinogram);
    end
    
    % Find the resolution of the resulting image and angular range
    img_res = size(sinogram, 1);

    if size(sinogram, 2) >= 360
        ang_range = 360;
    else
        ang_range = 180;
    end
    
    result = zeros(img_res, img_res);
    
    % For each line of the sinogram
    for line_index = 1 : ang_range

        % Extract the line from the sinogram
        line = sinogram(:, line_index);

        % Transform this line (projection) into Fourier space so we can 
        % apply filtering in the frequency domain
        fourier_line = fftshift(fft2(ifftshift(line)));   

        % Apply a high pass filter (filter out blurry low frequent details)
        % The Ram-Lak filter was proposed in the paper about the FBP topic.
        freqs=linspace(-1, 1, img_res).';
        ramlak = abs( freqs );
        
        fourier_line = fourier_line .* ramlak;

        % Transform back to spatial domain
        line = real(fftshift(ifft2(ifftshift(fourier_line))));
        
        % Backproject (inverse radon transform) each filtered projection
        smearing = iradon([line line], [line_index line_index], 'linear', 'none', 1 , img_res);

        result = result + smearing;  
    end
    
    % Normalized pixel values
    result = result - min(min(result));
    result = result/ max(max(result));
    
    % Show result
    imshow(result)
end