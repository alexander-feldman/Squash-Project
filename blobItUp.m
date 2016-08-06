function [centroids, bboxes] = blobItUp(frame1, frame2) %frame1 is faster diff, frame2 is slower
    scaleFactor = 5; %change this to optimize

    hblob = vision.BlobAnalysis;
    hblob.AreaOutputPort = false;
    hblob.CentroidOutputPort = true;
    hblob.BoundingBoxOutputPort = true;
    hblob.MinimumBlobArea = 20 * scaleFactor;
    hblob.MaximumBlobArea = 150 * scaleFactor;
    hblob.MaximumCount = 5;
    colorUsed = 'red';

    temp = frame1;
    imSE = strel('disk',scaleFactor);
    
    dilate1 = imdilate(logical(frame1), imSE);
    
    [centroid, bbox] = step (hblob, dilate1);
    
    if size(bbox, 1) == 0
        R = round(1.75 * scaleFactor);
        imSE = strel('disk', R);
        dilate1 = imdilate(logical(frame1), imSE);
        
        [centroid, bbox] = step (hblob, dilate1);
        colorUsed = 'blue';
    end
    

    if size(bbox, 1) > 2 %redo with other frame subracted
        dilate2 = imdilate(logical(frame2), imSE);
        dilate1 = noPeople(dilate1, dilate2);

        [centroid, bbox] = step (hblob, dilate1);
        %temp = frame1;
        %x = size(bbox);
        %if strcmp('blue', colorUsed)
        %    colorUsed = 'yellow';
        %else
        %    colorUsed = 'green';
        %end
    end

    %{
    rectPosition = zeros(size(bbox, 1),4);
    label = zeros(size(bbox, 1),1);
    
    if size(bbox, 1) > 0
        for i=1:size(bbox, 1)
               rectPosition(i,:) = [bbox(i,1) - 1, bbox(i,2) - 1, bbox(i,3) + 1, bbox(i,4) + 1];
            label(i) = char(i);
        end
    
        imageWBlobs = insertObjectAnnotation(temp, 'rectangle', rectPosition, label  ,'LineWidth',3,'Color', colorUsed);
    else
        for j=1:3
            temp2(:,:,j) = temp;
        end
        imageWBlobs = temp2;
    end
    imshow(imageWBlobs);
    %}
    
    centroids = centroid;
    bboxes = bbox;
    
end
    
    