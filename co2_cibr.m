function [co2_index, hotspot_mask] = co2_cibr()
% --- File path
imgFile = 'C:\Users\namra\OneDrive\Desktop\AVIRIS_CO2\AVIRIS-Classic_L2_Reflectance.f130503t01p00r23rdn_refl_img_corr.img';

% --- Metadata manually from .hdr
lines = 677;           % Rows
samples = 781;         % Columns
bands = 224;           % Spectral bands
interleave = 'bip';    % Band interleaved by pixel
datatype = 'uint16';   % AVIRIS format
byteorder = 'ieee-le'; % Little endian
offset = 0;            % Header offset

% --- Read and downsample (to reduce memory usage)
fprintf("Reading and downsampling...\n");
data = multibandread(imgFile, [lines, samples, bands], datatype, offset, interleave, byteorder);
ds = 5; % Downsample factor
data_ds = data(1:ds:end, 1:ds:end, :);

% --- CO₂ band indices (approximate)
band_left   = 166;  % ~2020 nm
band_absorb = 170;  % ~2050 nm
band_right  = 174;  % ~2080 nm

% --- Extract spectral bands
img_left   = double(data_ds(:, :, band_left));
img_absorb = double(data_ds(:, :, band_absorb));
img_right  = double(data_ds(:, :, band_right));

% --- Continuum interpolation
continuum = (img_left + img_right) / 2;

% --- CIBR index
co2_index = continuum ./ img_absorb;

% --- Threshold to generate binary mask
threshold = 0.5;  % You can adjust this based on visual inspection
hotspot_mask = co2_index > threshold;

% --- Display CO₂ Index Map
figure;
imagesc(co2_index); 
axis image off;
colormap(jet); 
colorbar;
title('CO₂ Index Map (CIBR Method)');


% --- Display binary hotspots map
figure;
imshow(hotspot_mask);
title('Detected CO₂ Hotspots (Binary Map)');
end