%% MJB 27.01.2026 read ERA5 monthly 1940-now for morayshire fire. DO plots as well probably

clear

cd('F:\ERA_5_monthly\SM_monthly_Dava')

ERA_info_data = ncinfo("c19cf6167c3b8b9cde6f03987c46836.nc") ; 



% read the data
ERA5_month_Scot_lat = ncread("c19cf6167c3b8b9cde6f03987c46836.nc",'latitude') ; 
ERA5_month_Scot_lon = ncread("c19cf6167c3b8b9cde6f03987c46836.nc",'longitude') ;
ERA5_month_Scot_time = ncread("c19cf6167c3b8b9cde6f03987c46836.nc",'valid_time') ;
ERA5_month_Scot_SM1 = ncread("c19cf6167c3b8b9cde6f03987c46836.nc",'swvl1') ;


ERA5_month_Scot_SM1 = permute(ERA5_month_Scot_SM1,[2 1 3]) ; 
ERA5_month_Scot_SM1(ERA5_month_Scot_SM1 == 0) = NaN ; 

% seconds since 1970-01-01
ERA5_month_Scot_time = datetime('01-Jan-1970') + seconds(ERA5_month_Scot_time) ; 


save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_lat','ERA5_month_Scot_lat') ; 
save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_lon','ERA5_month_Scot_lon') ; 
save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_time','ERA5_month_Scot_time') ; 
save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_SM1','ERA5_month_Scot_SM1') ; 



plot(squeeze(mean(ERA5_month_Scot_SM1,[1 2],'omitnan')))




load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\inScotland_ERA')

for i = 1:size(ERA5_month_Scot_SM1,3)

    dummy = ERA5_month_Scot_SM1(:,:,i) ;
    dummy(~inScotland_ERA) = NaN ; 
    ERA5_month_Scot_SM1(:,:,i) = dummy ; 


end






imagesc(mean(ERA5_month_Scot_SM1,3,'omitnan'))

%% Process to Dava extent and Scotland extent
clear 
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




load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_lat') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_lon') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_time') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_SM1') ; 

ERA5_month_Scot_lat = repmat(ERA5_month_Scot_lat,[1 52]) ; 
ERA5_month_Scot_lon = repmat(ERA5_month_Scot_lon',[39 1]) ; 



inScotland_ERA = inpolygon(ERA5_month_Scot_lon, ERA5_month_Scot_lat, cell2mat(GADM_Scotlandlatlon.Lon),  cell2mat(GADM_Scotlandlatlon.Lat));
save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\inScotland_ERA','inScotland_ERA') ; 



imagesc(ERA5_month_Scot_lon(1,:),(ERA5_month_Scot_lat(:,1)),(mean(ERA5_month_Scot_SM1,3,'omitnan')));
hold on 
plot(Effis_lon,Effis_lat);
xticks

% loaction of fire perimeter
% ys = [7, 8]
% xs = [26, 27]


% extract coords from SM 
ERA5_month_Dava_SM1 = ERA5_month_Scot_SM1(7:8,26:27,:) ; 

ERA5_month_Dava_lat = ERA5_month_Scot_lat(7:8,26:27) ; 
ERA5_month_Dava_lon = ERA5_month_Scot_lon(7:8,26:27) ; 



save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_SM1','ERA5_month_Dava_SM1') ; 
save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_lat','ERA5_month_Dava_lat') ; 
save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_lon','ERA5_month_Dava_lon') ; 



%% get SM anomalies relative to month 

load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_lat') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_lon') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_time') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_SM1') ;
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_SM1') ; 
startMonth = dateshift(ERA5_month_Scot_time(:), 'start', 'month');
endMonth   = dateshift(ERA5_month_Scot_time(:), 'end', 'month');
% Middle of each month = halfway between start and end
midMonthDates = startMonth + days(days(endMonth - startMonth) / 2);
midMonthDates_unique = unique(midMonthDates) ; 
[ydummyall mdummyall ddummyall] = ymd(midMonthDates_unique) ; 


ERA5_month_Scot_SM1_anomaly = NaN(size(ERA5_month_Scot_SM1)) ; 
ERA5_month_Dava_SM1_anomaly = NaN(size(ERA5_month_Dava_SM1)) ; 

ERA5_month_Dava_SM1(ERA5_month_Dava_SM1 == 0) = NaN ; 
ERA5_month_Scot_SM1(ERA5_month_Scot_SM1 == 0) = NaN ; 

