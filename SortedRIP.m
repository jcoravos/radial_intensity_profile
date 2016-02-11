%% Script for sorting outputstruct by cell size, then plotting individual cells

outputstruct.cellsize = squeeze(sum(sum(outputstruct.cellmask,1),2));

[~,size_ind] = sort(outputstruct.cellsize,1,'descend'); %sorts cell size ascending to descending (lower ind value is a larger cell)

%Plot histogram of cell sizes (pixel)
figure,
hist(outputstruct.cellsize)
xlabel('Cell Size (pixels)')
ylabel('Number of cells')


%% Plot individual cells
Cell_ID = find(size_ind == 50) %change the == value to find a particular cell

r_aggregate = cell(100,1);
    for j = 1:length(PF{Cell_ID}.Pfraw)
        r_aggregate{j} = vertcat(r_aggregate{j},cell2mat(PF{Cell_ID}.Pfraw(j)));
    end



%eliminate unused cells
populatedcell = find(~cellfun(@isempty,r_aggregate));
r_aggregate = r_aggregate(populatedcell);

%determine mean at each radius
for i = 1:length(r_aggregate)
    r_aggmean(i) = nanmean(r_aggregate{i});
    r_aggstd(i) = nanstd(r_aggregate{i});
end

xmax = length(r_aggmean);
x = 1:1:xmax;


figure
hold on
    hMean     = line(x,r_aggmean);
    hUpperSTD = line(x,(r_aggmean + r_aggstd));
    hLowerSTD = line(x,(r_aggmean - r_aggstd));
    
    
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
    title(strcat('Cell',num2str(Cell_ID),'|',filename))