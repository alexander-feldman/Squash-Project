function theFuncs = generateFunctions(vid1, vid2) %for now work on vids like this. Later incorp preproccessing.

    %candidate level
    %generate detections
    cent = cell(size(vid2,3),1);

    for i=1:size(vid2,3) - 1 %one frame of buffer on either end
        i
        cent{i} = blobItUp(vid1(:,:,i), vid2(:,:,i));
        
    end

    counter = 1;
    centMods = zeros(size(cent, 1), 8); %arbitrary length
    for i=2:size(cent) - 1
        i
        
        cent1 = cent{i - 1};
        cent2 = cent{i};
        cent3 = cent{i + 1};
        
        if ~isempty(cent1) && ~isempty(cent2) && ~isempty(cent1)
            models = candidateLevel(cent1, cent2, cent3);
        else
            continue
        end
	
        %column 1 = frame number
        %column 2:3 = x,y value at frame
        %column 4:9 = model(accel x&y, initV x&y, initPos x&y,)
        %column 10 = index of second point
        for j=1:size(models,1)
            centMods(counter, 1) = i;
            centMods(counter, 2:3) = models(j,5:6);
            centMods(counter, 4:9) = models(j,:);
            centMods(counter, 10) = false;
            counter = counter + 1;
        end

    end
    
    theFuncs = centMods(1:counter - 1,:);

end