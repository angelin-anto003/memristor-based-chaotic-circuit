%% CHAOTIC ATTRACTOR VISUALIZATION
% This script visualizes both 4D and 5D chaotic systems

clear; clc; close all;

% Add functions folder to path
addpath('functions');

% Initial conditions
ic_4D = [0.1, 0.2, 0.3, 0.4];
ic_5D = [0.1, 0.2, 0.3, 0.4, 0.5];
num_points = 10000;

% ... rest of the code stays the same ...
%% CHAOTIC ATTRACTOR VISUALIZATION
% This script visualizes both 4D and 5D chaotic systems

clear; clc; close all;

% Initial conditions
ic_4D = [0.1, 0.2, 0.3, 0.4];
ic_5D = [0.1, 0.2, 0.3, 0.4, 0.5];
num_points = 10000;

%% ========== 4D BASE CHAOTIC SYSTEM ==========
fprintf('=== 4D Base Chaotic System ===\n');
[X4, Y4, Z4, W4, ~] = memristor_chaotic_system(ic_4D, num_points, false);

% Create figure for 4D system
figure('Name', '4D Base Chaotic System', 'Position', [50, 50, 1400, 900]);

% 2D Phase Portraits
subplot(3,4,1); plot(X4, Y4, 'b', 'LineWidth', 0.5);
title('X-Y Phase Portrait'); xlabel('X'); ylabel('Y'); grid on; axis tight;

subplot(3,4,2); plot(X4, Z4, 'r', 'LineWidth', 0.5);
title('X-Z Phase Portrait'); xlabel('X'); ylabel('Z'); grid on; axis tight;

subplot(3,4,3); plot(Y4, Z4, 'g', 'LineWidth', 0.5);
title('Y-Z Phase Portrait'); xlabel('Y'); ylabel('Z'); grid on; axis tight;

subplot(3,4,4); plot(Z4, W4, 'm', 'LineWidth', 0.5);
title('Z-W Phase Portrait'); xlabel('Z'); ylabel('W'); grid on; axis tight;

% Time series
subplot(3,4,5); plot(X4, 'b', 'LineWidth', 0.5);
title('X Time Series'); xlabel('Time'); ylabel('X'); grid on;

subplot(3,4,6); plot(Y4, 'r', 'LineWidth', 0.5);
title('Y Time Series'); xlabel('Time'); ylabel('Y'); grid on;

subplot(3,4,7); plot(Z4, 'g', 'LineWidth', 0.5);
title('Z Time Series'); xlabel('Time'); ylabel('Z'); grid on;

subplot(3,4,8); plot(W4, 'm', 'LineWidth', 0.5);
title('W Time Series'); xlabel('Time'); ylabel('W'); grid on;

% 3D Attractors
subplot(3,4,9); 
plot3(X4, Y4, Z4, 'LineWidth', 0.5); 
title('3D Attractor: X-Y-Z'); 
xlabel('X'); ylabel('Y'); zlabel('Z'); 
grid on; view(45, 30); axis tight;

subplot(3,4,10); 
plot3(X4, Z4, W4, 'LineWidth', 0.5); 
title('3D Attractor: X-Z-W'); 
xlabel('X'); ylabel('Z'); zlabel('W'); 
grid on; view(45, 30); axis tight;

subplot(3,4,11); 
plot3(Y4, Z4, W4, 'LineWidth', 0.5); 
title('3D Attractor: Y-Z-W'); 
xlabel('Y'); ylabel('Z'); zlabel('W'); 
grid on; view(45, 30); axis tight;

% Poincaré section
subplot(3,4,12);
scatter(X4, Y4, 1, Z4, 'filled');
title('Poincaré Section (colored by Z)');
xlabel('X'); ylabel('Y'); 
colorbar; grid on; axis tight;

sgtitle('4D Base Chaotic System - Phase Space Analysis', 'FontSize', 14, 'FontWeight', 'bold');

%% ========== 5D MEMRISTOR CHAOTIC SYSTEM ==========
fprintf('\n=== 5D Memristor Chaotic System ===\n');
[X5, Y5, Z5, W5, U5] = memristor_chaotic_system(ic_5D, num_points, true);

% Create figure for 5D system
figure('Name', '5D Memristor Chaotic System', 'Position', [100, 100, 1400, 900]);

% 2D Phase Portraits
subplot(3,4,1); plot(X5, Y5, 'b', 'LineWidth', 0.5);
title('X-Y Phase Portrait'); xlabel('X'); ylabel('Y'); grid on; axis tight;

subplot(3,4,2); plot(X5, Z5, 'r', 'LineWidth', 0.5);
title('X-Z Phase Portrait'); xlabel('X'); ylabel('Z'); grid on; axis tight;

subplot(3,4,3); plot(Y5, Z5, 'g', 'LineWidth', 0.5);
title('Y-Z Phase Portrait'); xlabel('Y'); ylabel('Z'); grid on; axis tight;

subplot(3,4,4); plot(X5, U5, 'c', 'LineWidth', 0.5);
title('X-U Phase Portrait (Memristor)'); xlabel('X'); ylabel('U'); grid on; axis tight;

% Time series
subplot(3,4,5); plot(X5, 'b', 'LineWidth', 0.5);
title('X Time Series'); xlabel('Time'); ylabel('X'); grid on;

subplot(3,4,6); plot(Y5, 'r', 'LineWidth', 0.5);
title('Y Time Series'); xlabel('Time'); ylabel('Y'); grid on;

subplot(3,4,7); plot(Z5, 'g', 'LineWidth', 0.5);
title('Z Time Series'); xlabel('Time'); ylabel('Z'); grid on;

subplot(3,4,8); plot(U5, 'c', 'LineWidth', 0.5);
title('U Time Series (Memristor)'); xlabel('Time'); ylabel('U'); grid on;

% 3D Attractors
subplot(3,4,9); 
plot3(X5, Y5, Z5, 'LineWidth', 0.5); 
title('3D Attractor: X-Y-Z'); 
xlabel('X'); ylabel('Y'); zlabel('Z'); 
grid on; view(45, 30); axis tight;

subplot(3,4,10); 
plot3(X5, Y5, U5, 'LineWidth', 0.5); 
title('3D Attractor: X-Y-U'); 
xlabel('X'); ylabel('Y'); zlabel('U'); 
grid on; view(45, 30); axis tight;

subplot(3,4,11); 
plot3(Z5, W5, U5, 'LineWidth', 0.5); 
title('3D Attractor: Z-W-U'); 
xlabel('Z'); ylabel('W'); zlabel('U'); 
grid on; view(45, 30); axis tight;

% Poincaré section with memristor effect
subplot(3,4,12);
scatter(X5, Y5, 1, U5, 'filled');
title('Poincaré Section (colored by U - memristor)');
xlabel('X'); ylabel('Y'); 
colorbar; grid on; axis tight;

sgtitle('5D Memristor Chaotic System - Phase Space Analysis', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('\n✓ Visualization complete!\n');
fprintf('You should see complex, tangled attractors - these are chaotic!\n');