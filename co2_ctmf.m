function [mf_image, binaryMap] = co2_ctmf()
    clc;

    % Load AVIRIS hyperspectral image
    hdrPath = 'C:\Users\namra\OneDrive\Desktop\AVIRIS_CO2\AVIRIS-Classic_L2_Reflectance.f130503t01p00r23rdn_refl_img_corr.hdr';
    hcube = hypercube(hdrPath);

    % Downsample the data to reduce memory load
    dataCube = hcube.DataCube(1:5:end, 1:5:end, :);
    [~, ~, b] = size(dataCube);
    reshapedData = reshape(dataCube, [], b);  % [pixels x bands]

    % K-means clustering to partition image
    k = 4;
    [clusterIdx, ~] = kmeans(double(reshapedData), k, 'MaxIter', 300, 'Replicates', 3);

    % Define CO₂ absorption band and continuum bands
    band_center = 179;  % CO₂ absorption ~2050 nm
    band_left   = 177;  % Continuum left
    band_right  = 181;  % Continuum right

    % Build continuum-reflectance-based spectral signature
    left_spec  = mean(reshapedData(:, band_left), 1);
    right_spec = mean(reshapedData(:, band_right), 1);
    continuum  = (left_spec + right_spec) / 2;
    absorp_spec = mean(reshapedData(:, band_center), 1);

    co2_signature = zeros(1, b);
    co2_signature(band_center) = continuum - absorp_spec;
    co2_signature = co2_signature / norm(co2_signature + eps);

    % Apply Matched Filter per cluster
    mf_output = zeros(size(reshapedData, 1), 1);
    for i = 1:k
        clusterData = double(reshapedData(clusterIdx == i, :));
        if isempty(clusterData)
            continue;
        end
        C = cov(clusterData) + eye(size(clusterData, 2)) * 1e-6;  % Regularization
        mf_output(clusterIdx == i) = clusterData * (C \ co2_signature');
    end

    % Reshape the result to image
    mf_image = reshape(mf_output, size(dataCube, 1), size(dataCube, 2));
    mf_image = mat2gray(mf_image);  % Normalize

    % Binary detection using threshold
    threshold = graythresh(mf_image);  % Otsu method
    binaryMap = imbinarize(mf_image, threshold);

    % Optional Visualization (Remove if only using in main script)
    
    figure;
    imagesc(mf_image);
    colorbar;
    title('CTMF CO₂ Detection Map');

    figure;
    imshow(binaryMap);
    title('CTMF - Detected CO₂ Hotspots (Binary Map)');
    
end
