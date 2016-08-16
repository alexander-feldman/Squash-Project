function grayVideo = vidRGB2GRAY (inputVid)
    %input:  an RGB video. scale 1-255
    %output: a hieght x width x length grayscale video. 
    %        type double. scale 0-1.
        
    grayFrames = zeros(size(inputVid, 1), size(inputVid, 2), size(inputVid, 4));
        
    
    for i = 1:size(inputVid, 4)
        grayFrames (:,:,i) = rgb2gray(inputVid (:,:,:,i));
    end
    
    tempVid = grayFrames;
    grayVideo = double(tempVid)/255; %convert to double scaled 0-1
end