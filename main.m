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
Depth_matrix = listening_depths();

% Number of samples to the part of the center line we are listening
% -----------------------------------------------------------------
Depth_sample_matrix = depth_to_samples(Depth_matrix);

% Dynamic focus via repositioning of signals
% ------------------------------------------
Post_focus_signal = focus_signal(Depth_sample_matrix);

% Merge all channels into scan lines and apply apodization
% ---------------------------------------------------------
Post_beamform = Beamform(Post_focus_signal);


%time_gain_compensated = time_gain_compensation(merged_channel_signal);

Post_high_pass = butter_filter(Post_beamform);

Image_data = hilbert_transform(Post_high_pass);
figure;
imagesc(Image_data);colormap(gray)
title('preBeamformed image')

% load functions for dynamic receive focusing
% -------------------------------------------

function Depth_matrix = listening_depths()
    global samples channels sound_vel ...
           element_width sample_freq deadzone
    % Generate empty
    Depth_matrix = zeros(samples, channels);
    
    for sample = 1:samples
        for channel = 1:channels
            depth = listening_depth(sample, channel);
            time = depth / sound_vel;
            Depth_matrix(sample, channel) = depth;
        end
    end
    
    
    % calculate the current elements distance from the center element
    function dist = distance_from_center(channel)
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
        % first calculate the sample time i.e the time between samples
        sample_time = 1/sample_freq;
        % add
        dist = sample*sample_time*sound_vel;
    end

    % remember deadzone elements!

    % calculate where on the center line we are listening
    % 0 if outside listening window
    function ld = listening_depth(sample, channel)
        center_dist = distance_from_center(channel);
        echo_dist = echo_distance(sample);
        if echo_dist >= center_dist
            depth = sqrt(echo_dist^2 - center_dist^2) + deadzone;
            % dynamic apperature with F = 0.5
            if depth >= center_dist
                ld = depth;
            else
                ld = 0;
            end
        else
            ld = 0;
        end
    end
    
end

function Depth_sample_matrix = depth_to_samples(Depth_matrix)
    global sound_vel sample_freq
    Depth_sample_matrix = round(Depth_matrix ./ (sound_vel/sample_freq));
end

function Post_focus = focus_signal(Depth_sample_matrix)
    global samples channels lines signal
    Post_focus = zeros(samples, channels, lines);
    
    % place signal value into correct position given by distance to
    % center line
    for sample = 1:samples
        for channel = 1:channels
            % distance to place on center line we are listening in number of
            % samples
            center_depth = Depth_sample_matrix(sample, channel);
            % check if inside listening window
            if (center_depth<=samples) && (center_depth ~= 0)
                for line = 1:lines
                    value = signal(sample, channel, line);
                    Post_focus(center_depth, channel, line) = value;
                end
            end
        end
    end
end

function Post_beamform = Beamform(Post_focus_signal)
    global samples lines
    
    Post_beamform = zeros(samples, lines);
    
    for sample = 1:samples
        for line = 1:lines
            pre_merged = Post_focus_signal(sample, 1:end, line);
            post_apodization = apodization(pre_merged);
            Post_beamform(sample, line) = sum(post_apodization);
        end
    end
    
    % apodization of an array
    function output = apodization(input)
        l = length(input);
        weights = -1 * linspace(-0.95, 0.95, l).^2 + 1;
        output = input .* weights;
    end
end

function Post_high_pass = butter_filter(Post_beamform)
    global sample_freq
    cutoff_freq = 1000000;
    butter_param = cutoff_freq / (sample_freq/2);
    % Butterworthfilter 'high pass'
    [B,A] = butter(10, butter_param, 'high');
    Post_high_pass = filtfilt(B, A, Post_beamform);
end

function Image_data = hilbert_transform(Post_high_pass)
    Image_data = abs(hilbert(Post_high_pass));
end
        
    