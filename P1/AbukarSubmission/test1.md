
```{.matlab .numberLines}
opts = detectImportOptions("points.csv");
horizontalPlane = readmatrix("points.csv", opts);
verticalPlane = readmatrix("points.csv", opts);

horizontalPlane = horizontalPlane(1:64,:)
verticalPlane = verticalPlane(65:128, :)


B = []
leftLength = size(horizontalPlane)
leftLength = leftLength(1)

% Sampling all points from both planes to build B
for i = 1:leftLength
    xw = horizontalPlane(i,2)
    yw = horizontalPlane(i,3)
    zw = horizontalPlane(i,4)            
    xi = horizontalPlane(i,5)
    yi = horizontalPlane(i,6)
    

    data = [
        xw, yw, zw, 1, 0,0,0,0, (-xi * xw), (-xi * yw), (-xi * zw), -xi;
        0,  0,   0, 0, xw, yw, zw, 1, (-yi * xw), (-yi * yw), (-yi * zw), -yi
    ]

    B = [B; data]
end

rightLength = size(verticalPlane)
rightLength = rightLength(1)

for i = 1:rightLength
    xw = verticalPlane(i,2)
    yw = verticalPlane(i,3)
    zw = verticalPlane(i,4)
    xi = verticalPlane(i,5)
    yi = verticalPlane(i,6)
    
    data = [
        xw, yw, zw, 1, 0,0,0,0, (-xi * xw), (-xi * yw), (-xi * zw), -xi;
        0,  0,   0, 0, xw, yw, zw, 1, (-yi * xw), (-yi * yw), (-yi * zw), -yi
    ]

    B = [B; data]
end

M = B.'*B

[eigVect, eigVal] = eig(M)
[eigVal, index] = sort(diag(eigVal))
minIndex = index(1)
minEigVect = eigVect(:,minIndex)

P = [
    minEigVect(1), minEigVect(2), minEigVect(3), minEigVect(4);
    minEigVect(5), minEigVect(6), minEigVect(7), minEigVect(8);
    minEigVect(9), minEigVect(10), minEigVect(11), minEigVect(12);
]


wrldPts = [] % holds all points sampled in the image
pxlPrid = [] % stores estimated projections later

for i = 1:leftLength
    xw = horizontalPlane(i,2);
    yw = horizontalPlane(i,3);
    zw = horizontalPlane(i,4);
    xi = horizontalPlane(i,5);
    yi = horizontalPlane(i,6);

    data = [i, xw, yw, zw, 1, xi, yi];

    wrldPts = [wrldPts; data];
end

for i = 1:rightLength
    xw = verticalPlane(i,2);
    yw = verticalPlane(i,3);
    zw = verticalPlane(i,4);
    xi = verticalPlane(i,5);
    yi = verticalPlane(i,6);

    data = [i, xw, yw, zw, 1, xi, yi];
    wrldPts = [wrldPts; data]
end


jig = imread("calibrationrig.jpg");
projectedImage = jig;

% Using the projection matrix
xErr = []
yErr = []
for i = 1:128
    xw = wrldPts(i,2)
    yw = wrldPts(i,3)
    zw = wrldPts(i,4)
    w = wrldPts(i,5)
    xi = wrldPts(i,6)
    yi = wrldPts(i,7)    

    m = [xw, yw, zw, w;];
    prid = P * m.';
    prid = prid.';
    prid = prid/prid(3);
    
    xSubErr = ( abs( xi - prid(1) ) / xi ) * 100
    ySubErr = ( abs( yi - prid(2) ) / yi ) * 100
    
    xErr = [xErr; xSubErr];
    yErr = [yErr; ySubErr];
    projectedImage = insertShape(projectedImage, "circle", [prid(1), prid(2), 5], LineWidth = 2);
end

xError = mean(xErr);
yError = mean(yErr);
xErrorVariance = var(xErr);
yErrorVariance = var(yErr);

KR = P(1:3,1:3);
[intrinsic, rotationMatrix] = qr(KR);
alpha = intrinsic(1,1);
beta = intrinsic(2,2);
u0 = intrinsic(1,3);

v0 = intrinsic(2,3);
translationMatrix = P(:,4);
translationMatrix = inv(intrinsic) * translationMatrix;
imshow(projectedImage);
```