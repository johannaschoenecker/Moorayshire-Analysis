%% Morayshire, Dava fire final plot for climatic extremes, SM and precip

clear 

load('F:\Met_Office_Had_UK\processed\Hadgrid_rain_1km_anomaly_Scotland.mat')
load('F:\Met_Office_Had_UK\processed\Met_Hadgrid_1km_lat.mat')
load('F:\Met_Office_Had_UK\processed\Met_Hadgrid_1km_lon.mat')
load('F:\Met_Office_Had_UK\processed\Hadgrid_time_monthly.mat')

load('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly_median_m')
load('F:\projects\Dava_wildfire\data\plotting data\midMonthDates_unique')

load('F:\Met_Office_Had_UK\processed\Hadgrid_rain_1km_anomaly_Dava.mat')
load('F:\Met_Office_Had_UK\processed\Hadgrid_rain_1km_monthly.mat')


load('F:\projects\Dava_wildfire\data\SMAP_processed\SM_SMAP_moray_array')
load('F:\projects\Dava_wildfire\data\SMAP_processed\VOD_SMAP_moray_array')
load('F:\projects\Dava_wildfire\data\SMAP_processed\datetime_SMAP_full')

load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lon_cent')
load('F:\projects\Dava_wildfire\data\SMAP_processed\Moray_smap_lat_cent')

load('F:\projects\Dava_wildfire\data\plotting data\SM_SMAP_zscore_anomaly_Scotland')
load('F:\projects\Dava_wildfire\data\plotting data\VOD_SMAP_zscore_anomaly')

load('F:\projects\Dava_wildfire\data\SMAP_processed\datetime_SMAP_full.mat')


load('F:\projects\Dava_wildfire\data\plotting data\fSM')
load('F:\projects\Dava_wildfire\data\plotting data\fVOD')
load('F:\projects\Dava_wildfire\data\plotting data\fSMspring')
load('F:\projects\Dava_wildfire\data\plotting data\fVODspring')
load('F:\projects\Dava_wildfire\data\plotting data\fSMspringJan')
load('F:\projects\Dava_wildfire\data\plotting data\fVODspringJan')


load('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_zscore_anomaly.mat')
load('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP_zscore_anomaly_median_m.mat')


load('F:\projects\Dava_wildfire\data\plotting data\fP')
load('F:\projects\Dava_wildfire\data\plotting data\fP_Jun')


%%%%%%%%%%%%%%%%%%%%% anomalies relative to monthly mean %%%%%%%%%%%%%%%%%%








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
cd('E:\Daten Baur\Matlab code\redblue')
redblue_color = redblue(100) ; 
bam_color = crameri('bam') ;
tokyo_color = crameri('tokyo') ;
imola_color = crameri('imola') ;
cork_color = crameri('cork') ;
batlow_color = crameri('batlow') ;

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





Dava_SM_SMAP_zscore_anomaly_median_m_interp = interp1(Dava_SM_SMAP_zscore_anomaly_median_m,linspace(1,124,1000)) ; 
midMonthDates_unique_interp = linspace(midMonthDates_unique(1),midMonthDates_unique(end),1000) ; 


Dava_VOD_SMAP_zscore_anomaly_median_m_interp = interp1(Dava_VOD_SMAP_zscore_anomaly_median_m,linspace(1,124,1000)) ; 


Hadgrid_rain_1km_anomaly_Dava_median = squeeze(median(Hadgrid_rain_1km_anomaly_Dava,[1 2],'omitnan')) ; 
Hadgrid_rain_1km_anomaly_Dava_25 = squeeze(prctile(Hadgrid_rain_1km_anomaly_Dava,25,[1 2])) ; 
Hadgrid_rain_1km_anomaly_Dava_75 = squeeze(prctile(Hadgrid_rain_1km_anomaly_Dava,75,[1 2])) ; 

% interpolate datasets to get better performance of fill
Hadgrid_rain_1km_anomaly_Dava_median_interp = interp1(Hadgrid_rain_1km_anomaly_Dava_median,linspace(1,127,1000)) ; 
Hadgrid_time_monthly_interp = linspace(Hadgrid_time_monthly(1),Hadgrid_time_monthly(end),1000) ; 






%%


Fig_Panel = figure('units','centimeters','position',[5 2 40 22])  ;
Fig_width = 40 ; 
 Fig_height = 22 ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 1  SM map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub1 = subplot(2,3,1) ; 
