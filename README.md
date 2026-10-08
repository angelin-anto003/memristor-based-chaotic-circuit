# Memristor-Based Chaotic Image Encryption Using a 5D Chaotic System

A MATLAB project that explores RGB image encryption and decryption using a five-dimensional memristor-based chaotic system, DNA-based pixel operations, Arnold scrambling, and GF(257) diffusion. The project also includes basic statistical/security measurements and cropping-attack experiments.

> **Project note:** This repository documents an academic/research implementation. The code and saved outputs should be reviewed and tested in the intended MATLAB environment before being used for security-critical applications. This README describes the current scripts; it does not claim independent verification of the results.

## Table of Contents

- [Overview](#overview)
- [Main Features](#main-features)
- [Encryption and Decryption Workflow](#encryption-and-decryption-workflow)
- [Evaluation and Attack Analysis](#evaluation-and-attack-analysis)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [How to Run](#how-to-run)
- [Inputs and Outputs](#inputs-and-outputs)
- [Understanding the Metrics](#understanding-the-metrics)
- [Reproducibility Notes](#reproducibility-notes)
- [Limitations](#limitations)
- [Acknowledgements](#acknowledgements)

## Overview

Digital images contain substantial spatial correlation, so image-encryption experiments often combine pixel-position permutation with value transformation and diffusion. This project implements an image-encryption pipeline driven by sequences generated from a five-dimensional memristor-based chaotic system.

The main script processes three sample RGB images—`peppers.png`, `lena.png`, and `baboon.png`. Each image is resized to 256 × 256 pixels, encrypted channel by channel, decrypted using the inverse operations, and evaluated using entropy, NPCR, and PSNR measurements related to cropping attacks.

## Main Features

- **5D memristor-based chaotic sequence generation** used to derive keys for image processing.
- **Arnold transform scrambling** to permute pixel positions.
- **DNA-style encoding, decoding, and operations** applied to image data.
- **GF(257) diffusion** for forward and inverse pixel-value diffusion.
- **RGB image encryption and decryption** for three sample test images.
- **Histogram visualizations** comparing original and encrypted RGB-channel distributions.
- **Entropy and NPCR calculations** included in the main script.
- **Cropping-attack experiments** that remove regions of the encrypted image, attempt decryption, and calculate PSNR against the original.
- **Additional analysis scripts** for chaotic behavior, attractors, bifurcation, and sensitivity to initial conditions.

## Encryption and Decryption Workflow

The main entry point is `main_test.m`. At a high level, it performs the following steps:

1. **Generate chaotic sequences.** The function `memristor_chaotic_system` generates five sequences from the configured initial conditions.
2. **Derive discrete keys.** Values from the chaotic sequences are quantized into keys used by the scrambling, DNA-processing, and diffusion stages.
3. **Prepare the input image.** The script reads each configured sample image, converts grayscale input to RGB if necessary, and resizes it to 256 × 256.
4. **Scramble each color channel.** `arnold_transform` applies the Arnold transform to the red, green, and blue channels.
5. **Encode and operate on DNA-style representations.** `dna_process` encodes image data, applies operations using a chaotic mask and operation selector, and decodes the intermediate representation.
6. **Diffuse pixel values.** `gf257_diffuse` applies the forward diffusion operation to each channel.
7. **Decrypt in reverse order.** The script applies inverse diffusion, reverses the DNA operations and encoding/decoding steps, and applies the inverse Arnold transform.
8. **Save outputs and evaluate.** Encrypted and decrypted images, histogram plots, cropping-attack results, and a summary table are saved under a timestamped results directory.

This outline follows the stages implemented in `main_test.m`; refer to the MATLAB functions for the exact operations and parameters.

## Evaluation and Attack Analysis

### 1. Visual encryption/decryption comparison

For each input image, the script saves a figure showing the original, encrypted, and decrypted images. This is useful for visually inspecting whether the decryption resembles the original image.

### 2. Histogram analysis

The script plots the red, green, and blue channel histograms for the original image and the encrypted image. Histogram differences can help describe how pixel-value distributions change after encryption, but histogram appearance alone is not proof of cryptographic security.

### 3. Information entropy

The main script calculates entropy for each encrypted RGB channel using MATLAB's `entropy` function and reports the average across the three channels. Entropy is a statistical measure of intensity distribution; it should be interpreted alongside other tests rather than as a standalone security guarantee.

### 4. Number of Pixel Change Rate (NPCR)

The script changes one pixel value in the input image, re-encrypts the modified image, and calculates the percentage of changed pixels in the encrypted **red channel**. The script labels this value NPCR. Since this implementation measures the modified channel only, results should be described with that scope rather than as a full-RGB NPCR unless the calculation is expanded and verified.

### 5. Cropping-attack experiments and PSNR

The main script creates two modified cipher images by zeroing selected regions:
- **Quarter-crop experiment:** the upper-left 128 × 128 region is set to zero.
- **Eighth-crop experiment:** the upper-left 64 × 128 region is set to zero.

It then attempts to decrypt each modified cipher using `decrypt_rgb_full`, saves the reconstructed images, and computes PSNR against the original image. A figure compares the cropped cipher, the corresponding decrypted result, the original image, and the normal full-decryption result.

PSNR values are recorded in decibels (dB). They quantify pixel-wise reconstruction error relative to a reference image; they do not by themselves establish resistance to all possible attacks.

## Project Structure

The repository may contain additional saved runs and research scripts. The principal files are:

```text
memristor-based-chaotic-circuit/
├── main_test.m
├── decrypt_rgb_full.m
├── bifurcation_test.m
├── compare_initial_conditions.m
├── plot_attractors.m
├── run_lyapunov_exponent.m
├── step1_test_scrambling.m
├── verify_chaos.m
├── functions/
│   ├── arnold_transform.m
│   ├── dna_process.m
│   ├── dna_tables.m
│   ├── gf257_diffuse.m
│   ├── memristor_chaotic_system.m
│   └── quantize_keys.m
├── test_images/
│   ├── peppers.png
│   ├── lena.png
│   └── baboon.png
├── analysis/
│   └── bifurcation_plot.png
├── encrypted_images/       # if included: selected saved example
├── decrypted_images/       # if included: selected saved example
└── results/                # saved timestamped experiment outputs, if included
```

The exact set of files can vary depending on which analysis scripts and saved results are included in a particular repository version. Some older or experimental files may be present; use `main_test.m` as the primary entry point for the main image-encryption experiment.

## Requirements

- MATLAB.
- MATLAB Image Processing Toolbox functions used by the scripts, including `imread`, `imwrite`, `imresize`, `imshow`, `entropy`, and `psnr`.
- A MATLAB release that supports the plotting features used in the scripts, including `tiledlayout` and `nexttile`.
- The project's `.m` files and sample images in the expected relative folders.

Toolbox availability can depend on your MATLAB installation and release. If MATLAB reports that a function is unavailable, check which toolbox provides it and whether that toolbox is installed.

## How to Run

1. Download or clone this repository.
2. Open MATLAB.
3. Set MATLAB's **Current Folder** to the project root—the folder containing `main_test.m`.
4. Confirm that `functions/` and `test_images/` are present at that same level.
5. Run the main script:

   ```matlab
   main_test
   ```

6. When execution completes, inspect the newly created timestamped directory under `results/`.

The script uses relative paths such as `functions` and `test_images/...`, so it should be run from the project root unless the paths are adjusted.

### Running individual analysis scripts

Scripts such as `verify_chaos.m`, `plot_attractors.m`, `bifurcation_test.m`, `compare_initial_conditions.m`, and `run_lyapunov_exponent.m` are separate analysis utilities. Check each script's comments and dependencies before running it. Some may create figures or expect the same supporting functions to be available on the MATLAB path.

## Inputs and Outputs

### Inputs

The main script expects these files:

- `test_images/peppers.png`
- `test_images/lena.png`
- `test_images/baboon.png`

The script converts grayscale inputs to three channels if needed and resizes each image to 256 × 256 pixels before processing.

### Generated outputs

Each run creates a timestamped folder similar to:

```text
results/YYYY-MM-DD_HH-MM-SS/
├── peppers/
│   ├── encrypted.png
│   ├── decrypted.png
│   ├── encryption_results.png
│   ├── histogram.png
│   ├── crop_attack_quarter.png
│   ├── crop_attack_eighth.png
│   └── cropping_attack.png
├── lena/
│   └── ...
├── baboon/
│   └── ...
└── summary.txt
```

The exact contents depend on which images were successfully loaded and which scripts were run. Existing result folders are saved examples from earlier runs; new results are written to a new timestamped directory.

## Understanding the Metrics

| Metric / test | What it describes | Important caveat |
|---|---|---|
| Histogram comparison | Pixel-intensity distribution before and after encryption | A changed histogram is not proof of security |
| Entropy | Statistical uncertainty in encrypted-channel intensity values | High entropy alone does not establish secure encryption |
| NPCR | Percentage of encrypted pixels that change after a small input change | The current main script computes this for the red channel only |
| PSNR after cropping | Pixel-wise similarity between a decrypted crop-attack result and the original | Interpret alongside the attack setup and other measurements |
| Visual comparison | Qualitative view of encryption, decryption, and attack outcomes | Visual inspection is not a substitute for quantitative testing |

No fixed metric values are listed here because they depend on the saved run and should be taken from the corresponding `summary.txt` or generated outputs.

## Reproducibility Notes

- The main script creates a new timestamped output directory on each run.
- The initial conditions and key-derivation expressions are configured in `main_test.m`.
- The sample images are resized before processing, so measurements refer to the processed 256 × 256 images.
- If you change the input images, initial conditions, parameters, or MATLAB/toolbox version, your results may differ.
- Keep source code, sample inputs, and saved outputs clearly separated when updating the repository.
- If reporting numerical results in a resume, report, or presentation, use values from a run you have personally verified in MATLAB and identify the test conditions.

## Limitations

- This is an academic implementation and should not be treated as a production-ready cryptographic library.
- The project explores selected statistical tests and cropping scenarios; it does not demonstrate resistance to every cryptanalytic attack.
- Entropy, histogram, NPCR, and PSNR measurements each describe different properties and should not be treated as interchangeable security proofs.
- Some repository files may be experimental or redundant. The primary workflow is the one called by `main_test.m`; check dependencies before removing or renaming MATLAB functions.

## Acknowledgements

This project was developed as an academic exploration of memristor-based chaotic dynamics and image-encryption techniques. Add citations to any paper, algorithm, image dataset, or other resource used by the implementation before publishing a final academic version.

---

**Author:** Angelin Anto  
**Project:** Memristor-Based Chaotic Image Encryption  
**Language:** MATLAB
