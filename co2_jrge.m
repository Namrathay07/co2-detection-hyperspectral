function [gas_map,binary_hotspots] = co2_jrge()

% JRGE - Joint Reflectance and Gas Estimation for CO₂ Detection

% Load hyperspectral image
hdr_file = 'AVIRIS-Classic_L2_Reflectance.f130503t01p00r23rdn_refl_img_corr.hdr';
hcube = hypercube(hdr_file);

% Downsample data cube for performance
cube = hcube.DataCube;
cube = cube(1:5:end, 1:5:end, :);  % Create a smaller version
[rows, cols, bands] = size(cube);

% Reshape for pixel-wise processing
reshapedData = reshape(cube, [], bands);  % [pixels, bands]

% Ensure data is numeric double
reshapedData = double(reshapedData);

% Smooth reflectance using cubic smoothing splines
reflectance_estimate = zeros(size(reshapedData));
for i = 1:size(reshapedData, 1)
    % Suppress occasional NaNs or constant rows
    pixel_spectrum = reshapedData(i, :);
    if any(isnan(pixel_spectrum)) || std(pixel_spectrum) == 0
        reflectance_estimate(i, :) = pixel_spectrum;
    else
        reflectance_estimate(i, :) = fnval(csaps(1:bands, pixel_spectrum, 0.95), 1:bands);
    end
end

% Identify CO₂ absorption range ~640–660 nm
wavelength = hcube.Wavelength;
absorp_band = find(wavelength >= 640 & wavelength <= 660);

% Estimate gas density
gas_density = mean(reflectance_estimate(:, absorp_band), 2) - ...
              mean(reshapedData(:, absorp_band), 2);

% Iterative refinement (3 iterations)
for iter = 1:3
    reflectance_estimate = reflectance_estimate + ...
        0.1 * (reshapedData - reflectance_estimate);

    gas_density = mean(reflectance_estimate(:, absorp_band), 2) - ...
                  mean(reshapedData(:, absorp_band), 2);
end

% Convert to 2D gas density map
gas_map = reshape(gas_density, rows, cols);

% Normalize to [0,1] for visualization
gas_map = gas_map - min(gas_map(:));
gas_map = gas_map / max(gas_map(:));

% Threshold to binary hotspot mask
threshold = graythresh(gas_map);
binary_hotspots = gas_map > threshold;

% Display results
figure;
imagesc(gas_map);
colorbar;
title('JRGE CO₂ Gas Density Map');

figure;
imshow(binary_hotspots);
title('JRGE - Detected CO₂ Hotspots (Binary Mask)');
end