%% MJB 17-Jul-2025 Read SM from SMAP for UK since 2015
clear

cd('F:\projects\Dava_wildfire\data\SMAP_SCA_UK')

folderlist = string(ls('*2*')) ; 


testinfo = h5info('SMAP_L3_SM_P_E_20231205_R19240_001_HEGOUT.h5') ; 

SM_SMAP_moray_array = NaN(81,147,3760) ; 
VOD_SMAP_moray_array = NaN(81,147,3760) ; 
TS_SMAP_moray_array = NaN(81,147,3760) ; 
datetime_SMAP_full = datetime('01-Apr-2015'):days(1):datetime('16-Jul-2025') ; 


for i = 1:length(folderlist) 

    dummy_folder = folderlist(i) ; 
    cd(strcat('F:\projects\Dava_wildfire\data\SMAP_SCA_UK\',dummy_folder))
    filename = ls('*SMAP*') ;

    % testinfo = h5info(filename)
    SM_dummy = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/soil_moisture_dca') ; 
    SM_dummy(SM_dummy == -9999) = NaN ; 
    SM_dummy = SM_dummy' ; 

    VOD_dummy = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/vegetation_opacity_dca') ; 
    VOD_dummy(VOD_dummy == -9999) = NaN ; 
    VOD_dummy = VOD_dummy' ; 

    TS_dummy = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/surface_temperature') ; 
    TS_dummy(TS_dummy == -9999) = NaN ; 
    TS_dummy = TS_dummy' ; 

    datetime_dummy = h5readatt(filename,'/Metadata/Extent/','rangeBeginningDateTime') ; 
    datetime_dummy = datetime(datetime_dummy(1:10)) ; 

    % find correct time point for the array
    [Indextime]  = find(datetime_dummy == datetime_SMAP_full) ; 


    SM_SMAP_moray_array(:,:,Indextime) = SM_dummy ; 
    VOD_SMAP_moray_array(:,:,Indextime) = VOD_dummy ; 
    TS_SMAP_moray_array(:,:,Indextime) = TS_dummy ; 



i
end


save('F:\projects\Dava_wildfire\data\SMAP_processed\SM_SMAP_moray_array','SM_SMAP_moray_array')
save('F:\projects\Dava_wildfire\data\SMAP_processed\VOD_SMAP_moray_array','VOD_SMAP_moray_array')
save('F:\projects\Dava_wildfire\data\SMAP_processed\TS_SMAP_moray_array','TS_SMAP_moray_array')
save('F:\projects\Dava_wildfire\data\SMAP_processed\datetime_SMAP_full','datetime_SMAP_full')


cd('F:\projects\Dava_wildfire\data')



vegetation_opacity_dca
soil_moisture_dca
surface_temperature


Moray_smap_lon_cent = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/longitude_centroid') ; 
Moray_smap_lat_cent = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/latitude_centroid') ; 
Moray_smap_lon_cent(Moray_smap_lon_cent == -9999) = NaN ; 
Moray_smap_lat_cent(Moray_smap_lat_cent == -9999) = NaN ; 
Moray_smap_lon_cent = Moray_smap_lon_cent' ;
Moray_smap_lat_cent = Moray_smap_lat_cent' ; 
save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lon_cent','Moray_smap_lon_cent')
save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lat_cent','Moray_smap_lat_cent')


Moray_smap_lon = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/longitude') ; 
Moray_smap_lat = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/latitude') ; 
Moray_smap_lon(Moray_smap_lon == -9999) = NaN ; 
Moray_smap_lat(Moray_smap_lat == -9999) = NaN ; 
Moray_smap_lon = Moray_smap_lon' ;
Moray_smap_lat = Moray_smap_lat' ; 
save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lon','Moray_smap_lon')
save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lat','Moray_smap_lat')


% x and y is centers
Moray_smap_x = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/x') ; 
Moray_smap_y = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/y') ; 
Moray_smap_x(Moray_smap_x == -9999) = NaN ; 
Moray_smap_y(Moray_smap_y == -9999) = NaN ; 
Moray_smap_x = Moray_smap_x(40:end) ; 

save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_x','Moray_smap_x')
save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_y','Moray_smap_y')






load('F:\projects\Dava_wildfire\data\SMAP_processed\SM_SMAP_moray_array')
load('F:\projects\Dava_wildfire\data\SMAP_processed\VOD_SMAP_moray_array')
load('F:\projects\Dava_wildfire\data\SMAP_processed\TS_SMAP_moray_array')
load('F:\projects\Dava_wildfire\data\SMAP_processed\datetime_SMAP_full')



imagesc(mean(SM_SMAP_moray_array,3,'omitmissing')) 
[xs ys] = getpts() ; xs = round(xs) ; ys = round(ys) ; 
close



for i = 1:length(xs)

    figure
    plot(datetime_SMAP_full,squeeze(SM_SMAP_moray_array(ys(i),xs(i),:)),'o') ; 
    hold on 
    plot(datetime_SMAP_full,movmean(squeeze(SM_SMAP_moray_array(ys(i),xs(i),:)),120,'omitnan'),'r-') ;     

end



% standardize 
SM_SMAP_moray_array_zscore = (SM_SMAP_moray_array - mean(SM_SMAP_moray_array,3,'omitmissing')) ./ std(SM_SMAP_moray_array,0,3,'omitmissing') ; 
VOD_SMAP_moray_array_zscore = (VOD_SMAP_moray_array - mean(VOD_SMAP_moray_array,3,'omitmissing')) ./ std(VOD_SMAP_moray_array,0,3,'omitmissing') ; 

% map plot









%%

set(0, 'DefaultAxesFontSize',16)
% set(0,'defaultlinelinewidth',2)
set(0, 'DefaultAxesFontName','Helvetica')
set(0,'DefaultAxesTitleFontWeight','normal')
[Indextime_fire]  = find(datetime('12-Jul-2025') == datetime_SMAP_full) ; 

cd('E:\Daten Baur\Matlab code')
col_L = hex2rgb('808080') ; 
col_L_light = hex2rgb('CDCDCD') ; 

col_C = hex2rgb('3399FF') ;
col_C_light = hex2rgb('80E6FF') ; 

col_X = hex2rgb('FF3333') ;
col_X_light = hex2rgb('FF8080') ; 

cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('Coastlines.mat')
cd('E:\Daten Baur\Matlab code\redblue')
redblue_color = redblue(100) ; 
bam_color = crameri('bam') ;
tokyo_color = crameri('tokyo') ;
imola_color = crameri('imola') ;
cork_color = crameri('cork') ;
batlow_color = crameri('batlow') ;
sminterp = (0.01:0.01:0.6)' ; 
sminterp_zeppe = (linspace(0,1,50))' ; 


%%
load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lon_cent')
load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lat_cent')
load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lon')
load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lat')


difflon = diff(Moray_smap_lon(80,10:end)) ; 
difflat = diff(Moray_smap_lon(80,10:end)) ; 


Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
h = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , SM_SMAP_moray_array_zscore(:,:,Indextime_fire)) ; 
set(h,'LineStyle','none')
shading flat
% set(h, 'AlphaData', ~isnan(SM_SMAP_moray_array_zscore(:,10:end,Indextime_fire)))
% set(gca,'YDir','normal') 
hold on
% colormap(flipud(redblue_color(50:end,:)) )
clim([-3 -0])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'SM z scores 12-Jul-2025','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
pbaspect([9.9896 9.6328 1])
fontsize(16,'points')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_SM_zscores_firetime_03','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_SM_zscores_firetime_03','png')
close 




Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
h = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , VOD_SMAP_moray_array_zscore(:,:,Indextime_fire)) ; 
set(h,'LineStyle','none')
shading flat
% set(h, 'AlphaData', ~isnan(SM_SMAP_moray_array_zscore(:,10:end,Indextime_fire)))
% set(gca,'YDir','normal') 
hold on
colormap(flipud(redblue_color(:,:)) )
clim([-3 3])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'VOD z scores 12-Jul-2025','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
plot(CoastlineLon, CoastlineLat,'Color','k');
pbaspect([9.9896 9.6328 1])
fontsize(16,'points')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_VOD_zscores_firetime_03','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_VOD_zscores_firetime_03','png')
close 







