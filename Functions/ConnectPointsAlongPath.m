function [ mask ] = ConnectPointsAlongPath( InputImg, StartPt, EndPt )
%ConnectPointsAlongPath: Traces path between two points while constrained to 
%path of pixels with value one.

%Find the shortest path connecting the centroid and the endoiints.
%This script duplicates the image, and finds the path (following only
%along line of ones) from endpoint to center. In the second image, it
%finds the path from center to endpoint. When these two lines are
%added, the shortest path will be the one == n. Any other paths of
%connection (that are longer) will be erased. The output image is
%mask, that has ones where a valid shortest connection exists.

%OUTPUT: mask is an image the same size as input image. It contains 1s
%where the shortest path was discovered. 

%INPUT: 
%InputImg must be a black and white image where the path will lie
%along pixels of value 1. At the moment, it only works with 3D, but could
%easily be modified. 
%StartPt is the x y z coordinate of one pixel of interest. Note, this pixel
%must have a value of 1 in the original image. Check this, it could be
%causing your errors.
%EndPt is the second point of interest to be connected. It must also be of
%value 1 in the original image. 

si = size(InputImg);
sInd = sub2ind(si, StartPt(1), StartPt(2), StartPt(3)); 
eInd = sub2ind(si, EndPt(1), EndPt(2), EndPt(3));

D1 = bwdistgeodesic(InputImg, sInd, 'quasi-euclidean');
D2 = bwdistgeodesic(InputImg, eInd, 'quasi-euclidean');
D = D1+D2;
D = round(D*10)/10; % Handles floating point rounding error
D(isnan(D)) = inf;
mask = imregionalmin(D);

%figure; hold on
%P = imoverlay(max(InputImg,[],3), imdilate(max(mask,[],3), ones(3,3)), [1 0 0]);
%imshow(P, 'InitialMagnification', 200)

end

