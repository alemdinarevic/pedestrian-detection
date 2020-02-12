Th = 0.01; %threshold
N = 19; %number of seeds per dimension
sideMax = 600;%maximum side length in pixels

%load
[filename, pathname] = uigetfile (‘’);
Im = importdata ([pathname, filename]);

%resize
Scale = sidemax/(max(size(im(:, : ,:1))));
Im = imresize(im, scale*size(Im(:, :, 1)));

%%detect the sign
Mask = getSign (im, th, n, sideMax);
Bbox = regionprops(Mask, ‘BoundingBox’);
Bbox = bbox.BoundingBox;
SignImg = imcrop(im, bbox);

%result
Figure(‘Position’, [153, 137, 1610, 780]);
Subplot(1,2,1), imshow(Im), title(‘Input image’);
Subplot(1,2,2), imshow(Im);
Hold on, rectangle (‘Position’, bbox, ‘Edge color’, ‘g’, ‘LineWidth’, 3);
Hold off, title (‘Processed image’);
Figure(), imshow(SignImg), title(‘Detected sign’);
