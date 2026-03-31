%% Met Office data load for Morayshire fire MJB 09.09-2025
% Have data for 1km 5km and 12km. 5km is daily so probably best



%% for figures


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






%%
clear


cd('F:\Met_Office_Had_UK\1km\monthly')

metraininfo = ncinfo("rainfall_hadukgrid_uk_1km_mon_202501.nc") ; 

Met_rain_Hadgrid_1km_monthly = ncread('rainfall_hadukgrid_uk_1km_mon_202501.nc','rainfall') ;

% 'hours since 1800-01-01 00:00:00'
Hadgrid_time = ncread('rainfall_hadukgrid_uk_1km_mon_202501.nc','time') ;
Hadgrid_time_bnds = ncread('rainfall_hadukgrid_uk_1km_mon_202501.nc','time_bnds') ;

Hadgrid_time = datetime(1800,1,1,0,0,0) + hours(Hadgrid_time) ; 
Hadgrid_time_bnds = datetime(1800,1,1,0,0,0) + hours(Hadgrid_time_bnds) ; 



cd('F:\Met_Office_Had_UK\1km\monthly_rain')

Met_rain_Hadgrid_1km_monthly2 = ncread('rainfall_hadukgrid_uk_1km_mon_183801-183812.nc','rainfall') ;

Met_rain_Hadgrid_1km_monthly = flipud(permute(Met_rain_Hadgrid_1km_monthly,[2 1])) ; 



%% read lat and lons

Met_Hadgrid_1km_lat = ncread('rainfall_hadukgrid_uk_1km_mon_183801-183812.nc','latitude') ;
Met_Hadgrid_1km_lon = ncread('rainfall_hadukgrid_uk_1km_mon_183801-183812.nc','longitude') ;

Met_Hadgrid_1km_lat = flipud(permute(Met_Hadgrid_1km_lat,[2 1])) ; 
Met_Hadgrid_1km_lon = flipud(permute(Met_Hadgrid_1km_lon,[2 1])) ; 


save('F:\Met_Office_Had_UK\processed\Met_Hadgrid_1km_lat','Met_Hadgrid_1km_lat')
save('F:\Met_Office_Had_UK\processed\Met_Hadgrid_1km_lon','Met_Hadgrid_1km_lon')



%% read data from 2015 from Hadley. Read normal data first then do low latency 2025 and attach


cd('F:\Met_Office_Had_UK\1km\monthly_rain')

filelist = string(ls('*rainfall*')) ; 
% 180-end is from 2015

filelist_2015_2024 = filelist(180:end) ; 


Hadgrid_rain_1km_monthly = NaN(1450,900,120) ; 
counter = 1 ; 

for i = 1:length(filelist_2015_2024)

    dummy_rain = ncread(filelist_2015_2024(i),'rainfall') ; 
    dummy_rain = flipud(permute(dummy_rain,[2 1 3])) ; 
    dummy_time = ncread(filelist_2015_2024(i),'time') ; 
    dummy_time = datetime(1800,1,1,0,0,0) + hours(dummy_time) ; 

    Hadgrid_rain_1km_monthly(:,:,counter:counter+size(dummy_rain,3)-1) = dummy_rain ; 
    Hadgrid_time (counter:counter+size(dummy_rain,3)-1) = dummy_time ;
    counter = counter+size(dummy_rain,3) ;
i
end


% add month in 2025 manually




cd('F:\Met_Office_Had_UK\1km\monthly')

filelist = string(ls('*rainfall*')) ; 

Hadgrid_rain_1km_monthly_2025 = NaN(1450,900,7) ; 

for i = 1:length(filelist)

    dummy_rain = ncread(filelist(i),'rainfall') ; 
    dummy_rain = flipud(permute(dummy_rain,[2 1 3])) ; 
    dummy_time = ncread(filelist(i),'time') ; 
    dummy_time = datetime(1800,1,1,0,0,0) + hours(dummy_time) ; 

    Hadgrid_rain_1km_monthly_2025(:,:,i) = dummy_rain ; 
    Hadgrid_time2025 (i) = dummy_time ;

