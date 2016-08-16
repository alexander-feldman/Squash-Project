function doItAll(video, emptyCourt, frameStart, frameEnd)
    if nargin == 2
        frameStart = 1;
        frameEnd = size(video, 4);
    end
    
    %convert to grayscale
    disp ('converting to grayscale');
    grayVid = vidRGB2GRAY(video(:,:,:,frameStart:frameEnd));
    
    %convert to smoothed difference videos
    disp('generating smoothed difference videos');
    diffVid1 = toSmoothedDiff(grayVid, 1);
    diffVid2 = toSmoothedDiff(grayVid, 4);
    
    %generate points
    disp('generating points');
    [points, cent] = generatePoints(diffVid1, diffVid2);
    
    %generate tracklets
    disp('generating tracklets');
    [tracklets, points] = generateTracklets(points);
    
    %improve tracklets
    disp('improving tracklets');
    [tracklets, points, xyModels] = improveTracklets(tracklets, points);
    
    %connect tracklets
    disp('connecting tracklets');
    connections = connectTracklets(tracklets, points, xyModels);

    %draw curves
    disp('drawing curves');
    drawCurves(tracklets, points, xyModels, connections, emptyCourt, cent);

end