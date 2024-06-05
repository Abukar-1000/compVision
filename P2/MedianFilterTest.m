i = imread("src_imgs\s2.jpg");

% Add noise to image
i = imnoise(i, "salt & pepper");

kernelSize = [3 3];
matlabSol = medfilt2(i, kernelSize);
mySol = MedianFilter(i);

imshow(i);
montage({matlabSol, mySol});
title("matlab implementation vs my implementation");

function smoothedImg = MedianFilter(image)
    image = padarray(image, [1,1], 0, "both");
    smoothedImg = uint8(zeros(height(image), width(image)));

    for row = 2:height(image)
        for col = 2:width(image)
            if row <= height(image) - 1 && col <= width(image) - 1
                window = image(row - 1: row + 1, col - 1: col + 1);
                window = reshape(window, [1,9]);
                window = sort(window, "ascend");
                median = window(5);
                smoothedImg(row - 1, col - 1) = median;
            end
        end
    end
    
    for row = 3:height(smoothedImg)
        for col = width(smoothedImg) - 2:width(smoothedImg)
            smoothedImg(row, col) = smoothedImg(row, col - 2);
        end
    end

    for row = height(smoothedImg) - 2:height(smoothedImg)
        for col = 1:width(smoothedImg)
            smoothedImg(row, col) = smoothedImg(row - 2, col);
        end
    end
end