# Excitable Dynamics Simplify Neural Connectomes

![Sketch](sketch.png)

Illustration of the mapping of the model threshold to the network threshold.

(a) Starting from a weighted network on which excitable dynamics run, we investigated how the local model threshold can be translated into a global network threshold. In an excitable network, fundamentally, a node's activity is influenced by the inputs from the remainder of the network according to an activation function which encodes the model threshold. To verify the consistency of model versus network thresholds, we compared the resulting patterns of coactivations, a measure of functional connectivity.
(b) Parameter space exploration of the association (correlation) between coactivation patterns from a weighted network with varying model threshold values and the coactivation patterns from binarized versions of the network with different network threshold values. Scatter plots represent coactivation from binarized networks versus coactivation from weighted networks. The color encodes the magnitude of the correlation coefficient. From this parameter space, we extracted the coactivation pattern across network thresholds that best matched the coactivation pattern from the weighted network (`Matching'), and we compared the predicted threshold according to the maximal correlation against the model threshold (`Threshold agreement').

## Description

Minimal code to reproduce the main findings of ***Messé et al. (2025) Excitable Dynamics Simplify Neural Connectomes***.
We show how excitable dynamics simplify network representation by making weighted and binary networks dynamically equivalent for an appropriate network threshold.

## Use

<code>network_{SER,FHN}.m</code> : Code for simulating the SER model or the Fitzhugh-Nagumo model on networks.

<code>coactivation_FHN.m</code> : Code for computing coactivations from Fitzhugh-Nagumo simulations (using a time window integration).

<code>detect_threshold_FHN.m</code> : Code for computing the excitation threshold of the Fitzhugh-Nagumo model (cf. Figure S1 of the paper).

<code>link_usage.m</code> : Code for computing the proportion of excitation explained by a given number of neighbors (cf. Figure S6 of the paper).

<code>multiple_neighbors.m</code> : Code for computing the effective number of neighbors to trigger an excitation and the associated theoretical network threshold (cf. Figures S7 and S8 of the paper).

<code>mapping_threshold_{SER,FHN}.m</code> : Code for computing the correspondence between the model threshold and the network threshold for the SER model or the Fitzhugh-Nagumo model (cf. Figure 2 of the paper).

<code>mapping_threshold_SER_high_threshold.m</code> : Code for computing the correspondence between the model threshold and the network threshold for the SER model when using high threshold values (cf. Figure S8 of the paper).

<code>single_layer_perceptron.py</code> : Code for illustrating the correspondence between the model threshold and the network threshold in a simple Perceptron example applied to the MNIST database (cf. Figure 5 of the paper).

## Reference

If you use this code, please cite:

Arnaud Messé, Marc-Thorsten Hütt, Claus Christian Hilgetag.
Binary Brains: How Excitable Dynamics Simplify Neural Connectomes.
bioRxiv 2024.06.23.600265 https://doi.org/10.1101/2024.06.23.600265
