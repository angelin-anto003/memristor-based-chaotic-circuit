%% FINAL PROJECT: MEMRISTOR CHAOTIC IMAGE ENCRYPTION
clear; clc; close all;
addpath('functions');

fprintf('================================================\n');
fprintf('    5D MEMRISTOR DNA ENCRYPTION ALGORITHM       \n');
fprintf('================================================\n');

%% CONFIG
image_files = {'test_images/peppers.png', 'test_images/lena.png', 'test_images/baboon.png'};
image_names = {'Peppers', 'Lena', 'Baboon'};
num_images  = length(image_files);

%% OUTPUT FOLDER
timestamp  = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
out_folder = fullfile('results', timestamp);
mkdir(out_folder);
fprintf('Output folder: %s\n\n', out_folder);

%% CHAOS GENERATION
fprintf('Generating Hyper-Chaos (5D)...\n');
ic = [0.1, 0.2, 0.3, 0.4, 0.5];
[X, Y, Z, W, U] = memristor_chaotic_system(ic, 256*256, true);

%% KEY QUANTIZATION — exact Equation (10) and (11) from paper
fprintf('Quantizing Keys...\n');
Key_X = mod(floor(X * 1e4), 8) + 1;          % {1,...,8}
Key_Y = mod(floor(Y * 1e4), 8) + 1;          % {1,...,8}
Key_Z = mod(round(Z * 1e4), 4);              % {0,1,2,3} — Eq.11 uses round
Key_W = mod(floor(W * 1e4), 8) + 1;          % {1,...,8}
Key_U = mod(floor(U * 1e4), 8) + 1;          % {1,...,8}

% GF(257) key S from W sequence, values in {1,...,256}
Key_S = mod(floor(abs(W) * 1e6), 256) + 1;

summary = struct();

%% PROCESS EACH IMAGE
for idx = 1:num_images

    img_name = image_names{idx};
    img_file = image_files{idx};

    fprintf('\n================================================\n');
    fprintf('  Processing Image %d/%d: %s\n', idx, num_images, img_name);
    fprintf('================================================\n');

    img_folder = fullfile(out_folder, lower(img_name));
    mkdir(img_folder);

    try
        img = imread(img_file);
        if size(img,3) == 1, img = cat(3,img,img,img); end
        img = imresize(img, [256,256]);
    catch
        fprintf('  Could not load %s, skipping.\n', img_file);
        continue;
    end
    [M, N, ~] = size(img);
    total_pixels = M * N;
    fprintf('  Loaded: %dx%d RGB\n', M, N);

    % Pre-build DNA mask from Key_W (same for all channels, from chaotic W)
    mask_pixels = uint8(mod(Key_W - 1, 256));
    mask_img    = reshape(mask_pixels, M, N);
    dna_mask    = dna_process(mask_img, Key_W, [], [], 'encode');

    %% ENCRYPT
    fprintf('  Encrypting...\n');
    img_encrypted = zeros(M, N, 3, 'uint8');

    for ch = 1:3
        % Step 2: Arnold Scrambling
        ch_scr  = arnold_transform(img(:,:,ch), 1, 1, 10, 'encrypt');

        % Step 3: DNA Encode scrambled image (Rule X)
        dna_img = dna_process(ch_scr, Key_X, [], [], 'encode');

        % Step 4-5: DNA Operation with chaotic mask (Op selector = Key_Z)
        dna_op  = dna_process(dna_img, [], dna_mask, Key_Z, 'dna_op');

        % Step 6: DNA Decode (Rule U — paper Step 6 uses U for decoding)
        ch_dec  = dna_process(dna_op, Key_U, [], [], 'decode');

        % Step 7-8: Convert to vector + GF(257) bidirectional diffusion
        pv      = ch_dec(:);
        dv      = gf257_diffuse(pv, Key_S, 'encrypt');
        img_encrypted(:,:,ch) = reshape(dv, M, N);
    end

    imwrite(img_encrypted, fullfile(img_folder, 'encrypted.png'));
    fprintf('  Encrypted saved.\n');

    %% DECRYPT
    fprintf('  Decrypting...\n');
    img_restored = zeros(M, N, 3, 'uint8');

    for ch = 1:3
        % Reverse Step 8: GF(257) inverse
        pv      = img_encrypted(:,:,ch);
        inv_vec = gf257_diffuse(pv(:), Key_S, 'decrypt');
        ch_mat  = reshape(inv_vec, M, N);

        % Reverse Step 6: DNA Encode with Rule U
        dna_re  = dna_process(ch_mat, Key_U, [], [], 'encode');

        % Reverse Step 4-5: Inverse DNA Operation
        dna_inv = dna_process(dna_re, [], dna_mask, Key_Z, 'dna_op_inv');

        % Reverse Step 3: DNA Decode with Rule X
        ch_unscr = dna_process(dna_inv, Key_X, [], [], 'decode');

        % Reverse Step 2: Arnold Inverse
        img_restored(:,:,ch) = arnold_transform(ch_unscr, 1, 1, 10, 'decrypt');
    end

    imwrite(img_restored, fullfile(img_folder, 'decrypted.png'));
    fprintf('  Decrypted saved.\n');

    %% FIGURES
    fig1 = figure('Visible','off','Position',[100,100,1400,420]);
    subplot(1,3,1); imshow(img);           title('Original');
    subplot(1,3,2); imshow(img_encrypted); title('Encrypted (Cipher)');
    subplot(1,3,3); imshow(img_restored);  title('Decrypted');
    sgtitle(sprintf('%s — Encryption Results', img_name));
    saveas(fig1, fullfile(img_folder, 'encryption_results.png')); close(fig1);
fig2 = figure('Visible','off','Position',[100,100,1200,500]);

