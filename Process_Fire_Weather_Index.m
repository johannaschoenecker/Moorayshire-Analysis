%% MJB 26-09-2025 INvestigate Fire Weather index cause Hadgrid temp is down
clear


cd('F:\Fire_Weather_Index')


FWI_info = ncinfo('74296f80b2affe1e11929f84df19538.nc') ; 
FWI_read = ncread('74296f80b2affe1e11929f84df19538.nc','fwinx') ; 

% I believe lat and lons are centroid location, with two 90° centroid on
% either end.
FWI_latitude = ncread('74296f80b2affe1e11929f84df19538.nc','latitude') ; 
FWI_longitude = ncread('74296f80b2affe1e11929f84df19538.nc','longitude') ;

% 'seconds since 1970-01-01'
FWI_time = ncread('74296f80b2affe1e11929f84df19538.nc','valid_time') ; 
FWI_time = datetime('01-Jan-1970') + seconds(FWI_time) ; 
FWI_time2 = ncread('260db8c2533a5fc76e2a3fd0b8762f81.nc','valid_time') ; 
FWI_time2 = datetime('01-Jan-1970') + seconds(FWI_time2) ; 
FWI_time3 = ncread('971a673e192a8addb0401be13bf4b930.nc','valid_time') ; 
FWI_time3 = datetime('01-Jan-1970') + seconds(FWI_time3) ; 




save('F:\Fire_Weather_Index\processed\FWI_time','FWI_time') ; 
save('F:\Fire_Weather_Index\processed\FWI_time2','FWI_time2') ;
save('F:\Fire_Weather_Index\processed\FWI_time3','FWI_time3') ;

save('F:\Fire_Weather_Index\processed\FWI_latitude','FWI_latitude') ; 
save('F:\Fire_Weather_Index\processed\FWI_longitude','FWI_longitude') ; 

FWI_longitude = FWI_longitude - 180 ; 

FWI_read2 = ncread('260db8c2533a5fc76e2a3fd0b8762f81.nc','fwinx') ; 

FWI_read3 = ncread('971a673e192a8addb0401be13bf4b930.nc','fwinx') ; 


%% process FWI data
FWI_read_mean = mean(FWI_read,3,'omitnan') ; 
imagesc(FWI_read_mean) ; 


FWI_read = permute(FWI_read,[2 1 3]) ; 
FWI_read2 = permute(FWI_read2,[2 1 3]) ; 
FWI_read3 = permute(FWI_read3,[2 1 3]) ; 


for i = 1:3469

    dummy = FWI_read(:,:,i) ; 
    FWI_read(:,1:720,i) = dummy(:,721:end) ; 
    FWI_read(:,721:end,i) = dummy(:,1:720) ; 

    i

end

for i = 1:365

    dummy = FWI_read2(:,:,i) ; 
    FWI_read2(:,1:720,i) = dummy(:,721:end) ; 
    FWI_read2(:,721:end,i) = dummy(:,1:720) ; 

    i

end


for i = 1:116

    dummy = FWI_read3(:,:,i) ; 
    FWI_read3(:,1:720,i) = dummy(:,721:end) ; 
    FWI_read3(:,721:end,i) = dummy(:,1:720) ; 

    i
end





save('F:\Fire_Weather_Index\processed\FWI_read','FWI_read','-v7.3') ; 
save('F:\Fire_Weather_Index\processed\FWI_read2','FWI_read2','-v7.3') ; 
save('F:\Fire_Weather_Index\processed\FWI_read3','FWI_read3','-v7.3') ; 


save('F:\Fire_Weather_Index\processed\FWI_read_full','FWI_read','-v7.3') ; 
save('F:\Fire_Weather_Index\processed\FWI_read_full2','FWI_read2','-v7.3') ; 
save('F:\Fire_Weather_Index\processed\FWI_read3','FWI_read3','-v7.3') ; 




% indices to extract to roughly only get scotland
% 100:170
% 660:760

FWI_read = FWI_read(100:170,660:760,:) ; 
FWI_read2 = FWI_read2(100:170,660:760,:) ; 
FWI_latitude = FWI_latitude(100:170,660:760) ; 
FWI_longitude = FWI_longitude(100:170,660:760) ; 

