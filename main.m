% Matlab script that generates beamformed images from raw amplitude
% intensity data. The data is located under data/.
clear all;

% hand in wednesday at 12



% Comments from Magnus
% butterworth filter and filtfilt
% cutoff 0.04
% Add 3 mm for the deadzone, sound travels for 3 mm before we
% have time to listen
% Sound travels 6 mm before we start listening. 

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

% Generate distance and time to center line matrices
% --------------------------------------------------
Dist_matrix = zeros(samples, channels);
Time_matrix = zeros(samples, channels);

for sample = 1:2048
    for channel = 1:64
        ctr_line_dist = travel_distance(sample, channel);
        ctr_line_time = ctr_line_dist / sound_vel;
        Dist_matrix(sample, channel) = ctr_line_dist;
        Time_matrix(sample, channel) = ctr_line_time;
    end
end
clear sample channel ctr_line_dist ctr_line_time

% Number of samples to center line matrix
% ---------------------------------------
Nbr_sample_matrix = Dist_matrix ./ (sound_vel / sample_freq);
Nbr_sample_matrix = round(Nbr_sample_matrix);


% Reposition data via a method called dynamic focusing
% ----------------------------------------------------


% load functions for dynamic receive focusing
% -------------------------------------------
post_focus_signal = zeros(samples, channels);

for sample = 1:2048
    for channel = 1:64
        l = 1+1;
    end
end

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
        x = element_width * (channel-middle+1);
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
function td = travel_distance(sample, channel)
    x = x_position(channel);
    y = y_position(sample);
    td = sqrt(x^2 + y^2);
end