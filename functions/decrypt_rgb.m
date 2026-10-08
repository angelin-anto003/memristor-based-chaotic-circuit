function img_out = decrypt_rgb(img_enc, Key_X, Key_Y, Key_S, M, N)
    img_out = zeros(M, N, 3, 'uint8');
    for ch = 1:3
        ch_enc   = img_enc(:,:,ch);
        ch_gf    = gf257_diffuse(ch_enc, Key_S, 'decrypt');
        dna_re   = dna_process(ch_gf, Key_Y, [], [], 'encode');
        ch_unscr = dna_process(dna_re, Key_X, [], [], 'decode');
        img_out(:,:,ch) = arnold_transform(ch_unscr, 1, 1, 10, 'decrypt');
    end
end