i
end



Hadgrid_rain_1km_monthly = cat(3,Hadgrid_rain_1km_monthly,Hadgrid_rain_1km_monthly_2025) ; 
Hadgrid_time_monthly = cat(2,Hadgrid_time,Hadgrid_time2025) ; 




save('F:\Met_Office_Had_UK\processed\Hadgrid_rain_1km_monthly','Hadgrid_rain_1km_monthly')
save('F:\Met_Office_Had_UK\processed\Hadgrid_time_monthly','Hadgrid_time_monthly')




[ydummyall mdummyall ddummyall] = ymd(Hadgrid_time_monthly) ; 
Scotland_rain_SMAP_m_zscore_relm = NaN(size(Hadgrid_rain_1km_monthly)) ; 

for i = 1:length(Hadgrid_time_monthly)

    dummy_date = Hadgrid_time_monthly(i) ; 
    [ydummy mdummy ddummy] = ymd(dummy_date) ; 
    [Lia Locb] = find(mdummy == mdummyall) ; 

    rain_monthly_mean = mean(Hadgrid_rain_1km_monthly(:,:,Locb),3,'omitnan') ;    
    rain_monthly_std =  std(Hadgrid_rain_1km_monthly(:,:,Locb),1,3,'omitnan') ;

    Scotland_rain_SMAP_m_zscore_relm(:,:,i) = (Hadgrid_rain_1km_monthly(:,:,i) - rain_monthly_mean) ./ rain_monthly_std ;
  
i
end

histogram(Scotland_rain_SMAP_m_zscore_relm)
save('F:\Met_Office_Had_UK\processed\Scotland_rain_SMAP_m_zscore_relm','Scotland_rain_SMAP_m_zscore_relm')




%% cut to scotland

cd('F:\projects\Dava_wildfire\data\burnt_area_effis')
Effis_perimeter = shaperead('Dava_fire_perimeter.shp') ; 
Effis_perimeter_info = shapeinfo('Dava_fire_perimeter.shp');
Effis_CRS = Effis_perimeter_info.CoordinateReferenceSystem ; 
[Effis_lat, Effis_lon] = projinv(Effis_CRS, Effis_perimeter.X, Effis_perimeter.Y);

GADM_admin_boundaries = readgeotable('F:\projects\Dava_wildfire\data\GADM\gadm41_GBR_1.json');   
GADM_Scotland = GADM_admin_boundaries.Shape(2) ; 
GADM_Scotlandlatlon = geotable2table(GADM_admin_boundaries(2,:),["Lat","Lon"]); 
GADM_GBlatlon = geotable2table(GADM_admin_boundaries(4,:),["Lat","Lon"]); 
GADM_Waleslatlon = geotable2table(GADM_admin_boundaries(3,:),["Lat","Lon"]); 


% check inpolygon function to mask for scottish pixels #represent
inScotland = inpolygon(Met_Hadgrid_1km_lon, Met_Hadgrid_1km_lat, cell2mat(GADM_Scotlandlatlon.Lon),  cell2mat(GADM_Scotlandlatlon.Lat));
save('F:\Met_Office_Had_UK\processed\inScotland_Hadgrid','inScotland')



%%

load('F:\Met_Office_Had_UK\processed\inScotland_Hadgrid')
load('F:\Met_Office_Had_UK\processed\Hadgrid_rain_1km_monthly')


Hadgrid_rain_1km_anomaly = (Hadgrid_rain_1km_monthly - mean(Hadgrid_rain_1km_monthly,3,'omitmissing')) ./ std(Hadgrid_rain_1km_monthly,0,3,'omitmissing') ; 
Hadgrid_rain_1km_anomaly(Hadgrid_rain_1km_anomaly > 5  | Hadgrid_rain_1km_anomaly < -5) = NaN ; 
Hadgrid_rain_1km_anomaly_Scotland = NaN(size(Hadgrid_rain_1km_anomaly)) ; 

