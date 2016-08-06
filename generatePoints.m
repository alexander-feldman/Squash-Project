function [thePoints, cent] = generatePoints(vid1, vid2) %for now work on vids like this. Later incorp preproccessing.

    %candidate level
    %generate detections

    cent = cell(size(vid2,3),1);

    for i=1:size(vid2,3) - 1 %one frame of buffer on either end
        cent{i} = blobItUp(vid1(:,:,i), vid2(:,:,i));

    end
    
    counter = 1;
    points(1:2*size(cent, 1)) = Point();
    for i=2:size(cent) - 1
        for j=1:size(cent{i - 1}, 1)
            for k=1:size(cent{i},1)
                for m=1:size(cent{i + 1}, 1)
                    noModel = false; %flag to indicate if point has model
                    
                    cent1 = cent{i - 1}(j,:);
                    cent2 = cent{i}(k,:);
                    cent3 = cent{i + 1}(m,:);
                    
                    if ~isempty(cent1) && ~isempty(cent2) && ~isempty(cent1)
                        models = candidateLevel(cent1, cent2, cent3, i - 1, i, i + 1);
                        if size(models,1) == 0 %if no model was found
                            noModel = true;
                        end
                        for l=1:size(models,1)
                            flag = false; %indicates if point is repeat
                            for p=1:min(counter - 1, 3)
                                if(points(counter - p).xDim == cent2(1) && points(counter - p).yDim == cent2(2)) %if already included noModel version
                                    points(counter - p) = Point(cent2(1),cent2(2),i,models(l,:)); %overwrite that version
                                    flag = true; %point is repeat
                                end
                            end
                            if ~flag %if point is not repeat
                                points(counter) = Point(cent2(1),cent2(2),i,models(l,:));
                                counter = counter + 1;                                
                            end
                        end
                    elseif ~isempty(cent2) %if cent1 or cent3 are empty
                        noModel = true;
                    end
                    if noModel
                        flag = false; %flag if point is repeat
                        for p=1:min(counter - 1, 3)
                            if(points(counter - p).xDim == cent2(1) && points(counter - p).yDim == cent2(2))
                                flag = true; %point is repeat
                            end
                        end
                        if ~flag %if point is not repeat
                            points(counter) = Point(cent2(1), cent2(2), i);
                            counter = counter + 1;
                        end

                    end
                end
            end
        end
    end
    
    thePoints = points(1:counter - 1);
    
end