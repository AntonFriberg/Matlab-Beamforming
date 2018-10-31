# Matlab-Beamforming
Creates an ultrasound image from raw signal data contained in the data folder. The program calculates
the listening depth of each transducer element and uses it to reposition the signal data so that
data from the same listening area is on the same row. The program then performs dynamic focus with
apodization and merges all transducer data into a single line. The lines are combined into an image
which is high-pass filtered and hilbert transformed.
## Instructions
Run the main.m in matlab
## Warning
This repo may not have a perfectly correct Beamforming solution since we did get some feedback on how to reduce the noise. However since that was 2 years ago I do not quite remember what it was. Decided to release the source since the course material has been updated and this should not correspond to any assignment anymore. If you feel like contributing a better solution feel free to open a PR.
## Authors
Anton Friberg & Elin Korpås
Lund University