for i = 1:127

    dummy_rain  = Hadgrid_rain_1km_anomaly(:,:,i) ; 
    dummy_rain(~inScotland) = NaN ; 
    Hadgrid_rain_1km_anomaly_Scotland(:,:,i) = dummy_rain ;

i
end

save('F:\Met_Office_Had_UK\processed\Hadgrid_rain_1km_anomaly_Scotland','Hadgrid_rain_1km_anomaly_Scotland')







%% MAP figure Scotland
cd('F:\Met_Office_Had_UK\processed')

load('F:\Met_Office_Had_UK\processed\Hadgrid_rain_1km_anomaly_Scotland.mat')
load('F:\Met_Office_Had_UK\processed\Met_Hadgrid_1km_lat.mat')
load('F:\Met_Office_Had_UK\processed\Met_Hadgrid_1km_lon.mat')
load('F:\Met_Office_Had_UK\processed\Hadgrid_time_monthly.mat')



% test = squeeze(mean(Hadgrid_rain_1km_anomaly_Dava,[1 2],'omitnan')) ; 
% plot(test)

xmap = median(Hadgrid_rain_1km_anomaly_Scotland(:,:,Hadgrid_time_monthly > datetime('01-Jun-2025')),3,'omitnan') ; 

Fig_Panel = figure('units','centimeters','position',[10 2 25 18])  ;
h = pcolor(Met_Hadgrid_1km_lon, Met_Hadgrid_1km_lat , xmap) ; 
set(h,'LineStyle','none')
shading flat
axes1 = gca ; 
% set(h, 'AlphaData', ~isnan(SM_SMAP_moray_array_zscore(:,10:end,Indextime_fire)))
% set(gca,'YDir','normal') 
hold on
% colormap(flipud(redblue_color(50:end,:)) )
colormap(flipud(redblue_color))
clim([-2 2])% 
hcb2=colorbar;
set(hcb2, 'FontSize',16)
set(hcb2, 'FontSize',16,'YTick',-4:1:4)
xlabel('longitude','FontSize',16)
ylabel('latitude','FontSize',16)
ylabel(hcb2,'Precipitation pre-fire z-scores','FontSize',16)
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
h2 = pcolor(Met_Hadgrid_1km_lon, Met_Hadgrid_1km_lat , xmap) ; 
set(h2,'LineStyle','none')
shading flat
hold on
plot(Effis_lon,Effis_lat,'Color','k');
patch(cell2mat(GADM_Scotlandlatlon.Lon), cell2mat(GADM_Scotlandlatlon.Lat), [0.5 0.8 0.5], 'EdgeColor','k')
ylim(ax_inset,[57.3 57.56])
xlim(ax_inset,[-4.0 -3.3])
colormap(flipud(redblue_color) )
clim([-2 2])% 
pbaspect([range(xlim(ax_inset)) range(ylim(ax_inset)) 1])
ax_inset.XTick = [];
ax_inset.YTick = [];
text(axes1,-0.55,57.5,'Morayshire Wildfire','FontSize',18)



saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\Precip_zscore_anomalies_map','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\Precip_zscore_anomalies_map','png')
close 






%% time plot
load('F:\Met_Office_Had_UK\processed\inDava.mat')
% find in Dava fire pixels
inDava = inpolygon(Met_Hadgrid_1km_lon, Met_Hadgrid_1km_lat, Effis_lon,  Effis_lat);
save('F:\Met_Office_Had_UK\processed\inDava','inDava')

Hadgrid_rain_1km_anomaly_Dava = NaN(size(Hadgrid_rain_1km_anomaly)) ; 

for i = 1:127

    dummy_rain  = Hadgrid_rain_1km_anomaly(:,:,i) ; 
    dummy_rain(~inDava) = NaN ; 
    Hadgrid_rain_1km_anomaly_Dava(:,:,i) = dummy_rain ;