% max(Moray_smap_lon(1,:)) - min(Moray_smap_lon(1,:))
% max(Moray_smap_lat(:,100)) - min(Moray_smap_lat(:,100))

h = pcolor(Moray_smap_lon, Moray_smap_lat , SM_SMAP_moray_array_zscore(:,:,Indextime_fire)) ; 
hold on



%% do scotland shaded are z scores

imagesc(mean(SM_SMAP_moray_array,3,'omitmissing')) 
[xs ys] = getpts() ; xs = round(xs) ; ys = round(ys) ; 
close



SM_SMAP_moray_array_zscore_sample = SM_SMAP_moray_array_zscore(ys(1):ys(2),xs(1):xs(2),:) ; 
SM_SMAP_moray_array_zscore_sample = movmean(SM_SMAP_moray_array_zscore_sample,60,3,'omitnan') ; 


VOD_SMAP_moray_array_zscore_sample = VOD_SMAP_moray_array_zscore(ys(1):ys(2),xs(1):xs(2),:) ; 
VOD_SMAP_moray_array_zscore_sample = movmean(VOD_SMAP_moray_array_zscore_sample,60,3,'omitnan') ; 


SM_SMAP_moray_array_zscore_median =   squeeze(median(SM_SMAP_moray_array_zscore_sample,[1 2],'omitnan')) ;
SM_SMAP_moray_array_zscore_mean =   squeeze(mean(SM_SMAP_moray_array_zscore_sample,[1 2],'omitnan')) ;
SM_SMAP_moray_array_zscore_25 =   squeeze(prctile(SM_SMAP_moray_array_zscore_sample,25,[1 2])) ; 
SM_SMAP_moray_array_zscore_75 =   squeeze(prctile(SM_SMAP_moray_array_zscore_sample,75,[1 2])) ; 

VOD_SMAP_moray_array_zscore_median =   squeeze(median(VOD_SMAP_moray_array_zscore_sample,[1 2],'omitnan')) ;
VOD_SMAP_moray_array_zscore_mean =   squeeze(mean(VOD_SMAP_moray_array_zscore_sample,[1 2],'omitnan')) ;
VOD_SMAP_moray_array_zscore_25 =   squeeze(prctile(VOD_SMAP_moray_array_zscore_sample,25,[1 2])) ; 
VOD_SMAP_moray_array_zscore_75 =   squeeze(prctile(VOD_SMAP_moray_array_zscore_sample,75,[1 2])) ; 





Fig_Panel = figure('units','centimeters','position',[10 2 40 18])  ;
linepre = plot(datetime_SMAP_full,SM_SMAP_moray_array_zscore_median,'-','LineWidth',1,'Color','k') ;
hold on
yline(SM_SMAP_moray_array_zscore_median(end),'-r','LineWidth',2)
hold on
x2 = [datetime_SMAP_full, fliplr(datetime_SMAP_full)];
inBetween = [SM_SMAP_moray_array_zscore_median', fliplr(SM_SMAP_moray_array_zscore_25' )];
fillpre = fill(x2, inBetween, col_C,'FaceAlpha',0.25);
x2 = [datetime_SMAP_full, fliplr(datetime_SMAP_full)];
inBetween = [SM_SMAP_moray_array_zscore_median', fliplr(SM_SMAP_moray_array_zscore_75')];
fill(x2, inBetween, col_C,'FaceAlpha',0.25);
plot(datetime_SMAP_full,SM_SMAP_moray_array_zscore_median,'-','LineWidth',1,'Color','k')
ylim([-2 2])
line25 = plot(datetime_SMAP_full,SM_SMAP_moray_array_zscore_25,'-','LineWidth',1,'Color','k') ;
line75 = plot(datetime_SMAP_full,SM_SMAP_moray_array_zscore_75,'-','LineWidth',1,'Color','k') ;

%kolsmi_post = plot(sminterp(pre_index),prct_50,'','MarkerSize',15) ;
legend('SMAP SM anomalies median','anomaly at fire time')
xlabel('Time','FontSize',16)
ylabel('SMAP SM anomaly Scotland','FontSize',16)
fontsize(16,'points')

saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_SM_zscores_scot_timeseries','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_SM_zscores_scot_timeseries','png')
close 



SM_SMAP_moray_array_zscore_sample(SM_SMAP_moray_array_zscore_sample < -5) = NaN ; 
SM_SMAP_moray_array_zscore_sample(SM_SMAP_moray_array_zscore_sample > 5) = NaN ; 
Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
histogram(SM_SMAP_moray_array_zscore_sample,100)
xlabel('SM z-scores [-]','FontSize',16)
ylabel('count','FontSize',16)
xline(median(SM_SMAP_moray_array_zscore_sample(:,:,Indextime_fire),[1 2],'omitnan'),'-r','LineWidth',2)
legend('','conditions before fire')
fontsize(16,'points')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_SM_zscores_scot_histo','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_SM_zscores_scot_histo','png')
close 






Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
linepre = plot(datetime_SMAP_full,VOD_SMAP_moray_array_zscore_median,'-','LineWidth',1,'Color','k') ;
hold on
yline(VOD_SMAP_moray_array_zscore_median(end),'-r','LineWidth',2)
hold on
x2 = [datetime_SMAP_full, fliplr(datetime_SMAP_full)];
inBetween = [VOD_SMAP_moray_array_zscore_median', fliplr(VOD_SMAP_moray_array_zscore_25' )];
fillpre = fill(x2, inBetween, col_C,'FaceAlpha',0.25);
x2 = [datetime_SMAP_full, fliplr(datetime_SMAP_full)];
inBetween = [VOD_SMAP_moray_array_zscore_median', fliplr(VOD_SMAP_moray_array_zscore_75')];
fill(x2, inBetween, col_C,'FaceAlpha',0.25);
plot(datetime_SMAP_full,VOD_SMAP_moray_array_zscore_median,'-','LineWidth',1,'Color','k')
ylim([-2 2])
line25 = plot(datetime_SMAP_full,VOD_SMAP_moray_array_zscore_25,'-','LineWidth',1,'Color','k') ;
line75 = plot(datetime_SMAP_full,VOD_SMAP_moray_array_zscore_75,'-','LineWidth',1,'Color','k') ;

