function Image_data = filter_transform( Post_beamform )
%filter_transform Performs high-pas filter and hilbert transform
%   Detailed explanation goes here

    Post_high_pass = butter_filter(Post_beamform);
    Image_data = hilbert_transform(Post_high_pass);
    
    function Post_high_pass = butter_filter(Post_beamform)
        sample_freq = 50000000;
        cutoff_freq = 1000000;
        butter_param = cutoff_freq / (sample_freq/2);
        % Butterworthfilter 'high pass'
        [B,A] = butter(10, butter_param, 'high');
        Post_high_pass = filtfilt(B, A, double(Post_beamform));
    end

    function Image_data = hilbert_transform(Post_high_pass)
        Image_data = abs(hilbert(Post_high_pass));
    end

end

