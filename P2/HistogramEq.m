i = imread("src_imgs\tire.pnm");

matlabSol = histeq(i);
mySol = HistMap(i);

%imshow(i);
montage({matlabSol, mySol});
title("matlab implementation vs my implementation");

function histogramImg = HistMap(image)
    uniquePxlValues = 256;
    [height, width] = size(image);
    
    function pixlePobablility = GetPixlePobablility()
        pixleFreq = zeros(uniquePxlValues, 1);
        pixlePobablility = zeros(uniquePxlValues, 1);
        numOfPixles = height * width;

        for row = 1:height
            for col = 1:width
                pixleVal = image(row, col);
                pixleFreq(pixleVal + 1) = pixleFreq(pixleVal + 1) + 1;
                pixlePobablility(pixleVal + 1) = pixleFreq(pixleVal + 1) / numOfPixles;
            end
        end
    end

    function cumulativePixlePobablility = GetPixleCDF(pixlePobablility)
        cumulativePixleFeq = zeros(uniquePxlValues, 1);
        cumulativePixlePobablility  = zeros(uniquePxlValues, 1);
        cumulativeFreq = 0;
        
        for index = 1:size(pixlePobablility)
            cumulativeFreq = cumulativeFreq + pixlePobablility(index);
            cumulativePixleFeq(index) = cumulativeFreq;
            cumulativePixlePobablility(index) = cumulativePixleFeq(index);
        end
    end
    
    pixlePobablility = GetPixlePobablility();
    cumulativePixlePobablility = GetPixleCDF(pixlePobablility);
    histogramImg = uint8(zeros(height, width));
    histogramMapping = zeros(uniquePxlValues, 1);

    for index = 1:size(pixlePobablility)
        histogramMapping(index) = cumulativePixlePobablility(index) * uniquePxlValues;
    end

    for row = 1:height
        for col = 1:width
            histogramImg(row, col) = histogramMapping(image(row, col) + 1);
        end
    end
end