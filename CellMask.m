function [cellmask,raw_iso] = CellMask(image,pixres,vertx,verty)
%% CellMask 
%takes a raw image, pixel resolution (microns/pixel), and vertex x and y
%coordinates to determine cell masks for a single image. Possible to loop
%over a movie. vertx and verty should be cell vectors.
[row,col] = size(image);
cellmask = zeros(row,col,length(vertx));
raw_iso = zeros(row,col,length(vertx));

for i = 1:length(vertx)
    x = vertx{i}./pixres;
    y = verty{i}./pixres;
    if isnan(x) == 0
        BW = poly2mask(x,y,row,col);
        cellmask(:,:,i) = BW;
        raw_iso(:,:,i) = cellmask(:,:,i).*double(image(:,:));
        clear BW
    end
end
end