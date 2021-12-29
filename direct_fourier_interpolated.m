% Reconstructs the CT slice image using the Fourier Slice Theorem,
% given a sinogram image (Linear Interpolation version).
function direct_fourier_interpolated(img_file)

    % Read in image and normalize
    sinogram = imread(img_file);
    sinogram = double(sinogram)/255;

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

    % Result matrix stores the 2D FT (cartesian space)
    result_matrix = zeros(img_res, img_res);

    ang_fraction = ang_range / size(sinogram, 1);

    
    % Here we'll store the X- and Y-coordinates that will be used for 
    % linear interpolation
    x_coords = 1:(ang_range * img_res);
    y_coords = 1:(ang_range * img_res);

    % We'll store the complex values behind each (X,Y) pair in this vector
    complex_points = 1:(ang_range * img_res);
    
    % For our interpolated result in Fourier Space, we created a discrete 
    % mesh grid that has the same size as the image's resolution. The
    % complex points in each cell of this mesh grid will be filled in by
    % doing linear interpolation on the points represented by `x_coords`,
    % `y_coords` and `complex_points`.
    [xq,yq] = meshgrid(1:1:img_res, 1:1:img_res);

    for d = 1 : img_dimensions
        
        % Read in ang_range lines from the sinogram
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
            center_index = length(ft_line) / 2;
    
            for point = 1: length(ft_line)
                dist_to_center = interp1([0, length(ft_line)], [-center_index, center_index], point);
                
                % Retrieve cartesian coordinates (since we know rho and theta)
                [x,y] = pol2cart(deg2rad((line_index - 1) * ang_fraction), dist_to_center);
                
                % Shift to [0 ; img_res] range
                x = x + center_index;
                y = y + center_index;
                
                % Put all X coordinates, Y coordinates and complex points into
                % vectors so we can use them for grid interpolation
                x_coords((line_index - 1) * img_res + point) = x;
                y_coords((line_index - 1) * img_res + point) = y;
                complex_points((line_index - 1) * img_res + point) = ft_line(point);
            end
        end
        % Interpolate on a grid that corresponds to the image resolution
        result_matrix(:,:, d) = griddata(x_coords, y_coords, complex_points, xq, yq, 'linear');
    
        % Correction for values that are NaN
        for i = 1:size(result_matrix, 1)
            for j = 1:size(result_matrix, 2)
                if isnan(result_matrix(i, j, d))
                    result_matrix(i, j, d) = complex(0,0);
                end
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