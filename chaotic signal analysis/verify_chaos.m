%% CHAOS VERIFICATION SUITE
% Scientific methods to verify chaotic behavior

clear; clc; close all;
addpath('functions');
addpath('analysis');

fprintf('====================================\n');
fprintf('  CHAOS VERIFICATION FOR 5D SYSTEM  \n');
fprintf('====================================\n\n');

%% Setup
ic = [0.1, 0.2, 0.3, 0.4, 0.5];
a = 4.8; b = 1; c = 5.6;

% Define 5D system
system_5D = @(t, s) [
    -a*s(1) + s(2)*s(3) - s(3);
    2*s(2) - s(1)*s(3);
    s(1)*s(2) + s(4) - c*s(3) + cos(s(5))*s(1);
    -3*s(3) - s(4);
    s(1)
];

%% TEST 1: Sensitivity to Initial Conditions
fprintf('TEST 1: Sensitivity to Initial Conditions\n');
fprintf('------------------------------------------\n');

ic1 = ic;
ic2 = ic + 1e-8;  % Tiny difference

% Use SAME time points for both solutions
tspan = linspace(0, 100, 5000);

[t1, sol1] = ode45(system_5D, tspan, ic1);
[t2, sol2] = ode45(system_5D, tspan, ic2);

% Now they have the same size - calculate divergence
divergence = sqrt(sum((sol1(:,1:3) - sol2(:,1:3)).^2, 2));

figure('Position', [100, 100, 1200, 400]);

subplot(1,2,1);
semilogy(t1, divergence, 'LineWidth', 2);
xlabel('Time'); ylabel('Distance between trajectories');
title('Exponential Divergence (Log Scale)');
grid on;

% Fit exponential to estimate Lyapunov exponent
idx = find(t1 > 10 & t1 < 50);  % Avoid transient
if length(idx) > 10
    p = polyfit(t1(idx), log(divergence(idx)), 1);
    LE_estimate = p(1);
    
    hold on;
    plot(t1(idx), exp(p(1)*t1(idx) + p(2)), 'r--', 'LineWidth', 2);
    legend('Actual divergence', sprintf('Exponential fit (λ ≈ %.3f)', LE_estimate), 'Location', 'best');
else
    LE_estimate = 0;
    fprintf('Warning: Not enough data points for fitting\n');
end

subplot(1,2,2);
plot3(sol1(:,1), sol1(:,2), sol1(:,3), 'b', 'LineWidth', 1);
hold on;
plot3(sol2(:,1), sol2(:,2), sol2(:,3), 'r--', 'LineWidth', 1);
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Trajectory Divergence in Phase Space');
legend('IC1', 'IC2 (tiny difference)', 'Location', 'best');
grid on; view(45, 30);

if LE_estimate > 0
    fprintf('✓ PASSES: Exponential divergence detected (λ ≈ %.3f)\n\n', LE_estimate);
else
    fprintf('✗ FAILS: No exponential divergence\n\n');
end

%% TEST 2: Power Spectrum Analysis
fprintf('TEST 2: Power Spectrum Analysis\n');
fprintf('--------------------------------\n');

[t, sol] = ode45(system_5D, [0 500], ic);
X = sol(:,1);

% Resample to uniform time
t_uniform = linspace(t(1), t(end), 5000);
X_uniform = interp1(t, X, t_uniform);

% FFT
Fs = 1 / (t_uniform(2) - t_uniform(1));
L = length(X_uniform);
Y = fft(X_uniform);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;

figure('Position', [150, 150, 800, 400]);
loglog(f(2:end), P1(2:end), 'LineWidth', 1.5);
xlabel('Frequency (Hz)'); ylabel('Power');
title('Power Spectrum (Broadband = Chaos)');
grid on;

% Check for broadband spectrum
power_ratio = sum(P1(10:100)) / sum(P1(100:500));
if power_ratio > 0.5
    fprintf('✓ PASSES: Broadband spectrum detected (chaotic)\n\n');
else
    fprintf('✗ FAILS: Narrow spectrum (periodic)\n\n');
end

%% TEST 3: 0-1 Test for Chaos (Simple Implementation)
fprintf('TEST 3: 0-1 Test for Chaos\n');
fprintf('--------------------------\n');

[t, sol] = ode45(system_5D, [0 200], ic);
X = sol(1:5:end, 1);  % Downsample
n = length(X);

% Translation variables
c = pi / 5;
p = zeros(n, 1);
q = zeros(n, 1);

for i = 2:n
    p(i) = p(i-1) + X(i) * cos(i * c);
    q(i) = q(i-1) + X(i) * sin(i * c);
end

% Mean square displacement
M = zeros(floor(n/10), 1);
for j = 1:length(M)
    ncut = floor(n / j);
    M(j) = mean((p(1:ncut) - mean(p(1:ncut))).^2 + ...
                (q(1:ncut) - mean(q(1:ncut))).^2);
end

% Correlation coefficient
K = corrcoef(log(1:length(M)), log(M));
K_value = K(1,2);

figure('Position', [200, 200, 800, 400]);
subplot(1,2,1);
plot(p, q, 'LineWidth', 0.5);
xlabel('p'); ylabel('q');
title('Translation Plot');
grid on; axis equal;

subplot(1,2,2);
loglog(1:length(M), M, 'o-', 'LineWidth', 1.5);
xlabel('n'); ylabel('Mean Square Displacement');
title(sprintf('0-1 Test: K = %.3f', K_value));
grid on;

if K_value > 0.9
    fprintf('✓ PASSES: K = %.3f ≈ 1 (chaotic)\n\n', K_value);
elseif K_value < 0.1
    fprintf('✗ Regular motion: K ≈ 0\n\n');
else
    fprintf('? Intermediate: K = %.3f\n\n', K_value);
end

%% SUMMARY
fprintf('====================================\n');
fprintf('  CHAOS VERIFICATION SUMMARY\n');
fprintf('====================================\n');
fprintf('Estimated Lyapunov Exponent: %.4f\n', LE_estimate);
fprintf('0-1 Test K-value: %.4f\n', K_value);

if power_ratio > 0.5
    fprintf('Power Spectrum: Broadband (chaotic)\n');
else
    fprintf('Power Spectrum: Narrow (periodic)\n');
end

fprintf('\n');

if LE_estimate > 0 && K_value > 0.85
    fprintf('====================================\n');
    fprintf('✓✓✓ SYSTEM IS CONFIRMED CHAOTIC ✓✓✓\n');
    fprintf('====================================\n');
else
    fprintf('⚠ System may not be fully chaotic\n');
end