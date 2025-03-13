clc;
clear;

%% Data Import
[file, path] = uigetfile('*.txt', 'Select the data file to import');
data = readmatrix(fullfile(path, file));
% Data Columns:
%   x [mm]             y [mm]            z [mm]
%   HxRe [A/m]     HyRe [A/m]     HzRe [A/m]
%   HxIm [A/m]     HyIm [A/m]     HzIm [A/m]

x = data(:, 1);
y = data(:, 2);
z = data(:, 3);

% Check if data contains only imaginary part (eigenmode solver)
choice = questdlg('Is the data from the eigenmode solver (only imaginary part)?', 'Select', 'Yes', 'No', 'Yes');
switch choice
    case 'Yes'
        value = sqrt(data(:, 7).^2 + data(:, 8).^2 + data(:, 9).^2);
    case 'No'
        value = sqrt(data(:, 4).^2 + data(:, 5).^2 + data(:, 6).^2 + data(:, 7).^2 + data(:, 8).^2 + data(:, 9).^2);
end

% Check if the value should be converted to logarithmic scale
choice = questdlg('Convert value to logarithmic scale?', 'Select', 'Yes', 'No', 'Yes');
switch choice
    case 'Yes'
        value = log(value);
end

%% Data Restructuring
subsection = inputdlg('Enter the total number of interpolation grid points:', 'Interpolation Grid Points', [1 40]);
subsection = str2double(subsection{1});
vv = linspace(min(value), max(value), subsection);

xlim1 = min(x); xlim2 = max(x);
ylim1 = min(y); ylim2 = max(y);
zlim1 = min(z); zlim2 = max(z);

% Choose the plot plane
answer = questdlg('Which normal vector for the plot plane?', 'Select Plot Plane', 'x', 'y', 'z', 'x');

% Define grid for interpolation based on the selected plane
switch answer
    case 'x'
        [ylim1, ylim2, zlim1, zlim2] = defineAxisRange('y', 'z', ylim1, ylim2, zlim1, zlim2);
        [y_grid, z_grid] = meshgrid(linspace(ylim1, ylim2, subsection), linspace(zlim1, zlim2, subsection));
        value_grid = griddata(y, z, value, y_grid, z_grid);
        aa = linspace(ylim1, ylim2, subsection);
        bb = linspace(zlim1, zlim2, subsection);
        
    case 'y'
        [xlim1, xlim2, zlim1, zlim2] = defineAxisRange('x', 'z', xlim1, xlim2, zlim1, zlim2);
        [x_grid, z_grid] = meshgrid(linspace(xlim1, xlim2, subsection), linspace(zlim1, zlim2, subsection));
        value_grid = griddata(x, z, value, x_grid, z_grid);
        aa = linspace(xlim1, xlim2, subsection);
        bb = linspace(zlim1, zlim2, subsection);
        
    case 'z'
        [xlim1, xlim2, ylim1, ylim2] = defineAxisRange('x', 'y', xlim1, xlim2, ylim1, ylim2);
        [x_grid, y_grid] = meshgrid(linspace(xlim1, xlim2, subsection), linspace(ylim1, ylim2, subsection));
        value_grid = griddata(x, y, value, x_grid, y_grid);
        aa = linspace(xlim1, xlim2, subsection);
        bb = linspace(ylim1, ylim2, subsection);
        
    otherwise
        error('Invalid plot plane selection');
end

%% Plot Pseudocolor Map
choice = questdlg('Would you like to plot the data?', 'Select', 'Yes', 'No', 'Yes');
switch choice
    case 'Yes'
        figure('Units', 'inches', 'Position', [0, 0, 10.72, 8.205]);
        pcolor(aa, bb, value_grid);
        shading interp;
        colormap(jet);
        caxis([-18, -8]);
        c = colorbar;
        c.FontName = 'Arial';
        c.FontSize = 28;
        set(gca, 'xtick', [], 'ytick', []);
        box off;
        axis equal;
        xlim([-60 60]);
        ylim([-60 60]);
end

%% Save Data as TXT
choice = questdlg('Save data as TXT file?', 'Select', 'Yes', 'No', 'Yes');
switch choice
    case 'Yes'
        new_matrix = zeros(length(aa) + 1, length(bb) + 1);
        new_matrix(1, 2:end) = aa;
        new_matrix(2:end, 1) = bb;
        new_matrix(2:end, 2:end) = value_grid;
        new_matrix(1, 1) = NaN;
        file0 = erase(file, ".txt");
        txt_name = [path, file0, '-ori.txt'];
        dlmwrite(txt_name, new_matrix, 'delimiter', '\t');
end

%% Function to Define Axis Range
function [lim1, lim2, lim3, lim4] = defineAxisRange(axis1, axis2, lim1, lim2, lim3, lim4)
    choice = questdlg(['Manual input for ', axis1, ' and ', axis2, ' axis range needed?'], 'Select', 'Yes', 'No', 'Yes');
    if strcmp(choice, 'Yes')
        prompt = {[axis1, '-axis range (format: [lim1 lim2]):'], [axis2, '-axis range (format: [lim3 lim4]):']};
        dlgtitle = 'Enter Axis Range';
        dims = [1 50];
        definput = {'-2500 2500', '-2500 2500'};
        answer = inputdlg(prompt, dlgtitle, dims, definput);
        lim1 = str2num(answer{1});
        lim3 = str2num(answer{2});
        lim2 = lim1(2);
        lim1 = lim1(1);
        lim4 = lim3(2);
        lim3 = lim3(1);
    end
end
