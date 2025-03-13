function [smallesteigenvalue, eigenvalue, flag] = eigSSHnew(f, omega)
% eigSSHnew - Calculate the smallest eigenvalue of the impedance matrix
%
% Syntax: [smallesteigenvalue, eigenvalue, flag] = eigSSHnew(f, omega)
%
% Inputs:
%   f     - Frequency in Hz
%   omega - Angular frequency offset in Hz
%
% Outputs:
%   smallesteigenvalue - The smallest absolute eigenvalue of the impedance matrix
%   eigenvalue         - All eigenvalues of the impedance matrix
%   flag               - Indicator (1 if smallesteigenvalue is in (0, 1e-5), otherwise 0)

% Calculate complex angular frequency
w = 2 * pi * (f + omega * 1j);

% Define capacitance and impedance parameters
C = 47e-12; % F, Total equivalent capacitance inside the mesh
Z = -1j / (2 * pi * 64e6 * C); % Impedance due to capacitance

% Coupling ratio coefficient (strong vs weak coupling)
t = 0.22; 
Z1 = -Z / (1 + t); % Impedance for strong coupling
Z2 = t * Z1;       % Impedance for weak coupling

% Calculate inductance based on impedance
L1 = Z1 / (1j * 2 * pi * 64e6); % Strong coupling inductance
L2 = Z2 / (1j * 2 * pi * 64e6); % Weak coupling inductance

% Define resistance values from CST RLC solver
R1 = 0.076;  % Ohm, for width = 2 mm
R2 = 0.0105; % Ohm, for width = 20 mm
R3 = 0.01;   % Ohm, ESR for 47pF capacitor
% If no resistance, uncomment the following lines:
% R1 = 0;
% R2 = 0;

% Construct mesh impedance relationship
Z1 = 1j * w * L1 + R1; % Impedance for strong coupling
Z2 = 1j * w * L2 + R2; % Impedance for weak coupling
H = Z1 + Z2 - 1j ./ (w .* C) + 2 * R3; % Total impedance for each mesh

% Create impedance matrix
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

% Construct the full impedance matrix
ZZ_H = diag(Z_H);               % Main diagonal
ZZ_11 = diag(Z1_H, -1);         % Lower off-diagonal for strong coupling
ZZ_12 = diag(Z1_H, 1);          % Upper off-diagonal for strong coupling
ZZ_21 = diag(Z2_H, 1);          % Upper off-diagonal for weak coupling
ZZ_22 = diag(Z2_H, -1);         % Lower off-diagonal for weak coupling
ZZ = ZZ_H + ZZ_11 + ZZ_22 + ZZ_12 + ZZ_21; % Complete impedance matrix

% Calculate eigenvalues
eigenvalue = eig(ZZ); % All eigenvalues
smallesteigenvalue = min(abs(eigenvalue)); % Smallest absolute eigenvalue

% Determine flag based on smallest eigenvalue
if smallesteigenvalue > 0 && smallesteigenvalue < 1e-5
    flag = 1; % Small eigenvalue detected
else
    flag = 0; % No small eigenvalue in range
end
end
