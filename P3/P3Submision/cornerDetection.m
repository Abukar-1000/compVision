i = imread("imgs\pillsetc.jpg");
i = im2gray(i);


matlabCornersLoc = detectHarrisFeatures(im2gray(i));
matlabCorners = selectStrongest(matlabCornersLoc, 450);

imshow(i);
hold on;
plot(matlabCorners);
hold off;


function [corners] = detectCorners(image, sigma)
    
    colorChannels = size(image,3);
    isRGBImage = colorChannels > 1;
    if isRGBImage
        image=rgb2gray(image);
    end

    k = 0.1;
    threshold = 2 * 10^7;
    [gradientX, gradientY] = imgradientxy(double(image), 'sobel');
    
    gradientXSquared = gradientX.^2;
    gradientYSquared = gradientY.^2;
    
    gradientXY = gradientX .* gradientY;
    
    gradientXSquared = imgaussfilt(gradientXSquared, sigma);
    gradientYSquared = imgaussfilt(gradientYSquared, sigma);
    gradientXY = imgaussfilt(gradientXY, sigma);
    
    r = (gradientXSquared.*gradientYSquared - gradientXY.^2) - k*(gradientXSquared+gradientYSquared).^2;
    kernel = [
        1 1 1;
        1 1 1;
        1 1 1;
    ];

    kernelSize = 9;

    rMax = ordfilt2(r, kernelSize, kernel);
    corners = (r == rMax) & (r > threshold);
end
