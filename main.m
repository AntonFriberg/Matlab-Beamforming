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

% Generate listening depth matrix
% --------------------------------------------------
Dist_matrix = zeros(samples, channels);
Time_matrix = zeros(samples, channels);

for sample = 1:samples
    for channel = 1:channels
        depth = listening_depth(sample, channel);
        time = depth / sound_vel;
        Dist_matrix(sample, channel) = depth;
        Time_matrix(sample, channel) = time;
    end
end
% remove from workspace
clear sample channel depth time

% Number of samples to center line matrix
% ---------------------------------------
Nbr_sample_matrix = Dist_matrix ./ (sound_vel / sample_freq);
Nbr_sample_matrix = round(Nbr_sample_matrix);


% Reposition data via a method called dynamic focusing
% ----------------------------------------------------
% make sure to add dynamic apperature here later
% New matrix that our signal values will be placed
post_focus_signal = zeros(samples, channels, lines);
% remove from workspace
clear dz_samples

% place signal value into correct position given by distance to
% center line
for sample = 1:samples
    for channel = 1:channels
        % distance to place on center line we are listening in number of
        % samples
        center_sample_depth = Nbr_sample_matrix(sample, channel);
        if center_sample_depth <= samples
            for line = 1:lines
                value = signal(sample, channel, line);
                if center_sample_depth ~= 0
                    post_focus_signal(center_sample_depth, channel, line) = value;
                end  
            end
        end
    end
end
% remove from workspace
clear sample channel line center_sample_depth;

% Merge all samples of different channels
% ---------------------------------------
% this is the place to perform apodization later
merged_channel_signal = zeros(samples, lines);
for channel = 1:samples
    for line = 1:lines
        linear_array = post_focus_signal(channel, 1:end, line);
        % apodization
        apodization_array = apodization(linear_array);
        merged_channel_signal(channel, line) = sum(apodization_array);
    end
end

cutoff_freq = 1000000;
butter_param = cutoff_freq / (sample_freq/2);

[B,A] = butter(10, butter_param, 'high');
data = filtfilt(B, A, merged_channel_signal);
image_data = abs(hilbert(data));
figure;
imagesc(image_data);
colormap(gray)

% load functions for dynamic receive focusing
% -------------------------------------------

% calculate the current elements distance from the center element
function dist = distance_from_center(channel)
    global element_width channels
    % middle elements above tissue line
    % if even amounts of elements -> two middle elements
    middle = channels / 2;
    if channel < middle
        % case left
        dist = element_width * (middle-channel);
    elseif channel > middle+1
        % case right
        dist = element_width * (channel-(middle+1));
    else
        % otherwise on center line
        dist = 0;
    end
end

% calculate the distance travelled by the echo received from center focus
function dist = echo_distance(sample)
    global sample_freq sound_vel
    % first calculate the sample time i.e the time between samples
    sample_time = 1/sample_freq;
    % add 
    dist = sample*sample_time*sound_vel;
end

% remember deadzone elements!

% calculate where on the center line we are listening
% 0 if outside listening window
function ld = listening_depth(sample, channel)
    global deadzone
    center_dist = distance_from_center(channel);
    echo_dist = echo_distance(sample);
    if echo_dist >= center_dist
        ld = sqrt(echo_dist^2 - center_dist^2) + deadzone;
    else
        ld = 0;
    end
end

% apodization of an array
function return_array = apodization(linear_array)
    l = length(linear_array);
    scaling_array = -1 * linspace(-0.95, 0.95, l).^2 + 1;
    return_array = linear_array.*scaling_array;
    
end