i
end

save('F:\Met_Office_Had_UK\processed\Hadgrid_rain_1km_anomaly_Dava','Hadgrid_rain_1km_anomaly_Dava')

% imagesc(mean(Hadgrid_rain_1km_anomaly_Dava,3,'omitnan'))


Hadgrid_rain_1km_anomaly_Dava_median = squeeze(median(Hadgrid_rain_1km_anomaly_Dava,[1 2],'omitnan')) ; 
Hadgrid_rain_1km_anomaly_Dava_25 = squeeze(prctile(Hadgrid_rain_1km_anomaly_Dava,25,[1 2])) ; 
Hadgrid_rain_1km_anomaly_Dava_75 = squeeze(prctile(Hadgrid_rain_1km_anomaly_Dava,75,[1 2])) ; 



% interpolate datasets to get better performance of fill
Hadgrid_rain_1km_anomaly_Dava_median = interp1(Hadgrid_rain_1km_anomaly_Dava_median,linspace(1,127,1000)) ; 
Hadgrid_time_monthly = linspace(Hadgrid_time_monthly(1),Hadgrid_time_monthly(end),1000) ; 



%%%%%%%%%%%%%% rain %%%%%%%%%%%%%%

Fig_Panel = figure('units','centimeters','position',[10 2 33 18])  ;

% Plot the anomaly line
plot(Hadgrid_time_monthly, Hadgrid_rain_1km_anomaly_Dava_median, ...
    '-', 'LineWidth', 1, 'Color', 'k') ;
hold on
yline(0, 'k--');
yline(median(Hadgrid_rain_1km_anomaly_Dava_median(Hadgrid_time_monthly > datetime('01-Jun-2025')),'omitnan'), 'r--');
% --- Positive anomalies (blue) ---
yPos = Hadgrid_rain_1km_anomaly_Dava_median;
yPos(yPos < 0) = 0;   % keep only >0
x2 = [Hadgrid_time_monthly, fliplr(Hadgrid_time_monthly)];
inBetween = [yPos, fliplr(zeros(size(yPos))) ];
fill(x2, inBetween, redblue_color(50-20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

% --- Negative anomalies (red) ---
yNeg = Hadgrid_rain_1km_anomaly_Dava_median;
yNeg(yNeg > 0) = 0;   % keep only <0
inBetween = [yNeg, fliplr(zeros(size(yNeg))) ];
fill(x2, inBetween, redblue_color(51+20,:), 'FaceAlpha', 0.5, 'EdgeColor','none');

xlim([datetime('01-Jan-2015')   datetime('16-Jul-2025') ])
xtickangle(45)
% xlabel('Time','FontSize',16)
ylabel('Precipitation anomaly','FontSize',16)
fontsize(18,'points')
grid on;


saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\Rain_zscore_anomalies_ts_shade','svg')
saveas(Fig_Panel,'F:\projects\Dava_wildfire\figures_02\Rain_zscore_anomalies_ts_shade','png')
close





%%
load('F:\Met_Office_Had_UK\processed\Hadgrid_rain_1km_anomaly_Dava')


[fP,xiP]   = ksdensity(Hadgrid_rain_1km_anomaly_Dava(:),linspace(-5,5,1000)) ; 

Jun_2025 = Hadgrid_time_monthly > datetime('01-Jan-2025')  ; 

Hadgrid_rain_1km_anomaly_Dava_Jun = Hadgrid_rain_1km_anomaly_Dava(:,:,Jun_2025) ; 


[fP_Jan,xiP_Jun]   = ksdensity(Hadgrid_rain_1km_anomaly_Dava_Jun(:),linspace(-5,5,1000)) ; 



save('F:\projects\Dava_wildfire\data\plotting data\fP','fP')
save('F:\projects\Dava_wildfire\data\plotting data\fP_Jan','fP_Jan')






