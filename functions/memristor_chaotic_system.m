function [X, Y, Z, W, U] = memristor_chaotic_system(initial_conditions, num_points, use_5D)
% MEMRISTOR_CHAOTIC_SYSTEM - 4D and 5D chaotic systems
%
% INPUTS:
%   initial_conditions - Starting values [x0, y0, z0, w0] or [x0, y0, z0, w0, u0]
%   num_points - Number of points to generate
%   use_5D - true for 5D memristor system, false for 4D base system
%
% OUTPUTS:
%   X, Y, Z, W, U - Chaotic sequences (U is empty for 4D system)

    % Parameters from paper
    a = 4.58;
    b = 1;
    c = 5.6;
    
    % Time span - longer for chaotic behavior
    tspan = [0, 500];
    options = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);
    
    if use_5D
        % ===== 5D MEMRISTOR CHAOTIC SYSTEM (Equation 3) =====
        % ẋ = -4.8x + yz - z
        % ẏ = 2y - xz
        % ż = xy + w - 5.6z + cos(u)x
        % ẇ = -3z - w
        % u̇ = x
        
        if length(initial_conditions) < 5
            initial_conditions = [initial_conditions, 0.5]; % Add u0 if missing
        end
        
        system = @(t, s) [
            -a*s(1) + s(2)*s(3) - s(3);                    % ẋ
            2*s(2) - s(1)*s(3);                             % ẏ
            s(1)*s(2) + s(4) - c*s(3) + cos(s(5))*s(1);    % ż
            -3*s(3) - s(4);                                 % ẇ
            s(1)                                            % u̇
        ];
        
        fprintf('Running 5D Memristor Chaotic System...\n');
        
    else
        % ===== 4D BASE CHAOTIC SYSTEM (Equation 1) =====
        % ẋ = -ax + yz - bz
        % ẏ = 2y - xz
        % ż = xy + w - cz
        % ẇ = -3z - w
        
        system = @(t, s) [
            -a*s(1) + s(2)*s(3) - b*s(3);      % ẋ
            2*s(2) - s(1)*s(3);                 % ẏ
            s(1)*s(2) + s(4) - c*s(3);         % ż
            -3*s(3) - s(4)                      % ẇ
        ];
        
        fprintf('Running 4D Base Chaotic System...\n');
    end
    
    % Solve the system
    [t, solutions] = ode45(system, tspan, initial_conditions, options);
    
    % Skip transient (first 20% of data)
    skip = floor(length(t) * 0.2);
    solutions = solutions(skip:end, :);
    t = t(skip:end);
    
    % Sample the desired number of points
    indices = round(linspace(1, length(t), num_points));
    
    X = solutions(indices, 1);
    Y = solutions(indices, 2);
    Z = solutions(indices, 3);
    W = solutions(indices, 4);
    
    if use_5D
        U = solutions(indices, 5);
    else
        U = [];  % Empty for 4D system
    end
    
    fprintf('✓ Generated %d chaotic points\n', num_points);
end