save('F:\Fire_Weather_Index\processed\FWI_latitude','FWI_latitude') ; 
save('F:\Fire_Weather_Index\processed\FWI_longitude','FWI_longitude') ; 
save('F:\Fire_Weather_Index\processed\FWI_read','FWI_read','-v7.3') ; 
save('F:\Fire_Weather_Index\processed\FWI_read2','FWI_read2','-v7.3') ; 


save('F:\Fire_Weather_Index\processed\FWI_latitude_all','FWI_latitude') ; 
save('F:\Fire_Weather_Index\processed\FWI_longitude_all','FWI_longitude') ;


%% load latlos for inDava and inScotland
clear

load('F:\Fire_Weather_Index\processed\FWI_read3') ;
load('F:\Fire_Weather_Index\processed\FWI_read2') ;
load('F:\Fire_Weather_Index\processed\FWI_read') ;
load('F:\Fire_Weather_Index\processed\FWI_latitude') ; 
load('F:\Fire_Weather_Index\processed\FWI_longitude') ; 
load('F:\Fire_Weather_Index\processed\FWI_time') ; 
load('F:\Fire_Weather_Index\processed\FWI_time2') ; 
load('F:\Fire_Weather_Index\processed\FWI_time3') ; 


% FWI_latitude = repmat(FWI_latitude,[1 1440]) ; 
% FWI_longitude = repmat(FWI_longitude',[721 1]) ; 

% FWI_time3 = FWI_time(1):days(1):FWI_time(end) ;
% FWI_time = FWI_time3 ; 
% FWI_read_3 = NaN(71,101,3834) ; 
% FWI_read_3(:,:,1:1096) = FWI_read(:,:,1:1096) ; 
% FWI_read_3(:,:,1097:1097+364) = FWI_read2; 
% FWI_read_3(:,:,1097+364+1:end) = FWI_read(:,:,1097:end); 
% 
% FWI_read = FWI_read_3 ; 



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


% Effis_lon(isnan(Effis_lon)) = [] ;
% Effis_lat(isnan(Effis_lat)) = [] ;
inScotlandFWI = inpolygon(FWI_longitude, FWI_latitude, cell2mat(GADM_Scotlandlatlon.Lon),  cell2mat(GADM_Scotlandlatlon.Lat));
inDavaFWI = inpolygon(FWI_longitude, FWI_latitude, Effis_lon,  Effis_lat);


save('F:\Fire_Weather_Index\processed\inScotlandFWI','inScotlandFWI') ; 
save('F:\Fire_Weather_Index\processed\inDavaFWI','inDavaFWI') ; 

% load FWI and cut 
load('F:\Fire_Weather_Index\processed\FWI_read') ; 


[rowdummy coldummy] = find(inDavaFWI) ; 
FWI_read_Dava = squeeze(FWI_read(rowdummy,coldummy,:)) ; 
save('F:\Fire_Weather_Index\processed\FWI_read_Dava','FWI_read_Dava','-v7.3') ; 








%% aggregate to monthly 

load('F:\Fire_Weather_Index\processed\FWI_read_Dava') ; 

inScotlandFWI = repmat(inScotlandFWI,[1 1 3834]) ; 
FWI_read(~inScotlandFWI) = NaN ; 
FWI_read_zscore = (FWI_read - mean(FWI_read,3,'omitnan')) ./ std(FWI_read,1,3,'omitnan') ; 

imagesc(mean(FWI_read,3,'omitnan'))

startMonth = dateshift(FWI_time(:), 'start', 'month');
endMonth   = dateshift(FWI_time(:), 'end', 'month');
midMonthDates = startMonth + days(days(endMonth - startMonth) / 2);
midMonthDates_unique = unique(midMonthDates) ; 
midMonthDates_uniqueFWI = midMonthDates_unique ; 
[yall mall dall] = ymd(FWI_time) ; 


Dava_FWI_mean_zscore_m = NaN([126 1]) ; 
Dava_FWI_mean_m = NaN([126 1]) ; 

Scotland_FWI_mean_zscore_m = NaN([71 101 126]) ; 
Scotland_FWI_mean_m = NaN([71 101 126]) ; 


for i = 1:length(midMonthDates_unique)

    [y m d] = ymd(midMonthDates_unique(i)) ; 
    [Lia Locb] = find(yall == y & mall == m) ; 
    [Liaallm Locballm] = find(mall == m) ;     

    FWI_monthly_mean = mean(FWI_read(:,:,Locb),3,'omitnan') ;
    FWI_monthly_std =  std(FWI_read(:,:,Locb),1,3,'omitnan') ;
    FWI_allmonth_mean = mean(FWI_read(:,:,Locballm),3,'omitnan') ;    
    FWI_allmonth_std =  std(FWI_read(:,:,Locballm),1,3,'omitnan') ;      

    FWI_Dava_monthly_mean = mean(FWI_read_Dava(Locb),1,'omitnan') ;
    FWI_Dava_monthly_std =  std(FWI_read_Dava(Locb),1,1,'omitnan') ;
    FWI_Dava_allmonth_mean = mean(FWI_read_Dava(Locballm),1,'omitnan') ;    
    FWI_Dava_allmonth_std =  std(FWI_read_Dava(Locballm),1,1,'omitnan') ;  

    Scotland_FWI_mean_zscore_m(:,:,i) = (FWI_monthly_mean - FWI_allmonth_mean) ./ FWI_allmonth_std ;
    Scotland_FWI_mean_m(:,:,i) = FWI_monthly_mean  ;     
  
    Dava_FWI_mean_zscore_m(i) = (FWI_Dava_monthly_mean - FWI_Dava_allmonth_mean) ./ FWI_Dava_allmonth_std ;
    Dava_FWI_mean_m(i) = FWI_Dava_monthly_mean  ;    


i
end

midMonthDates_unique = midMonthDates_unique' ; 


save('F:\projects\Dava_wildfire\data\plotting data\Scotland_FWI_mean_zscore_m','Scotland_FWI_mean_zscore_m')
save('F:\projects\Dava_wildfire\data\plotting data\Scotland_FWI_mean_m','Scotland_FWI_mean_m')
save('F:\projects\Dava_wildfire\data\plotting data\Dava_FWI_mean_zscore_m','Dava_FWI_mean_zscore_m')
save('F:\projects\Dava_wildfire\data\plotting data\Dava_FWI_mean_m','Dava_FWI_mean_m')
save('F:\projects\Dava_wildfire\data\plotting data\midMonthDates_uniqueFWI','midMonthDates_uniqueFWI')





%% get global in correct order


load('FWI_read_full.mat')
load('FWI_read_full.mat')
load('FWI_read_full2.mat')
load('F:\Fire_Weather_Index\processed\FWI_latitude') ; 
load('F:\Fire_Weather_Index\processed\FWI_longitude') ; 
load('F:\Fire_Weather_Index\processed\FWI_time') ; 
load('F:\Fire_Weather_Index\processed\FWI_time2') ; 
load('F:\Fire_Weather_Index\processed\FWI_time3') ; 



full_datetime = FWI_time(1):days(1):FWI_time3(end) ; 
FWI_global_Jan_2015_Oct_2025 = NaN(721,1440,3950) ; 


for i = 1:length(full_datetime)


    dummy_date = full_datetime(i) ; 

    datefind_1 = find(dummy_date == FWI_time) ; 
    datefind_2 = find(dummy_date == FWI_time2) ; 
    datefind_3 = find(dummy_date == FWI_time3) ; 

    if ~isempty(datefind_1)

        FWI_global_Jan_2015_Oct_2025(:,:,i) = FWI_read(:,:,datefind_1) ;
        
    end

    if ~isempty(datefind_2)

        FWI_global_Jan_2015_Oct_2025(:,:,i) = FWI_read(:,:,datefind_2) ;
        
    end

    if ~isempty(datefind_3)

        FWI_global_Jan_2015_Oct_2025(:,:,i) = FWI_read(:,:,datefind_3) ;
        
    end

i

end


FWI_datetime_2015_2025 = full_datetime ; 
save('F:\Fire_Weather_Index\processed\FWI_global_Jan_2015_Oct_2025','FWI_global_Jan_2015_Oct_2025','-v7.3') ; 
save('F:\Fire_Weather_Index\processed\FWI_datetime_2015_2025','FWI_datetime_2015_2025','-v7.3') ; 


test = squeeze(FWI_global_Jan_2015_Oct_2025(200,1200,:)) ; 
plot(test)