%kolsmi_post = plot(sminterp(pre_index),prct_50,'','MarkerSize',15) ;
legend('SMAP VOD anomalies median','anomaly at fire time')
xlabel('Time','FontSize',16)
ylabel('SMAP SM anomaly Scotland','FontSize',16)
fontsize(16,'points')

saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_VOD_zscores_scot_timeseries','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_VOD_zscores_scot_timeseries','png')
close 





SM_SMAP_moray_array_zscore_sample(VOD_SMAP_moray_array_zscore_sample < -5) = NaN ; 
SM_SMAP_moray_array_zscore_sample(VOD_SMAP_moray_array_zscore_sample > 5) = NaN ; 
Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
histogram(SM_SMAP_moray_array_zscore_sample,100)
xlabel('VOD z-scores [-]','FontSize',16)
ylabel('count','FontSize',16)
xline(median(VOD_SMAP_moray_array_zscore_sample(:,:,Indextime_fire),[1 2],'omitnan'),'-r','LineWidth',2)
legend('','conditions before fire')
fontsize(16,'points')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_VOD_zscores_scot_histo','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures\SMAP_DCA_VOD_zscores_scot_histo','png')
close 












%% get spatial overlap between fire area and SMAP pixels

cd('F:\projects\Dava_wildfire\data\burnt_area_effis')


Dava_fire_perimeter = readgeotable('Dava_fire_perimeter.shp') ; 
Dava_fire_perimeter_T = geotable2table(Dava_fire_perimeter,["Lat","Lon"]); 

[latDAVA,lonDAVA] = projinv(Dava_fire_perimeter.Shape.ProjectedCRS,cell2mat(Dava_fire_perimeter_T.Lat),cell2mat(Dava_fire_perimeter_T.Lon)) ; 




hold on
plot(lonDAVA,latDAVA,'r-')

figure 
geoplot(Dava_fire_perimeter)


%% save as geotiffs
cd('F:\projects\Dava_wildfire\data\SMAP_processed')

load('Moray_smap_lat.mat')
load('Moray_smap_lat_cent.mat')
load('Moray_smap_lon.mat')
load('Moray_smap_lon_cent.mat')
load('SM_SMAP_moray_array.mat')
load('TS_SMAP_moray_array.mat')
load('VOD_SMAP_moray_array.mat')



% Your 3D data
data = SM_SMAP_moray_array;

% Check dimensions
[rows, cols, bands] = size(data);


Moray_smap_lat_02 = lat(min(Locbr):max(Locbr),min(Locbc):max(Locbc)) ; 
Moray_smap_lon_02 = lon(min(Locbr):max(Locbr),min(Locbc):max(Locbc)) ; 

% save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lat_02','Moray_smap_lat_02')
% save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lon_02','Moray_smap_lon_02')

SM_SMAP_moray_array_02 = SM_SMAP_moray_array(:,40:end,:) ;  
VOD_SMAP_moray_array_02 = VOD_SMAP_moray_array(:,40:end,:) ;  
TS_SMAP_moray_array_02 = TS_SMAP_moray_array(:,40:end,:) ;  

 save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lat_02','Moray_smap_lat_02')
 save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lon_02','Moray_smap_lon_02')
 save('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lon_02','Moray_smap_lon_02')




% Compute resolution (assumes uniform spacing)
dlat = abs(Moray_smap_lat_02(2,1) - Moray_smap_lat_02(1,1));
dlon = abs(Moray_smap_lon_02(1,1) - Moray_smap_lon_02(1,2));

lat_centers = Moray_smap_lat_02(:,1) ; 
lon_centers = Moray_smap_lon_02(1,:)' ; 

% Compute edges from centers
lat_edges = [lat_centers - dlat/2; lat_centers(end) + dlat/2];
lon_edges = [lon_centers - dlon/2; lon_centers(end) + dlon/2];

% Compute bounding box (in [south north], [west east] format)
latlim = [min(lat_edges), max(lat_edges)];
lonlim = [min(lon_edges), max(lon_edges)];


% Create referencing object
R = maprefcells(lonlim,latlim, [length(lat_centers), length(lon_centers)]);
% R = georefcells(latlim, lonlim, [length(lat_centers), length(lon_centers)]);

R.ProjectedCRS = projcrs(3410) ; 
% Define filename
filename = 'SMAP_SM_moray_time.tif';

projcrs(6933)

% Save all bands at once
geotiffwrite(filename, flipud(SM_SMAP_moray_array_02),R,'CoordRefSysCode', 3410);



% 'CoordRefSysCode', proj





Moray_smap_lon_cent = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/longitude_centroid') ; 
Moray_smap_lon = h5read(filename,'/Soil_Moisture_Retrieval_Data_AM/longitude') ; 

load('E:\Daten Baur\Matlab files\means_über_zeitreihe\lat.mat.mat')
load('E:\Daten Baur\Matlab files\means_über_zeitreihe\lon.mat.mat')


[Liac, Locbc] = ismember(Moray_smap_lon(1,:),lon(1,:)) ; 
[Liar, Locbr] = ismember(Moray_smap_lat(:,147),lat(:,1)) ;

Locbc(Locbc == 0) = NaN ; 
Locbr(Locbr == 0) = NaN ; 





%%

% Input data
data = SM_SMAP_moray_array_02;

% X (cols) and Y (rows) in meters — pixel centers
% Moray_smap_x = Moray_smap_x(40:end) ; 
x_centers = Moray_smap_x(:)';  % Ensure row vector, size = [1, 147]
y_centers = Moray_smap_y(:);   % Ensure column vector, size = [81, 1]

% Flip data vertically if Y increases (south to north)

    data = flip(data, 1);


% Compute spacing
dx = mean(diff(x_centers));
dy = mean(diff(y_centers));

% Compute pixel edges
x_edges = [x_centers - dx/2, x_centers(end) + dx/2];
y_edges = [y_centers - dy/2; y_centers(end) + dy/2];

% Set spatial limits
xlim = [min(x_edges), max(x_edges)];
ylim = [min(y_edges), max(y_edges)];

% Create spatial reference for projected data
R = maprefcells(xlim, ylim, size(data(:,:,1)));
% R.CellExtentInWorldX = R.CellExtentInWorldY ;
% Set projection (EASE-Grid 2.0 Global)
proj = projcrs(6933);  % EPSG:6933

% Write GeoTIFF (multi-band)
geotiffwrite('SMAP_EASE_SM.tif', data, R, 'CoordRefSysCode', 6933);







%% similar figures but final for publication level


datetime_SMAP_full = datetime('01-Apr-2015'):days(1):datetime('16-Jul-2025') ; 
set(0, 'DefaultAxesFontSize',16)
% set(0,'defaultlinelinewidth',2)
set(0, 'DefaultAxesFontName','Helvetica')
set(0,'DefaultAxesTitleFontWeight','normal')
[Indextime_fire]  = find(datetime('12-Jul-2025') == datetime_SMAP_full) ; 

cd('E:\Daten Baur\Matlab code')
col_L = hex2rgb('808080') ; 
col_L_light = hex2rgb('CDCDCD') ; 

