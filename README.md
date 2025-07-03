# CO₂ Detection from Hyperspectral AVIRIS Data

This project implements four CO₂ detection algorithms using MATLAB:
- CIBR (Continuum Interpolated Band Ratio)
- CTMF (Cluster-Tuned Matched Filter)
- JRGE (Joint Reflectance and Geometric Enhancement)
- SFA (Spectral Fitting Algorithm)

### Features
- Uses AVIRIS hyperspectral reflectance imagery
- Preprocessing and clustering
- Index map generation and binary hotspot detection
- Geospatial visualization of detected CO₂ emissions

### Files Included
- `main_co2_visualisation.m` – Main script to run all methods and show outputs
- `co2_cibr.m`, `co2_ctmf.m`, `co2_jrge.m`, `co2_sfa.m` – Method-specific functions
- `README.md` – This file
- `LICENSE` – MIT license terms

### Requirements
- MATLAB R2021b or newer
- Mapping Toolbox (for geospatial visualization)
- Image Processing Toolbox

### License
This project is licensed under the [MIT License](LICENSE).
