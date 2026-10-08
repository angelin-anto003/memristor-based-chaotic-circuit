%% STEP 1: TEST ARNOLD SCRAMBLING (Paper Eq. 9)
clear; clc; close all;
addpath('functions');

% 1. Load Image
try
    img = imread('test_images/lena.png');
    if size(img,3)==3, img=rgb2gray(img); end
    img = imresize(img, [256, 256]);
catch
    error('Run the "Get Lena" code I gave you earlier!');
end

% 2. Parameters (A, B) from Paper Eq 9
a = 1;
b = 1;
iterations = 10; % Paper says "repeat several times"

fprintf('Scrambling image (Iter=%d)...\n', iterations);

% 3. Encrypt (Scramble)
tic;
img_scrambled = arnold_transform(img, a, b, iterations, 'encrypt');
t_enc = toc;

% 4. Decrypt (Unscramble)
fprintf('Unscrambling...\n');
img_restored = arnold_transform(img_scrambled, a, b, iterations, 'decrypt');

% 5. Show Results
figure('Name', 'Step 1: Arnold Scrambling', 'Position', [100, 100, 1000, 400]);
subplot(1,3,1); imshow(img); title('Original');
subplot(1,3,2); imshow(img_scrambled); title(['Scrambled (Iter=', num2str(iterations), ')']);
subplot(1,3,3); imshow(img_restored); title('Restored');

% Check if perfect
diff = sum(abs(double(img(:)) - double(img_restored(:))));
if diff == 0
    fprintf('✓ Arnold Transform works perfectly!\n');
    fprintf('  Encryption Time: %.4fs\n', t_enc);
else
    fprintf('✗ Error: Restored image is not identical (Diff=%d)\n', diff);
end