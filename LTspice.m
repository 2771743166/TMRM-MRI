clear;
clc;

%% Import LTspice Data
[file, path] = uigetfile('*.raw', 'Select the LTspice data file');
raw_data = LTspice2Matlab(fullfile(path, file));
f = raw_data.freq_vect; % Frequency vector
target_frequency = 63.8e6;  % Target frequency to find
% Find the index closest to the target frequency
[~, index] = min(abs(f(1, :) - target_frequency));
num_steps = raw_data.num_steps; % Number of simulation steps

%% Determine Mesh Count and Component Position
k = find(strcmp(raw_data.variable_name_list, 'I(C1)')); % Find the index of the current through C1
num = 8; % Number of meshes

%% Single Mesh Plot (Commented Out)
% Plot current vs frequency for a single mesh across all simulation steps
% for i = 1:1:raw_data.num_steps
%     yy = abs(raw_data.variable_mat(k, :, i));
%     xx = f(i, :) ./ 1e6; % Convert frequency to MHz
%     semilogy(xx, yy);
%     hold on;
%     grid off;
%     set(gca, 'XLim', [min(f) / 1e6 max(f) / 1e6]);
% end

%% Multi-Mesh Plot Data Preparation
% Prepare data for plotting currents in multiple meshes at the target frequency
yy = zeros(num_steps, num / 2); % Preallocate current matrix
for p = 1:num_steps
    j = 1;
    for i = k:2:(num - 1) * 2 + k
        yy(p, j) = abs(raw_data.variable_mat(i, index, p));
        j = j + 1;
    end
end

%% Plot Current Distribution for Each Simulation Step
% Generate bar plots for current in each mesh across all steps
for i = 1:num_steps
    figure(i);
    bar(yy(i, :));
    ylabel('Current (A)');
    xlabel('Mesh Number');
    title(['Current Distribution at Step ' num2str(i)]);
    caxis([0 1.4]); % Color axis range
end

%% Save Data as TXT File (Commented Out)
% Uncomment to save current data to a text file
% data = [xx' yy'];
% save('k=6_with_resistance.txt', 'data', '-ascii', '-double');
