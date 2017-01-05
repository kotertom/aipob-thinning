function outputImage = kmm(image, aim)
% usage: outputImage = kmm(image, aim)
%
% This function performs thinning on given image (1 is background, 0 is foreground) 
% using KMM algorithm and returns the result
%
% aim is an optional parameter which can be either 
%   'skeleton' or 's' for short, which yields 1-pixel wide skeleton or
%   'contour' or 'c' for short, which yields the contour of the shape

if ~(ismember(image, [0 1]) && 1)
  disp("Error: image must be binary");
  return;
endif

if nargin < 2
  aim = 's';
elseif nargin > 2
  disp("Error: function takes 2 arguments");
  return;
else
  if aim == 'skeleton'
    aim = 's';
  elseif aim == 'contour'
    aim = 'c';
  elseif ~any(aim == ['s' 'c'])
    disp("Error: function argument 2 is invalid");
    return;
  endif
endif

% padarray
pkg load image;

% set background as 0's, image as 1's
markImage = double(bitxor(image, 1));

deletionArray = [3      5      7      12     13     14     15     20  ...
                 21     22     23     28     29     30     31     48     ...
                 52     53     54     55     56     60     61     62     ...
                 63     65     67     69     71     77     79     80     ...
                 81     83     84     85     86     87     88     89     ...
                 91     92     93     94     95     97     99     101     ...
                 103    109    111    112    113    115    116    117    ...
                 118    119    120    121    123    124    125    126    ...
                 127    131    133    135    141    143    149    151    ...
                 157    159    181    183    189    191    192    193    ...
                 195    197    199    205    207    208    209    211    ...
                 212    213    214    215    216    217    219    220    ...
                 221    222    223    224    225    227    229    231    ...
                 237    239    240    241    243    244    245    246    ...
                 247    248    249    251    252    253    254    255];

tagFourArray = bitxor([3   6   12  24  48  96  192 129 ...
                7   14  28  56  112 224 193 131 ...
                15  30  60  120 240 225 195 135],255);
                
shift = 256;
mask = [128 1 2; ...
        64 0 4; ...
        32 16 8];

change = 1;
        
while change
  change = 0;
  outputImage = markImage > 0;
  workingImage = markImage;
  workingImage = padarray(workingImage, [1 1], 0);
  workingImage = workingImage == 0;
  workingImage = conv2(workingImage, mask, 'valid');



  % set 2's on mark image -- contour
  
  markImage = markImage + (workingImage > 0 & markImage > 0);

  % set 3's on tag image -- elbow points
  % this means that it has bits corresponding to any of numbers: 2, 8, 32, 128 on and to all of: 1, 4, 16, 64 off.
  
  on = sum([2 8 32 128]);
  off = sum([1 4 16 64]);
  markImage = markImage + ((markImage == 2) & bitand(workingImage,on) & ~bitand(workingImage,off));

  if aim == 'c'
    outputImage = ~(markImage == 2);
    return;
  endif

  % set 4's on tag image 
  
  mask1 = (markImage > 1) & ismember(workingImage, tagFourArray);
  markImage = markImage .* ~mask1 + 4 * mask1;

  mask1 = (markImage == 4);
  markImage = markImage .* ~mask1;

  workingImage = zeros(size(markImage));
  w = size(markImage, 2);
  h = size(markImage, 1);
  markImage = padarray(markImage, [1 1], 0);
  for n=2:3
    for i=1:h
      for j=1:w
        if markImage(i+1,j+1) != n
          continue;
        endif
        
        workingImage(i,j) = sum(sum((markImage(i:i+2,j:j+2) > 0) .* mask));
        
        if ismember(workingImage(i,j), deletionArray)
          markImage(i+1,j+1) = 0;
        else
          markImage(i+1,j+1) = 1;
        endif

      end
    end
  end
  markImage = markImage(2:end-1,2:end-1);

  change = ~all(all(outputImage == (markImage > 0)));
  %imshow(outputImage);
  end

outputImage = ~outputImage;
end