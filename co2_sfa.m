function [co2_map,hotspot_map] = co2_sfa()

% co2_sfa.m – Spectral Fitting Algorithm for CO₂ Detection
clc; clear;

% Load the AVIRIS hyperspectral data
hcube = hypercube('AVIRIS-Classic_L2_Reflectance.f130503t01p00r23rdn_refl_img_corr.hdr');

% Downsample spatially to reduce memory load
hcubeData = hcube.DataCube(1:5:end, 1:5:end, :);
[rows, cols, bands] = size(hcubeData);
reshapedData = reshape(hcubeData, [], bands);

% Convert data to double for processing
reshapedData = double(reshapedData);

% Define CO₂ absorption band center (adjust if needed)
co2_band_center = 179;  % example center band
bandwidth = 5;
x = 1:bands;

% Simulated Gaussian-shaped CO₂ absorption reference spectrum
ref_spectrum = exp(-((x - co2_band_center).^2) / (2 * bandwidth^2));
ref_spectrum = ref_spectrum / max(ref_spectrum);  % normalize

% Normalize each pixel spectrum (row-wise)
pixel_norms = vecnorm(reshapedData, 2, 2);
normData = reshapedData ./ pixel_norms;

% Perform spectral fitting via dot product with reference spectrum
co2_match_score = normData * ref_spectrum';

% Reshape back to spatial map
co2_map = reshape(co2_match_score, rows, cols);

% Normalize the map
co2_map = mat2gray(co2_map);

% Show CO₂ detection map
figure;
imagesc(co2_map); axis image; colorbar;
title('SFA CO₂ Detection Map');

% Threshold for binary CO₂ hotspot map
threshold = 0.7;
hotspot_map = co2_map > threshold;

% Show binary hotspot output
figure;
imshow(hotspot_map);
title('SFA - Detected CO₂ Hotspots (Binary Map)');