col_C = hex2rgb('3399FF') ;
col_C_light = hex2rgb('80E6FF') ; 

col_X = hex2rgb('FF3333') ;
col_X_light = hex2rgb('FF8080') ; 

cd('E:\Daten Baur\Matlab files\means_über_zeitreihe')
load('Coastlines.mat')
cd('E:\Daten Baur\Matlab code\redblue')
redblue_color = redblue(100) ; 
bam_color = crameri('bam') ;
tokyo_color = crameri('tokyo') ;
imola_color = crameri('imola') ;
cork_color = crameri('cork') ;
batlow_color = crameri('batlow') ;
sminterp = (0.01:0.01:0.6)' ; 
sminterp_zeppe = (linspace(0,1,50))' ; 


load('F:\projects\Dava_wildfire\data\SMAP_processed\SM_SMAP_moray_array')
load('F:\projects\Dava_wildfire\data\SMAP_processed\VOD_SMAP_moray_array')
load('F:\projects\Dava_wildfire\data\SMAP_processed\TS_SMAP_moray_array')
load('F:\projects\Dava_wildfire\data\SMAP_processed\datetime_SMAP_full')

load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lon')
load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lat')

load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_x')
load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_y')

load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lon_cent')
load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lat_cent')


cd('F:\projects\Dava_wildfire\data\burnt_area_effis')
Effis_perimeter = shaperead('Dava_fire_perimeter.shp') ; 
Effis_perimeter_info = shapeinfo('Dava_fire_perimeter.shp');
Effis_CRS = Effis_perimeter_info.CoordinateReferenceSystem ; 
% mapshow(Effis_perimeter, 'DisplayType', 'polygon'); % or 'line', 'point'
% Convert to geographic (lat/lon)
[Effis_lat, Effis_lon] = projinv(Effis_CRS, Effis_perimeter.X, Effis_perimeter.Y);
% geoplot(Effis_lat, Effis_lon);
GADM_admin_boundaries = readgeotable('F:\projects\Dava_wildfire\data\GADM\gadm41_GBR_1.json');   
% geoplot(GADM_admin_boundaries)
GADM_Scotland = GADM_admin_boundaries.Shape(2) ; 
GADM_Scotlandlatlon = geotable2table(GADM_admin_boundaries(2,:),["Lat","Lon"]); 
GADM_GBlatlon = geotable2table(GADM_admin_boundaries(4,:),["Lat","Lon"]); 
GADM_Waleslatlon = geotable2table(GADM_admin_boundaries(3,:),["Lat","Lon"]); 


% indices of 3-4 dava fire pixels
Dava_fire_pixels = {[14, 74], [14 75],[15, 74], [15 75],[14, 76], [14 77], [14 78]} ;



% patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')

Indextime_fire = 3756 ; 


% calculate standardized anomalies
SM_SMAP_zscore_anomaly = (SM_SMAP_moray_array - mean(SM_SMAP_moray_array,3,'omitmissing')) ./ std(SM_SMAP_moray_array,0,3,'omitmissing') ; 
VOD_SMAP_zscore_anomaly = (VOD_SMAP_moray_array - mean(VOD_SMAP_moray_array,3,'omitmissing')) ./ std(VOD_SMAP_moray_array,0,3,'omitmissing') ; 
TS_SMAP_zscore_anomaly = (TS_SMAP_moray_array - mean(TS_SMAP_moray_array,3,'omitmissing')) ./ std(TS_SMAP_moray_array,0,3,'omitmissing') ; 

SM_SMAP_zscore_anomaly(SM_SMAP_zscore_anomaly > 5  | SM_SMAP_zscore_anomaly < -5) = NaN ; 
VOD_SMAP_zscore_anomaly(VOD_SMAP_zscore_anomaly > 5  | VOD_SMAP_zscore_anomaly < -5) = NaN ; 
TS_SMAP_zscore_anomaly(TS_SMAP_zscore_anomaly > 5  | TS_SMAP_zscore_anomaly < -5) = NaN ; 


Dava_SM_SMAP_zscore_anomaly = NaN(7,3760) ; 
Dava_VOD_SMAP_zscore_anomaly = NaN(7,3760) ; 
Dava_TS_SMAP_zscore_anomaly = NaN(7,3760) ; 


% extract standardized anomalies for fire area only
for i = 1:length(Dava_fire_pixels)
    cur_row_col = Dava_fire_pixels{i} ;
    Dava_SM_SMAP_zscore_anomaly(i,:)  =  SM_SMAP_zscore_anomaly(cur_row_col(1),cur_row_col(2),:) ; 
    Dava_VOD_SMAP_zscore_anomaly(i,:) =  VOD_SMAP_zscore_anomaly(cur_row_col(1),cur_row_col(2),:) ; 
    Dava_TS_SMAP_zscore_anomaly(i,:)  =  TS_SMAP_zscore_anomaly(cur_row_col(1),cur_row_col(2),:) ; 

end


save('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly','Dava_SM_SMAP_zscore_anomaly')
save('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP_zscore_anomaly','Dava_VOD_SMAP_zscore_anomaly')
save('F:\projects\Dava_wildfire\data\plotting data\inScotland','inScotland')



% check inpolygon function to mask for scottish pixels #represent
inScotland = inpolygon(Moray_smap_lon_cent, Moray_smap_lat_cent, cell2mat(GADM_Scotlandlatlon.Lon),  cell2mat(GADM_Scotlandlatlon.Lat));

SM_SMAP_zscore_anomaly_Scotland  = SM_SMAP_zscore_anomaly ; 
VOD_SMAP_zscore_anomaly_Scotland = VOD_SMAP_zscore_anomaly ; 
TS_SMAP_zscore_anomaly_Scotland  = TS_SMAP_zscore_anomaly ; 


for i = 1:3760

    dummy_SM  = SM_SMAP_zscore_anomaly_Scotland(:,:,i) ; 
    dummy_VOD = VOD_SMAP_zscore_anomaly_Scotland(:,:,i) ; 
    dummy_TS  = TS_SMAP_zscore_anomaly_Scotland(:,:,i) ; 

    dummy_SM(~inScotland) = NaN ; 
    dummy_VOD(~inScotland) = NaN ; 
    dummy_TS(~inScotland) = NaN ; 

    SM_SMAP_zscore_anomaly_Scotland(:,:,i) = dummy_SM ;
    VOD_SMAP_zscore_anomaly_Scotland(:,:,i) = dummy_VOD ;
    TS_SMAP_zscore_anomaly_Scotland(:,:,i) = dummy_TS ;

i
end

save('F:\projects\Dava_wildfire\data\plotting data\SM_SMAP_zscore_anomaly_Scotland','SM_SMAP_zscore_anomaly_Scotland')
save('F:\projects\Dava_wildfire\data\plotting data\VOD_SMAP_zscore_anomaly_Scotland','VOD_SMAP_zscore_anomaly_Scotland')



%% MAP figure Scotland


Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
h = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , SM_SMAP_zscore_anomaly_Scotland(:,:,Indextime_fire)) ; 
set(h,'LineStyle','none')
shading flat
axes1 = gca ; 
% set(h, 'AlphaData', ~isnan(SM_SMAP_moray_array_zscore(:,10:end,Indextime_fire)))
% set(gca,'YDir','normal') 
hold on
colormap(flipud(redblue_color(50:end,:)) )
clim([-3 -0])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'SM z scores 12-Jul-2025','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6 3])
pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

