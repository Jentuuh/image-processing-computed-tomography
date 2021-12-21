% Read in image and normalize
img = imread("./data/Parallel Projection/sino_circle.png");
img = double(img)/255;

CT_slice(img);

% Reconstructs the CT slice image using the Fourier Slice Theorem,
% given a sinogram image (Nearest Neighbour Rounding version).
function CT_slice(sinogram)

    first_row = sinogram(1, :);
    first_col = sinogram(:, 1);
    
    % Check whether we need to transpose the sinogram
    if sum(first_row)/length(first_row) < sum(first_col)/length(first_col)
        sinogram = pagetranspose(sinogram);
    end
    
    % Find the resolution of the resulting image and angular range
    img_res = size(sinogram, 2);
    img_dimensions = size(sinogram, 3);

    if size(sinogram, 1) >= 360
        ang_range = 360;
    else
        ang_range = 180;
    end

    % Inter result matrix stores the 1D FTs
    inter_result_matrix = zeros(ang_range, img_res);

    % Result matrix stores the 2D FT (cartesian space)
    result_matrix = zeros(img_res, img_res, img_dimensions);


    % Read in ang_range lines from the sinogram
    for d = 1 : img_dimensions
        for line_index = 1 : ang_range
    
           line = sinogram(line_index, :, d);
    
           % Transform the line into Fourier space
            line_fourier_space = fftshift(fft(ifftshift(line)));
            
            % Store in inter_result_matrix
            inter_result_matrix(line_index, :) = line_fourier_space;
        end
    
        % Transform each 1D Fourier-Transformed line to cartesian space
        for line_index = 1: ang_range
            ft_line = inter_result_matrix(line_index, :);
    
            % The center index (index of the center point on a line) can be
            % used to calculate the distance to the center (radius)
            center_index = size(ft_line, 2) / 2;
    
            for point = 1: size(ft_line, 2)
                % dist_to_center = point - center_index;
                dist_to_center = interp1([0, size(ft_line,2)], [-center_index, center_index], point);
    
                [x,y] = pol2cart(deg2rad(line_index - 1), dist_to_center);
    
                % Transform to [0 ; img_res] range
                x = x + center_index + 1;
                y = y + center_index + 1;
    
                result_matrix(round(y), round(x), d) = ft_line(point);
            end
        end
        % Inverse 2D FFT (to retrieve the resulting image), and flip it vert.
        result_image(:, :, d) = flipud(real(fftshift(ifft2(ifftshift(result_matrix(:, :, d))))));
        
        % Normalized pixel values (applied in each dimension)
        result_image(:, :, d) = result_image(:, :, d) - min(min(result_image(:, :, d)));
        result_image(:, :, d) = result_image(:, :, d) / max(max(result_image(:, :, d)));
    end
   
    % Show the result
    imshow(result_image)
end