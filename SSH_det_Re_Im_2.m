clear;
clc;

%% Calculate Inductance for SSH Circuit Balancing
% Frequency and angular frequency
f = 64e6; % Hz
w = 2 * pi * f;

% Capacitance and impedance parameters
C = 47e-12; % F, Total equivalent capacitance inside the mesh
Z = -1j / (w * C); % Impedance due to capacitance

% Coupling ratio coefficient (strong vs weak coupling)
t = 0.22; 
Z1 = -Z / (1 + t); % Impedance for strong coupling
Z2 = t * Z1;       % Impedance for weak coupling

% Calculate inductance based on impedance
L1 = Z1 / (1j * w); % Strong coupling inductance
L2 = Z2 / (1j * w); % Weak coupling inductance

% Resistance values (considering or ignoring ESR)
R1 = 5;      % Ohm, for strong coupling
R2 = 0;      % Ohm, for weak coupling
R3 = 0;      % Ohm, ignoring ESR

%% Frequency Response Plot (Find det or eig for known frequencies)
clear f w; % Clear previous frequency variables

f = [40:0.01:300] * 1e6; % Frequency range in Hz
ii = 1; % Index for storing results

% Calculate eigenvalues for each frequency
for f1 = f
    w1 = f1 * 2 * pi; % Angular frequency
    
    %% Define Mesh Impedance Relationship
    Z1 = 1j * w1 * L1 + R1; % Impedance for strong coupling
    Z2 = 1j * w1 * L2 + R2; % Impedance for weak coupling
    
    % Adjust ESR based on frequency
    if f1 < 100e6
        R3 = 0; % Ignore ESR below 100 MHz
    else
        R3 = 0.01; % ESR for 47pF capacitor above 100 MHz
    end
    
    % Total impedance for each mesh
    H = Z1 + Z2 - 1j / (w1 * C) + 2 * R3;
    
    %% Construct Impedance Matrix
    num = 12; % Number of mesh points
    Z_H = repmat(H, 1, num); % Main diagonal with total impedance
    
    % Define off-diagonal elements for coupling
    Z1_H = zeros(1, num - 1);
    Z2_H = zeros(1, num - 1);
    for i = 1:num - 1
        if mod(i, 2) == 1
            Z1_H(i) = 0;      % Weak coupling
            Z2_H(i) = -Z2;    % Strong coupling
        else
            Z1_H(i) = -Z1;    % Strong coupling
            Z2_H(i) = 0;      % Weak coupling
        end
    end
    
    % Build full impedance matrix
    ZZ_H = diag(Z_H);                % Main diagonal
    ZZ_11 = diag(Z1_H, -1);          % Lower off-diagonal for strong coupling
    ZZ_12 = diag(Z1_H, 1);           % Upper off-diagonal for strong coupling
    ZZ_21 = diag(Z2_H, 1);           % Upper off-diagonal for weak coupling
    ZZ_22 = diag(Z2_H, -1);          % Lower off-diagonal for weak coupling
    ZZ = ZZ_H + ZZ_11 + ZZ_22 + ZZ_12 + ZZ_21; % Complete impedance matrix
    
    %% Calculate Eigenvalues and Determinant of Impedance Matrix
    d(ii) = min(eig(ZZ)); % Minimum eigenvalue as determinant proxy
    ii = ii + 1; % Increment index
end

%% Plot Frequency Response
semilogy(f / 1e6, abs(d));
xlabel('Frequency (MHz)');
ylabel('Minimum Eigenvalue');
title('Frequency Response of SSH Circuit');
grid on;

%% Save Data as TXT File (Commented Out)
% Uncomment to save frequency and eigenvalue data to a text file
% data = [f' / 1e6, abs(d')];
% save('freq-det.txt', 'data', '-ascii', '-double');