% news aces for zoom
ax_inset = axes('Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset,'Position',[0.53 0.55 0.3 0.3])
h2 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , SM_SMAP_zscore_anomaly_Scotland(:,:,Indextime_fire)) ; 
set(h2,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset,[57.3 57.56])
xlim(ax_inset,[-4.0 -3.3])
colormap(flipud(redblue_color(50:end,:)) )
clim([-3 -0])% 
pbaspect([range(xlim(ax_inset)) range(ylim(ax_inset)) 1])
ax_inset.XTick = [];
ax_inset.YTick = [];
text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)

saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\SM_zscore_anomalies_map','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\SM_zscore_anomalies_map','png')
close 


save('F:\projects\Dava_wildfire\data\plotting data\SM_SMAP_zscore_anomaly_Scotland','SM_SMAP_zscore_anomaly_Scotland')
save('F:\projects\Dava_wildfire\data\plotting data\VOD_SMAP_zscore_anomaly','VOD_SMAP_zscore_anomaly')



%%%%%%%%%%%%%%% VOD %%%%%%%%%%%%%%%%%%%%%
Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
h = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , VOD_SMAP_zscore_anomaly(:,:,Indextime_fire)) ; 
set(h,'LineStyle','none')
shading flat
axes1 = gca ; 
% set(h, 'AlphaData', ~isnan(SM_SMAP_moray_array_zscore(:,10:end,Indextime_fire)))
% set(gca,'YDir','normal') 
hold on
colormap(flipud(redblue_color) )
clim([-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'VOD z scores 12-Jul-2025','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6 3])
pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.5 57 -3--4.5 58-57])

% news aces for zoom
ax_inset = axes('Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset,'Position',[0.53 0.55 0.3 0.3])
h2 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , VOD_SMAP_zscore_anomaly(:,:,Indextime_fire)) ; 
set(h2,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset,[57 58])
xlim(ax_inset,[-4.5 -3])
colormap(flipud(redblue_color) )
clim([-2 2])% 
pbaspect([range(xlim(ax_inset)) range(ylim(ax_inset)) 1])
ax_inset.XTick = [];
ax_inset.YTick = [];

saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\VOD_zscore_anomalies_map','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\VOD_zscore_anomalies_map','png')
close 




%%%%%%%%%%%%%%% TS %%%%%%%%%%%%%%%%%%%%%
Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
h = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , TS_SMAP_zscore_anomaly_Scotland(:,:,Indextime_fire)) ; 
set(h,'LineStyle','none')
shading flat
axes1 = gca ; 
% set(h, 'AlphaData', ~isnan(SM_SMAP_moray_array_zscore(:,10:end,Indextime_fire)))
% set(gca,'YDir','normal') 
hold on
colormap((redblue_color(50:end,:)) )
clim([0 3])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'Ts z scores 12-Jul-2025','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6 3])
pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.5 57 -3--4.5 58-57])

% news aces for zoom
ax_inset = axes('Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset,'Position',[0.53 0.55 0.3 0.3])
h2 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , TS_SMAP_zscore_anomaly_Scotland(:,:,Indextime_fire)) ; 
set(h2,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset,[57 58])
xlim(ax_inset,[-4.5 -3])
colormap((redblue_color(50:end,:)) )
clim([0 3])% 
pbaspect([range(xlim(ax_inset)) range(ylim(ax_inset)) 1])
ax_inset.XTick = [];
ax_inset.YTick = [];

saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\TS_zscore_anomalies_map_02','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\TS_zscore_anomalies_map_02','png')
close 



%% Distribution plots of anomalies. Fit pdfs
load('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly')
load('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP_zscore_anomaly')




[fSM,xiSM]   = ksdensity(Dava_SM_SMAP_zscore_anomaly(:),linspace(-5,5,1000)) ; 
[fVOD,xiVOD] = ksdensity(Dava_VOD_SMAP_zscore_anomaly(:),linspace(-5,5,1000)) ; 
% [fTS,xiTS]   = ksdensity(TS_SMAP_zscore_anomaly_Scotland(:),linspace(-5,5,1000)) ; 

Jun_2025 = datetime_SMAP_full > datetime('01-Jan-2025')  ; 

SM_SMAP_zscore_anomaly_Scotland_spring = Dava_SM_SMAP_zscore_anomaly(:,Jun_2025) ; 
VOD_SMAP_zscore_anomaly_Scotland_spring = Dava_VOD_SMAP_zscore_anomaly(:,Jun_2025) ; 
% TS_SMAP_zscore_anomaly_Scotland_spring = TS_SMAP_zscore_anomaly_Scotland(:,:,Spring_2025) ; 


[fSMspringJan,xiSMspring]   = ksdensity(SM_SMAP_zscore_anomaly_Scotland_spring(:),linspace(-5,5,1000)) ; 
[fVODspringJan,xiVODspring] = ksdensity(VOD_SMAP_zscore_anomaly_Scotland_spring(:),linspace(-5,5,1000)) ; 
% [fTSspring,xiTSspring]   = ksdensity(TS_SMAP_zscore_anomaly_Scotland_spring(:),linspace(-5,5,1000)) ; 





save('F:\projects\Dava_wildfire\data\plotting data\fSM','fSM')
save('F:\projects\Dava_wildfire\data\plotting data\fVOD','fVOD')


save('F:\projects\Dava_wildfire\data\plotting data\fSMspringJan','fSMspringJan')
save('F:\projects\Dava_wildfire\data\plotting data\fVODspringJan','fVODspringJan')



%%%%%%%%%%%% SM %%%%%%%%%%%%%%%
Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
plot(linspace(-5,5,1000),fSM,'Color',col_C,'LineWidth',3)
hold on
plot(linspace(-5,5,1000),fSMspring,'Color',col_L,'LineWidth',3)

xlabel('SM z-scores [-]','FontSize',16)
ylabel('count','FontSize',16)
xline(median(Dava_SM_SMAP_zscore_anomaly(:,Indextime_fire),[1],'omitnan'),'Color',col_X,'LineWidth',2)
legend('SM Apr 2015 - July 2025','SM Jan 2025 - July 2025','SM fire perimeter 12th of July 2025')
fontsize(14,'points')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\SM_zscore_anomalies_hist','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\SM_zscore_anomalies_hist','png')
close


%%%%%%%%%%%% VOD %%%%%%%%%%%%%%%
Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
plot(linspace(-5,5,1000),fVOD,'Color',col_C,'LineWidth',3)
hold on
plot(linspace(-5,5,1000),fVODspring,'Color',col_L,'LineWidth',3)

xlabel('VOD z-scores [-]','FontSize',16)
ylabel('count','FontSize',16)
xline(median(Dava_VOD_SMAP_zscore_anomaly(:,Indextime_fire),[1],'omitnan'),'Color',col_X,'LineWidth',2)
legend('VOD Apr 2015 - July 2025','VOD Jan 2025 - July 2025','VOD fire perimeter 12th of July 2025')
fontsize(14,'points')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\VOD_zscore_anomalies_hist','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\VOD_zscore_anomalies_hist','png')
close

