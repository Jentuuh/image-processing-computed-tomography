% Reconstructs the CT slice image using Filtered Backprojection,
% given a sinogram image.
function filtered_backprojection(img_file, filter, ang_range)

    if filter ~= "gauss" && filter ~= "ramlak"
        disp("Unknown filter was used. Please try again with " + ...
                "'ramlak' or 'gauss'.")
        return
    end

    % Read in image and normalize
    sinogram = imread(img_file);
    sinogram = double(sinogram)/255;

    first_row = sinogram(1, :);
    first_col = sinogram(:, 1);
    
    % Check whether we need to transpose the sinogram
    if sum(first_row)/length(first_row) > sum(first_col)/length(first_col)
        sinogram = pagetranspose(sinogram);
    end
    
    % Find the resolution of the resulting image
    img_res = size(sinogram, 1);

%     if size(sinogram, 2) >= 360
%         ang_range = 360;
%     else
%         ang_range = 180;
%     end
    
    result = zeros(img_res, img_res);

    ang_fraction = ang_range / size(sinogram, 2);
    
    % For each line of the sinogram
    for line_index = 1 : ang_range

        % Extract the line from the sinogram
        line = sinogram(:, line_index);

        % Transform this line (projection) into Fourier space so we can 
        % apply filtering in the frequency domain
        fourier_line = fftshift(fft2(ifftshift(line)));   
        

        % Apply a high pass filter (filter out blurry low frequent details)
        % The Ram-Lak filter was proposed in the paper about the FBP topic.
        % But as you can see down below I have also experimented with a
        % Gaussian-difference filter.
        if filter == "gauss"
            % Anonymous function creating 1D Gaussian values
            gauss = @(x,mu,sig,amp,vo)amp*exp(-(((x-mu).^2)/(2*sig.^2)))+vo;
    
            % Construct two 1D Gaussian functions with different std. dev.
            x = floor(-img_res/2):1:floor(img_res/2)-1;
            y1 = gauss(x,0,100,9,0);
            y2 = gauss(x,0,150,9,0);

            % We take the Gaussian difference (and transpose for
            % correctness)
            y3 = y2-y1;
            y3 = transpose(y3);
    
            fourier_line = fourier_line .* y3;        

        elseif filter == "ramlak"
            freqs=linspace(-1, 1, img_res).';
            ramlak = abs( freqs );
            
            fourier_line = fourier_line .* ramlak;
        end

        % Transform back to spatial domain
        line = real(fftshift(ifft2(ifftshift(fourier_line))));
        
        % Backproject (inverse radon transform) each filtered projection
        smearing = iradon([line line], [(line_index - 1) * ang_fraction (line_index - 1) * ang_fraction], 'linear', 'none', 1 , img_res);

        result = result + smearing;  
    end
    
    % Normalized pixel values
    result = result - min(min(result));
    result = result/ max(max(result));
    
    % Show result
    imshow(result)
end