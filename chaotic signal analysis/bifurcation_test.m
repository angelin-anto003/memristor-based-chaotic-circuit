%% BIFURCATION DIAGRAM - Visual Proof of Chaos
% Saves result to 'analysis/bifurcation_plot.png'
clear; clc; close all;
addpath('functions');
if ~exist('analysis', 'dir'), mkdir('analysis'); end

fprintf('Generating Bifurcation Diagram (this takes ~1-2 mins)...\n');

% Parameters
a_range = linspace(4.0, 5.5, 200); % Range to test parameter 'a'
b = 1; c = 5.6;
ic = [0.1, 0.2, 0.3, 0.4, 0.5];
num_points = 200; % Points to plot per parameter value

hold on;
title('Bifurcation Diagram of 5D Memristor System');
xlabel('Parameter a'); ylabel('State x (Local Maxima)');
grid on;

for i = 1:length(a_range)
    a = a_range(i);
    
    % Define system locally for speed
    sys = @(t, s) [
        -a*s(1) + s(2)*s(3) - s(3);
        2*s(2) - s(1)*s(3);
        s(1)*s(2) + s(4) - c*s(3) + cos(s(5))*s(1);
        -3*s(3) - s(4);
        s(1)
    ];

    % Fast integration
    options = odeset('RelTol',1e-3, 'AbsTol',1e-3);
    [~, Y] = ode45(sys, [0 200], ic, options);
    
    % Extract last 50% of points to avoid transient
    x_vals = Y(end-round(length(Y)/2):end, 1);
    
    % Simple plotting of state values to show density
    plot(a * ones(size(x_vals)), x_vals, 'k.', 'MarkerSize', 1);
    
    if mod(i, 20) == 0, fprintf('Progress: %.0f%%\n', (i/length(a_range))*100); end
end

% Highlight our chosen parameter
xline(4.6, 'r-', 'Chosen a=4.6', 'LineWidth', 2);
saveas(gcf, 'analysis/bifurcation_plot.png');
fprintf('✓ Done! Saved to analysis/bifurcation_plot.png\n');