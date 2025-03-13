close all;
clear all;
clc;

global mm_pixs;

%% Load DICOM Image and Display
% Read DICOM metadata and image
info = dicominfo("SNR_se_tra_ACWM-VTC_3501.dcm");
Rows = info.Height;        % Number of rows in the DICOM image
Columns = info.Width;      % Number of columns in the DICOM image
DICOM_img = dicomread("SNR_se_tra_ACWM-VTC_3501.dcm"); % Read DICOM image
mm_pixs = info.PixelSpacing; % Pixel spacing in mm

% Display DICOM image
imshow(DICOM_img, 'DisplayRange', [min(DICOM_img(:)) max(DICOM_img(:))]);
title('DICOM Image');

% Draw ROI (Region of Interest) interactively
ROI = drawrectangle();

% Add listener to respond to ROI movements
addlistener(ROI, 'ROIMoved', @(source, eventdata) allevents(source, eventdata, DICOM_img));

%% Function to Handle ROI Events
function allevents(~, evt, DICOM_img)
    % Handle ROI movement events to calculate and display statistics
    global mm_pixs;
    evname = evt.EventName;
    
    % Check if the event is due to ROI being moved
    if strcmp(evname, 'ROIMoved')
        % Create mask for the selected ROI
        mask = createMask(evt.Source);
        ROI_img = DICOM_img(mask); % Extract pixels within ROI
        
        % Calculate average intensity within ROI
        Avg = mean(ROI_img);
        
        % Calculate uniformity using the NEMA standard
        uniformity2 = 100 * (1 - double(max(ROI_img) - min(ROI_img)) / double(max(ROI_img) + min(ROI_img)));
        disp(['Uniformity (%): ', num2str(uniformity2)]);
        
        % Calculate the number of pixels and the area of the ROI
        pixs_ROI = length(ROI_img); % Number of pixels in ROI
        Area_ROI = pixs_ROI * mm_pixs(1) * mm_pixs(2); % Area in mm²
        
        % Display calculated results
        disp(['Average Intensity: ', num2str(Avg)]);
        disp(['ROI Pixel Count: ', num2str(pixs_ROI)]);
        disp(['ROI Area (mm²): ', num2str(Area_ROI)]);
    end
end
