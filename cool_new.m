clc
clearvars
warning off

region_str = "piemonte";
italy = shaperead("DATA/gadm36_ITA_1.shp");
[region,  ~    , conf_mi, conf_ma] = region_select(region_str);

load DATA\SRTM.mat
elevation_h = elevation_srtm*9.81;
[latitude_era,longitude_era,z_ERA5] = load_data('DATA/ERA5/ERA5_2008_6hrs.nc','z',conf_mi,conf_ma);
[    ~       ,      ~      ,T_ERA5] = load_data('DATA/ERA5/ERA5_2008_6hrs.nc','t',conf_mi,conf_ma);
T_ERA5 = T_ERA5-273;
TA = mean(T_ERA5(:,:,:,1:4),4,'omitnan');
level_e = double(ncread('DATA/ERA5/ERA5_2008_6hrs.nc','level'));

lev = linspace(400,1000,100)';

[TA, ~] = regrid_mask(latitude_era,longitude_era,latitude_era,longitude_era,TA,region,region_str, 'bilinear');

%%
for i = 1:length(latitude_era)
    for j = 1:length(longitude_era)
        z_reg(i,j,:,:) = interp1(level_e,squeeze(z_ERA5(i,j,:,:)),lev,'linear');
        T_reg(i,j,:,:) = interp1(level_e,squeeze(TA(i,j,:)),lev,'linear');
    end
end

[z_reg_n, ~] = regrid_mask(latitude_era,longitude_era,latitude_srtm(1000:1900),longitude_srtm(900:1800),z_reg(:,:,:,1),region, 'none', 'bilinear');
[T_reg_n, ~] = regrid_mask(latitude_era,longitude_era,latitude_srtm(1000:1900),longitude_srtm(900:1800),T_reg,region, 'none', 'bilinear');
[elevation_h, ~] = regrid_mask(latitude_srtm,longitude_srtm,latitude_srtm(1000:1900),longitude_srtm(900:1800),elevation_h, region,'none', 'bilinear');


for i = 1:size(T_reg_n,1)
    for j = 1:size(T_reg_n,2)
        for t = 1:size(z_reg_n,4)
            [c in(i,j)] = min(abs(z_reg_n(i,j,:,t)-elevation_h(i,j)));
        end
    end
end

for i = 1:size(T_reg_n,1)
    for j = 1:size(T_reg_n,2)
        for t = 1:size(T_reg_n,4)
            T_mod(i,j,t) = T_reg_n(i,j,in(i,j),t);
        end
    end
end


%%
% [latitude_st,longitude_st,elevation_st,temperature_st] = station(2008);

f1 = figure;
f1.Position = [90 90 800 600];

s = pcolor(longitude_srtm,latitude_srtm,elevation_srtm.*mask_tot_high);
s.EdgeColor = 'none';
hold on
for i = 1:length(longitude_era)
    for j = 1:length(latitude_era)
        scatter(longitude_era(i),latitude_era(j),40,TA(j,i,1)-10000,'filled')
        hold on
    end
end
caxis([-2000 3000])

%%
f2 = figure;
f2.Position = [90 90 800 600];
for i = 4:6
    for j = 4:6
        for h = 5 : size(z_ERA5,3)-1
            if i == 4 & j == 2 & h == size(z_ERA5,3)-1
                scatter3(latitude_era(i),longitude_era(j),z_ERA5(i,j,h,1)/9.81,50,TA(i,j,h),'filled','o','MarkerEdgeColor','k','DisplayName','ERA5 data');
                legend
            else
                scatter3(latitude_era(i),longitude_era(j),z_ERA5(i,j,h,1)/9.81,50,TA(i,j,h),'filled','o','MarkerEdgeColor','k','HandleVisibility','off');
            end
            hold on
        end
    end
end

for h = 30 : size(z_reg_n,3)-1
    if h == 30
        s = surf(latitude_srtm(1000:1900),longitude_srtm(900:1800),z_reg_n(:,:,h,1)/9.81,'CData',T_reg_n(:,:,h),'FaceAlpha',0.05,'DisplayName','Regridded field');
        s.EdgeColor = 'none';
    else
        s = surf(latitude_srtm(1000:1900),longitude_srtm(900:1800),z_reg_n(:,:,h,1)/9.81,'CData',T_reg_n(:,:,h),'FaceAlpha',0.05,'HandleVisibility','off');
        s.EdgeColor = 'none';
    end

    hold on
end
hold off
legend


% Create doublearrow
annotation(f2,'doublearrow',[0.5 0.77388888888889],...
    [0.0678391959798995 0.1821608040201]);

% Create doublearrow
annotation(f2,'doublearrow',[0.106944444444444 0.318055555555556],...
    [0.220590909090909 0.0579545454545455]);

% Create textbox
annotation(f2,'textbox',...
    [0.0560000000000002 0.0933188670625853 0.145944444444444 0.0515075376884421],...
    'String',{'Method	-> Nearest','Ratio 		-> 1:300'},...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create doublearrow
annotation(f2,'doublearrow',[0.7975 0.7975],...
    [0.669454545454545 0.297727272727273]);

% Create textbox
annotation(f2,'textbox',...
    [0.674888888888889 0.07286432160804 0.145944444444444 0.0515075376884422],...
    'String',{'Method	-> Nearest','Ratio 		-> 1:300'},...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation(f2,'textbox',...
    [0.811555555555557 0.480818867062585 0.145944444444444 0.0515075376884422],...
    'String',{'Method	-> Linear','Ratio 		-> ~ 1:5'},...
    'FontSize',13,...
    'FitBoxToText','off',...
    'EdgeColor','none');

colorbar('northoutside')
zlabel('Elevation [m]')
set(gca,'fontsize',13)
view([49.4398067665345 32.9460041393254]);
