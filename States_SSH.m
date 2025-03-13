function [states] = States_SSH(freq, t, n)
% States_SSH - Calculate eigenstates of the SSH model impedance matrix
%
% Syntax: [states] = States_SSH(freq, t, n)
%
% Inputs:
%   freq - Frequency in Hz
%   t    - Coupling ratio (t = v/w)
%   n    - Number of mesh points or sites
%
% Outputs:
%   states - Matrix of eigenstates (real part)

%% Define Capacitance and Impedance Parameters
f = 64e6; % Reference frequency in Hz
w = 2 * pi * f; % Angular frequency
C = 47e-12; % F, Total equivalent capacitance inside the mesh
Z = -1j / (w * C); % Impedance due to capacitance

% Define coupling impedances based on coupling ratio t
Z1 = -Z / (1 + t); % Impedance for strong coupling
Z2 = t * Z1;       % Impedance for weak coupling

% Calculate inductances based on impedance
L1 = Z1 / (1j * w); % Strong coupling inductance
L2 = Z2 / (1j * w); % Weak coupling inductance

% Define resistance values (considering or ignoring ESR)
R1 = 0.03; % Ohm, for strong coupling
R2 = 0.03; % Ohm, for weak coupling
R3 = 0.03; % Ohm, initial ESR value

% Define angular frequency for the specified frequency
w1 = freq * 2 * pi;

%% Define Mesh Impedance Relationship
% Calculate impedance for strong and weak coupling
Z1 = 1j * w1 * L1 + R1; % Impedance for strong coupling
Z2 = 1j * w1 * L2 + R2; % Impedance for weak coupling

% Adjust ESR based on reference frequency
if f < 100e6
    R3 = 0; % Ignore ESR below 100 MHz
else
    R3 = 0.01; % ESR for 47pF capacitor above 100 MHz
end

% Total impedance for each mesh
H = Z1 + Z2 - 1j / (w1 * C) + 2 * R3;

%% Construct Impedance Matrix
% Preallocate diagonal and off-diagonal impedance arrays
Z_H = repmat(H, 1, n); % Main diagonal with total impedance
Z1_H = zeros(1, n - 1); % Off-diagonal for strong coupling
Z2_H = zeros(1, n - 1); % Off-diagonal for weak coupling

% Define off-diagonal elements for coupling
for i = 1:n - 1
    if mod(i, 2) == 1
        Z1_H(i) = 0;     % Weak coupling
        Z2_H(i) = -Z2;   % Strong coupling
    else
        Z1_H(i) = -Z1;   % Strong coupling
        Z2_H(i) = 0;     % Weak coupling
    end
end

% Build full impedance matrix
ZZ_H = diag(Z_H);                % Main diagonal
ZZ_11 = diag(Z1_H, -1);          % Lower off-diagonal for strong coupling
ZZ_12 = diag(Z1_H, 1);           % Upper off-diagonal for strong coupling
ZZ_21 = diag(Z2_H, 1);           % Upper off-diagonal for weak coupling
ZZ_22 = diag(Z2_H, -1);          % Lower off-diagonal for weak coupling
ZZ = ZZ_H + ZZ_11 + ZZ_22 + ZZ_12 + ZZ_21; % Complete impedance matrix

%% Calculate Eigenstates
% Compute eigenstates of the impedance matrix
[states, ~] = eigs(ZZ, n); % Eigenstates as columns
states = real(states);      % Return only the real part of eigenstates