ERA5_month_Dava_SM1(ERA5_month_Dava_SM1 < 0.001) = NaN ; 
ERA5_month_Scot_SM1(ERA5_month_Scot_SM1 < 0.001) = NaN ; 



for i = 1:length(midMonthDates_unique)

    dummy_date = midMonthDates_unique(i) ; 
    [ydummy mdummy ddummy] = ymd(dummy_date) ; 
    [Lia Locb] = find(mdummy == mdummyall) ; 

    SM_Scot_monthly_mean = mean(ERA5_month_Scot_SM1(:,:,Lia),3,'omitnan') ;
    SM_Scot_monthly_std =  std(ERA5_month_Scot_SM1(:,:,Lia),1,3,'omitnan') ;

    SM_Dava_monthly_mean = mean(ERA5_month_Dava_SM1(:,:,Lia),3,'omitnan') ;
    SM_Dava_monthly_std =  std(ERA5_month_Dava_SM1(:,:,Lia),1,3,'omitnan') ;
    
    ERA5_month_Scot_SM1_anomaly(:,:,i) = (ERA5_month_Scot_SM1(:,:,i) - SM_Scot_monthly_mean) ./ SM_Scot_monthly_std ;
    ERA5_month_Dava_SM1_anomaly(:,:,i) = (ERA5_month_Dava_SM1(:,:,i) - SM_Dava_monthly_mean) ./ SM_Dava_monthly_std ;
i
end

histogram(ERA5_month_Scot_SM1_anomaly)
histogram(ERA5_month_Dava_SM1_anomaly)



save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_SM1_anomaly','ERA5_month_Scot_SM1_anomaly') ; 
save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_SM1_anomaly','ERA5_month_Dava_SM1_anomaly') ; 




%% get annual anomalies
clear


load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_lat') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_lon') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_time') ; 
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_SM1') ;
load('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_SM1') ; 
startMonth = dateshift(ERA5_month_Scot_time(:), 'start', 'month');
endMonth   = dateshift(ERA5_month_Scot_time(:), 'end', 'month');
% Middle of each month = halfway between start and end
midMonthDates = startMonth + days(days(endMonth - startMonth) / 2);
midMonthDates_unique = unique(midMonthDates) ; 
[ydummyall mdummyall ddummyall] = ymd(midMonthDates_unique) ; 


ydummyall_unique = unique(ydummyall) ; 


ERA5_month_Scot_SM1_anomaly_y = NaN(39,52,86) ; 
ERA5_month_Dava_SM1_anomaly_y = NaN(2,2,86) ; 

ERA5_month_Dava_SM1(ERA5_month_Dava_SM1 == 0) = NaN ; 
ERA5_month_Scot_SM1(ERA5_month_Scot_SM1 == 0) = NaN ; 

ERA5_month_Dava_SM1(ERA5_month_Dava_SM1 < 0.001) = NaN ; 
ERA5_month_Scot_SM1(ERA5_month_Scot_SM1 < 0.001) = NaN ; 




for i = 1:length(ydummyall_unique)

    dummy_y = ydummyall_unique(i) ; 
    [Lia Locb] = find(dummy_y == ydummyall) ; 

    SM_Scot_monthly_mean = mean(ERA5_month_Scot_SM1,3,'omitnan') ;
    SM_Scot_monthly_std =  std(ERA5_month_Scot_SM1,1,3,'omitnan') ;

    SM_Dava_monthly_mean = mean(ERA5_month_Dava_SM1,3,'omitnan') ;
    SM_Dava_monthly_std =  std(ERA5_month_Dava_SM1,1,3,'omitnan') ;
    
    ERA5_month_Scot_SM1_anomaly_y(:,:,i) = (mean(ERA5_month_Scot_SM1(:,:,Lia),3,'omitnan') - SM_Scot_monthly_mean) ./ SM_Scot_monthly_std ;
    ERA5_month_Dava_SM1_anomaly_y(:,:,i) = (mean(ERA5_month_Dava_SM1(:,:,Lia),3,'omitnan') - SM_Dava_monthly_mean) ./ SM_Dava_monthly_std ;
i
end



histogram(ERA5_month_Scot_SM1_anomaly_y)

histogram(ERA5_month_Dava_SM1_anomaly_y)



save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Scot_SM1_anomaly_y','ERA5_month_Scot_SM1_anomaly_y') ; 
save('F:\projects\Dava_wildfire\data\ERA5_monthly_SM\ERA5_month_Dava_SM1_anomaly_y','ERA5_month_Dava_SM1_anomaly_y') ; 




