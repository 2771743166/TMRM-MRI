clear;
clc;

%% Define Initial Frequency and Omega Range
f0 = 64e6; % Initial frequency in Hz
f = f0;
omegasample = linspace(-1e6, 1e6, 2000); % Omega range for sampling
smallesteigenvaluenorm = zeros(1, 2000); % Preallocate array for smallest eigenvalues

%% Find Smallest Eigenvalue Across Omega Range
for i = 1:2000
    [eig1, eigenvalue, flag1] = eigSSHnew(f, omegasample(i));
    smallesteigenvaluenorm(i) = eig1; % Store smallest eigenvalue
end

% Find minimum eigenvalue and corresponding omega
[smallesteigenvalue, l] = min(smallesteigenvaluenorm);
omega = omegasample(l);

% Display initial results
disp('Initial Results:');
disp(['Smallest Eigenvalue: ', num2str(smallesteigenvalue)]);
disp(['Omega: ', num2str(omega)]);

%% Iterative Refinement of Frequency and Omega
order = 5; % Initial order of magnitude for refinement
for order = 5:-1:-5
    % Refine frequency around the current best estimate
    fsample = linspace(f - 50 * 10^order, f + 50 * 10^order, 101);
    smallesteigenvaluenorm = zeros(1, 101); % Preallocate for refined search

    % Search for minimum eigenvalue at each refined frequency
    for j = 1:101
        [eig1, eigenvalue, flag1] = eigSSHnew(fsample(j), omega);
        smallesteigenvaluenorm(j) = eig1;
    end

    % Find minimum eigenvalue and update best frequency
    [smallesteigenvalue, l] = min(smallesteigenvaluenorm);
    f = fsample(l);

    % Display intermediate results for frequency refinement
    disp(['Order ', num2str(order), ' Frequency Refinement:']);
    disp(['Smallest Eigenvalue: ', num2str(smallesteigenvalue)]);
    disp(['Frequency: ', num2str(f)]);

    % Refine omega around the current best estimate
    omegasample = linspace(omega - 50 * 10^(order - 1), omega + 50 * 10^(order - 1), 101);
    smallesteigenvaluenorm = zeros(1, 101); % Preallocate for refined search

    % Search for minimum eigenvalue at each refined omega
    for j = 1:101
        [eig1, eigenvalue, flag1] = eigSSHnew(f, omegasample(j));
        smallesteigenvaluenorm(j) = eig1;
    end

    % Find minimum eigenvalue and update best omega
    [smallesteigenvalue, l] = min(smallesteigenvaluenorm);
    omega = omegasample(l);

    % Display intermediate results for omega refinement
    disp(['Order ', num2str(order), ' Omega Refinement:']);
    disp(['Smallest Eigenvalue: ', num2str(smallesteigenvalue)]);
    disp(['Omega: ', num2str(omega)]);
end

%% Display Final Results with High Precision
disp('Final Results with High Precision:');
vpa([f, omega, smallesteigenvalue], 15); % Display results with 15 decimal places
