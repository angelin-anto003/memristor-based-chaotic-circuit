function [Key_X, Key_Y, Key_Z, Key_W, Key_U] = quantize_keys(X, Y, Z, W, U)
% QUANTIZE_KEYS - Implements Equation (10) from the paper
% Converts chaos to integers for DNA rules
    
    % Rule Keys (1-8)
    Key_X = mod(floor(abs(X) * 10^4), 8) + 1;
    Key_Y = mod(floor(abs(Y) * 10^4), 8) + 1;
    Key_W = mod(floor(abs(W) * 10^4), 8) + 1;
    Key_U = mod(floor(abs(U) * 10^4), 8) + 1;
    
    % Operation Key (1-4)
    Key_Z = mod(floor(abs(Z) * 10^4), 4) + 1;
end