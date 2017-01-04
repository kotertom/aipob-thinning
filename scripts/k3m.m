function outputImage = k3m(image)
  
  % initial preparations
  pkg load image;
  
  neighbourMask = [128 1   2; ...
                  64  0   4; ...
                  32  16  8];

  phase0Lookup = [3,  6,  7,  12,  14,  15,  24,  28,  30,  31,  48, 56, 60, ...
                  62, 63, 96, 112, 120, 124, 126, 127, 129, 131, 135, ...
                  143, 159, 191, 192, 193, 195, 199, 207, 223, 224, ...
                  225, 227, 231, 239, 240, 241, 243, 247, 248, 249, ...
                  251, 252, 253, 254];             
                  
  phase1Lookup = [7, 14, 28, 56, 112, 131, 193, 224]; 
  
  phase2Lookup = [7, 14, 15, 28, 30, 56, 60, 112, 120, 131, 135, ...
                  193, 195, 224, 225, 240];
                  
  phase3Lookup = [7, 14, 15, 28, 30, 31, 56, 60, 62, 112, 120, ...
                  124, 131, 135, 143, 193, 195, 199, 224, 225, 227, ...
                  240, 241, 248];
                  
  phase4Lookup = [7, 14, 15, 28, 30, 31, 56, 60, 62, 63, 112, 120, ...
                  124, 126, 131, 135, 143, 159, 193, 195, 199, 207, ...
                  224, 225, 227, 231, 240, 241, 243, 248, 249, 252];
                  
  phase5Lookup = [7, 14, 15, 28, 30, 31, 56, 60, 62, 63, 112, 120, ...
                  124, 126, 131, 135, 143, 159, 191, 193, 195, 199, ...
                  207, 224, 225, 227, 231, 239, 240, 241, 243, 248, ...
                  249, 251, 252, 254];
                  
  phase1pixLookup = [3, 6, 7, 12, 14, 15, 24, 28, 30, 31, 48, 56, ...
                     60, 62, 63, 96, 112, 120, 124, 126, 127, 129, 131, ...
                     135, 143, 159, 191, 192, 193, 195, 199, 207, 223, ...
                     224, 225, 227, 231, 239, 240, 241, 243, 247, 248, ...
                     249, 251, 252, 253, 254];
  

  % bitmap for manipulation
  workingImage = padarray(bitxor(image, 1), [1 1], 0);
  % bitmap storing pixel neighbour weights
  weightImage = zeros(size(image));
  
  [height width] = size(image);
 
  % actual algorithm body
  
  % --for performance purposes only
  iterationCounter = 0;
  
  change = 1;
  while change
    change = 0;
    
    % --for performance purposes only 
    iterationCounter = iterationCounter + 1;
    
    % phase 0 - marking borders
    
    % calculate neighbour flags
    % Convolution is useful in this phase, but later changes in the image structure will be made
    % that will require to recalculate weights before every other pixel
    weightImage = conv2(workingImage, neighbourMask, 'valid') .* (workingImage(2:end-1,2:end-1) > 0);
    % mark borders with 2's
    workingImage = workingImage + padarray(ismember(weightImage, phase0Lookup), [1 1], 0);
    
    % phase 1 - deleting borders with 3 linked neighbours
    
    for i=1:height
      for j=1:width
        
        if workingImage(i+1,j+1) != 2
          continue;
        endif
        
        weight = sum(sum(neighbourMask .* (workingImage(i:i+2,j:j+2) > 0)));
        if ismember(weight, phase1Lookup)
          workingImage(i+1,j+1) = 0;
          change = 1;
        endif
        
      end
    end
    
    % phase 2 - deleting borders with 3 or 4 linked neighbours
    
    for i=1:height
      for j=1:width
        
        if workingImage(i+1,j+1) != 2
          continue;
        endif
        
        weight = sum(sum(neighbourMask .* (workingImage(i:i+2,j:j+2) > 0)));
        if ismember(weight, phase2Lookup)
          workingImage(i+1,j+1) = 0;
          change = 1;
        endif
        
      end
    end
    
    % phase 3 - deleting borders with 3, 4 or 5 linked neighbours
    
    for i=1:height
      for j=1:width
        
        if workingImage(i+1,j+1) != 2
          continue;
        endif
        
        weight = sum(sum(neighbourMask .* (workingImage(i:i+2,j:j+2) > 0)));
        if ismember(weight, phase3Lookup)
          workingImage(i+1,j+1) = 0;
          change = 1;
        endif
        
      end
    end
    
    % phase 4 - deleting borders with 3, 4, 5 or 6 linked neighbours
    
    for i=1:height
      for j=1:width
        
        if workingImage(i+1,j+1) != 2
          continue;
        endif
        
        weight = sum(sum(neighbourMask .* (workingImage(i:i+2,j:j+2) > 0)));
        if ismember(weight, phase4Lookup)
          workingImage(i+1,j+1) = 0;
          change = 1;
        endif
        
      end
    end
    
    % phase 5 - deleting borders with 3, 4, 5, 6 or 7 linked neighbours
    
    for i=1:height
      for j=1:width
        
        if workingImage(i+1,j+1) != 2
          continue;
        endif
        
        weight = sum(sum(neighbourMask .* (workingImage(i:i+2,j:j+2) > 0)));
        if ismember(weight, phase5Lookup)
          workingImage(i+1,j+1) = 0;
          change = 1;
        endif
        
      end
    end
    
    % phase 6 - unmarking remaining borders
    
    workingImage = workingImage > 0;
    
  end
  
  printf("\nImage thinned after %d iterations.\n\n", iterationCounter);
  
  
  % 1-pixel width phase
  
  for i=1:height
    for j=1:width
      
      if workingImage(i+1,j+1) == 0
        continue;
      endif
      
      weight = sum(sum(neighbourMask .* (workingImage(i:i+2,j:j+2) > 0)));
      if ismember(weight, phase1pixLookup)
        %DEBUG/PERFORMANCE printf("%d, coords: %d,%d\n", ismember(weight, phase1pixLookup),i,j);
        workingImage(i+1,j+1) = 0;
      endif
      
    end
  end
  
  % assign output
  outputImage = ~workingImage(2:end-1,2:end-1);
end   