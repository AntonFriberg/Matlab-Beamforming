% Matlab script that generates beamformed images from raw amplitude
% intensity data. The data is located under data/.
clear all;

% load data
PostRF_files = {'data/PostRF_Carotid'; 'data/PostRF_Fantom'};
PreRF_files = {'data/PreRF_BildA'; 'data/PreRF_BildB'; 'data/PreRF_BildC'};

% PostRF files
for i = 1:length(PostRF_files)
    load(char(PostRF_files(i)))
    Post_beamform = PostRF.Signal;
    Image_data = filter_transform(Post_beamform);
    figure(i);
    imagesc(Image_data);colormap(gray)
    name = sprintf('Filtering from PostRF %d', i);
    title(name)
    filename = sprintf('output/filtering_PostRF%d', i);
    saveas(gcf, filename, 'bmp')
end

% PreRF files
for i = 1:length(PreRF_files)
    load(char(PreRF_files(i)))
    % Beamform from function in seperate file
    Post_beamform = beamform(preBeamformed);
    % high-pass filter and hilbert transform from seperate file
    Image_data = filter_transform(Post_beamform);
    figure(i+2);
    imagesc(Image_data);colormap(gray)
    name = sprintf('Beamforming and filtering from PreRF %d', i);
    title(name)
    filename = sprintf('output/beam_filt_PreRF_%d', i);
    print(filename,'-dpng') 
end



        
    