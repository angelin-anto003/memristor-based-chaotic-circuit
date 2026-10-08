# Memristor-Based Chaotic Circuit for Image Encryption

MATLAB project exploring image encryption using a memristor-based chaotic system, Arnold transform, DNA-based processing, and GF(257) diffusion.

## Run
1. Open MATLAB and set the Current Folder to this project directory.
2. Run `main_test.m`.
3. The script uses the images in `test_images/` and the functions in `functions/`.

## Included
- `main_test.m`: main image-encryption/decryption workflow.
- `functions/`: functions used by the main workflow and supporting scripts.
- `test_images/`: example inputs (`lena.png`, `peppers.png`, `baboon.png`).
- Root-level analysis scripts: chaos verification, bifurcation, Lyapunov exponent, initial-condition comparison, and scrambling test.
- `analysis/`: saved bifurcation plot.
- `results/`: one representative saved run for all three test images, including encrypted/decrypted outputs, histograms, encryption-result plots, and cropping-attack outputs (quarter and eighth crop).

The saved results are included as existing project outputs; the project has not been re-executed as part of packaging.