%%%%%%%%%%%% TS %%%%%%%%%%%%%%%
Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
plot(linspace(-5,5,1000),fTS,'Color',col_C,'LineWidth',3)
hold on
plot(linspace(-5,5,1000),fTSspring,'Color',col_L,'LineWidth',3)

xlabel('TS z-scores [-]','FontSize',16)
ylabel('count','FontSize',16)
xline(median(Dava_TS_SMAP_zscore_anomaly(:,Indextime_fire),[1],'omitnan'),'Color',col_X,'LineWidth',2)
legend('TS Apr 2015 - July 2025','TS Jan 2025 - July 2025','TS fire perimeter 12th of July 2025')
fontsize(14,'points')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\TS_zscore_anomalies_hist','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\TS_zscore_anomalies_hist','png')
close



% save layers for plotting eventually
save('F:\projects\Dava_wildfire\data\plotting data\fSM','fSM')
save('F:\projects\Dava_wildfire\data\plotting data\fVOD','fVOD')
save('F:\projects\Dava_wildfire\data\plotting data\fSMspring','fSMspring')
save('F:\projects\Dava_wildfire\data\plotting data\fVODspring','fVODspring')










%% timeline plots
% movmean(SM_SMAP_moray_array_zscore_sample,60,3,'omitnan') ; 

Dava_SM_SMAP_zscore_anomaly_median =   squeeze(median(movmean(Dava_SM_SMAP_zscore_anomaly,60,2,'omitnan'),[1],'omitnan')) ;
Dava_SM_SMAP_zscore_anomaly_25 =       squeeze(prctile(movmean(Dava_SM_SMAP_zscore_anomaly,60,2,'omitnan'),25,[1])) ; 
Dava_SM_SMAP_zscore_anomaly_75 =       squeeze(prctile(movmean(Dava_SM_SMAP_zscore_anomaly,60,2,'omitnan'),75,[1])) ; 

Dava_VOD_SMAP_zscore_anomaly_median_m =   squeeze(median(movmean(Dava_VOD_SMAP_zscore_anomaly,60,2,'omitnan'),[1],'omitnan')) ;
Dava_VOD_SMAP_zscore_anomaly_25 =       squeeze(prctile(movmean(Dava_VOD_SMAP_zscore_anomaly,60,2,'omitnan'),25,[1])) ; 
Dava_VOD_SMAP_zscore_anomaly_75 =       squeeze(prctile(movmean(Dava_VOD_SMAP_zscore_anomaly,60,2,'omitnan'),75,[1])) ; 

Dava_TS_SMAP_zscore_anomaly_median =   squeeze(median(movmean(Dava_TS_SMAP_zscore_anomaly,60,2,'omitnan'),[1],'omitnan')) ;
Dava_TS_SMAP_zscore_anomaly_25 =       squeeze(prctile(movmean(Dava_TS_SMAP_zscore_anomaly,60,2,'omitnan'),25,[1])) ; 
Dava_TS_SMAP_zscore_anomaly_75 =       squeeze(prctile(movmean(Dava_TS_SMAP_zscore_anomaly,60,2,'omitnan'),75,[1])) ; 


load('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly_median')
load('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly_25')
load('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly_75')

load('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP_zscore_anomaly_median')
load('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP_zscore_anomaly_25')
load('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP_zscore_anomaly_75')







% YM = dateshift(datetime_SMAP_full(:),'start','month');
% [G, unique_months] = findgroups(YM);
% Start and end of each month
startMonth = dateshift(datetime_SMAP_full(:), 'start', 'month');
endMonth   = dateshift(datetime_SMAP_full(:), 'end', 'month');
% Middle of each month = halfway between start and end
midMonthDates = startMonth + days(days(endMonth - startMonth) / 2);
midMonthDates_unique = unique(midMonthDates) ; 

[yall mall dall] = ymd(datetime_SMAP_full) ; 


Dava_SM_SMAP_zscore_anomaly_median_m = NaN([1 124]) ; 
Dava_SM_SMAP_zscore_anomaly_25_m = NaN([1 124]) ; 
Dava_SM_SMAP_zscore_anomaly_75_m = NaN([1 124]) ; 
Dava_VOD_SMAP_zscore_anomaly_median_m = NaN([1 124]) ;

for i = 1:length(midMonthDates_unique)

    [y m d] = ymd(midMonthDates_unique(i)) ; 
    [Lia Locb] = find(yall == y & mall == m) ; 

    Dava_SM_SMAP_zscore_anomaly_median_m(:,i) = median(Dava_SM_SMAP_zscore_anomaly(:,Locb),[1 2],'omitnan')  ; 
    Dava_SM_SMAP_zscore_anomaly_25_m(:,i) = prctile(Dava_SM_SMAP_zscore_anomaly(:,Locb),25,[1 2])  ;     
    Dava_SM_SMAP_zscore_anomaly_75_m(:,i) = prctile(Dava_SM_SMAP_zscore_anomaly(:,Locb),75,[1 2])  ; 
    Dava_VOD_SMAP_zscore_anomaly_median_m(:,i) = median(Dava_VOD_SMAP_zscore_anomaly(:,Locb),[1 2],'omitnan')  ;     

i
end

midMonthDates_unique = midMonthDates_unique' ; 


save('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly_median_m','Dava_SM_SMAP_zscore_anomaly_median_m')
save('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP_zscore_anomaly_median_m','Dava_VOD_SMAP_zscore_anomaly_median_m')

save('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly_25_m','Dava_SM_SMAP_zscore_anomaly_25_m')
save('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly_75_m','Dava_SM_SMAP_zscore_anomaly_75_m')
save('F:\projects\Dava_wildfire\data\plotting data\midMonthDates_unique','midMonthDates_unique')




%%%%%%%%%%%%%% SM %%%%%%%%%%%%%%
Fig_Panel = figure('units','centimeters','position',[10 2 33 18])  ;
linepre = plot(midMonthDates_unique,Dava_SM_SMAP_zscore_anomaly_median_m,'-','LineWidth',1,'Color','k') ;
hold on
yline(Dava_SM_SMAP_zscore_anomaly_median_m(end),'-r','LineWidth',2)
hold on
x2 = [midMonthDates_unique, fliplr(midMonthDates_unique)];
inBetween = [Dava_SM_SMAP_zscore_anomaly_median_m, fliplr(Dava_SM_SMAP_zscore_anomaly_25_m ) ];
fillpre = fill(x2, inBetween, col_C,'FaceAlpha',0.25);
x2 = [midMonthDates_unique, fliplr(midMonthDates_unique)];
inBetween = [Dava_SM_SMAP_zscore_anomaly_median_m, fliplr(Dava_SM_SMAP_zscore_anomaly_75_m)];
fill(x2, inBetween, col_C,'FaceAlpha',0.25);
plot(midMonthDates_unique,Dava_SM_SMAP_zscore_anomaly_median_m,'-','LineWidth',1,'Color','k')
ylim([-2 2])
line25 = plot(midMonthDates_unique,Dava_SM_SMAP_zscore_anomaly_25_m,'-','LineWidth',1,'Color','k') ;
line75 = plot(midMonthDates_unique,Dava_SM_SMAP_zscore_anomaly_75_m,'-','LineWidth',1,'Color','k') ;

