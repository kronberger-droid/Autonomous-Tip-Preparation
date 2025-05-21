#set page(paper: "a4")
#set text(lang: "en", font: "New Computer Modern", size: 10pt)

= Summary of Papers regarding: Autonomous Tip Conditioning

#outline(depth: 2)

== Conclusion

#pagebreak()

== Automated Tip Conditioning for Scanning Tunneling Spectroscopy

#cite(<wang_automated_2021>, form: "full")

=== Method Overview
Wang et al. (2021) develop a fully automated, closed-loop protocol to prepare atomically sharp scanning-tunneling-microscope (STM) tips at 4.2 K.
Their routine alternates between “conditioning” (mechanical pokes) and “assessment” ($(d I)/(d V)$ spectroscopy + machine-learning classification) until two consecutive spectra indicate a high-quality tip, or until all candidate sites are exhausted and the scan area shifts.

=== Workflow Steps

+ *Image Acquisition & Flattening*
  - Capture a 100 nm × 100 nm topograph at $V_"bias" = 50 "mV"$, $I_t = 20 "pA"$.
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
  + Normalize the second spectrum over -1.5…2.0 V (896 points).
  + Classify with an AdaBoost model:
  - *Good:* mark success; two consecutive “good” $arrow$ terminate.
  - *Bad:* repeat poke + spectroscopy at the same site.

+ *Scan-Area Shift*
  - If no site yields two good spectra, shift the scan window by 100 nm in X or Y and repeat from Step 1 until piezo limits are reached.

=== Key Findings & Recommendations

- *AdaBoost* offers the best balance of accuracy, precision, recall, and implementation simplicity.
- Deep nets require more computational overhead and careful tuning.
- The closed-loop poke, measure, classify cycle converges to a publication-quality tip in fewer than ten attempts on average.

=== Short Method Summary

An automated loop acquires and flattens STM images, segments flat terraces, selects conditioning sites, and iteratively “pokes” and measures dI/dV spectra at each site.
A lightweight AdaBoost classifier judges tip quality; two consecutive “good” calls end conditioning.
If all local sites fail, the scan region shifts and the process repeats until a sharp tip is achieved.

#pagebreak()

== Autonomous In Situ Tip Conditioning via Machine Learning

#cite(<rashidi_autonomous_2018>, form: "full")

=== Method Overview

Rashidi & Wolkow (2018) present an automated routine for in situ conditioning of STM tips during hydrogen‐terminated Si(100) experiments.
A convolutional neural network (CNN) analyzes isolated dangling‐bond images to detect degraded (“double”) tips; upon detection, controlled tip indentations restore sharpness until the CNN confirms a single‐atom apex.

=== Workflow Steps

+ *Data Acquisition & Preprocessing*
  - Collect ∼3500 STM sub-images of isolated dangling bonds at -1.8 V, 50 pA (5.6 × 5.6 nm²).
  - Resize each to 28 × 28 px; augment by four 90° rotations and mirror (×8 total).

+ *Baseline Benchmark (Pearson Correlation)*
  - Compute Pearson’s coefficient against sharp‐tip references.
  - Grid-search threshold yields 77 % classification accuracy.

+ *Model Training & Selection*
  - Evaluate KNN (k = 5), RFC (5000 trees), SVM (RBF kernel, C = 500, γ = 0.5), FCNN (18 layers × 784 nodes), and CNN.
  - Optimal CNN: conv5×5 filters (30 $arrow$ 40 channels, stride 1) $arrow$ max-pool 2×2 $arrow$ dense 128 nodes (ReLU) $arrow$ softmax output; trained with Adam (lr $10^(-4)$), cross‐entropy loss.

+ *Automated Tip-Conditioning Loop*
  + Acquire full‐frame STM image; detect and extract dangling‐bond patches.
  + Classify each patch via CNN; perform majority voting across N patches (>99 % reliability).
  + If tip = “double,” perform indentation at a user‐preset spot: approach 700 pm $arrow$ 1 nm beyond setpoint (-1.8 V, 50 pA), incrementing by 10 pm on failure.
  + Repeat acquisition and classification until CNN outputs “sharp.”

+ *Integration with Atomic Fabrication*
  - Demonstrated during binary atomic wire patterning: routine paused fabrication only to recondition when tip degraded, then resumed seamlessly.

