clc
clear all

display('LOADING DATA')

italy = shaperead("DATA/gadm36_ITA_1.shp");
region_str = ["piemonte"];
[region, limits, conf_mi, conf_ma] = region_select(region_str);
f = 
timeit(region_select(region_str))
%%
display('Geographic data done')

[latitude_era,longitude_era,elevation_era] = load_data('DATA/ERA5/geo_height_ERA5.nc','z',conf_mi,conf_ma);
elevation_era_ori = elevation_era./9.81;
display('ERA5 land orography done')

load H_high.mat
load DATA\mask_high.mat

latitude = lat_high';
longitude = lon_high';
i_lon_min = find(longitude>conf_mi(1));
i_lon_max = find(longitude<conf_ma(1));
i_lat_min = find(latitude>conf_mi(2));
i_lat_max = find(latitude<conf_ma(2));
longitude_srtm = double(longitude(i_lon_min(1):i_lon_max(end)));
latitude_srtm = double(latitude(i_lat_min(1):i_lat_max(end)));
elevation_srtm_ori = H_high(i_lat_min(1):i_lat_max(end),i_lon_min(1):i_lon_max(end));
mask_tot_high = mask_piemonte_high(i_lat_min(1):i_lat_max(end),i_lon_min(1):i_lon_max(end));
display('SRTM orography done')

meta = readtable('STAZIONI\staz_metadata.xlsx');
[latitude_st, longitude_st] = utm2deg(meta.Longitudine,meta.Latitudine,char(meta.Zona));
elevation_st = meta.H;
display('In situ stations orography done')

display('DATA LOADED')
display('----------------')

clear lat_high lon_high i_lon_max i_lon_min i_lat_max i_lat_min H_high mask_aosta_high

%%
display('CHECKING STATIONS CONSISTANCY')
alpha = 50;
display(['Discrimant value: ' num2str(alpha) ' m'])

longitude_tot = sort(cat(1, longitude_srtm, longitude_st));
latitude_tot = sort(cat(1, latitude_srtm, latitude_st));
[elevation_temp, ~] = regrid_mask(latitude_srtm,longitude_srtm,latitude_tot,longitude_tot,elevation_srtm_ori,region, 'none', 'nearest');

reject = zeros([1 length(elevation_st)]);
reject_bound = zeros([1 length(elevation_st)]);
reject_elev = zeros([1 length(elevation_st)]);
for i = 1:length(elevation_st)
    if ~inpolygon(longitude_st(i),latitude_st(i),region(1).X,region(1).Y);
        reject_bound(i) = 1;
    else
        i_lat = find(latitude_tot==latitude_st(i));
        i_lon = find(longitude_tot==longitude_st(i));
        elev_model(i) = elevation_temp(i_lat(1),i_lon(1));
        err(i) = abs(elev_model(i) - elevation_st(i));
        if err(i) > alpha
            reject_elev(i) = 1;
        end
    end
end

reject = reject_bound+reject_elev;

elevation_rej = elevation_st(reject > 0);
latitude_rej = latitude_st(reject > 0);
longitude_rej = longitude_st(reject > 0);

elevation_st(reject > 0) = [];
latitude_st(reject > 0) = [];
longitude_st(reject > 0) = [];

display([num2str(sum(reject_elev)) ' stations rejected for elevation discrepance'])
display([num2str(sum(reject_bound)) ' stations rejected for boundaries'])

display('CONSISTANCY CHECK DONE')
display('----------------')

clear elevation_temp

%%
display('SPLITTING IN CALIBRATION AND VALIDATION DATA')

val_ind = [1:1:length(longitude_st)];
vfg = [1:5:length(longitude_st)];
val_ind(vfg) = [];

elevation_val = elevation_st(val_ind);
latitude_val = latitude_st(val_ind);
longitude_val = longitude_st(val_ind);

elevation_st(val_ind) = [];
latitude_st(val_ind) = [];
longitude_st(val_ind) = [];

display([num2str(length(elevation_st)) ' stations for calibration'])
display([num2str(length(elevation_val)) ' stations for validation'])

display('SPLITTING DONE')
display('----------------')
%%

display('MASKING DATA')
elev = nan * zeros([size(elevation_srtm_ori,1)*size(elevation_srtm_ori,2) 2]);

elevation_srtm = elevation_srtm_ori.*mask_tot_high;
elev(:,1) = reshape(elevation_srtm,[size(elevation_srtm,1)*size(elevation_srtm,2) 1]);
display(['SRTM done         ' num2str(sum(~isnan(elev(:,1)))) ' data points'])

[elevation_era, ~] = regrid_mask(latitude_era,longitude_era,latitude_era,longitude_era,elevation_era_ori,region, region_str, 'bilinear');
elev(1:size(elevation_era,1)*size(elevation_era,2),2) = reshape(elevation_era,[size(elevation_era,1)*size(elevation_era,2) 1]);
display(['ERA5 done         ' num2str(sum(~isnan(elev(:,2)))) ' data points'])

datasets = categorical(["SRTM","ERA5"]);

display('DATA MASKED')
display('----------------')

quot = linspace(0, 3500, 300);
dens_srtem = histcounts(elevation_srtm,quot);
dens_era = histcounts(elevation_era,quot);

s = [sum(~isnan(elevation_srtm(:))) sum(~isnan(elevation_era(:)))];

%%

f2 = figure;
f2.Position = [90 90 1200 600];
t = tiledlayout(1,6);
t.TileSpacing = 'none';

nexttile
boxchart(elev(:,1),'BoxFaceColor','k','MarkerStyle','+','MarkerColor','k')
set(gca,'FontSize',13)
xticklabels([])
grid on

nexttile([1 5])
worldmap([conf_mi(2) conf_ma(2)], ...  % Basemap
    [conf_mi(1) conf_ma(1)]);
s = pcolorm(latitude_srtm,longitude_srtm,elevation_srtm);      % Map                 
s.EdgeColor = 'none';
hold on
h = pcolorm(latitude_srtm,longitude_srtm,elevation_srtm_ori,'FaceAlpha',0.2);      % Map                 
h.EdgeColor = 'none';
colormap('parula')
caxis([0 3000])
c = colorbar("southoutside");
c.Label.String = 'Elevation [m]';
for i =1:length(region)
    plotm(region(i).Y,region(i).X,'Color','k','LineWidth',2)
    hold on 
end
set(gca,'FontName','Calibri')
set(gca,'FontSize',13)

xtickformat('degrees')
set(gca,'FontName','Calibri')
set(gca,'FontSize',13)
setm(gca,'mapprojection','giso')
setm(gca,'MLabelLocation',1)


