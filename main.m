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
global signal samples channels lines transmit_freq ...
       sample_freq sound_vel deadzone pitch fs ft  ...
       element_width;
signal          = preBeamformed.Signal;
samples         = preBeamformed.Samples;
channels        = preBeamformed.Channels;
lines           = preBeamformed.Lines;
transmit_freq   = preBeamformed.TransmittFreq;
sample_freq     = preBeamformed.SampleFreq;
sound_vel       = preBeamformed.SoundVel;
deadzone        = preBeamformed.DeadZone;
pitch           = preBeamformed.Pitch;
fs              = preBeamformed.fs;
ft              = preBeamformed.ft;
element_width   = preBeamformed.ElementWidth;

clear preBeamformed

travel_distance(3, 400)

% load functions for dynamic receive focusing
% ----------------------------------------

% calculate the x position from element width and current channel
function x = x_position(channel)
    global element_width channels
    % middle elements above tissue line
    % if even amounts of elements -> two middle elements
    middle = channels / 2;
    if channel < middle
        % case left
        x = element_width * (channel-middle);
    elseif channel > middle+1
        % case right
        x = e_width * (channel-middle+1);
    else
        % otherwise on center line
        x = 0;
    end
end

% calculate the y position from sample frequency and current sample
function y = y_position(sample)
    global sample_freq sound_vel deadzone
    % first calculate the sample time i.e the time between samples
    sample_time = 1/sample_freq;
    % add 
    y = sample*sample_time*sound_vel+deadzone;
end

% remember deadzone elements!

% calculate the travel distance to the center line
function td = travel_distance(channel, sample)
    x = x_position(channel);
    y = y_position(sample);
    td = sqrt(x^2 + y^2);
end

