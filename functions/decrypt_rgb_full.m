function img_out = decrypt_rgb_full(img_enc, Key_X, Key_U, Key_Z, dna_mask, Key_S, M, N)
    img_out = zeros(M, N, 3, 'uint8');
    for ch = 1:3
        pv       = img_enc(:,:,ch);
        inv_vec  = gf257_diffuse(pv(:), Key_S, 'decrypt');
        ch_mat   = reshape(inv_vec, M, N);
        dna_re   = dna_process(ch_mat,  Key_U,  [], [],       'encode');
        dna_inv  = dna_process(dna_re,  [],     dna_mask, Key_Z, 'dna_op_inv');
        ch_unscr = dna_process(dna_inv, Key_X,  [], [],       'decode');
        img_out(:,:,ch) = arnold_transform(ch_unscr, 1, 1, 10, 'decrypt');
    end
end