function [centroids, bboxes] = blobItUp(frame1, frame2) 
    %frame1 is faster diff, frame2 is slower
    
    scaleFactor = 5; %change this to do minor tuning. Used 5 for test video

    hblob = vision.BlobAnalysis;                %initialize
    hblob.AreaOutputPort = false;               %ignore area of blob
    hblob.CentroidOutputPort = true;            %output a centroid
    hblob.BoundingBoxOutputPort = true;         %output a bounding box
    hblob.MinimumBlobArea = 20 * scaleFactor;   %minimum blob size
    hblob.MaximumBlobArea = 150 * scaleFactor;  %maximum blob size
    hblob.MaximumCount = 5;                     %limit detections to 5

    imSE = strel('disk',scaleFactor);           
    
    dilate1 = imdilate(logical(frame1), imSE);  %dialate the difference vid with disk
    
    [centroid, bbox] = step (hblob, dilate1);   %find blobs
    
    if size(centroid, 1) == 0                       %if no blobs are found
        R = round(1.75 * scaleFactor);
        imSE = strel('disk', R);
        dilate1 = imdilate(logical(frame1), imSE);  %dialate with larger disk
        [centroid, bbox] = step (hblob, dilate1);   %test again
    end
    
    if size(centroid, 1) > 2                        %if more than 2 detections   
        dilate2 = imdilate(logical(frame2), imSE);
        dilate1 = noPeople(dilate1, dilate2);
        [centroid, bbox] = step (hblob, dilate1);   %redo with other frame subracted
    end

    % uncomment to display detections in each frame as they are generated
    % useful for tuning
    %{
    rectPosition = zeros(size(bbox, 1),4);
    label = zeros(size(bbox, 1),1);
    
    if size(bbox, 1) > 0
        for i=1:size(bbox, 1)
               rectPosition(i,:) = [bbox(i,1) - 1, bbox(i,2) - 1, bbox(i,3) + 1, bbox(i,4) + 1];
            label(i) = char(i);
        end
    
        imageWBlobs = insertObjectAnnotation(frame1, 'rectangle', rectPosition, label  ,'LineWidth', 3);
    else
        for j=1:3
            temp2(:,:,j) = frame1;
        end
        imageWBlobs = temp2;
    end
    waitforbuttonpress();
    imshow(imageWBlobs);
    %}
    
    centroids = centroid;
    
    %output not used in my final implementation, 
    %still relevant for displaying imageWBlobs
    bboxes = bbox; 
end
    
    