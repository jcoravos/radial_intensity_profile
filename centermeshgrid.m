function [xmesh,ymesh,xmesh_mask,ymesh_mask,maxdim] = centermeshgrid(centx, centy, cellmask, pixres)
%% centermeshgrid draws a meshgrid on a cellmask that covers the entire cellmask and is centered on the cell centroid
%mesh is a generic grid centered on 0. mesh_mask is the same dimension
%square grid centered on the cell centroid. This is used for querying pixel
%intensity values at that position in the grid.

    cent_col = centx/pixres;
    cent_row = centy/pixres;
    
    [rowind, colind] = find(cellmask == 1);
    maxdim = ceil(max([abs(cent_col-max(colind)), ...
                   abs(cent_col-min(colind)), ...
                   abs(cent_row-max(rowind)), ...
                   abs(cent_row-min(rowind))]));
              
    [xmesh, ymesh] = meshgrid(-maxdim:maxdim-1,-maxdim:maxdim-1);           
    %make a meshgrid centered on the centroid and extending to the max
    %distance from the centroid
    
    [xmesh_mask,ymesh_mask] = meshgrid(cent_col-maxdim:cent_col+maxdim-1, cent_row-maxdim:cent_row+maxdim-1);
end