%kolsmi_post = plot(sminterp(pre_index),prct_50,'','MarkerSize',15) ;
legend('SM median anomaly','anomaly at fire time')
xlabel('Time','FontSize',16)
ylabel('SMAP SM zscores fire perimeter','FontSize',16)
fontsize(16,'points')

saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\SM_zscore_anomalies_ts','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\SM_zscore_anomalies_ts','png')
close



%%%%%%%%%%%%%% VOD %%%%%%%%%%%%%%
Fig_Panel = figure('units','centimeters','position',[10 2 33 18])  ;
linepre = plot(datetime_SMAP_full,Dava_VOD_SMAP_zscore_anomaly_median_m,'-','LineWidth',1,'Color','k') ;
hold on
yline(Dava_VOD_SMAP_zscore_anomaly_median_m(end),'-r','LineWidth',2)
hold on
x2 = [datetime_SMAP_full, fliplr(datetime_SMAP_full)];
inBetween = [Dava_VOD_SMAP_zscore_anomaly_median_m, fliplr(Dava_VOD_SMAP_zscore_anomaly_25 ) ];
fillpre = fill(x2, inBetween, col_C,'FaceAlpha',0.25);
x2 = [datetime_SMAP_full, fliplr(datetime_SMAP_full)];
inBetween = [Dava_VOD_SMAP_zscore_anomaly_median_m, fliplr(Dava_VOD_SMAP_zscore_anomaly_75)];
fill(x2, inBetween, col_C,'FaceAlpha',0.25);
plot(datetime_SMAP_full,Dava_VOD_SMAP_zscore_anomaly_median_m,'-','LineWidth',1,'Color','k')
ylim([-2 2])
line25 = plot(datetime_SMAP_full,Dava_VOD_SMAP_zscore_anomaly_25,'-','LineWidth',1,'Color','k') ;
line75 = plot(datetime_SMAP_full,Dava_VOD_SMAP_zscore_anomaly_75,'-','LineWidth',1,'Color','k') ;

%kolsmi_post = plot(sminterp(pre_index),prct_50,'','MarkerSize',15) ;
legend('VOD median anomaly','anomaly at fire time')
xlabel('Time','FontSize',16)
ylabel('SMAP VOD zscores fire perimeter','FontSize',16)
fontsize(16,'points')

saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\VOD_zscore_anomalies_ts','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\VOD_zscore_anomalies_ts','png')
close




%%%%%%%%%%%%%% TS %%%%%%%%%%%%%%
Fig_Panel = figure('units','centimeters','position',[10 2 33 18])  ;
linepre = plot(datetime_SMAP_full,Dava_TS_SMAP_zscore_anomaly_median,'-','LineWidth',1,'Color','k') ;
hold on
yline(Dava_TS_SMAP_zscore_anomaly_median(end),'-r','LineWidth',2)
hold on
x2 = [datetime_SMAP_full, fliplr(datetime_SMAP_full)];
inBetween = [Dava_TS_SMAP_zscore_anomaly_median, fliplr(Dava_TS_SMAP_zscore_anomaly_25 ) ];
fillpre = fill(x2, inBetween, col_C,'FaceAlpha',0.25);
x2 = [datetime_SMAP_full, fliplr(datetime_SMAP_full)];
inBetween = [Dava_TS_SMAP_zscore_anomaly_median, fliplr(Dava_TS_SMAP_zscore_anomaly_75)];
fill(x2, inBetween, col_C,'FaceAlpha',0.25);
plot(datetime_SMAP_full,Dava_TS_SMAP_zscore_anomaly_median,'-','LineWidth',1,'Color','k')
ylim([-2 2])
line25 = plot(datetime_SMAP_full,Dava_TS_SMAP_zscore_anomaly_25,'-','LineWidth',1,'Color','k') ;
line75 = plot(datetime_SMAP_full,Dava_TS_SMAP_zscore_anomaly_75,'-','LineWidth',1,'Color','k') ;

%kolsmi_post = plot(sminterp(pre_index),prct_50,'','MarkerSize',15) ;
legend('TS median anomaly','anomaly at fire time')
xlabel('Time','FontSize',16)
ylabel('SMAP TS zscores fire perimeter','FontSize',16)
fontsize(16,'points')

saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\TS_zscore_anomalies_ts','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\TS_zscore_anomalies_ts','png')
close


%%
load('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly_median_m')
load('F:\projects\Dava_wildfire\data\plotting data\midMonthDates_unique')




% interpolate datasets to get better performance of fill
Dava_SM_SMAP_zscore_anomaly_median_m = interp1(Dava_SM_SMAP_zscore_anomaly_median_m,linspace(1,124,1000)) ; 
midMonthDates_unique = linspace(midMonthDates_unique(1),midMonthDates_unique(end),1000) ; 

%%%%%%%%%%%%%% SM %%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[10 2 33 18])  ;

