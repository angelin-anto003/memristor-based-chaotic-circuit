%% RUN LYAPUNOV ANALYSIS (Corrected for 5D System)
% This script drives the Lyapunov calculation with the correct parameters
clear; clc; close all;

fprintf('==========================================\n');
fprintf('   5D MEMRISTOR SYSTEM - LYAPUNOV TEST    \n');
fprintf('==========================================\n');

% 1. PARAMETERS (Using a = 4.6 to force Chaos)
a = 4.6;  % Changed from 4.8 (Periodic) to 4.6 (Chaotic)
b = 1; 
c = 5.6;

% 2. SYSTEM DEFINITION (State Equations)
sys = @(t, s) [
    -a*s(1) + s(2)*s(3) - s(3);                  % x dot
    2*s(2) - s(1)*s(3);                          % y dot
    s(1)*s(2) + s(4) - c*s(3) + cos(s(5))*s(1);  % z dot
    -3*s(3) - s(4);                              % w dot
    s(1)                                         % u dot
];

% 3. JACOBIAN DEFINITION (Crucial for LE Calculation)
% This describes how errors stretch in 5 dimensions
jacobian = @(t, s) [
    -a,           s(3),        s(2)-1,  0,  0;              % dx_dot/d...
    -s(3),        2,           -s(1),   0,  0;              % dy_dot/d...
    s(2)+cos(s(5)), s(1),      -c,      1,  -s(1)*sin(s(5));% dz_dot/d...
    0,            0,           -3,      -1, 0;              % dw_dot/d...
    1,            0,           0,       0,  0               % du_dot/d...
];

% 4. CONFIGURATION
initial_conditions = [0.1, 0.2, 0.3, 0.4, 0.5];
tmax = 200;    % Duration
dt = 0.05;     % Time step

% 5. MAIN CALCULATION LOOP (Wolf's Algorithm)
n = 5; % Dimension
Q = eye(n); % Orthonormal basis
LE_sum = zeros(n, 1);
num_steps = round(tmax/dt);

state = initial_conditions(:);
t = 0;

fprintf('Calculating Spectrum for a=%.1f (Please wait...)\n', a);

for i = 1:num_steps
    % A. Integrate 5D System one step
    [~, sol_state] = ode45(sys, [0, dt], state);
    state = sol_state(end, :)';
    
    % B. Integrate Variational Equations (Linearized flow)
    % Approx: J * Q
    J = jacobian(t, state);
    % Evolve Q using Euler method (faster than ODE45 for variations)
    Q = Q + (J * Q) * dt;
    
    % C. Gram-Schmidt Orthogonalization (QR Decomposition)
    [Q, R] = qr(Q);
    
    % D. Accumulate Exponents
    LE_sum = LE_sum + log(abs(diag(R)));
    
    t = t + dt;
    if mod(i, 500) == 0
        fprintf('Progress: %.0f%%\n', (i/num_steps)*100);
    end
end

% 6. RESULTS
LE_spectrum = LE_sum / tmax;
LE_spectrum = sort(LE_spectrum, 'descend'); % Sort largest to smallest

fprintf('\n----------------RESULTS----------------\n');
fprintf('Lyapunov Exponents (LE):\n');
fprintf('LE1: %.4f\nLE2: %.4f\nLE3: %.4f\nLE4: %.4f\nLE5: %.4f\n', LE_spectrum);
fprintf('---------------------------------------\n');

if LE_spectrum(1) > 0 && LE_spectrum(2) > 0
    fprintf('✓ HYPER-CHAOS CONFIRMED! (Two positive exponents)\n');
elseif LE_spectrum(1) > 0
    fprintf('✓ CHAOS CONFIRMED! (One positive exponent)\n');
else
    fprintf('⚠ NO CHAOS DETECTED (Try changing parameter "a")\n');
end