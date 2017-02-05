% Matlab script that generates beamformed images from raw amplitude
% intensity data. The data is located under data/.
clear all;

% Kommentarer från Magnus
% butterworld filter och filtfilt
% lägga till 3 mm för deadzone, ljudet hinner färdas 3 mm innan vi hinner
% lyssna

% load data
PostRF_files = {'data/PostRF_Carotid'; 'data/PostRF_Fantom'};
PreRF_files = {'data/PreRF_BildA'; 'data/PreRF_BildB'; 'data/PreRF_BildC'};
load(char(PreRF_files(1)))
clear PostRF_files PreRF_files

% load functions
% ---

% Structure of data
% -----------------
% Amplitude data in "preBeamformed.Samples"

% PostRF.Signal
% Amplitude data with "PostRF.Samples" rows of samples and "PostRF.Lines"
% columns of lines. "PostRF.TransFreq" is the transmitted frequency of the
% ultrasound pulse. 



