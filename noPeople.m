function resultFrame = noPeople(lowDiff, highDiff)

    LowerB = 100;   %minimum legal ball size
    UpperB = 750;   %maximum legal ball size
        
    %remove blobs too small or too large
    Iout = xor(bwareaopen(highDiff,LowerB), bwareaopen(highDiff,UpperB));
    mask = highDiff - Iout;

    %remove areas of lowDiff which were excluded in highDiff
    se = strel ('disk', 5);
    midFrame = lowDiff - logical(imdilate(mask, se));
    
    %remove negative values
    for i=1:size(midFrame, 1)
        for j=1:size(midFrame , 2)
            if midFrame (i,j) > 0
                midFrame (i,j) = 1;
            else
                midFrame (i,j) = 0;
            end
        end
    end
    
    resultFrame = logical (midFrame);

end