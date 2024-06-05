clear;
i = imread("imgs\hinge.jpg");
i = im2gray(i);
i = im2double(i);

bw = edge(i,'canny');
[H, T, R] = hough(bw, "Theta",-90:0.5:89);


r1 = -90:0.5:89;
[myHaugh, associatedPts, t, r] = computeHaugh(bw, r1);
[minEigVector, detectedLines] = fitLines(bw, myHaugh, associatedPts, r, t);
minEigVector
detectedLines

function [Accumulator, associatedPts, Theta, Rhou] = computeHaugh(Bw, thetaRange)
    Theta = deg2rad(thetaRange);
    [row, col] = size(Bw);
    diagLen = sqrt(row^2 + col^2);
    Rhou = -diagLen:1:diagLen;
    cosTheta = cos(deg2rad(thetaRange));
    sinTheta = sin(deg2rad(thetaRange));

    accRow = length(Rhou);
    accCol = length(thetaRange);
    Accumulator = zeros(accRow, accCol);
    associatedPts(1:accRow, 1:accCol) = struct("q",0,"theta",0,"pts",[]);

    for y = 1:row
        for x = 1:col
            isEdgePixel = Bw(y, x) ~= 0;
            
            if isEdgePixel
                for thetaIndex = 1:length(thetaRange)
                    rho = y*cosTheta(thetaIndex) + x*sinTheta(thetaIndex);
                    rhoIndex = ceil(rho + floor(accRow / 2));
                    prevValue = Accumulator(rhoIndex, thetaIndex);
                    Accumulator(rhoIndex, thetaIndex) = prevValue + 1;
                    associatedPts(rhoIndex, thetaIndex).q = rho;
                    associatedPts(rhoIndex, thetaIndex).theta = thetaRange(thetaIndex);
                    previousPts = associatedPts(rhoIndex, thetaIndex).pts;
                    associatedPts(rhoIndex, thetaIndex).pts = [previousPts; struct("x", x, "y", y)];
                end
            end
        end
    end
end


function [minEigVect, lines] = fitLines(iamge, HaughTrans, associatedPts, rhous, thetas)
    % get peak
    peakValue = max(HaughTrans, [], "all")
    [peakY, peakX] = find(HaughTrans == peakValue);
    
    nei = associatedPts(peakY, peakX).pts;
    rhou = associatedPts(peakY, peakX).q;
    theta = associatedPts(peakY, peakX).theta;
    [height, width] = size(image);
    [rows, cols] = size(HaughTrans);
    
    centerY = floor(height / 2);
    centerX = floor(width / 2);
    lineLength = sqrt(centerX^2 + centerY^2);
    binThresh = 20;
    
    xValues = [];
    yValues = [];
    
    for i = 1:length(nei)
        s = nei(i,:);
        xValues = [xValues; s.x];
        yValues = [yValues; s.y];
    end
    
    xBar = mean(xValues);
    yBar = mean(yValues);
    A = [];
    for i = 1:length(nei)
        s = nei(i,:);
        rowData = [s.x - xBar s.y - yBar];
        A = [A; rowData];
    end

    M = A.'*A;
    [eigVect, eigVal] = eig(M);
    [eigVal, index] = sort(diag(eigVal));
    minIndex = index(1);
    minEigVect = eigVect(:,minIndex);
    lines = [];

    % create line points
    for row = 1:rows
        for col = 1:cols
            isMaxima = abs(HaughTrans(row, col) - peakValue) <= binThresh;
            if isMaxima
                rhou = rhous(row);
                theta = thetas(col);

                s = nei(i,:);
                a = cos(deg2rad(theta));
                b = sin(deg2rad(theta));
        
                x1 = ((a * rhou) + centerX) + lineLength * (-b);
                x2 = ((a * rhou) - centerX) - lineLength * (-b);
                y1 = ((b * rhou) + centerY) + lineLength * (a);
                y2 = ((b * rhou) - centerY) - lineLength * (a);
                lines = [lines; int16([rhou theta x1 y1 x2 y2])];
            end
        end
    end
end