% Plot the anomaly line
plot(midMonthDates_unique, Dava_SM_SMAP_zscore_anomaly_median_m, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Dava_SM_SMAP_zscore_anomaly_median_m(midMonthDates_unique > datetime('01-Jun-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Dava_SM_SMAP_zscore_anomaly_median_m;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [midMonthDates_unique, fliplr(Hadgrid_time_monthly)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Dava_SM_SMAP_zscore_anomaly_median_m;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-2 2])
xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('Soil moisture anomaly','FontSize',16)
fontsize(18,'points')
grid on;

saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\SM_zscore_anomalies_ts_shade','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\SM_zscore_anomalies_ts_shade','png')
close






% interpolate datasets to get better performance of fill
Dava_VOD_SMAP_zscore_anomaly_median_m = interp1(Dava_VOD_SMAP_zscore_anomaly_median_m,linspace(1,124,1000)) ; 
midMonthDates_unique = linspace(midMonthDates_unique(1),midMonthDates_unique(end),1000) ; 

%%%%%%%%%%%%%% VOD %%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[10 2 33 18])  ;

% Plot the anomaly line
plot(midMonthDates_unique, Dava_VOD_SMAP_zscore_anomaly_median_m, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Dava_VOD_SMAP_zscore_anomaly_median_m(midMonthDates_unique > datetime('01-Jun-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Dava_VOD_SMAP_zscore_anomaly_median_m;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [midMonthDates_unique, fliplr(Hadgrid_time_monthly)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Dava_VOD_SMAP_zscore_anomaly_median_m;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-2 2])
xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('VOD anomaly','FontSize',16)
fontsize(18,'points')
grid on;

saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\VOD_zscore_anomalies_ts_shade','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\VOD_zscore_anomalies_ts_shade','png')
close









%% Aggregate SM and VOD to monthly to then get anomalies from monthly mean
clear

datetime_SMAP_full = datetime('01-Apr-2015'):days(1):datetime('16-Jul-2025') ; 
% YM = dateshift(datetime_SMAP_full(:),'start','month');
% [G, unique_months] = findgroups(YM);
% Start and end of each month
startMonth = dateshift(datetime_SMAP_full(:), 'start', 'month');
endMonth   = dateshift(datetime_SMAP_full(:), 'end', 'month');
% Middle of each month = halfway between start and end
midMonthDates = startMonth + days(days(endMonth - startMonth) / 2);
midMonthDates_unique = unique(midMonthDates) ; 
load('F:\projects\Dava_wildfire\data\plotting data\inScotland.mat')
load('F:\projects\Dava_wildfire\data\SMAP_processed\SM_SMAP_moray_array')
load('F:\projects\Dava_wildfire\data\SMAP_processed\VOD_SMAP_moray_array')


SM_SMAP_Scotland_array = NaN(size(SM_SMAP_moray_array)) ; 
VOD_SMAP_Scotland_array = NaN(size(SM_SMAP_moray_array)) ; 
for i = 1:3760
    dummy_SM  = SM_SMAP_moray_array(:,:,i) ; 
    dummy_VOD = VOD_SMAP_moray_array(:,:,i) ; 

    dummy_SM(~inScotland) = NaN ; 
    dummy_VOD(~inScotland) = NaN ; 

    SM_SMAP_Scotland_array(:,:,i) = dummy_SM ;
    VOD_SMAP_Scotland_array(:,:,i) = dummy_VOD ;
i
end

save('F:\projects\Dava_wildfire\data\plotting data\SM_SMAP_Scotland_array','SM_SMAP_Scotland_array')
save('F:\projects\Dava_wildfire\data\plotting data\VOD_SMAP_Scotland_array','VOD_SMAP_Scotland_array')


% indices of 3-4 dava fire pixels
Dava_fire_pixels = {[14, 74], [14 75],[15, 74], [15 75],[14, 76], [14 77], [14 78]} ;
Dava_SM_SMAP = NaN(7,3760) ; 
Dava_VOD_SMAP = NaN(7,3760) ; 


% extract standardized anomalies for fire area only
for i = 1:length(Dava_fire_pixels)
    cur_row_col = Dava_fire_pixels{i} ;
    Dava_SM_SMAP(i,:)  =  SM_SMAP_moray_array(cur_row_col(1),cur_row_col(2),:) ; 
    Dava_VOD_SMAP(i,:) =  VOD_SMAP_moray_array(cur_row_col(1),cur_row_col(2),:) ; 
 
end

save('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP','Dava_SM_SMAP')
save('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP','Dava_VOD_SMAP')



[yall mall dall] = ymd(datetime_SMAP_full) ; 

Dava_SM_SMAP_m = NaN([7 124]) ; 
Dava_VOD_SMAP_m = NaN([7 124]) ; 
SM_SMAP_Scotland_array_m = NaN([81 147 124]) ; 
VOD_SMAP_Scotland_array_m = NaN([81 147 124]) ; 


for i = 1:length(midMonthDates_unique)

    [y m d] = ymd(midMonthDates_unique(i)) ; 
    [Lia Locb] = find(yall == y & mall == m) ; 

    Dava_SM_SMAP_m(:,i) = median(Dava_SM_SMAP(:,Locb),[2],'omitnan')  ; 
    Dava_VOD_SMAP_m(:,i) = median(Dava_VOD_SMAP(:,Locb),[2],'omitnan')  ;     

    SM_SMAP_Scotland_array_m(:,:,i) =  median(SM_SMAP_Scotland_array(:,:,Locb),[3],'omitnan')  ; 
    VOD_SMAP_Scotland_array_m(:,:,i) = median(VOD_SMAP_Scotland_array(:,:,Locb),[3],'omitnan')  ;     

i
end


midMonthDates_unique = midMonthDates_unique' ; 


save('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_m','Dava_SM_SMAP_m')
save('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP_m','Dava_VOD_SMAP_m')
save('F:\projects\Dava_wildfire\data\plotting data\SM_SMAP_Scotland_array_m','SM_SMAP_Scotland_array_m')
save('F:\projects\Dava_wildfire\data\plotting data\VOD_SMAP_Scotland_array_m','VOD_SMAP_Scotland_array_m')


% now convert them to anomalies but relative to monthly mean


[ydummyall mdummyall ddummyall] = ymd(midMonthDates_unique) ; 

Dava_SM_SMAP_m_zscore_relm = NaN(size(Dava_SM_SMAP_m)) ; 
Dava_VOD_SMAP_m_zscore_relm = NaN(size(Dava_SM_SMAP_m)) ; 
Scotland_SM_SMAP_m_zscore_relm = NaN(size(SM_SMAP_Scotland_array_m)) ; 
Scotland_VOD_SMAP_m_zscore_relm = NaN(size(SM_SMAP_Scotland_array_m)) ; 


for i = 1:length(midMonthDates_unique)

    dummy_date = midMonthDates_unique(i) ; 
    [ydummy mdummy ddummy] = ymd(dummy_date) ; 
    [Lia Locb] = find(mdummy == mdummyall) ; 

    SM_monthly_mean = mean(Dava_SM_SMAP_m(:,Locb),2,'omitnan') ;
    SM_monthly_std =  std(Dava_SM_SMAP_m(:,Locb),1,2,'omitnan') ;
    VOD_monthly_mean = mean(Dava_VOD_SMAP_m(:,Locb),2,'omitnan') ;
    VOD_monthly_std =  std(Dava_VOD_SMAP_m(:,Locb),1,2,'omitnan') ;


    Dava_SM_SMAP_m_zscore_relm(:,i) = (Dava_SM_SMAP_m(:,i) - SM_monthly_mean) ./ SM_monthly_std ;
    Dava_VOD_SMAP_m_zscore_relm(:,i) = (Dava_VOD_SMAP_m(:,i) - VOD_monthly_mean) ./ VOD_monthly_std ;

    SM_monthly_mean = mean(SM_SMAP_Scotland_array_m(:,:,Locb),3,'omitnan') ;
    SM_monthly_std =  std(SM_SMAP_Scotland_array_m(:,:,Locb),1,3,'omitnan') ;
    VOD_monthly_mean = mean(VOD_SMAP_Scotland_array_m(:,:,Locb),3,'omitnan') ;
    VOD_monthly_std =  std(VOD_SMAP_Scotland_array_m(:,:,Locb),1,3,'omitnan') ;

    Scotland_SM_SMAP_m_zscore_relm(:,:,i) = (SM_SMAP_Scotland_array_m(:,:,i) - SM_monthly_mean) ./ SM_monthly_std ;
    Scotland_VOD_SMAP_m_zscore_relm(:,:,i) = (VOD_SMAP_Scotland_array_m(:,:,i) - VOD_monthly_mean) ./ SM_monthly_std ;


end


save('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_m_zscore_relm','Dava_SM_SMAP_m_zscore_relm')
save('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP_m_zscore_relm','Dava_VOD_SMAP_m_zscore_relm')
save('F:\projects\Dava_wildfire\data\plotting data\Scotland_SM_SMAP_m_zscore_relm','Scotland_SM_SMAP_m_zscore_relm')
save('F:\projects\Dava_wildfire\data\plotting data\Scotland_VOD_SMAP_m_zscore_relm','Scotland_VOD_SMAP_m_zscore_relm')



histogram(Scotland_SM_SMAP_m_zscore_relm )


