clc
clearvars
warning off

region_str = "piemonte";
discr_altitude_value = 50;
years = [2020];
%years = linspace(1990,2020,31);

italy = shaperead("DATA/gadm36_ITA_1.shp");
[region,  ~    , conf_mi, conf_ma] = region_select(region_str);

load DATA\SRTM.mat
elev_ori = elevation_srtm;

[    ~       ,      ~      ,T_ERA5] = load_data(['DATA/ERA5/ERA5_' num2str(years) '_6hrs.nc'],'t',conf_mi,conf_ma);
[latitude_era,longitude_era,z_ERA5] = load_data(['DATA/ERA5/ERA5_' num2str(years) '_6hrs.nc'],'z',conf_mi,conf_ma);
level_e = double(ncread(['DATA/ERA5/ERA5_' num2str(years) '_6hrs.nc'],'level'));
T_ERA5 = T_ERA5 - 273;

%%
[X,Y] = meshgrid(1:10,1:10);

f2 = figure;
f2.Position = [90 90 800 600];

for i = 1:size(T_ERA5,3)
    c = z_ERA5(5,5,i,400)/9.81*ones([10 10]);
    t = T_ERA5(5,5,i,400)*ones([10 10]);
    s = surf(X,Y,c,t);
    s.EdgeColor = 'none';
    s.FaceAlpha = 0.2;
    
    yticklabels([])
    xticklabels([])

    hold on
    scatter3(5,5,c(1,1),500,t(1,1),'filled')
end
zticks(linspace(0,6000,11))
zlabel('Quota [m]')
colorbar
set(gca,'Fontsize',13)
zlim([0 4000])
caxis([-4 20])
scatter3(4,8,2135,100,'k','filled')

%%

f2 = figure;
f2.Position = [90 90 800 600];

scatter(squeeze(T_ERA5(5,5,:,400)),squeeze(z_ERA5(5,5,:,400))./9.81,200,'red','*','DisplayName','Valori ERA5')
hold on 
plot(squeeze(T_ERA5(5,5,:,400)),squeeze(z_ERA5(5,5,:,400))./9.81,'b','DisplayName','Valori interpolati')
hold on
scatter(5,2135,100,'k','filled','DisplayName','Stazione')
ylim([0 4000])
legend
ylabel('Quota [m]')
xlabel('Temperatura [°C]')
set(gca,'Fontsize',13)
grid on