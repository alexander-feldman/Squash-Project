function diffVid = toSmoothedDiff (inputVid, subtractionDistance) 
    %video must be grayscale, double and scaled 0-1
    %second input is distance between frames to subract
    if nargin < 2
        subtractionDistance = 1;
    end

    vidSize = size(inputVid);
    diffVid = zeros(size(inputVid, 1), size(inputVid, 2), size(inputVid, 3) - subtractionDistance);
    
    %loop through input vid, must stop before end to prevent index out of bounds
    for k=1:vidSize(3) - subtractionDistance
        %get the difference between two frames
        justDiff = imabsdiff (inputVid(:,:,k), inputVid(:,:,k + subtractionDistance));
        
        %multiply to increase differences, smooth with gaussian
        diffVid(:,:,k) = imgaussfilt(justDiff * 25, .6);
        
        %convert to logical
        threshold = .45;
        for i = 1:vidSize(1)
            for j = 1:vidSize(2)
                if diffVid(i,j,k) > threshold
                  diffVid(i,j,k) = 1;
                else
                   diffVid(i,j,k) = 0;
                end
            end
        end
    
       %reduce salt and pepper noise
       diffVid(:,:,k) = medfilt2(diffVid(:,:,k));
    end
  
end
