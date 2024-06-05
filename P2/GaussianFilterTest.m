i = imread("src_imgs\auto.png");

% Add noise to image
i = imnoise(i, "salt & pepper");

sig = 2;
matlabSol = imgaussfilt(i, sig);
mySol = GaussianFilter(i, sig);

%imshow(i);
montage({matlabSol, mySol});
title("matlab implementation vs my implementation");


function smoothedImg = GaussianFilter(image, sigma)
    imgWidth = width(image);
    imgHeight = height(image);

    function weight = GaussianWeight(x, sigma)
        weight = (1 / (sqrt(2 * pi) * sigma)) * exp((-1/2) * (x/sigma)^2);   
    end

    function pixelValue = Convolve(kernelBound, row, col)
        sum = 0;
        normalizationFactor = 0;

        for kernelY = -kernelBounds:kernelBounds
            yWeight = GaussianWeight(kernelY, sigma);
            
            for kernelX = -kernelBounds:kernelBounds
                xWeight = GaussianWeight(kernelX, sigma);
                weight = xWeight * yWeight;
                x = col + kernelX;
                y = row + kernelY;
                if x >= 1 && x <= imgWidth && y >= 1 && y <= imgHeight
                    sum = sum + weight * double(image(y, x));
                    normalizationFactor = normalizationFactor + weight;
                end
            end
        end

        pixelValue = sum/normalizationFactor;
    end

    kernelSize = round(2 * pi * sigma);

    % Ensure kernel size is odd
    evenSizedKernel = mod(kernelSize, 2) == 0;
    if evenSizedKernel
        kernelSize = kernelSize + 1;
    end
    kernelBounds = floor(kernelSize / 2);

    smoothedImg = uint8(zeros(imgHeight, imgWidth));

    for row = 1:imgHeight
        for col = 1:imgWidth
            smoothedImg(row, col) = Convolve(kernelBounds, row, col);
        end
    end
end