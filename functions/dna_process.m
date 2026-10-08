function [out_data] = dna_process(in_data, key_rule, key_mask, key_op, mode)
% DNA_PROCESS - All DNA operations
% Modes: 'encode', 'decode', 'encrypt_op', 'decrypt_op', 'dna_op', 'dna_op_inv'

    [CODE_RULES, XOR_TAB, ADD_TAB, SUB_TAB] = dna_tables();

    if strcmp(mode, 'encode')
    % --- ENCODING (Image -> DNA) ---
        img_vec = double(in_data(:));
        N = numel(img_vec);

        b1 = bitshift(bitand(img_vec, 192), -6);
        b2 = bitshift(bitand(img_vec, 48),  -4);
        b3 = bitshift(bitand(img_vec, 12),  -2);
        b4 = bitand(img_vec, 3);

        out_data = zeros(N, 4);
        for i = 1:N
            r = key_rule(i);
            out_data(i,1) = CODE_RULES(r, b1(i)+1);
            out_data(i,2) = CODE_RULES(r, b2(i)+1);
            out_data(i,3) = CODE_RULES(r, b3(i)+1);
            out_data(i,4) = CODE_RULES(r, b4(i)+1);
        end

    elseif strcmp(mode, 'decode')
    % --- DECODING (DNA -> Image) ---
        N = size(in_data, 1);
        out_vec = zeros(N, 1);
        for i = 1:N
            r    = key_rule(i);
            row  = CODE_RULES(r, :);
            b1   = find(row == in_data(i,1)) - 1;
            b2   = find(row == in_data(i,2)) - 1;
            b3   = find(row == in_data(i,3)) - 1;
            b4   = find(row == in_data(i,4)) - 1;
            out_vec(i) = b1*64 + b2*16 + b3*4 + b4;
        end
        dim      = sqrt(N);
        out_data = reshape(uint8(out_vec), dim, dim);

    elseif strcmp(mode, 'encrypt_op')
    % --- LEGACY ENCRYPT OP WITH FEEDBACK ---
        dna_data = in_data;
        N        = size(dna_data, 1);
        out_data = zeros(N, 4);
        mask_dna = mod(key_mask, 4) + 1;
        prev_val = [1, 2, 3, 4];
        for i = 1:N
            op = mod(key_op(i), 3) + 1;
            m  = mask_dna(i);
            for k = 1:4
                val = dna_data(i, k);
                if op==1,     temp = XOR_TAB(val, m);
                elseif op==2, temp = ADD_TAB(val, m);
                else,         temp = SUB_TAB(val, m); end
                res           = XOR_TAB(temp, prev_val(k));
                out_data(i,k) = res;
                prev_val(k)   = res;
            end
        end

    elseif strcmp(mode, 'decrypt_op')
    % --- LEGACY DECRYPT OP WITH FEEDBACK ---
        dna_data = in_data;
        N        = size(dna_data, 1);
        out_data = zeros(N, 4);
        mask_dna = mod(key_mask, 4) + 1;
        prev_val = [1, 2, 3, 4];
        for i = 1:N
            op = mod(key_op(i), 3) + 1;
            m  = mask_dna(i);
            for k = 1:4
                val_enc     = dna_data(i, k);
                temp        = XOR_TAB(val_enc, prev_val(k));
                prev_val(k) = val_enc;
                if op==1,     res = XOR_TAB(temp, m);
                elseif op==2, res = SUB_TAB(temp, m);
                else,         res = ADD_TAB(temp, m); end
                out_data(i,k) = res;
            end
        end

    elseif strcmp(mode, 'dna_op')
    % --- DNA OPERATION (Paper Step 4-5) ---
    % in_data  : image DNA matrix  (Nx4)
    % key_mask : chaotic DNA mask  (Nx4)
    % key_op   : operation selector per pixel (0=Add,1=Sub,2=XOR,3=XNOR)
        dna_a    = in_data;
        dna_b    = key_mask;
        N_px     = size(dna_a, 1);
        out_data = zeros(N_px, 4);
        for i = 1:N_px
            op = key_op(i);   % 0,1,2,3
            for k = 1:4
                a = dna_a(i,k);
                b = dna_b(i,k);
                if op == 0
                    out_data(i,k) = ADD_TAB(a, b);
                elseif op == 1
                    out_data(i,k) = SUB_TAB(a, b);
                elseif op == 2
                    out_data(i,k) = XOR_TAB(a, b);
                else
                    % XNOR: complement of XOR in DNA (flip: A<->T, C<->G)
                    xor_val = XOR_TAB(a, b);
                    out_data(i,k) = dna_complement(xor_val);
                end
            end
        end

    elseif strcmp(mode, 'dna_op_inv')
    % --- INVERSE DNA OPERATION (Paper Step 4-5 inverse) ---
    % Inverse operations:
    %   Add  -> Sub  (inverse of Add is Sub)
    %   Sub  -> Add  (inverse of Sub is Add)
    %   XOR  -> XOR  (self-inverse)
    %   XNOR -> XNOR (self-inverse: complement(XOR) inverted = same)
        dna_a    = in_data;
        dna_b    = key_mask;
        N_px     = size(dna_a, 1);
        out_data = zeros(N_px, 4);
        for i = 1:N_px
            op = key_op(i);
            for k = 1:4
                a = dna_a(i,k);
                b = dna_b(i,k);
                if op == 0
                    out_data(i,k) = SUB_TAB(a, b);   % inverse of Add
                elseif op == 1
                    out_data(i,k) = ADD_TAB(a, b);   % inverse of Sub
                elseif op == 2
                    out_data(i,k) = XOR_TAB(a, b);   % XOR is self-inverse
                else
                    % XNOR inverse: complement first, then XOR
                    a_comp = dna_complement(a);
                    out_data(i,k) = XOR_TAB(a_comp, b);
                end
            end
        end

    end
end

% --- Helper: DNA complement (A<->T, C<->G) ---
% DNA values: 1=A, 2=T, 3=C, 4=G  (or per your dna_tables mapping)
function c = dna_complement(v)
    % Complement map: 1<->2, 3<->4
    map = [2, 1, 4, 3];
    if v >= 1 && v <= 4
        c = map(v);
    else
        c = v;
    end
end