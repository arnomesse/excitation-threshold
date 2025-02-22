# Excitable Dynamics Simplify Neural Connectomes

![Sketch](sketch.png)

# Description

Minimal code to reproduce the main findings of ***Messé et al. (2025) Excitable Dynamics Simplify Neural Connectomes***.
We show how excitable dynamics simplify network representation by making weighted and binary networks dynamically equivalent for an appropriate network threshold.

# Use

<code>network_{SER,FHN}.m</code> : Code for simulating the SER model or the Fitzhugh-Nagumo model on networks.

<code>coactivation_FHN.m</code> : Code for computing coactivations from Fitzhugh-Nagumo simulations (using a time window integration).

<code>detect_threshold_FHN.m</code> : Code for computing the excitation threshold of the Fitzhugh-Nagumo model.

<code>mapping_threshold{SER,FHN}.m</code> : Code for computing the correspondence between the model threshold and the network threshold (for the SER model or the the Fitzhugh-Nagumo model).

<code>single_layer_perceptron.py</code> : Code for illustrating the correspondence between the model threshold and the network threshold in a simple Perceptron example applied to the MNIST database.

# Reference

If you use this code, please cite:

Binary Brains: How Excitable Dynamics Simplify Neural Connectomes
Arnaud Messé, Marc-Thorsten Hütt, Claus C. Hilgetag
bioRxiv 2024.06.23.600265; doi: https://doi.org/10.1101/2024.06.23.600265
