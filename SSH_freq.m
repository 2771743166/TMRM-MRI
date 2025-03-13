clear;
clc;

%% Define Parameters
n = 12; % Number of sites or mesh points
num_steps = 301; % Number of frequency steps

%% Calculate Frequencies for SSH Model
% Preallocate matrix for frequencies
freq = zeros(n, num_steps);

% Compute frequencies for each step
for j = 1:num_steps
    data = freq_SSH(j / 100, n); % Get frequency data for given v/w
    freq(:, j) = data(:, 1);     % Extract and store frequency values
end

%% Convert Frequency to Angular Frequency and Inverse Square
t = 0.01:0.01:3.01; % v/w range
w = freq * 2 * pi;   % Convert frequency to angular frequency
w = w.^(-2);          % Compute inverse square of angular frequency

%% Plot Spectrum of SSH Model
figure(1);
plot(t, w); % Plot energy (inverse square of frequency) vs v/w
xlabel('v/w');
ylabel('Energy E');
title(['The Spectrum of Finite SSH Model (n = ', num2str(n), ')']);

% Save spectrum data to a text file
spectrum_data = [t' w'];
dlmwrite('D:\ZSY\Matlab\20231019-Spectrum.txt', spectrum_data, 'delimiter', '\t');

%% Define Specific v/w for State Distribution
t = 0.26; % Specific v/w ratio for eigenstate analysis

%% Plot Eigenstate Distribution for Specific Frequency
figure(2);
freq = 64e6; % Frequency in Hz
states = States_SSH(freq, t, n); % Compute eigenstates at given frequency and v/w
bar(states(:, 11));              % Plot distribution of the 11th eigenstate

% Save eigenstate data to a text file
eigenstate_data = states(:, 11);
dlmwrite('D:\ZSY\Matlab\20231019-EigenstateDistribution.txt', eigenstate_data, 'delimiter', '\t');

% Title for the plot
title(['Frequency = ', num2str(freq / 1e6), ' [MHz], v/w = ', num2str(t)]);
xlabel('Site Index');
ylabel('Amplitude');
