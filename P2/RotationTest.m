i = imread("src_imgs\building.jpeg");
theta = 330;
myrotated = rotateImage(i, theta);

rotated = imrotate(i, -theta);
montage({rotated, myrotated});
title("matlab implementation vs my implementation");

function rotatedImg = rotateImage(inputImg, theta)

    function rotatedImg = MapCorrespondingPixels(xOffset, yOffset, xRange, yRange, theta)
        rotatedImg = zeros(yRange, xRange, 'uint8');
    
        [originalHeight, originalWidth] = size(inputImg);

        for y = 1:yRange
            for x = 1:xRange
                inputX = round((x - xOffset) * cos(theta) - (y - yOffset) * sin(theta) + centerX);
                inputY = round((x - xOffset) * sin(theta) + (y - yOffset) * cos(theta) + centerY);
    
                if inputX >= 1 && inputX <= originalWidth && inputY >= 1 && inputY <= originalHeight
                    rotatedImg(y, x) = inputImg(inputY, inputX);
                else
                    rotatedImg(y, x) = 0;
                end
            end
        end
    end

    [height, width] = size(inputImg);

    centerX = (width + 1) / 2;
    centerY = (height + 1) / 2;

    VerticalOrHorizontalRotation = mod(abs(theta), 90) == 0;
    theta = -theta * (pi/180);

    if VerticalOrHorizontalRotation
        rotatedImg = MapCorrespondingPixels(centerX, centerY, width, height, theta);
    else
        maxRadius = ceil(sqrt(centerX^2 + centerY^2));
        width = round(2 * maxRadius);
        height = round(2 * maxRadius);
        rotatedImg = MapCorrespondingPixels(maxRadius, maxRadius, width, height, theta);
    end
end