=== Key Findings & Recommendations

- *CNN* outperforms classical and shallow ML methods, achieving 97 % raw accuracy and >99 % with voting.
- Majority voting over multiple defects significantly reduces misclassification risk.
- Framework is generalizable to any surface with recurrent atomic features (e.g., defects, adsorbates).

=== Short Method Summary

A loop extracts dangling‐bond images, classifies tip quality with a CNN, and performs controlled indentations until tip sharpness is confirmed, enabling uninterrupted, autonomous atomic‐scale fabrication.

#pagebreak()

== Scanbot: An STM Automation Bot

#cite(<ceddia_scanbot_2024>, form: "full")

=== Method Overview
Ceddia et al. (2024) introduce Scanbot, a Python-based “robot” that fully automates key STM tasks—tip conditioning, sample surveying, and data acquisition—by coordinating piezoceramic scanners with a real-time camera feed and requiring *Nanonis V5* control software for STM integration.

=== Workflow Steps

+ *DSH Calibration & Tip Tracking*
  - Initialize camera feed to locate and track the STM tip apex and target positions on both the sample and a clean reference metal.
  - Use piezoceramic scanner commands (via Nanonis V5 API) to maneuver the tip between regions.

+ *Sample Survey & Site Identification*
  - Acquire a coarse topographic map of the sample area.
  - Identify regions of interest (flat, debris-free patches) on both the sample and the clean metal for imaging and conditioning.

+ *Tip-Shaping Loop*
  + *Imprint Generation*: Gently impinge the tip onto the clean reference metal to leave an atomic-scale imprint.
  + *Imprint Imaging*: Scan the imprint region to produce an image that reflects the tip’s geometry.
  + *Quality Assessment*: Measure *area* and *circularity* of the imprint; compare against predefined thresholds.
  + *Conditional Shaping*:
    - If criteria are met $arrow$ tip deemed “sharp.”
    - If not $arrow$ perform a more aggressive poke at a new location on the metal and repeat steps 1-4.

+ *Resumption of Data Acquisition*
  - Once the imprint satisfies quality metrics for two consecutive assessments, automatically return the tip to the sample of interest and resume STM imaging or spectroscopy.

=== Key Findings & Recommendations

+ *Software Compatibility*
  Scanbot is compatible with any STM system controllable via *Nanonis V5*.

+ *Modular Design*
  All core functionalities are hook-based, allowing labs to plug in custom imaging or conditioning routines without modifying the Scanbot core.

+ *Imprint-Based Metrics*
  Quantitative analysis of imprint geometry (area & circularity) provides a robust, microscope-agnostic metric for tip quality.

+ *Performance*
  Demonstrated reliable convergence to high-quality tips in a handful of shaping cycles, reducing manual overhead.

=== Short Method Summary
Scanbot leverages *Nanonis V5* control software to orchestrate a closed-loop sequence, camera-guided tip positioning, imprint-based tip-shaping on a clean reference metal, and quantitative image analysis, automatically restoring and maintaining an atomically sharp STM probe before returning to the sample for uninterrupted, high-resolution data acquisition.

#pagebreak()


== Automated Scanning Probe Tip State Classification without Machine Learning

#cite(<barker_automated_2024>, form: "full")

=== Method Overview
Barker et al. (2024) present a template-matching (TM)–based approach to classify STM tip state directly from a single topographical image without requiring large labeled data sets or machine learning. Their LabVIEW scripts interface with an RC5 *Nanonis* controller to automate image acquisition, classification, and in situ tip conditioning via bias pulses and nano-indentations.

=== Workflow Steps

+ *Image Acquisition & Preprocessing*
  - Acquire constant-current STM topographs (20 × 20 nm², 720 × 720 px) at system-specific biases and setpoints (e.g., 2 V/200 pA for Si(111) 7 × 7).
  - Flatten images and remove bottom scan lines to avoid creep artifacts.

