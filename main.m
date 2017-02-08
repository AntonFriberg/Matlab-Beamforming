% Matlab script that generates beamformed images from raw amplitude
% intensity data. The data is located under data/.
clear all;

% hand in wednesday at 12



% Comments from Magnus
% butterworth filter and filtfilt
% cutoff 0.04
% Add 3 mm for the deadzone, sound travels for 3 mm before we
% have time to listen

% load data
PostRF_files = {'data/PostRF_Carotid'; 'data/PostRF_Fantom'};
PreRF_files = {'data/PreRF_BildA'; 'data/PreRF_BildB'; 'data/PreRF_BildC'};
load(char(PreRF_files(1)))
clear PostRF_files PreRF_files

% load given variables
global signal
signal          = preBeamformed.Signal;
samples         = preBeamformed.Samples
channels        = preBeamformed.Channels
lines           = preBeamformed.Lines
transmit_freq   = preBeamformed.TransmittFreq
sample_freq     = preBeamformed.SampleFreq
sound_vel       = preBeamformed.SoundVel
deadzone        = preBeamformed.DeadZone
pitch           = preBeamformed.Pitch
fs              = preBeamformed.fs
ft              = preBeamformed.ft
element_width   = preBeamformed.ElementWidth

clear preBeamformed

travel_distance(3, channels, element_width, ...
                400, sample_freq, sound_vel, deadzone)

% load functions for dynamic receive focusing
% ----------------------------------------

% calculate the x position from element width and current channel
% ch: current channel
% nbr_ch: number of total elements
% e_width: element width
% return: current x pos
function x = x_position(ch, nbr_ch, e_width)
    % middle elements above tissue line
    % if even amounts of elements -> two middle elements
    middle = nbr_ch / 2;
    if ch < middle
        % case left
        x = e_width * (ch-middle);
    elseif ch > middle+1
        % case right
        x = e_width * (ch-middle+1);
    else
        % otherwise on center line
        x = 0;
    end
end

% calculate the y position from sample frequency and current sample
% smp: current sample
% smp_freq: sample frequency'
% vel: sound velocity
% dead_z: deadzone
% return: current y pos
function y = y_position(smp, smp_freq, vel, dead_z)
    % first calculate the sample time i.e the time between samples
    smp_time = 1/smp_freq;
    % add 
    y = smp*smp_time*vel + dead_z;
end

% remember deadzone elements!

% calculate the travel distance to the center line
function td = travel_distance(ch, nbr_ch, e_width, ...
                              smp, smp_freq, vel, dead_z)
    x = x_position(ch, nbr_ch, e_width);
    y = y_position(smp, smp_freq, vel, dead_z);
    td = sqrt(x^2 + y^2);
end

