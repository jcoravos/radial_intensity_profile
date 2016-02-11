function [outputstruct,Data] = RadialIP(inputstruct)
image = inputstruct.image;
pixres = inputstruct.pixres;
vertx = inputstruct.vertx;
verty = inputstruct.verty;
centx = inputstruct.centx;
centy = inputstruct.centy;

%% Generate cell masks
disp('Generating masks...')
[cellmask,image_iso] = CellMask(image,pixres,vertx,verty); %cellmask is the binary mask, image_iso is the masked pixels from the original image.

%% Converting Pixel intensity values from cartesian to polar coordinates
disp('Converting to polar coordinates...')
for i = 1:length(vertx)
    %Drawing a meshgrid centered on the cell centroid
    
    [xmesh,ymesh,xmesh_mask,ymesh_mask,maxdim] = centermeshgrid(centx{i}, centy{i}, cellmask(:,:,i), pixres);
   
   % convert to polar coordinates
   [~,rho] = cart2pol(xmesh, ymesh); %theta is not used in the function, but this is the part where theta could be collected to learn something about orientation
   rho = round(rho);
   ind = cell(maxdim,1);
        for r = 0:maxdim-1 %need to offset this to catch the origin
             ind{r+1} = find(rho == r);
        end
   Pfraw = cell(maxdim,1);
   Pfstd = zeros(maxdim,1);
   Pfmean = zeros(maxdim,1);
   zeroind = find(image_iso(:,:,i) == 0);
   rawimage = image_iso(:,:,i);
   rawimage(zeroind) = NaN; 
        for r = 1:maxdim
           rawcolcoord = round(xmesh_mask(ind{r}));
           rawrowcoord = round(ymesh_mask(ind{r}));
           rawind = sub2ind(size(rawimage),rawrowcoord,rawcolcoord);
           Pfraw{r} = rawimage(rawind);
           Pfmean(r) = nanmean(Pfraw{r});
        end
        
        Data{i}.Pfraw = Pfraw;
end

% Dumping Pfraw from all cells into one cell array. Row is radius in
% pixels. This collects all values for each row.

disp('Rho statistics...')
r_aggregate = cell(100,1);
for i = 1:length(Data)
    for j = 1:length(Data{i}.Pfraw)
        r_aggregate{j} = vertcat(r_aggregate{j},cell2mat(Data{i}.Pfraw(j)));
    end
end

%eliminate unused cells
populatedcell = find(~cellfun(@isempty,r_aggregate));
r_aggregate = r_aggregate(populatedcell);

%determine mean at each radius
r_aggmean = zeros(1,length(r_aggregate));
r_aggstd = zeros(1,length(r_aggregate));

for i = 1:length(r_aggregate)
    r_aggmean(i) = nanmean(r_aggregate{i});
    r_aggstd(i) = nanstd(r_aggregate{i});
end

outputstruct.rho = r_aggregate; %this is the pooled values at each rho
outputstruct.rhomean = r_aggmean; %mean value at each rho
outputstruct.rhostd = r_aggstd; %std at each rho
outputstruct.cellmask = cellmask; %the array of cellmasks (x,y,# of cells)
outputstruct.image_iso = image_iso; %the isolated pixels under each cell mask (x,y,# of cells)
end