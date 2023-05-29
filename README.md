# Project-Fly

The Project Fly repository contains all (most?) of the code necessary to run behavioural experiments using a Texas Instruments projector (model) and a RPi4 running PsychToolbox on Octave.

## Arduino

This folder contains relevant Arduino scripts. The role of the Arduino is to orchestrate the different elements of the experiment such as triggering the display of stimuli (via serial signal to the RPi), triggering the onset of recording of the 2P microscope as well as the shutter, camera recording, and ball tracking.

## Octave

This folder contains code to run behavioural experiments so it requires PsychToolbox. The code can interface with the Arduino via a serial port and this way receive signals triggering the display of stimuli. The second type of interface is via an internal socket to a python program that controls the turning on and off of the projector on demand.

## Python

This folder contains a module provided by TI containing scripts that communicate with the projector using the i2c protocol. There are several modified scripts relative to the original module, or which two are of particular importance.

init_parallel.py

This script initiates initiate the projector, i.e. it makes it the default screen for for the RPi. Usually there is some keystone correction for the angle of projection.

on_off_socket.py

This script starts a socket interface that listens for a serial signal, usually from Matlab in this setup, that turns on and off the projector. The lag in turning on and off the projector has been measured empirically with an oscilloscope and seems to be a maximum of 10 ms for ON and maximum of 15 ms for OFF.

## RPi config file

The config.txt file has many tweaks allowing the RPi and the projector to work together. It lives inside the /boot directory of the RPi.