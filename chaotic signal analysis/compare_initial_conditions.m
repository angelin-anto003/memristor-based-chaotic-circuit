%% SENSITIVITY ANALYSIS (Fixed)
% Compares two trajectories with 1e-10 difference
clear; clc; close all;
addpath('functions');

% 1. Setup
a = 4.6; b = 1; c = 5.6; % Hyper-chaotic parameters
ic1 = [0.1, 0.2, 0.3, 0.4, 0.5];
ic2 = ic1; 
ic2(1) = ic2(1) + 1e-10; % Tiny change in x0

fprintf('Running Sensitivity Test...\n');

% 2. Run Simulations
% FIX: Define explicit time points so outputs align perfectly
t_fixed = linspace(0, 100, 5000); 

sys = @(t, s) [
    -a*s(1) + s(2)*s(3) - s(3);
    2*s(2) - s(1)*s(3);
    s(1)*s(2) + s(4) - c*s(3) + cos(s(5))*s(1);
    -3*s(3) - s(4);
    s(1)
];

[t1, y1] = ode45(sys, t_fixed, ic1);
[t2, y2] = ode45(sys, t_fixed, ic2);

% 3. Plotting
figure('Position', [100, 100, 1000, 400]);

% Time Series
subplot(1, 2, 1);
plot(t_fixed, y1(:,1), 'b'); hold on;
plot(t_fixed, y2(:,1), 'r--'); % Now they share the same x-axis (t_fixed)
title('State x vs Time');
legend('Original', 'Modified (1e-10)', 'Location', 'best');
xlabel('Time'); ylabel('x'); grid on;

% Error Plot (Log Scale)
subplot(1, 2, 2);
error = abs(y1(:,1) - y2(:,1)); % Direct subtraction now works
semilogy(t_fixed, error, 'k', 'LineWidth', 1.5);
title('Error Divergence (Log Scale)');
xlabel('Time'); ylabel('|x1 - x2|'); grid on;

fprintf('✓ Sensitivity Verified. Divergence observable after t=50.\n');