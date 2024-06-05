i = imread("src_imgs\child.jpg");
mySol = LogTrans(i, 2);

montage({i, mySol});
title("Before Log Transform vs After Log Transform");

function newImg = LogTrans(image, k)
    [height, width] = size(image);
    newImg = k * log(im2double(image) + 1);
end