+ *Template Matching Classification*
  + *Cross-Correlation (CC)*
    - Choose a small reference template (e.g., corner-hole on Si(111) 7 × 7 or dangling bond on B:Si(111)).
    - Compute the cross-correlation ratio (CCR) feature map by scanning the template over the input image.
    - Aggregate top N CCR peaks to derive a single metric; classify as *Good* or *Bad* based on an empirically determined threshold.

  + *Circularity Measurement (for adatoms)*
    - Locate adatom via CC; normalize and binarize the region at multiple thresholds (0.4-0.7).
    - Compute circularity $C(r) = sigma(r)/overline(r)$ across thresholds; classify based on threshold (e.g., C < 0.035 denotes *Good*).

+ *Automated Tip Preparation Loop*
  - Repeatedly acquire images and classify tip state.
  - If *Bad*, move ~200 nm away, apply bias pulses and indentations of increasing magnitude to condition the tip.
  - After a set number of shaping attempts or upon classification as *Good*, return to imaging site or shift scan area using the coarse motor.

=== Key Findings & Recommendations

+ *Accuracy & Precision*
  TM classifier achieves ~90% accuracy and >95% true-positive precision (TPP) on Si-based surfaces, comparable to CNN models and human operators.

+ *Minimal Overhead*
  Requires only a single *Good* reference image; no training or large labeled data sets needed.

+ *Wide Applicability*
  Effective on systems with repeating surface features; flexible to new substrates by selecting appropriate templates.

+ *Robust Automation*
  Integrated within LabVIEW and RC5 *Nanonis* for a fully autonomous tip conditioning tool, achieving a *Good* tip in ~12 shaping events (~10 min).

=== Short Method Summary
A LabVIEW–driven tool using an RC5 *Nanonis* controller automates STM tip state classification via cross-correlation and circularity template matching, then performs bias-pulse and indentation conditioning until consecutive *Good* classifications restore an atomically sharp tip for uninterrupted high-resolution imaging.

#pagebreak()

== Automated Structure Discovery for Scanning Tunneling Microscopy\*

#cite(<kurki_automated_2024>, form: "full")

=== Method Overview
Kurki et al. (2024) present *ASD-STM*, a machine-learning pipeline that predicts atomic structure directly from bond-resolved STM images by training an Attention U-Net on simulated STM/AFM datasets. No real-time STM control is required; the method operates on acquired images

=== Workflow Steps

+ *Synthetic Dataset Generation*
  - Compute electronic states for ∼81,000 organic molecules using FHI-aims (PBE functional).
  - Simulate constant-height STM images via PPSTM (Bardeen tunneling theory) and AFM images via PPAFM over a range of tip–sample distances.
  - Generate atomic disk descriptors (size #sym.prop covalent radius, brightness #sym.prop height) for training
+ *Machine Learning Model Training*
  - Formulate as an image-to-image task: STM image #sym.arrow atomic disk descriptor.
  - Develop an Attention U-Net with encoder-decoder blocks and attention gating.
  - Train in PyTorch for 50 epochs on 180 k training images (with noise and cut-outs), validate on 20 k, and test on 35.5 k images
+ *Inference & Validation*
  - Apply the trained model to experimental bond-resolved STM images of various organic molecules.
  - Assess performance: ∼1 % mean absolute error on simulated images; ∼91 % atom-level and ∼74 % ring-level accuracy on hydrocarbons.
  - Demonstrate qualitative chemical identification (H vs C vs O) and discuss limitations on challenging cases

=== *Software Requirements*
+ FHI-aims for electronic structure calculations
+ PPSTM & PPAFM for STM/AFM simulations
+ PyTorch for ML model implementation and inference

=== Key Findings & Recommendations

+ *High Prediction Accuracy*
  Mean absolute error ∼1 % on simulated images; ∼91 % atom accuracy on experimental STM
+ *No Real-Time Control Needed*
  Decouples ML from instrument operation: runs post-acquisition on standard STM images.
+ *Generalizable Pipeline*
  Synthetic-dataset approach enables extension to diverse molecules without modifying STM control software.
+ *Future Directions*
  Incorporate simultaneous AFM signals, vary tip-orbital contributions, and tailor datasets for specialized molecular domains.

=== Short Method Summary
*ASD-STM* trains an Attention U-Net on a large, simulated STM/AFM image dataset (via FHI-aims, PPSTM, PPAFM), then predicts atomic structure from a single experimental STM image with high accuracy, requiring only PyTorch for inference and no specialized STM control software.

#pagebreak()

#bibliography("bibliography.bib")