xmap = median(SM_SMAP_zscore_anomaly_Scotland(:,:,datetime_SMAP_full > datetime('01-Jun-2025')),3,'omitnan') ; 
h1 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent ,xmap) ; 
set(h1,'LineStyle','none')
shading flat
axes1 = gca ; 
hold on
% colormap(axes1,flipud(redblue_color(50:end,:)) )
colormap(axes1,flipud(redblue_color(:,:)) )
clim(sub1,[-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('','FontSize',16)
xticks([])
ylabel('latitude','FontSize',16)
ylabel(hcb2,'SM anomaly [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6 3])
% pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub1,'units','centimeter','position',  [2, 12 , 9*1.5, 6*1.5])

% news aces for zoom
ax_inset1 = axes('units','centimeters','Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset1,'units','centimeters','Position',[8.7, 16.5, 6, 6])
h12 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , xmap) ; 
set(h12,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset1,[57.3 57.56])
xlim(ax_inset1,[-4.0 -3.3])
% colormap(ax_inset1,flipud(redblue_color(50:end,:)) )
 colormap(ax_inset1,flipud(redblue_color(:,:)) )
clim(ax_inset1,[-2 2])% 
pbaspect([range(xlim(ax_inset1)) range(ylim(ax_inset1)) 1])
ax_inset1.XTick = [];
ax_inset1.YTick = [];
% text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 2  Precip map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xmap = median(Hadgrid_rain_1km_anomaly_Scotland(:,:,Hadgrid_time_monthly > datetime('01-Jun-2025')),3,'omitnan') ; 
sub2 = subplot(2,3,2) ; 
h2 = pcolor(Met_Hadgrid_1km_lon, Met_Hadgrid_1km_lat , xmap) ; 
set(h2,'LineStyle','none')
shading flat
axes2 = gca ; 
hold on
% colormap(flipud(redblue_color(50:end,:)) )
colormap(axes2,flipud(redblue_color))
clim([-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'P anomaly [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes2,[54 60])
xlim(axes2,[-6 3])
% pbaspect([range(xlim(axes2)) range(ylim(axes2)) 1])
rectangle(axes2,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub2,'units','centimeter','position',  [2, 2 , 9*1.5, 6*1.5])


% news aces for zoom
ax_inset2 = axes('Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset2,'units','centimeters','Position',[8.7, 6.5, 6, 6])
h21 = pcolor(Met_Hadgrid_1km_lon, Met_Hadgrid_1km_lat , xmap) ; 
set(h21,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset2,[57.3 57.56])
xlim(ax_inset2,[-4.0 -3.3])
colormap(ax_inset2,flipud(redblue_color) )
clim([-2 2])% 
pbaspect([range(xlim(ax_inset2)) range(ylim(ax_inset2)) 1])
ax_inset2.XTick = [];
ax_inset2.YTick = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 3  SM anomaly timseries %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sub3 = subplot(2,3,3) ; 

% Plot the anomaly line
plot(midMonthDates_unique_interp, Dava_SM_SMAP_zscore_anomaly_median_m_interp, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Dava_SM_SMAP_zscore_anomaly_median_m_interp(midMonthDates_unique_interp > datetime('01-Jun-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Dava_SM_SMAP_zscore_anomaly_median_m_interp;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [midMonthDates_unique_interp, fliplr(midMonthDates_unique_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Dava_SM_SMAP_zscore_anomaly_median_m_interp;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-2 2])
xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('SM anomaly','FontSize',16)

grid on;

set(sub3,'units','centimeter','position',  [21, 17 , 18, 3])




%%%%%%%%%%%%%%%%%% SUb 4 time series rianfall anomaly %%%%%%%%%%%%%%%%%%%%
sub4 = subplot(2,3,5) ; 


% Plot the anomaly line
plot(sub4,Hadgrid_time_monthly_interp, Hadgrid_rain_1km_anomaly_Dava_median_interp, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(median(Hadgrid_rain_1km_anomaly_Dava_median_interp(Hadgrid_time_monthly_interp > datetime('01-Jun-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Hadgrid_rain_1km_anomaly_Dava_median_interp;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [Hadgrid_time_monthly_interp, fliplr(Hadgrid_time_monthly_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(sub4,x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Hadgrid_rain_1km_anomaly_Dava_median_interp;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(sub4,x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('P anomaly','FontSize',16)
grid on;

set(sub4,'units','centimeter','position',  [21, 7 , 18, 3])




%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 5  SM anomaly histogram %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sub5 = subplot(2,3,5) ; 

plot(sub5,linspace(-5,5,1000),fSM,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub5,linspace(-5,5,1000),fSMspring,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('SM anomaly [-]','FontSize',16)
ylabel('count','FontSize',16)
xline(sub5,median(Dava_SM_SMAP_zscore_anomaly(:,datetime_SMAP_full > datetime('01-Jun-2025')),[2 1],'omitnan'),'Color',col_X,'LineWidth',2)
legend('2015-2025','> 01-Jun-2025','fire time')

set(sub5,'units','centimeter','position',  [21, 12 , 18, 3])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 6  rain anomaly histogram %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sub6 = subplot(2,3,6) ; 

plot(sub6,linspace(-5,5,1000),fP,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub6,linspace(-5,5,1000),fP_Jun,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('P anomaly [-]','FontSize',16)
ylabel('count','FontSize',16)
precip_anomaly_dava_dummmy = median(Hadgrid_rain_1km_anomaly_Dava(:,:,Hadgrid_time_monthly > datetime('01-Jun-2025')),[2 1 ],'omitnan') ;
xline(sub6,precip_anomaly_dava_dummmy(1),'Color',col_X,'LineWidth',2)
legend('2015-2025','> 01-Jun-2025','fire time')
set(sub6,'units','centimeter','position',  [21, 2 , 18, 3])

fontsize(14,'points')


set(sub3,'units','centimeter','position',  [21, 17.5 , 18, 3])
set(sub4,'units','centimeter','position',  [21, 7.5 , 18, 3])
set(sub5,'units','centimeter','position',  [21, 12.5 , 18, 3])
set(sub6,'units','centimeter','position',  [21, 2.5 , 18, 3])




saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\SM_and_Precip_Panel02','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\SM_and_Precip_Panel02','png')
close




%%  Just SM 


[Indextime_fire]  = find(datetime('12-Jul-2025') > datetime_SMAP_full & datetime('28-Jun-2025') < datetime_SMAP_full) ; 



%%%%%%%%%%%%%%%%%%% SUb 1 %%%%%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[5 2 30 22])  ;
Fig_width = 40 ; 
 Fig_height = 22 ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 1  SM map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub1 = subplot(3,1,1) ; 
xmap = median(SM_SMAP_zscore_anomaly_Scotland(:,:,datetime_SMAP_full > datetime('01-Jun-2025')),3,'omitnan') ; 
h1 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent ,xmap) ; 
set(h1,'LineStyle','none')
shading flat
axes1 = gca ; 
hold on
% colormap(axes1,flipud(redblue_color(50:end,:)) )
colormap(axes1,flipud(redblue_color(:,:)) )
clim(sub1,[-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
% xticks([])
ylabel('latitude','FontSize',16)
ylabel(hcb2,'SM anomaly [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6.5 3])
% pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub1,'units','centimeter','position',  [2, 12 , 9*1.5, 6*1.5])

% news aces for zoom
ax_inset1 = axes('units','centimeters','Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset1,'units','centimeters','Position',[8.7, 16.5, 6, 6])
h12 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , xmap) ; 
set(h12,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset1,[57.3 57.56])
xlim(ax_inset1,[-4.0 -3.3])
% colormap(ax_inset1,flipud(redblue_color(50:end,:)) )
 colormap(ax_inset1,flipud(redblue_color(:,:)) )
clim(ax_inset1,[-2 2])% 
pbaspect([range(xlim(ax_inset1)) range(ylim(ax_inset1)) 1])
ax_inset1.XTick = [];
ax_inset1.YTick = [];
% text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)



%%%%%%%%%%%%%%%%%%% SUb 2 %%%%%%%%%%%%%%%%%
sub2 = subplot(3,1,2) ; 

% Plot the anomaly line
plot(midMonthDates_unique_interp, Dava_SM_SMAP_zscore_anomaly_median_m_interp, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Dava_SM_SMAP_zscore_anomaly_median_m_interp(midMonthDates_unique_interp > datetime('01-Jun-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Dava_SM_SMAP_zscore_anomaly_median_m_interp;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [midMonthDates_unique_interp, fliplr(midMonthDates_unique_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Dava_SM_SMAP_zscore_anomaly_median_m_interp;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-2 2])
xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('SM anomaly','FontSize',16)

grid on;

set(sub2,'units','centimeter','position',  [2, 7 , 13.5000, 3])


%%%%%%%%%%%%%%%%%%%%%%%% Sub 3 %%%%%%%%%%%%%%%%%%%%%%%%%%


sub3 = subplot(3,1,3) ; 

plot(sub3,linspace(-5,5,1000),fSM,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub3,linspace(-5,5,1000),fSMspringJan,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('SM anomaly [-]','FontSize',16)
ylabel('density','FontSize',16)
xline(sub3,median(Dava_SM_SMAP_zscore_anomaly(:,datetime_SMAP_full > datetime('01-Jun-2025')),[2 1],'omitnan'),'Color',col_X,'LineWidth',2)
% anomaly SM = -1.4965 ; 
legend(sub3,'2015-2025','> 01-Jan-2025','> 01-Jun-2025','FontSize',12)

set(sub3,'units','centimeter','position',  [2, 1.6 , 13.5000, 3])


textbox1_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 18) ; 
set(textbox1_label,'Units','centimeters', 'Position', [2, 12+9+0.1 ,1, 1], 'EdgeColor', 'none')
textbox2_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 18) ; 
set(textbox2_label,'Units','centimeters', 'Position', [2, 10+0.1 , 1, 1], 'EdgeColor', 'none')
textbox3_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 18) ; 
set(textbox3_label,'Units','centimeters', 'Position', [2, 4.6+0.1 , 1, 1], 'EdgeColor', 'none')

fontsize(14,'points')


saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\SM_Panel_01','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\SM_Panel_01','png')
close





%% VOD


[Indextime_fire]  = find(datetime('12-Jul-2025') > datetime_SMAP_full & datetime('28-Jun-2025') < datetime_SMAP_full) ; 



%%%%%%%%%%%%%%%%%%% SUb 1 %%%%%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[5 2 30 22])  ;
Fig_width = 40 ; 
 Fig_height = 22 ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 1  SM map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub1 = subplot(3,1,1) ; 
xmap = median(VOD_SMAP_zscore_anomaly(:,:,datetime_SMAP_full > datetime('01-Jun-2025')),3,'omitnan') ; 
xmap(~inScotland) = NaN ; 
h1 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent ,xmap) ; 
set(h1,'LineStyle','none')
shading flat
axes1 = gca ; 
hold on
% colormap(axes1,flipud(redblue_color(50:end,:)) )
colormap(axes1,flipud(redblue_color(:,:)) )
clim(sub1,[-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
% xticks([])
ylabel('latitude','FontSize',16)
ylabel(hcb2,'VOD anomaly [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6.5 3])
% pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub1,'units','centimeter','position',  [2, 12 , 9*1.5, 6*1.5])

% news aces for zoom
ax_inset1 = axes('units','centimeters','Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset1,'units','centimeters','Position',[8.7, 16.5, 6, 6])
h12 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , xmap) ; 
set(h12,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset1,[57.3 57.56])
xlim(ax_inset1,[-4.0 -3.3])
% colormap(ax_inset1,flipud(redblue_color(50:end,:)) )
 colormap(ax_inset1,flipud(redblue_color(:,:)) )
clim(ax_inset1,[-2 2])% 
pbaspect([range(xlim(ax_inset1)) range(ylim(ax_inset1)) 1])
ax_inset1.XTick = [];
ax_inset1.YTick = [];
% text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)



%%%%%%%%%%%%%%%%%%% SUb 2 %%%%%%%%%%%%%%%%%
sub2 = subplot(3,1,2) ; 

% Plot the anomaly line
plot(midMonthDates_unique_interp, Dava_VOD_SMAP_zscore_anomaly_median_m_interp, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Dava_VOD_SMAP_zscore_anomaly_median_m_interp(midMonthDates_unique_interp > datetime('01-Jun-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Dava_VOD_SMAP_zscore_anomaly_median_m_interp;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [midMonthDates_unique_interp, fliplr(midMonthDates_unique_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Dava_VOD_SMAP_zscore_anomaly_median_m_interp;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-2 2])
xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('VOD anomaly','FontSize',16)

grid on;

set(sub2,'units','centimeter','position',  [2, 7 , 13.5000, 3])


%%%%%%%%%%%%%%%%%%%%%%%% Sub 3 %%%%%%%%%%%%%%%%%%%%%%%%%%


sub3 = subplot(3,1,3) ; 

plot(sub3,linspace(-5,5,1000),fVOD,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub3,linspace(-5,5,1000),fVODspringJan,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('VOD anomaly [-]','FontSize',14)
ylabel('count','FontSize',16)
xline(sub3,median(Dava_VOD_SMAP_zscore_anomaly(:,datetime_SMAP_full > datetime('01-Jun-2025')),[2 1],'omitnan'),'Color',col_X,'LineWidth',2)
% anomaly = 1.1721 ;
legend(sub3,'2015-2025','> 01-Jan-2025','> 01-Jun-2025','FontSize',12)

set(sub3,'units','centimeter','position',  [2, 1.6 , 13.5000, 3])


textbox1_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 18) ; 
set(textbox1_label,'Units','centimeters', 'Position', [2, 12+9+0.1 ,1, 1], 'EdgeColor', 'none')
textbox2_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 18) ; 
set(textbox2_label,'Units','centimeters', 'Position', [2, 10+0.1 , 1, 1], 'EdgeColor', 'none')
textbox3_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 18) ; 
set(textbox3_label,'Units','centimeters', 'Position', [2, 4.6+0.1 , 1, 1], 'EdgeColor', 'none')

fontsize(14,'points')


saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\VOD_Panel_01','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\VOD_Panel_01','png')
close







%% Just Precip


[Indextime_fire]  = find(datetime('12-Jul-2025') > datetime_SMAP_full & datetime('28-Jun-2025') < datetime_SMAP_full) ; 



%%%%%%%%%%%%%%%%%%% SUb 1 %%%%%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[5 2 30 22])  ;
Fig_width = 40 ; 
 Fig_height = 22 ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 1  SM map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub1 = subplot(3,1,1) ; 
xmap = median(Hadgrid_rain_1km_anomaly_Scotland(:,:,Hadgrid_time_monthly > datetime('01-Jun-2025')),3,'omitnan') ; 
h1 = pcolor(Met_Hadgrid_1km_lon, Met_Hadgrid_1km_lat ,xmap) ; 
set(h1,'LineStyle','none')
shading flat
axes1 = gca ; 
hold on
% colormap(axes1,flipud(redblue_color(50:end,:)) )
colormap(axes1,flipud(redblue_color(:,:)) )
clim(sub1,[-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
% xticks([])
ylabel('latitude','FontSize',16)
ylabel(hcb2,'P anomaly [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6.5 3])
% pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub1,'units','centimeter','position',  [2, 12 , 9*1.5, 6*1.5])

% news aces for zoom
ax_inset1 = axes('units','centimeters','Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset1,'units','centimeters','Position',[8.7, 16.5, 6, 6])
h12 = pcolor(Met_Hadgrid_1km_lon, Met_Hadgrid_1km_lat , xmap) ; 
set(h12,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset1,[57.3 57.56])
xlim(ax_inset1,[-4.0 -3.3])
% colormap(ax_inset1,flipud(redblue_color(50:end,:)) )
 colormap(ax_inset1,flipud(redblue_color(:,:)) )
clim(ax_inset1,[-2 2])% 
pbaspect([range(xlim(ax_inset1)) range(ylim(ax_inset1)) 1])
ax_inset1.XTick = [];
ax_inset1.YTick = [];
% text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)



%%%%%%%%%%%%%%%%%%% SUb 2 %%%%%%%%%%%%%%%%%
sub2 = subplot(3,1,2) ; 

% Plot the anomaly line
plot(Hadgrid_time_monthly_interp, Hadgrid_rain_1km_anomaly_Dava_median_interp, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Hadgrid_rain_1km_anomaly_Dava_median_interp(Hadgrid_time_monthly_interp > datetime('01-Jun-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Hadgrid_rain_1km_anomaly_Dava_median_interp;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [Hadgrid_time_monthly_interp, fliplr(Hadgrid_time_monthly_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Hadgrid_rain_1km_anomaly_Dava_median_interp;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-2 2])
xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('P anomaly','FontSize',16)

grid on;

set(sub2,'units','centimeter','position',  [2, 7 , 13.5000, 3])


%%%%%%%%%%%%%%%%%%%%%%%% Sub 3 %%%%%%%%%%%%%%%%%%%%%%%%%%


sub3 = subplot(3,1,3) ; 

plot(sub3,linspace(-5,5,1000),fP,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub3,linspace(-5,5,1000),fP_Jan,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('P anomaly [-]','FontSize',16)
ylabel('count','FontSize',16)
precip_anomaly_dava_dummmy = median(Hadgrid_rain_1km_anomaly_Dava(:,:,Hadgrid_time_monthly > datetime('01-Jun-2025')),[2 1 ],'omitnan') ;
xline(sub3,precip_anomaly_dava_dummmy(1),'Color',col_X,'LineWidth',2)
legend(sub3,'2015-2025','> 01-Jan-2025','> 01-Jun-2025','FontSize',12)
set(sub3,'units','centimeter','position',  [2, 1.6 , 13.5000, 3])



textbox1_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 18) ; 
set(textbox1_label,'Units','centimeters', 'Position', [2, 12+9+0.1 ,1, 1], 'EdgeColor', 'none')
textbox2_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 18) ; 
set(textbox2_label,'Units','centimeters', 'Position', [2, 10+0.1 , 1, 1], 'EdgeColor', 'none')
textbox3_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 18) ; 
set(textbox3_label,'Units','centimeters', 'Position', [2, 4.6+0.1 , 1, 1], 'EdgeColor', 'none')

fontsize(14,'points')


saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\P_Panel_01','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\P_Panel_01','png')
close








%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Final plots but all anomalies are relative to monthly means, so deseasoned



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

load('F:\projects\Dava_wildfire\data\plotting data\Dava_SM_SMAP_m_zscore_relm')
load('F:\projects\Dava_wildfire\data\plotting data\Dava_VOD_SMAP_m_zscore_relm')
load('F:\projects\Dava_wildfire\data\plotting data\Scotland_SM_SMAP_m_zscore_relm')
load('F:\projects\Dava_wildfire\data\plotting data\Scotland_VOD_SMAP_m_zscore_relm')

load('F:\Met_Office_Had_UK\processed\Scotland_rain_SMAP_m_zscore_relm')
load('F:\Met_Office_Had_UK\processed\inDava.mat')
load('F:\Met_Office_Had_UK\processed\inScotland_Hadgrid.mat')
load('F:\projects\Dava_wildfire\data\plotting data\midMonthDates_unique')
load('F:\Met_Office_Had_UK\processed\Hadgrid_time_monthly.mat')


Dava_SM_SMAP_m_zscore_relm = mean(Dava_SM_SMAP_m_zscore_relm,1,'omitnan') ; 
Dava_SM_SMAP_zscore_anomaly_median_m_interp = interp1(Dava_SM_SMAP_m_zscore_relm,linspace(1,124,1000)) ; 
midMonthDates_unique_interp = linspace(midMonthDates_unique(1),midMonthDates_unique(end),1000) ; 

Dava_VOD_SMAP_m_zscore_relm = mean(Dava_VOD_SMAP_m_zscore_relm,1,'omitnan') ; 
Dava_VOD_SMAP_zscore_anomaly_median_m_interp = interp1(Dava_VOD_SMAP_m_zscore_relm,linspace(1,124,1000)) ; 



Dava_rain_SMAP_m_zscore_relm = Scotland_rain_SMAP_m_zscore_relm ; 

for i = 1:size(Dava_rain_SMAP_m_zscore_relm,3)

    dummy = Dava_rain_SMAP_m_zscore_relm(:,:,i) ;
    dummy(~inDava) = NaN ;
    Dava_rain_SMAP_m_zscore_relm(:,:,i) = dummy ;

    dummy = Scotland_rain_SMAP_m_zscore_relm(:,:,i) ;
    dummy(~inScotland) = NaN ;
    Scotland_rain_SMAP_m_zscore_relm(:,:,i) = dummy ;

end


Hadgrid_rain_1km_anomaly_Dava_median = squeeze(mean(Dava_rain_SMAP_m_zscore_relm,[1 2],'omitnan')) ; 
% interpolate datasets to get better performance of fill
Hadgrid_rain_1km_anomaly_Dava_median_interp = interp1(Hadgrid_rain_1km_anomaly_Dava_median,linspace(1,127,1000)) ; 
Hadgrid_time_monthly_interp = linspace(Hadgrid_time_monthly(1),Hadgrid_time_monthly(end),1000) ; 




[fSM,xiSM]   = ksdensity(Dava_SM_SMAP_m_zscore_relm(:),linspace(-5,5,1000)) ; 
[fVOD,xiVOD] = ksdensity(Dava_VOD_SMAP_m_zscore_relm(:),linspace(-5,5,1000)) ; 

SM_SMAP_zscore_anomaly_Dava_spring = Dava_SM_SMAP_m_zscore_relm(:,midMonthDates_unique > datetime('01-Jan-2025')) ;
VOD_SMAP_zscore_anomaly_Dava_spring = Dava_VOD_SMAP_m_zscore_relm(:,midMonthDates_unique > datetime('01-Jan-2025')) ;

[fSMspringJan,xiSMspring]   = ksdensity(SM_SMAP_zscore_anomaly_Dava_spring(:),linspace(-5,5,1000)) ; 
[fVODspringJan,xiVODspring] = ksdensity(VOD_SMAP_zscore_anomaly_Dava_spring(:),linspace(-5,5,1000)) ; 


[fP,xiP]   = ksdensity(Dava_rain_SMAP_m_zscore_relm(:),linspace(-5,5,1000)) ; 

Jun_2025 = Hadgrid_time_monthly > datetime('01-Jan-2025')  ; 
Hadgrid_rain_1km_anomaly_Dava_Jun = Dava_rain_SMAP_m_zscore_relm(:,:,Jun_2025) ; 
[fP_Jan,xiP_Jun]   = ksdensity(Hadgrid_rain_1km_anomaly_Dava_Jun(:),linspace(-5,5,1000)) ; 



%%  Just SM 

max(Moray_smap_lon_cent(:))
min(Moray_smap_lon_cent(:))

max(Moray_smap_lat_cent(:))
min(Moray_smap_lat_cent(:))


%%%%%%%%%%%%%%%%%%% SUb 1 %%%%%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[5 2 30 22])  ;
Fig_width = 40 ; 
 Fig_height = 22 ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 1  SM map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub1 = subplot(3,1,1) ; 
xmap = median(Scotland_SM_SMAP_m_zscore_relm(:,:,midMonthDates_unique == datetime('15-Jun-2025 12:00:00')),3,'omitnan') ; 
h1 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent ,xmap) ; 
set(h1,'LineStyle','none')
shading flat
axes1 = gca ; 
hold on
% colormap(axes1,flipud(redblue_color(50:end,:)) )
colormap(axes1,flipud(redblue_color(:,:)) )
clim(sub1,[-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
% xticks([])
ylabel('latitude','FontSize',16)
ylabel(hcb2,'Soil Moisture anomaly [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6.5 3])
% pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub1,'units','centimeter','position',  [2, 12 , 9*1.5, 6*1.5])

% news aces for zoom
ax_inset1 = axes('units','centimeters','Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset1,'units','centimeters','Position',[8.7, 16.5, 6, 6])
h12 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , xmap) ; 
set(h12,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset1,[57.3 57.56])
xlim(ax_inset1,[-4.0 -3.3])
% colormap(ax_inset1,flipud(redblue_color(50:end,:)) )
 colormap(ax_inset1,flipud(redblue_color(:,:)) )
clim(ax_inset1,[-2 2])% 
pbaspect([range(xlim(ax_inset1)) range(ylim(ax_inset1)) 1])
ax_inset1.XTick = [];
ax_inset1.YTick = [];
% text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)



%%%%%%%%%%%%%%%%%%% SUb 2 %%%%%%%%%%%%%%%%%
sub2 = subplot(3,1,2) ; 

% Plot the anomaly line
plot(midMonthDates_unique_interp, Dava_SM_SMAP_zscore_anomaly_median_m_interp, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Dava_SM_SMAP_zscore_anomaly_median_m_interp(midMonthDates_unique_interp > datetime('01-Jun-2025') &...
    midMonthDates_unique_interp < datetime('01-Jul-2025'))   ,'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Dava_SM_SMAP_zscore_anomaly_median_m_interp;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [midMonthDates_unique_interp, fliplr(midMonthDates_unique_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Dava_SM_SMAP_zscore_anomaly_median_m_interp;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-3 3])
xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('Soil Moisture anomaly','FontSize',16)

grid on;

set(sub2,'units','centimeter','position',  [2, 7 , 13.5000, 3])


%%%%%%%%%%%%%%%%%%%%%%%% Sub 3 %%%%%%%%%%%%%%%%%%%%%%%%%%


sub3 = subplot(3,1,3) ; 

plot(sub3,linspace(-5,5,1000),fSM,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub3,linspace(-5,5,1000),fSMspringJan,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('Soil Moisture anomaly [-]','FontSize',16)
ylabel('density','FontSize',16)
xline(sub3,median(Dava_SM_SMAP_m_zscore_relm(:,midMonthDates_unique == datetime('15-Jun-2025 12:00:00')),[2 1],'omitnan'),'Color',col_X,'LineWidth',2)
% anomaly SM = -1.4965 ; 
legend(sub3,'2015-2025','2025','before fire','FontSize',12)

set(sub3,'units','centimeter','position',  [2, 1.6 , 13.5000, 3])


textbox1_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox1_label,'Units','centimeters', 'Position', [2, 12+9+0.1 ,1, 1], 'EdgeColor', 'none')
textbox2_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox2_label,'Units','centimeters', 'Position', [2, 10+0.1 , 1, 1], 'EdgeColor', 'none')
textbox3_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox3_label,'Units','centimeters', 'Position', [2, 4.6+0.1 , 1, 1], 'EdgeColor', 'none')

fontsize(14,'points')


saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\SM_Panel_01_relm','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\SM_Panel_01_relm','png')
close






%% VOD


%%%%%%%%%%%%%%%%%%% SUb 1 %%%%%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[5 2 30 22])  ;
Fig_width = 40 ; 
 Fig_height = 22 ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 1  SM map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub1 = subplot(3,1,1) ; 
xmap = median(Scotland_VOD_SMAP_m_zscore_relm(:,:,midMonthDates_unique == datetime('15-Jun-2025 12:00:00')),3,'omitnan') ; 
h1 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent ,xmap) ; 
set(h1,'LineStyle','none')
shading flat
axes1 = gca ; 
hold on
% colormap(axes1,flipud(redblue_color(50:end,:)) )
colormap(axes1,flipud(redblue_color(:,:)) )
clim(sub1,[-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
% xticks([])
ylabel('latitude','FontSize',16)
ylabel(hcb2,'VOD anomaly [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6.5 3])
% pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub1,'units','centimeter','position',  [2, 12 , 9*1.5, 6*1.5])

% news aces for zoom
ax_inset1 = axes('units','centimeters','Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset1,'units','centimeters','Position',[8.7, 16.5, 6, 6])
h12 = pcolor(Moray_smap_lon_cent, Moray_smap_lat_cent , xmap) ; 
set(h12,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset1,[57.3 57.56])
xlim(ax_inset1,[-4.0 -3.3])
% colormap(ax_inset1,flipud(redblue_color(50:end,:)) )
 colormap(ax_inset1,flipud(redblue_color(:,:)) )
clim(ax_inset1,[-2 2])% 
pbaspect([range(xlim(ax_inset1)) range(ylim(ax_inset1)) 1])
ax_inset1.XTick = [];
ax_inset1.YTick = [];
% text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)



%%%%%%%%%%%%%%%%%%% SUb 2 %%%%%%%%%%%%%%%%%
sub2 = subplot(3,1,2) ; 

% Plot the anomaly line
plot(midMonthDates_unique_interp, Dava_VOD_SMAP_zscore_anomaly_median_m_interp, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Dava_VOD_SMAP_zscore_anomaly_median_m_interp(midMonthDates_unique_interp > datetime('01-Jun-2025') &...
    midMonthDates_unique_interp < datetime('01-Jul-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Dava_VOD_SMAP_zscore_anomaly_median_m_interp;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [midMonthDates_unique_interp, fliplr(midMonthDates_unique_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Dava_VOD_SMAP_zscore_anomaly_median_m_interp;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-3 3])
xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('VOD anomaly','FontSize',16)

grid on;

set(sub2,'units','centimeter','position',  [2, 7 , 13.5000, 3])


%%%%%%%%%%%%%%%%%%%%%%%% Sub 3 %%%%%%%%%%%%%%%%%%%%%%%%%%


sub3 = subplot(3,1,3) ; 

plot(sub3,linspace(-5,5,1000),fVOD,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub3,linspace(-5,5,1000),fVODspringJan,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('VOD anomaly [-]','FontSize',14)
ylabel('density','FontSize',16)
xline(sub3,median(Dava_VOD_SMAP_m_zscore_relm(:,midMonthDates_unique == datetime('15-Jun-2025 12:00:00')),[2 1],'omitnan'),'Color',col_X,'LineWidth',2)
% anomaly = 1.1721 ;
legend(sub3,'2015-2025','2025','before fire','FontSize',12,'Location','northwest')

set(sub3,'units','centimeter','position',  [2, 1.6 , 13.5000, 3])


textbox1_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox1_label,'Units','centimeters', 'Position', [2, 12+9+0.1 ,1, 1], 'EdgeColor', 'none')
textbox2_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox2_label,'Units','centimeters', 'Position', [2, 10+0.1 , 1, 1], 'EdgeColor', 'none')
textbox3_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox3_label,'Units','centimeters', 'Position', [2, 4.6+0.1 , 1, 1], 'EdgeColor', 'none')

fontsize(14,'points')


saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\VOD_Panel_01_relm','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\VOD_Panel_01_relm','png')
close




%% Just Precip




%%%%%%%%%%%%%%%%%%% SUb 1 %%%%%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[5 2 30 22])  ;
Fig_width = 40 ; 
 Fig_height = 22 ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 1  SM map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub1 = subplot(3,1,1) ; 
xmap = median(Scotland_rain_SMAP_m_zscore_relm(:,:,Hadgrid_time_monthly == datetime('16-Jun-2025')),3,'omitnan') ; 
h1 = pcolor(Met_Hadgrid_1km_lon, Met_Hadgrid_1km_lat ,xmap) ; 
set(h1,'LineStyle','none')
shading flat
axes1 = gca ; 
hold on
% colormap(axes1,flipud(redblue_color(50:end,:)) )
colormap(axes1,flipud(redblue_color(:,:)) )
clim(sub1,[-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
% xticks([])
ylabel('latitude','FontSize',16)
ylabel(hcb2,'Precipitation anomaly [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6.5 3])
% pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub1,'units','centimeter','position',  [2, 12 , 9*1.5, 6*1.5])

% news aces for zoom
ax_inset1 = axes('units','centimeters','Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset1,'units','centimeters','Position',[8.7, 16.5, 6, 6])
h12 = pcolor(Met_Hadgrid_1km_lon, Met_Hadgrid_1km_lat , xmap) ; 
set(h12,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset1,[57.3 57.56])
xlim(ax_inset1,[-4.0 -3.3])
% colormap(ax_inset1,flipud(redblue_color(50:end,:)) )
 colormap(ax_inset1,flipud(redblue_color(:,:)) )
clim(ax_inset1,[-2 2])% 
pbaspect([range(xlim(ax_inset1)) range(ylim(ax_inset1)) 1])
ax_inset1.XTick = [];
ax_inset1.YTick = [];
% text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)



%%%%%%%%%%%%%%%%%%% SUb 2 %%%%%%%%%%%%%%%%%
sub2 = subplot(3,1,2) ; 

% Plot the anomaly line
plot(Hadgrid_time_monthly_interp, Hadgrid_rain_1km_anomaly_Dava_median_interp, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Hadgrid_rain_1km_anomaly_Dava_median_interp(Hadgrid_time_monthly_interp > datetime('01-Jun-2025') & ...
    Hadgrid_time_monthly_interp < datetime('01-Jul-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Hadgrid_rain_1km_anomaly_Dava_median_interp;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [Hadgrid_time_monthly_interp, fliplr(Hadgrid_time_monthly_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Hadgrid_rain_1km_anomaly_Dava_median_interp;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-3 3])
xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('Precipitation anomaly','FontSize',16)

grid on;

set(sub2,'units','centimeter','position',  [2, 7 , 13.5000, 3])


%%%%%%%%%%%%%%%%%%%%%%%% Sub 3 %%%%%%%%%%%%%%%%%%%%%%%%%%


sub3 = subplot(3,1,3) ; 

plot(sub3,linspace(-5,5,1000),fP,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub3,linspace(-5,5,1000),fP_Jan,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('Precipitation anomaly [-]','FontSize',16)
ylabel('density','FontSize',16)
precip_anomaly_dava_dummmy = median(Hadgrid_rain_1km_anomaly_Dava(:,:,Hadgrid_time_monthly == datetime('16-Jun-2025')),[2 1 ],'omitnan') ;
xline(sub3,precip_anomaly_dava_dummmy(1),'Color',col_X,'LineWidth',2)
legend(sub3,'2015-2025','2025','before fire','FontSize',12)
set(sub3,'units','centimeter','position',  [2, 1.6 , 13.5000, 3])



textbox1_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox1_label,'Units','centimeters', 'Position', [2, 12+9+0.1 ,1, 1], 'EdgeColor', 'none')
textbox2_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox2_label,'Units','centimeters', 'Position', [2, 10+0.1 , 1, 1], 'EdgeColor', 'none')
textbox3_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox3_label,'Units','centimeters', 'Position', [2, 4.6+0.1 , 1, 1], 'EdgeColor', 'none')

fontsize(14,'points')


saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\P_Panel_01_relm','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\P_Panel_01_relm','png')
close






%% FWI 

load('F:\projects\Dava_wildfire\data\plotting data\Scotland_FWI_mean_zscore_m')
load('F:\projects\Dava_wildfire\data\plotting data\Scotland_FWI_mean_m')
load('F:\projects\Dava_wildfire\data\plotting data\Dava_FWI_mean_zscore_m')
load('F:\projects\Dava_wildfire\data\plotting data\Dava_FWI_mean_m')
load('F:\Fire_Weather_Index\processed\FWI_latitude') ; 
load('F:\Fire_Weather_Index\processed\FWI_longitude') ; 
load('F:\Fire_Weather_Index\processed\FWI_time') ;
load('F:\projects\Dava_wildfire\data\plotting data\midMonthDates_uniqueFWI')

Dava_FWI_mean_zscore_m_interp = interp1(Dava_FWI_mean_zscore_m,linspace(1,126,1000)) ; 
FWI_time_monthly_interp = linspace(midMonthDates_uniqueFWI(1),midMonthDates_uniqueFWI(end),1000) ; 

[fFWI,xiFWI]   = ksdensity(Dava_FWI_mean_zscore_m(:),linspace(-5,5,1000)) ; 
Jun_2025 = midMonthDates_uniqueFWI > datetime('01-Jan-2025')  ; 
FWI_zscore_anomaly_Scotland_spring = Dava_FWI_mean_zscore_m(Jun_2025) ; 
[fFWIspringJan,xiFWIspring]   = ksdensity(FWI_zscore_anomaly_Scotland_spring(:),linspace(-5,5,1000)) ; 


[yFWI mFWI dFWI] = ymd(midMonthDates_uniqueFWI) ; 

only_summer = (mFWI >= 6 & mFWI <= 8) ; 
midMonthDates_uniqueFWI_summer = midMonthDates_uniqueFWI ;
midMonthDates_uniqueFWI_summer(~only_summer) = NaT ; 

% 
% plot(midMonthDates_uniqueFWI_summer, Dava_FWI_mean_m, ...
%     '-o', 'LineWidth', 1, 'Color', 'k') ;
% 
% plot(midMonthDates_uniqueFWI, Dava_FWI_mean_zscore_m, ...
%     '-o', 'LineWidth', 1, 'Color', 'k') ;
% 
% plot(midMonthDates_uniqueFWI, Dava_FWI_mean_m, ...
%     '-o', 'LineWidth', 1, 'Color', 'k') ;



%%%%%%%%%%%%%%%%%%% SUb 1 %%%%%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[5 2 30 22])  ;
Fig_width = 40 ; 
 Fig_height = 22 ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 1  SM map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub1 = subplot(3,1,1) ; 
xmap = median(Scotland_FWI_mean_zscore_m(:,:,midMonthDates_uniqueFWI == datetime('15-Jun-2025 12:00:00')),3,'omitnan') ; 
h1 = pcolor(FWI_longitude, FWI_latitude ,xmap) ; 
set(h1,'LineStyle','none')
shading flat
axes1 = gca ; 
hold on
% colormap(axes1,flipud(redblue_color(50:end,:)) )
colormap(axes1,(redblue_color(:,:)) )
clim(sub1,[-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
% xticks([])
ylabel('latitude','FontSize',16)
ylabel(hcb2,'FWI anomaly [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6.5 3])
% pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub1,'units','centimeter','position',  [2, 12 , 9*1.5, 6*1.5])

% news aces for zoom
ax_inset1 = axes('units','centimeters','Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset1,'units','centimeters','Position',[8.7, 16.5, 6, 6])
h12 = pcolor(FWI_longitude, FWI_latitude , xmap) ; 
set(h12,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset1,[57.3 57.56])
xlim(ax_inset1,[-4.0 -3.3])
% colormap(ax_inset1,flipud(redblue_color(50:end,:)) )
 colormap(ax_inset1,(redblue_color(:,:)) )
clim(ax_inset1,[-2 2])% 
pbaspect([range(xlim(ax_inset1)) range(ylim(ax_inset1)) 1])
ax_inset1.XTick = [];
ax_inset1.YTick = [];
% text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)



%%%%%%%%%%%%%%%%%%% SUb 2 %%%%%%%%%%%%%%%%%
sub2 = subplot(3,1,2) ; 

% Plot the anomaly line
plot(FWI_time_monthly_interp, Dava_FWI_mean_zscore_m_interp, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Dava_FWI_mean_zscore_m_interp(FWI_time_monthly_interp > datetime('01-Jun-2025') & ...
    FWI_time_monthly_interp < datetime('01-Jul-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Dava_FWI_mean_zscore_m_interp;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [FWI_time_monthly_interp, fliplr(FWI_time_monthly_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Dava_FWI_mean_zscore_m_interp;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% ylim([-3 3])
 ylim([-2 2])
xlim(sub2,[datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('FWI anomaly','FontSize',16)

grid on;

set(sub2,'units','centimeter','position',  [2, 7 , 13.5000, 3])


%%%%%%%%%%%%%%%%%%%%%%%% Sub 3 %%%%%%%%%%%%%%%%%%%%%%%%%%


sub3 = subplot(3,1,3) ; 

plot(sub3,linspace(-5,5,1000),fFWI,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub3,linspace(-5,5,1000),fFWIspringJan,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('FWI anomaly [-]','FontSize',16)
ylabel('density','FontSize',16)
FWI_anomaly_dava_dummmy = mean(Dava_FWI_mean_zscore_m(midMonthDates_uniqueFWI == datetime('15-Jun-2025 12:00:00')),[2 1 ],'omitnan') ;
xline(sub3,FWI_anomaly_dava_dummmy(1),'Color',col_X,'LineWidth',2)
legend(sub3,'2015-2025','2025','before fire','FontSize',12)
set(sub3,'units','centimeter','position',  [2, 1.6 , 13.5000, 3])


textbox1_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox1_label,'Units','centimeters', 'Position', [2, 12+9+0.1 ,1, 1], 'EdgeColor', 'none')
textbox2_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox2_label,'Units','centimeters', 'Position', [2, 10+0.1 , 1, 1], 'EdgeColor', 'none')
textbox3_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox3_label,'Units','centimeters', 'Position', [2, 4.6+0.1 , 1, 1], 'EdgeColor', 'none')

fontsize(14,'points')


saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\FWI_Panel_01_relm_02','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\FWI_Panel_01_relm_02','png')
close




%% figure with absolute FWI



Dava_FWI_mean_m_interp = interp1(Dava_FWI_mean_m,linspace(1,126,1000)) ; 
FWI_time_monthly_interp = linspace(midMonthDates_uniqueFWI(1),midMonthDates_uniqueFWI(end),1000) ; 


[fFWI,xiFWI]   = ksdensity(Dava_FWI_mean_m(:),linspace(0,10,1000)) ; 
Jun_2025 = midMonthDates_uniqueFWI > datetime('01-Jan-2025')  ; 
FWI_Scotland_spring = Dava_FWI_mean_m(Jun_2025) ; 
[fFWIspringJan,xiFWIspring]   = ksdensity(FWI_Scotland_spring(:),linspace(0,10,1000)) ; 



%%%%%%%%%%%%%%%%%%% SUb 1 %%%%%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[5 2 30 22])  ;
Fig_width = 40 ; 
 Fig_height = 22 ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 1  SM map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub1 = subplot(3,1,1) ; 
xmap = median(Scotland_FWI_mean_m(:,:,midMonthDates_uniqueFWI == datetime('15-Jun-2025 12:00:00')),3,'omitnan') ; 
h1 = pcolor(FWI_longitude, FWI_latitude ,xmap) ; 
set(h1,'LineStyle','none')
shading flat
axes1 = gca ; 
hold on
% colormap(axes1,flipud(redblue_color(50:end,:)) )
colormap(axes1,(redblue_color(50:end,:)) )
clim(sub1,[0 10])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',0:2:10)
xlabel('longitude','FontSize',16)
% xticks([])
ylabel('latitude','FontSize',16)
ylabel(hcb2,'FWI [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6.5 3])
% pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub1,'units','centimeter','position',  [2, 12 , 9*1.5, 6*1.5])

% news aces for zoom
ax_inset1 = axes('units','centimeters','Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset1,'units','centimeters','Position',[8.7, 16.5, 6, 6])
h12 = pcolor(FWI_longitude, FWI_latitude , xmap) ; 
set(h12,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset1,[57.3 57.56])
xlim(ax_inset1,[-4.0 -3.3])
% colormap(ax_inset1,flipud(redblue_color(50:end,:)) )
 colormap(ax_inset1,(redblue_color(50:end,:)) )
clim(ax_inset1,[0 10])% 
pbaspect([range(xlim(ax_inset1)) range(ylim(ax_inset1)) 1])
ax_inset1.XTick = [];
ax_inset1.YTick = [];
% text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)



%%%%%%%%%%%%%%%%%%% SUb 2 %%%%%%%%%%%%%%%%%
sub2 = subplot(3,1,2) ; 

% Plot the anomaly line
plot(FWI_time_monthly_interp, Dava_FWI_mean_m_interp, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(mean(Dava_FWI_mean_m_interp(FWI_time_monthly_interp > datetime('01-Jun-2025') & ...
    FWI_time_monthly_interp < datetime('01-Jul-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Dava_FWI_mean_m_interp;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [FWI_time_monthly_interp, fliplr(FWI_time_monthly_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Dava_FWI_mean_m_interp;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([0 10])
xlim(sub2,[datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('FWI','FontSize',16)

grid on;

set(sub2,'units','centimeter','position',  [2, 7 , 13.5000, 3])


%%%%%%%%%%%%%%%%%%%%%%%% Sub 3 %%%%%%%%%%%%%%%%%%%%%%%%%%


sub3 = subplot(3,1,3) ; 

plot(sub3,linspace(0,10,1000),fFWI,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub3,linspace(0,10,1000),fFWIspringJan,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('FWI [-]','FontSize',16)
ylabel('density','FontSize',16)
FWI_anomaly_dava_dummmy = mean(Dava_FWI_mean_m(midMonthDates_uniqueFWI == datetime('15-Jun-2025 12:00:00')),[2 1 ],'omitnan') ;
xline(sub3,FWI_anomaly_dava_dummmy(1),'Color',col_X,'LineWidth',2)
legend(sub3,'2015-2025','2025','before fire','FontSize',12)
set(sub3,'units','centimeter','position',  [2, 1.6 , 13.5000, 3])


textbox1_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox1_label,'Units','centimeters', 'Position', [2, 12+9+0.1 ,1, 1], 'EdgeColor', 'none')
textbox2_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox2_label,'Units','centimeters', 'Position', [2, 10+0.1 , 1, 1], 'EdgeColor', 'none')
textbox3_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox3_label,'Units','centimeters', 'Position', [2, 4.6+0.1 , 1, 1], 'EdgeColor', 'none')

fontsize(14,'points')


saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\FWI_Panel_01_abs','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\FWI_Panel_01_abs','png')
close




%% FWI absolute summer months plots with regression line



only_summer = (mFWI >= 5 & mFWI <= 9) ; 
midMonthDates_uniqueFWI_summer = midMonthDates_uniqueFWI ;
midMonthDates_uniqueFWI_summer(~only_summer) = [] ; 
Dava_FWI_mean_dummy = Dava_FWI_mean_m ; 
Dava_FWI_mean_dummy(~only_summer) = [] ; 

plot(midMonthDates_uniqueFWI, Dava_FWI_mean_m, ...
    '-o', 'LineWidth', 1, 'Color', 'k') ;
hold on

plot(midMonthDates_uniqueFWI_summer, Dava_FWI_mean_dummy, ...
    '-o', 'LineWidth', 1, 'Color', 'k') ;
hold on


cd('E:\Daten Baur\Matlab code')
[m_cur b_cur] = TheilSen([(1:length(Dava_FWI_mean_dummy))' , Dava_FWI_mean_dummy]) ; 
[H,p_value] = Mann_Kendall(Dava_FWI_mean_dummy,0.05)  ;   



%% average summer FWI
[yall mall dall] = ymd(midMonthDates_uniqueFWI) ; 

years_unique = unique(yall) ;


for i = 1:length(unique(yall))

curyear =   years_unique(i) ; 

cur_summer = find(yall == curyear & mall >= 6 & mall <= 8) ; 
Dava_FWI_annual_summer(i) = mean(Dava_FWI_mean_m(cur_summer)) ; 

i
end


cd('E:\Daten Baur\Matlab code')
[m_cur b_cur] = TheilSen([(1:length(Dava_FWI_annual_summer))' , Dava_FWI_annual_summer']) ; 
[H,p_value] = Mann_Kendall(Dava_FWI_annual_summer,0.05)  ;   





Fig_Panel = figure('units','centimeters','position',[5 2 25 10])  ;
plot(2015:2025, Dava_FWI_annual_summer, ...
    '-o', 'LineWidth', 1.5, 'Color', 'k') ;
hold on
plot(2015:2025, (1:11).*m_cur+b_cur, ...
    '-', 'LineWidth', 1.5, 'Color', 'r') ;

ylabel('average summer FWI [-]')
xlabel('')
ylim([0 8])
fontsize(14,'points')
legend('','0.2361 * x + 1.0920','FontSize',14)

saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\FWI_summer_trends_01','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\FWI_summer_trends_01','png')
close




%% Same figure but for SM ERA over 80 yearsmax(Moray_smap_lon_cent(:))
clear 


load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_lat') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_lon') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_time') ; 

load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_lat') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_lon') ; 


startMonth = dateshift(ERA5_month_Scot_time(:), 'start', 'month');
endMonth   = dateshift(ERA5_month_Scot_time(:), 'end', 'month');
% Middle of each month = halfway between start and end
midMonthDates = startMonth + days(days(endMonth - startMonth) / 2);
midMonthDates_unique = unique(midMonthDates) ; 


load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_SM1_anomaly') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_SM1_anomaly') ; 

ERA5_month_Dava_SM1_anomaly = squeeze(mean(ERA5_month_Dava_SM1_anomaly,[1 2]))  ; 
ERA5_month_Dava_SM1_anomaly_interp = interp1(ERA5_month_Dava_SM1_anomaly,linspace(1,1032,5000)) ; 
midMonthDates_unique_interp = linspace(midMonthDates_unique(1),midMonthDates_unique(end),5000) ; 


load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_SM1_anomaly_y') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_SM1_anomaly_y') ; 

ydummyall_unique = datetime('01-Aug-1940'):years(1):datetime('01-Aug-2025') ; 
ydummyall_unique_interp = linspace(ydummyall_unique(1),ydummyall_unique(end),2000) ; 

ERA5_month_Dava_SM1_anomaly_y = squeeze(mean(ERA5_month_Dava_SM1_anomaly_y,[1 2]))  ; 
ERA5_month_Dava_SM1_anomaly_y_interp = interp1(ERA5_month_Dava_SM1_anomaly_y,linspace(1,86,2000)) ; 





[fSM,xiSM]   = ksdensity(ERA5_month_Dava_SM1_anomaly(:),linspace(-5,5,1000)) ; 
SM_SMAP_zscore_anomaly_Dava_spring = ERA5_month_Dava_SM1_anomaly(midMonthDates_unique > datetime('01-Jan-2025')) ;
[fSMspringJan,xiSMspring]   = ksdensity(SM_SMAP_zscore_anomaly_Dava_spring(:),linspace(-5,5,1000)) ; 








%%%%%%%%%%%%%%%%%%% SUb 1 %%%%%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[5 2 30 22])  ;
Fig_width = 40 ; 
 Fig_height = 22 ; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sub 1  SM map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub1 = subplot(3,1,1) ; 
xmap = median(ERA5_month_Scot_SM1_anomaly(:,:,midMonthDates_unique == datetime('15-Jun-2025 12:00:00')),3,'omitnan') ; 
h1 = pcolor(ERA5_month_Scot_lon,ERA5_month_Scot_lat + 0.25,xmap) ; 
set(h1,'LineStyle','none')
shading flat
axes1 = gca ; 
hold on
% colormap(axes1,flipud(redblue_color(50:end,:)) )
colormap(axes1,flipud(redblue_color(:,:)) )
clim(sub1,[-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
% xticks([])
ylabel('latitude','FontSize',16)
ylabel(hcb2,'ERA5 Soil Moisture anomaly [-]','FontSize',16)
%ylabel(hcb2,'\DeltaSM/\Deltat change [%]','FontSize',16)
% plot(CoastlineLon, CoastlineLat,'Color','k');
plot(Effis_lon,Effis_lat,'Color','k');
fontsize(16,'points')
patch(cell2mat(GADM_GBlatlon.Lon), cell2mat(GADM_GBlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
patch(cell2mat(GADM_Waleslatlon.Lon), cell2mat(GADM_Waleslatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(axes1,[54 60])
xlim(axes1,[-6.5 3])
% pbaspect([range(xlim(axes1)) range(ylim(axes1)) 1])
rectangle(axes1,'Position',[-4.0 57.3 -3.3--4.0 57.56-57.3],'LineWidth',1.3)

set(sub1,'units','centimeter','position',  [2, 12 , 9*1.5, 6*1.5])

% news aces for zoom
ax_inset1 = axes('units','centimeters','Position',[0.6 0.7 0.3 0.3]); % [x y width height]
set(ax_inset1,'units','centimeters','Position',[8.7, 16.5, 6, 6])
h12 = pcolor(ERA5_month_Scot_lon, ERA5_month_Scot_lat + 0.25 , xmap) ; 
set(h12,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset1,[57.3 57.56])
xlim(ax_inset1,[-4.0 -3.3])
% colormap(ax_inset1,flipud(redblue_color(50:end,:)) )
 colormap(ax_inset1,flipud(redblue_color(:,:)) )
clim(ax_inset1,[-2 2])% 
pbaspect([range(xlim(ax_inset1)) range(ylim(ax_inset1)) 1])
ax_inset1.XTick = [];
ax_inset1.YTick = [];
% text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)



%%%%%%%%%%%%%%%%%%% SUb 2 %%%%%%%%%%%%%%%%%
% sub2 = subplot(3,1,2) ; 
% plot_anomaly = ERA5_month_Dava_SM1_anomaly_interp ; 
% % Plot the anomaly line
% plot(midMonthDates_unique_interp, plot_anomaly, ...
%     '-', 'LineWidth', 1, 'Color', 'k') ;
% hold on
% yline(0, 'k--');
% yline(mean(plot_anomaly(midMonthDates_unique_interp > datetime('01-Jun-2025') &...
%     midMonthDates_unique_interp < datetime('01-Jul-2025'))   ,'omitnan'), 'r--');
% % --- Positive anomalies (blue) ---
% yPos = plot_anomaly;
% yPos(yPos < 0) = 0;   % keep only >0
% x2 = [midMonthDates_unique_interp, fliplr(midMonthDates_unique_interp)];
% inBetween = [yPos, fliplr(zeros(size(yPos))) ];
% fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');
% 
% % --- Negative anomalies (red) ---
% yNeg = plot_anomaly;
% yNeg(yNeg > 0) = 0;   % keep only <0
% inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
% fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');
% 
% ylim([-4 4])
% % xlim([datetime('01-Jan-1940')   datetime('16-Jul-2025') ])
% xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
% xtickangle(45)
% % xlabel('Time','FontSize',16)
% ylabel('ERA5 Soil Moisture anomaly','FontSize',16)
% 
% grid on;
% 
% set(sub2,'units','centimeter','position',  [2, 7 , 13.5000, 3])


sub2 = subplot(3,1,2) ; 
plot_anomaly = ERA5_month_Dava_SM1_anomaly_y_interp ; 
% Plot the anomaly line
plot(ydummyall_unique_interp, plot_anomaly, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
% yline(mean(plot_anomaly(ydummyall_unique_interp > datetime('01-Jun-2025') &...
%     ydummyall_unique_interp < datetime('01-Jul-2025'))   ,'omitnan'), 'r--');

% all year avrg anomaly 
yline(ERA5_month_Dava_SM1_anomaly_y(end), 'r--');


% --- Positive anomalies (blue) ---
yPos = plot_anomaly;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [ydummyall_unique_interp, fliplr(ydummyall_unique_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = plot_anomaly;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-1.5 1])
% xlim([datetime('01-Jan-1940')   datetime('16-Jul-2025') ])
 xlim([datetime('01-Jan-1940')   datetime('31-Dec-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('ERA5 Soil Moisture anomaly','FontSize',16)
grid on;
set(sub2,'units','centimeter','position',  [2, 7 , 13.5000, 3])




%%%%%%%%%%%%%%%%%%%%%%%% Sub 3 %%%%%%%%%%%%%%%%%%%%%%%%%%


sub3 = subplot(3,1,3) ; 

plot(sub3,linspace(-5,5,1000),fSM,'Color',redblue_color(50-20,:),'LineWidth',3)
hold on
plot(sub3,linspace(-5,5,1000),fSMspringJan,'Color',redblue_color(51+20,:),'LineWidth',3)
xlabel('ERA5 Soil Moisture anomaly [-]','FontSize',16)
ylabel('density','FontSize',16)
xline(sub3,median(ERA5_month_Dava_SM1_anomaly(midMonthDates_unique == datetime('15-Jun-2025 12:00:00')),[2 1],'omitnan'),'Color',col_X,'LineWidth',2)
% anomaly SM = -1.4965 ; 
legend(sub3,'2015-2025','2025','before fire','FontSize',12)
ylim([0 0.5])
set(sub3,'units','centimeter','position',  [2, 1.6 , 13.5000, 3])


textbox1_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'a)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox1_label,'Units','centimeters', 'Position', [2, 12+9+0.1 ,1, 1], 'EdgeColor', 'none')
textbox2_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'b)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox2_label,'Units','centimeters', 'Position', [2, 10+0.1 , 1, 1], 'EdgeColor', 'none')
textbox3_label = annotation('textbox', [0, 0.2, 0, 0],  'string', 'c)', 'FontSize', 18,'fontweight', 'bold') ; 
set(textbox3_label,'Units','centimeters', 'Position', [2, 4.6+0.1 , 1, 1], 'EdgeColor', 'none')

fontsize(14,'points')


saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\SM_ERA_Panel_R1_relm02','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\SM_ERA_Panel_R1_relm02','png')
close




%% just annual anomalies for ERA



%%%%%%%%%%%%%%%%%%% SUb 2 %%%%%%%%%%%%%%%%%
Fig_Panel = figure('units','centimeters','position',[5 2 30 15])  ;


plot_anomaly = ERA5_month_Dava_SM1_anomaly_y_interp ; 
% Plot the anomaly line
plot(ydummyall_unique_interp, plot_anomaly, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
% yline(mean(plot_anomaly(ydummyall_unique_interp > datetime('01-Jun-2025') &...
%     ydummyall_unique_interp < datetime('01-Jul-2025'))   ,'omitnan'), 'r--');

% all year avrg anomaly 
yline(ERA5_month_Dava_SM1_anomaly_y(end), 'r--');


% --- Positive anomalies (blue) ---
yPos = plot_anomaly;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [ydummyall_unique_interp, fliplr(ydummyall_unique_interp)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = plot_anomaly;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

ylim([-1.5 1])
% xlim([datetime('01-Jan-1940')   datetime('16-Jul-2025') ])
 xlim([datetime('01-Jan-1940')   datetime('31-Dec-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('Annual ERA5 Soil Moisture anomaly','FontSize',16)
grid on;

saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\SM_ERA_R2_y','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\Panel_figures\SM_ERA_R2_y','png')
close










