afunction out = gf257_diffuse(in_vec, Key_S, mode)
% GF(257) bidirectional diffusion — exact paper Eq.(12)
% Forward:  C_i = C_{i-1} * S_i * P_i  mod 257
% Backward: C_i = C_{i+1} * S_i * P_i  mod 257
% Both applied in sequence for encryption; reversed for decryption.

    MOD  = 257;
    flat = double(in_vec(:));
    L    = length(flat);

    % Tile Key_S to length L, values strictly in {1,...,256}
    reps = ceil(L / length(Key_S));
    S    = repmat(Key_S(:), reps, 1);
    S    = double(S(1:L));
    S    = mod(S - 1, 256) + 1;

    % Precompute modular inverses for all values 1..256
    inv_table = zeros(1, MOD);
    for v = 1:256
        inv_table(v) = mod_inv_ext(v, MOD);
    end

    out_flat = zeros(L, 1);

    if strcmp(mode, 'encrypt')

        % --- FORWARD PASS: C_i = C_{i-1} * S_i * P_i mod 257 ---
        fwd = zeros(L, 1);
        C   = 1;                            % C_0 = 1
        for i = 1:L
            P   = mod(flat(i), 256) + 1;   % map pixel {0..255} -> {1..256}
            C   = mod(C * S(i), MOD);
            C   = mod(C * P,    MOD);
            if C == 0, C = 1; end
            fwd(i) = C;
        end

        % --- BACKWARD PASS: C_i = C_{i+1} * S_i * fwd_i mod 257 ---
        C = 1;                              % C_{L+1} = 1
        for i = L:-1:1
            P   = fwd(i);
            C   = mod(C * S(i), MOD);
            C   = mod(C * P,    MOD);
            if C == 0, C = 1; end
            out_flat(i) = C - 1;           % map {1..256} -> {0..255}
        end

    elseif strcmp(mode, 'decrypt')

        % --- INVERSE BACKWARD PASS: fwd_i = C_i / (C_{i+1} * S_i) ---
        fwd = zeros(L, 1);
        C   = 1;
        for i = L:-1:1
            Ci  = mod(flat(i), 256) + 1;   % cipher value in {1..256}
            % fwd_i = Ci * inv(C_{i+1}) * inv(S_i)
            fwd(i) = mod(Ci * inv_table(C) * inv_table(S(i)), MOD);
            if fwd(i) == 0, fwd(i) = 1; end
            C = Ci;                         % advance: C_{i+1} = current cipher
        end

        % --- INVERSE FORWARD PASS: P_i = fwd_i / (C_{i-1} * S_i) ---
        C = 1;
        for i = 1:L
            Fi  = fwd(i);
            % P_i = Fi * inv(C_{i-1}) * inv(S_i)
            P   = mod(Fi * inv_table(C) * inv_table(S(i)), MOD);
            if P == 0, P = 1; end
            out_flat(i) = P - 1;           % map {1..256} -> {0..255}
            % advance C: reconstruct what C_i was during forward pass
            % C_i = C_{i-1} * S_i * P_i = Fi (that's exactly fwd(i))
            C = Fi;
        end

    end

    out = uint8(out_flat);
end

function inv = mod_inv_ext(a, m)
% Modular inverse via extended Euclidean algorithm
    a = mod(a, m);
    if a <= 1, inv = a; return; end
    [~, x, ~] = extended_gcd(a, m);
    inv = mod(x, m);
    if inv == 0, inv = 1; end
end

function [g, x, y] = extended_gcd(a, b)
    if a == 0
        g = b; x = 0; y = 1;
    else
        [g, x1, y1] = extended_gcd(mod(b,a), a);
        x = y1 - floor(b/a)*x1;
        y = x1;
    end
end