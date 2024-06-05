i = imread("imgs\building.jpg");
i = im2double(i);
i = im2gray(i);


matlabImplEdge = edge(i, 'Canny', [0.01 0.3], 1);
[ myCanny, gradientMagnitude, gradientAngle ] = myCannyEdgeDetection(i, 1, 0.01, 0.3);
montage({myCanny, matlabImplEdge});


function [gradientMagnitudeCpy, gradientMagnitude, gradientAngle ] = myCannyEdgeDetection(image, sigma, threshLow, threshHigh)
    image = imgaussfilt(image, sigma);
    [gradientX, gradientY] = computeGradient(image);
    
    [gradientMagnitude, gradientAngle] = computeMagnitudeAndAngle(gradientX, gradientY);
    
    gradientAngle = quantisizeGradientAngle(gradientAngle);
    

    gradientMagnitudeCpy = nonMaximaSupression(gradientMagnitude, gradientAngle, 3);
    
    threshHigh = threshHigh * 1.2;
    weak = 0.2;
    strong = 1;
    [gradientMagnitudeCpy] = gradientThreshold(gradientMagnitudeCpy, threshLow, threshHigh, weak, strong);
    
    gradientMagnitudeCpy = computeHysteresis(gradientMagnitudeCpy, 3, weak, strong);
end


function [gradientMagnitude, gradientAngle] = computeMagnitudeAndAngle(gradientX, gradientY)

    gradientMagnitude = sqrt(gradientX.^2 + gradientY.^2);
    gradientAngle = atand(gradientY./gradientX); 
    gradientAngle(gradientMagnitude == 0) = 0; 
end

function [gradientX, gradientY] = computeGradient(row)
    sobleDx = [
        -1 0 1;
        -2 0 2;
        -1 0 1;
    ];
    
    sobleDy = [
        -1 -2 -1;
         0 0 0;
         1 2 1;
    ];

    gradientX = conv2(row, sobleDx, "same");
    gradientY = conv2(row, sobleDy, "same");
end


function gradientAngle = quantisizeGradientAngle(gradientAngle)
    [rows, cols] = size(gradientAngle);
    for y = 1:rows
        for x = 1:cols
            theta = gradientAngle(y, x);
            if theta > -67.5 && theta < -22.5
                theta = -45;
            elseif theta >= -22.5 && theta <= 22.5
                theta = 0;
            elseif theta > 22.5 && theta < 67.5
                theta = 45;
            elseif theta >= 67.5 && theta <= 90
                theta = 90;
            elseif theta >= -90 && theta <= -67.5
                theta = 90;
            end

            gradientAngle(y, x) = theta;
        end
    end
end

function [suppressionMtx] = getSupressionMtrx(quantasizedAngle)
    if quantasizedAngle == 90
        suppressionMtx = [
            0 1 0;
            0 1 0;
            0 1 0;
        ];
    elseif quantasizedAngle == 45
        suppressionMtx = [
            1 0 0;
            0 1 0;
            0 0 1;
        ];
    elseif quantasizedAngle == 0
        suppressionMtx = [
            0 0 0;
            1 1 1;
            0 0 0;
        ];
    elseif quantasizedAngle == -45
        suppressionMtx = [
            0 0 1;
            0 1 0;
            1 0 0;
        ];
    end
end

function gradientMagnitudeCpy = nonMaximaSupression(gradientMagnitude,gradientAngle, kernelSize)

    [rows, cols] = size(gradientMagnitude);
    middleKernelIndex = (kernelSize^2-1)/2+1;
    offset = floor((kernelSize-1)/2);
    gradientMagnitudeCpy = gradientMagnitude;
    gradientMagnitude = padarray(gradientMagnitude, [offset, offset], "replicate");
    
    for row = 1+offset:rows+offset
        for col = 1+offset:cols+offset
            theta = gradientAngle(row-offset,col-offset);
            [supressionMtrx] = getSupressionMtrx(theta);
            region = gradientMagnitude(row-offset:row+offset,col-offset:col+offset);
            region = region .* supressionMtrx;
            maxIndex = find(region == max(region(:))); 
            maxValueNotInCenter = maxIndex ~= middleKernelIndex;
            
            if maxValueNotInCenter
                    gradientMagnitudeCpy(row-offset,col-offset) = 0;
            end
        end
    end
end


function [gradientMagnitudeCpy] = gradientThreshold(gradientMagnitude, threshLow, threshHigh, weak, strong)
    gradientMagnitudeCpy = gradientMagnitude;
    gradientMagnitudeCpy(gradientMagnitudeCpy >= threshHigh) = strong;
    gradientMagnitudeCpy(gradientMagnitudeCpy > threshLow & gradientMagnitudeCpy < threshHigh) = weak;
    gradientMagnitudeCpy(gradientMagnitudeCpy <= threshLow) = 0;
end


function gradientMagnitudeCpy = computeHysteresis(gradientMagnitude, kernelSize, weak, strong)
    gradientMagnitudeCpy = gradientMagnitude;
    [rows, cols] = size(gradientMagnitudeCpy);
    offset = floor((kernelSize-1)/2);
    changed = true;
    while changed 
        changed = false;
        Edges = padarray(gradientMagnitudeCpy, [offset, offset], "replicate");
        for row = 1+offset:rows+offset
            for col = 1+offset:cols+offset
                if Edges(row, col) == weak
                    window = Edges(row-offset:row+offset, col-offset:col+offset);
                    
                    isConnectedToStrongEdge = ~isempty(find(window == strong));
                    if isConnectedToStrongEdge
                        gradientMagnitudeCpy(row-offset, col-offset) = strong;
                        changed = true;
                    end
                end          
            end
        end
    end

    for row = 1:rows
        for col = 1:cols
            isWeakEdge = gradientMagnitudeCpy(row, col) <= weak;
            if isWeakEdge
                gradientMagnitudeCpy(row, col) = 0;
            end
        end
    end 
end