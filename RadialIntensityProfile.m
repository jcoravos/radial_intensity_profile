%% Radial Intensity Profile 
%This script takes the following inputs:
%   -a single frame image (i.e. maximum intensity projection of actin
%   fluorescence)
%   -EDGE vertex data for the data
%   -centroid data (EDGE or other)
%
%With these inputs, this script imposes a polar coordinate system on each
%cell in the image, and converts the position information for each pixel
%from cartesian(x,y) to polar(rho, theta) coordinates. Then the script
%pools all of the pixels at each value of rho. These pooled values
%constitute a radial intensity profile.

%Calls the following functions:
    %CellMask
    %centermeshgrid

%Jonathan Coravos 6/22/15

%% User Inputs
%This section can be adjusted depending on the type of inputs you want
%(i.e. if you are working with a movie, you will need to write a different
%script to feed individual frames to the script.)

image = imread(strcat('/Volumes/CORAVOS 2/Myo6GFP_67;15_+/Fixed -- MPRIP-647,Dcad-568/Image47_062415/Image47_062415_c001_z001.tif'));
savefolder = ('/Volumes/CORAVOS 2/Myo6GFP_67;15_+/Fixed -- MPRIP-647,Dcad-568/Image47_062415/');
filename = 'Image47_062415';
pixres = 0.10; %microns per pixel
t = 1; %pick this time frame (default should be 1)
z = 1; %pick this slice

vertx = load(strcat('/Users/jcoravos/Documents/MATLAB/EDGE-1.06/DATA_GUI/',filename,'/Measurements/Membranes--vertices--Vertex-x.mat'));
vertx = squeeze(vertx.data(t,z ,:));
verty = load(strcat('/Users/jcoravos/Documents/MATLAB/EDGE-1.06/DATA_GUI/',filename,'/Measurements/Membranes--vertices--Vertex-y.mat'));
verty = squeeze(verty.data(t,z ,:));
centx = load(strcat('/Users/jcoravos/Documents/MATLAB/EDGE-1.06/DATA_GUI/',filename,'/Measurements/Membranes--basic_2d--Centroid-x.mat'));
centx = squeeze(centx.data(t,z ,:));
centy = load(strcat('/Users/jcoravos/Documents/MATLAB/EDGE-1.06/DATA_GUI/',filename,'/Measurements/Membranes--basic_2d--Centroid-y.mat'));
centy = squeeze(centy.data(t,z ,:));

%% Constructing input structure
% Whatever happens upstream of this is variable, but this structure has to
% be created well in order for the following function to work.
inputstruct.image = double(image) %image is a two-dimensional class double
inputstruct.pixres = pixres %this is the pixel resolution of the image (microns/pixel)
inputstruct.vertx = vertx %this is a column vector cell array (i.e. number of cells x 1, where each cell is the x coordinate vertex of the cell.)
inputstruct.verty = verty %as above but for the y coordinate
inputstruct.centx = centx %as above but for centroid x. Once again, must be a cell array even though there is one entry per cell.
inputstruct.centy = centy %as above but for centroid y.



%% RadialIntensityProfile

[outputstruct,PF] = RadialIP(inputstruct);

save(strcat(savefolder,filename,'RadialIP_output.mat'),'outputstruct')

%% Plotting
xmax = length(outputstruct.rhomean);
x = 1:1:xmax;

figure
hold on
    hMean     = line(x,outputstruct.rhomean);
    hUpperSTD = line(x,(outputstruct.rhomean + outputstruct.rhostd));
    hLowerSTD = line(x,(outputstruct.rhomean - outputstruct.rhostd));
    
    
    set(hMean                       ,...
        'Color'         ,'black'    ,...
        'LineWidth'     , 2         );
    
    set(hUpperSTD                   ,...
        'Color'         ,'black'    ,...
        'LineWidth'     , 2         );
    
    set(hLowerSTD                   ,...
        'Color'         ,'black'    ,...
        'LineWidth'     , 2         );

    set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'off'     , ...
    'YMinorTick'  , 'off'     , ...
    'XTick'       , 0:1/inputstruct.pixres:5/inputstruct.pixres   , ...
    'XTickLabel'  , {num2str(0),num2str(1),num2str(2),num2str(3),num2str(4),num2str(5)},...
    'LineWidth'   , 1         );

    xlabel('Radius (µm)')
    ylabel('Mean Intensity, (a.u.)')
    title(strcat('Radial Intensity Profile',filename))
