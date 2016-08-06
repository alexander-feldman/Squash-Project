function result = toSmoothedDiff (varargin) %file must be double and scaled 0-1, second input is amount between frames

    inputVid = varargin{1};  
    amount = varargin{2};
    
    x = size(inputVid);
    
    
    for k=1:x(3) - amount
        justDiff = imabsdiff (inputVid(:,:,k), inputVid(:,:,k + amount));
      
        diffVid(:,:,k) = imgaussfilt(justDiff * 25, .6);
        for i = 1:x(1)
            for j = 1:x(2)
                if diffVid(i,j,k) > .45
                  diffVid(i,j,k) = 1;
                else
                   diffVid(i,j,k) = 0;
                end
            end
         end
    
    
        
       diffVid(:,:,k) = medfilt2(diffVid(:,:,k));
       %imshow(diffVid(:,:,k));
    end
    
    
    result = diffVid;
  
end
