%% Initialization
clear;
clc;

%% Import DICOM Files for SNR Map
% Select and read DICOM files
[file, path] = uigetfile('*.dcm', 'Select the first DICOM file');
img1 = dicomread(fullfile(path, file));
[file, path] = uigetfile('*.dcm', 'Select the second DICOM file');
img2 = dicomread(fullfile(path, file));
[file, path] = uigetfile('*.dcm', 'Select the third DICOM file');
img3 = dicomread(fullfile(path, file));
[file, path] = uigetfile('*.dcm', 'Select the fourth DICOM file');
img4 = dicomread(fullfile(path, file));

% Define threshold for signal
S = 100;

% Convert DICOM images to double precision for calculations
img1_S = double(img1);
img2_S = double(img2);
img3_S = double(img3);
img4_S = double(img4);

% Apply threshold: Values below S are set to NaN
img1_S(img1_S < S) = NaN;
img2_S(img2_S < S) = NaN;
img3_S(img3_S < S) = NaN;
img4_S(img4_S < S) = NaN;

%% Calculate Ratios for SNR Map
R1 = img1_S ./ img2_S; % Ratio for first pair of images
R2 = img3_S ./ img4_S; % Ratio for second pair of images

% Rotate R1 by 180 degrees
R1 = rot90(R1, 2);

% Shift R1 by 2 pixels to the left (column-wise)
R1 = circshift(R1, -2, 2);

% Concatenate R1 and R2 vertically
R = [R1; R2];

% Remove rows 240 to 778 from the concatenated matrix
R(240:778, :) = [];

%% Calculate Theta and Display as an Image
theta = acosd(R / 2); % Calculate angle map based on ratio R
imagesc(real(theta));  % Display real part of theta map

% Customize colormap and color axis limits
colorbar;
colormap(jet);
caxis([0, 60]);

% Set axis limits and appearance
xlim([150 350]);
ylim([50 500]);
axis equal;
box off;
