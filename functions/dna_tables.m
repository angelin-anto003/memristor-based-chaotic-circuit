function [CODE_RULE, XOR_TABLE, ADD_TABLE, SUB_TABLE] = dna_tables()
% DNA_TABLES - Returns lookup tables (Self-Correcting Inverse)
% Mappings: 1=A, 2=C, 3=G, 4=T

    % 1. DNA Encoding Rules (Standard 8 Rules)
    CODE_RULE = [
        4, 3, 2, 1; 
        4, 2, 3, 1; 
        3, 4, 1, 2; 
        3, 1, 4, 2;
        2, 4, 1, 3; 
        2, 1, 4, 3; 
        1, 3, 2, 4; 
        1, 2, 3, 4
    ];

    % 2. Operation Tables (XOR & ADD from Paper)
    XOR_TABLE = [
        3, 4, 1, 2; 
        4, 3, 2, 1; 
        1, 2, 3, 4; 
        2, 1, 4, 3
    ];

    ADD_TABLE = [
        4, 1, 2, 3; 
        1, 2, 3, 4; 
        2, 3, 4, 1; 
        3, 4, 1, 2
    ];

    % 3. SUB TABLE (The Fix: Calculate Inverse Dynamically)
    % We ensure that if ADD(x, key) = y, then SUB(y, key) = x
    SUB_TABLE = zeros(4, 4);
    
    for key = 1:4        % For every column (Key)
        for result = 1:4 % For every possible result
            % Find the input 'x' that produced this 'result'
            x = find(ADD_TABLE(:, key) == result);
            SUB_TABLE(result, key) = x;
        end
    end
end