function grayVideo = vidRGB2GRAY (inputVid)
    
    x =  size(inputVid);
    vidLength = x(4);
    
    % uncomment for small videos
    %{
    videoSizeArray = zeros(1,3);
    videoSizeArray(1) = x (1);
    videoSizeArray(2) = x (2);
    videoSizeArray(3) = x (4);
    
    grayFrames = zeros(videoSizeArray);
    %}
    
    for i = 1:vidLength
        grayFrames (:,:,i) = rgb2gray(inputVid (:,:,:,i));
    end
    
    tempVid = grayFrames;
    grayVideo = double(tempVid)/255;
end