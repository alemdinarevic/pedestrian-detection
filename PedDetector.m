%%Load the testing image
testingImage = imread('singleped.jpg');
[height, width, dim] = size(testingImage);
disp('Dimension of Testing Image');
disp(height);
disp(width);
figure;
imshow(testingImage);
windowHeightMin = 300;
%windowWidthMin = 170;
windowHeightMax = 530;
windowWidth = 170;
bboxes = [];

for windowHeight = windowHeightMin:100:windowHeightMax

%%Load training set
trainDir = dir('H:\MITPedDataset\*.png'); 
numTrainImages = length(trainDir);
disp('Number of Training Images');
disp(numTrainImages);

imageDim = imread(strcat('H:\MITPedDataset\',trainDir(1).name));
imageDim = imresize(imageDim, [windowHeight windowWidth]);

[hog_4x4, vis4x4] = extractHOGFeatures(imageDim,'CellSize',[8 8]);
cellSize = [10 10];
hogFeatureSize = length(hog_4x4);
disp('Size of Feature Vector');
disp(size(hog_4x4));

%%Extract HOG features from training set
trainingFeatures = [];
trainingLabels = [];

features = zeros(numTrainImages, hogFeatureSize);
labels = zeros(numTrainImages, 1);

for j=1:numTrainImages
    currentImage = ...
        strcat('H:\MITPedDataset\',trainDir(j).name);
    name = trainDir(j).name;
    img = imread(currentImage);
    
    % Resize images to a constant height
    img = imresize(img, [windowHeight windowWidth]);
   
    % Extract HOG Features and HOG Visulization
    [feat, visu] = extractHOGFeatures(img, 'CellSize', [8 8]);
   
    features(j, :) = feat;
   
    s = trainDir(j).name;
    
    % Assign labels based on image name
    if strfind(s, 'per')
        labels(j) = 1;
    end
    if strfind(s, 'crop')
        labels(j) = 1;
    end
end

trainingFeatures = [trainingFeatures; features];
trainingLabels = [trainingLabels; labels];
classifier = fitcsvm(trainingFeatures, trainingLabels);
disp('Training Set Completed & SVM trained');

%%Start with smallest segmentation size in left corner 
pixelSlideY = 10;
pixelSlideX = 100;
slideY = 0;
slideX = 0;


for w = 0:pixelSlideX:(width - windowWidth)
    for h = 0:pixelSlideY:(height - windowHeight)
        for i = 1:windowHeight
            for j = 1:windowWidth
                temp(i, j, :) = testingImage(i + h, j + w,:);
            end
        end
        [tfeat, visu] = extractHOGFeatures(temp, 'CellSize', [8 8]);
        currSegmentLength = length(tfeat);
        [label, score] = predict(classifier, tfeat); 
        disp(score);
        disp(label);
        if label == 1
            bboxes = [bboxes; [w h windowWidth windowHeight]];
        end
    end
end
end

test = insertObjectAnnotation(testingImage,'rectangle',bboxes,'Person');

figure;
imshow(test);
title('Peds Detected');
    %%Run classifier on features from image segment w training data
    %%features from
    