t = tiledlayout(2,3, 'Padding', 'compact', 'TileSpacing', 'compact');

ch_names = {'Red','Green','Blue'};

% ===== FIRST ROW: ORIGINAL =====
for ch = 1:3
    nexttile;
    data = img(:,:,ch);
    histogram(data(:), 256);
    title(['Original (' ch_names{ch} ')']);
    xlim([0 255]);
end

% ===== SECOND ROW: ENCRYPTED =====
for ch = 1:3
    nexttile;
    data_enc = img_encrypted(:,:,ch);
    histogram(data_enc(:), 256);
    title(['Encrypted (' ch_names{ch} ')']);
    xlim([0 255]);
end

title(t, [img_name ' Histogram Analysis'], 'FontWeight','bold');

saveas(fig2, fullfile(img_folder, 'histogram.png'));
close(fig2);
    %% SECURITY METRICS
    % Entropy
    e_vals = zeros(1,3);
    for ch = 1:3, e_vals(ch) = entropy(img_encrypted(:,:,ch)); end
    e = mean(e_vals);

    % NPCR — per channel 1 (where pixel was changed), per paper convention
    img_diff      = img;
    img_diff(1,1,1) = mod(double(img_diff(1,1,1)) + 1, 256);
    img_enc2      = zeros(M, N, 3, 'uint8');
    for ch = 1:3
        ch_s   = arnold_transform(img_diff(:,:,ch), 1, 1, 10, 'encrypt');
        dna_e  = dna_process(ch_s, Key_X, [], [], 'encode');
        dna_o2 = dna_process(dna_e, [], dna_mask, Key_Z, 'dna_op');
        ch_d   = dna_process(dna_o2, Key_U, [], [], 'decode');
        pv2    = ch_d(:);
        dv2    = gf257_diffuse(pv2, Key_S, 'encrypt');
        img_enc2(:,:,ch) = reshape(dv2, M, N);
    end
    % NPCR on channel 1 only (the modified channel)
    diff_ch1 = sum(sum(img_encrypted(:,:,1) ~= img_enc2(:,:,1)));
    npcr     = (diff_ch1 / total_pixels) * 100;

    fprintf('  Entropy (avg RGB): %.4f\n', e);
    fprintf('  NPCR:              %.4f%%\n', npcr);

    %% CROPPING ATTACK
    cipher_cut4 = img_encrypted; cipher_cut4(1:128, 1:128, :) = 0;
    cipher_cut8 = img_encrypted; cipher_cut8(1:64,  1:128, :) = 0;

    img_cut4 = decrypt_rgb_full(cipher_cut4, Key_X, Key_U, Key_Z, dna_mask, Key_S, M, N);
    img_cut8 = decrypt_rgb_full(cipher_cut8, Key_X, Key_U, Key_Z, dna_mask, Key_S, M, N);

    imwrite(img_cut4, fullfile(img_folder, 'crop_attack_quarter.png'));
    imwrite(img_cut8, fullfile(img_folder, 'crop_attack_eighth.png'));

    p4 = psnr(img_cut4, img);
    p8 = psnr(img_cut8, img);

    fig3 = figure('Visible','off','Position',[100,100,1400,500]);
    subplot(2,3,1); imshow(cipher_cut4);  title('1/4 Cropped Cipher');
    subplot(2,3,2); imshow(img_cut4);     title(sprintf('Decrypted 1/4 (PSNR=%.1fdB)',p4));
    subplot(2,3,3); imshow(img);          title('Original');
    subplot(2,3,4); imshow(cipher_cut8);  title('1/8 Cropped Cipher');
    subplot(2,3,5); imshow(img_cut8);     title(sprintf('Decrypted 1/8 (PSNR=%.1fdB)',p8));
    subplot(2,3,6); imshow(img_restored); title('Full Decryption');
    sgtitle(sprintf('%s — Cropping Attack', img_name));
    saveas(fig3, fullfile(img_folder, 'cropping_attack.png')); close(fig3);

    fprintf('  PSNR 1/4 crop: %.2f dB\n', p4);
    fprintf('  PSNR 1/8 crop: %.2f dB\n', p8);

    summary(idx).name    = img_name;
    summary(idx).entropy = e;
    summary(idx).npcr    = npcr;
    summary(idx).psnr_q4 = p4;
    summary(idx).psnr_q8 = p8;
end

%% SUMMARY TABLE
fprintf('\n================================================\n');
fprintf('  SUMMARY TABLE\n');
fprintf('================================================\n');
fprintf('  %-10s | %8s | %8s | %10s | %10s\n','Image','Entropy','NPCR(%)','PSNR_1/4','PSNR_1/8');
fprintf('  %s\n', repmat('-',1,58));
for i = 1:length(summary)
    fprintf('  %-10s | %8.4f | %8.4f | %10.2f | %10.2f\n', ...
        summary(i).name, summary(i).entropy, summary(i).npcr, ...
        summary(i).psnr_q4, summary(i).psnr_q8);
end

fid = fopen(fullfile(out_folder,'summary.txt'),'w');
fprintf(fid,'%-10s | %8s | %8s | %10s | %10s\n','Image','Entropy','NPCR(%)','PSNR_1/4','PSNR_1/8');
fprintf(fid,'%s\n',repmat('-',1,58));
for i = 1:length(summary)
    fprintf(fid,'%-10s | %8.4f | %8.4f | %10.2f | %10.2f\n', ...
        summary(i).name, summary(i).entropy, summary(i).npcr, ...
        summary(i).psnr_q4, summary(i).psnr_q8);
end
fclose(fid);

fprintf('\n  All results saved to: %s\n', out_folder);
fprintf('  PROJECT COMPLETE!\n');