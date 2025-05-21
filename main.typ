#import "@preview/fletcher:0.5.7": diagram, edge, node
#set page(paper: "a4")
#set text(lang: "en", font: "New Computer Modern", size: 10pt)

#outline()
#pagebreak()

== Automated Tip Conditioning for Scanning Tunneling Spectroscopy

=== Method Overview
Wang et al. (2021) develop a fully automated, closed-loop protocol to prepare atomically sharp scanning-tunneling-microscope (STM) tips at 4.2 K.
Their routine alternates between “conditioning” (mechanical pokes) and “assessment” (dI/dV spectroscopy + machine-learning classification) until two consecutive spectra indicate a high-quality tip, or until all candidate sites are exhausted and the scan area shifts.

=== Workflow Steps

+ *Image Acquisition & Flattening*
  - Capture a 100 nm × 100 nm topograph at V_bias = 50 mV, I_t = 20 pA.
  - Remove tilt by fitting a plane to either the entire image (uniform surfaces) or three widely separated flat regions (stepped/molecular surfaces).

+ *Surface Segmentation*
  - Build a height histogram.
  - Detect peaks and group pixels within ±0.05 nm of each peak into “terrace” labels.

+ *Site Selection*
  - Slide a 5 nm × 5 nm window across the image.
  - Select centers of uniformly labeled squares at least 15 nm apart as conditioning sites.

+ *Conditioning & Assessment Loop*
  + Move the tip to the chosen site; perform a 2 nm “poke.”
  + Record two dI/dV spectra (lock-in frequency = 455 Hz, modulation = 10 mV).
  + Normalize the second spectrum over –1.5…2.0 V (896 points).
  + Classify with an AdaBoost model:
  - *Good:* mark success; two consecutive “good” → terminate.
  - *Bad:* repeat poke + spectroscopy at the same site.

+ *Scan-Area Shift*
  - If no site yields two good spectra, shift the scan window by 100 nm in X or Y and repeat from Step 1 until piezo limits are reached.

=== Key Findings & Recommendations

- *AdaBoost* offers the best balance of accuracy, precision, recall, and implementation simplicity.
- Deep nets require more computational overhead and careful tuning.
- The closed-loop poke–measure–classify cycle converges to a publication-quality tip in fewer than ten attempts on average.

=== Short Method Summary

An automated loop acquires and flattens STM images, segments flat terraces, selects conditioning sites, and iteratively “pokes” and measures dI/dV spectra at each site.
A lightweight AdaBoost classifier judges tip quality; two consecutive “good” calls end conditioning.
If all local sites fail, the scan region shifts and the process repeats until a sharp tip is achieved.

#pagebreak()

== Autonomous In Situ Tip Conditioning via Machine Learning

=== Method Overview

Rashidi & Wolkow (2018) present an automated routine for in situ conditioning of STM tips during hydrogen‐terminated Si(100) experiments.
A convolutional neural network (CNN) analyzes isolated dangling‐bond images to detect degraded (“double”) tips; upon detection, controlled tip indentations restore sharpness until the CNN confirms a single‐atom apex.

=== Workflow Steps

+ *Data Acquisition & Preprocessing*
  - Collect ∼3500 STM sub-images of isolated dangling bonds at −1.8 V, 50 pA (5.6 × 5.6 nm²).
  - Resize each to 28 × 28 px; augment by four 90° rotations and mirror (×8 total).

+ *Baseline Benchmark (Pearson Correlation)*
  - Compute Pearson’s coefficient against sharp‐tip references.
  - Grid-search threshold yields 77 % classification accuracy.

+ *Model Training & Selection*
  - Evaluate KNN (k = 5), RFC (5000 trees), SVM (RBF kernel, C = 500, γ = 0.5), FCNN (18 layers × 784 nodes), and CNN.
  - Optimal CNN: conv5×5 filters (30 → 40 channels, stride 1) → max-pool 2×2 → dense 128 nodes (ReLU) → softmax output; trained with Adam (lr 10⁻⁴), cross‐entropy loss.

+ *Automated Tip-Conditioning Loop*
  + Acquire full‐frame STM image; detect and extract dangling‐bond patches.
  + Classify each patch via CNN; perform majority voting across N patches (>99 % reliability).
  + If tip = “double,” perform indentation at a user‐preset spot: approach 700 pm → 1 nm beyond setpoint (−1.8 V, 50 pA), incrementing by 10 pm on failure.
  + Repeat acquisition and classification until CNN outputs “sharp.”

+ *Integration with Atomic Fabrication*
  - Demonstrated during binary atomic wire patterning: routine paused fabrication only to recondition when tip degraded, then resumed seamlessly.

=== Key Findings & Recommendations

- *CNN* outperforms classical and shallow ML methods, achieving 97 % raw accuracy and >99 % with voting.
- Majority voting over multiple defects significantly reduces misclassification risk.
- Framework is generalizable to any surface with recurrent atomic features (e.g., defects, adsorbates).

=== Short Method Summary

A loop extracts dangling‐bond images, classifies tip quality with a CNN, and performs controlled indentations until tip sharpness is confirmed, enabling uninterrupted, autonomous atomic‐scale fabrication.
