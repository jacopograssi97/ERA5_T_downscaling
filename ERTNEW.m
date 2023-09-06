clc
clearvars
warning off

region_str = "piemonte";
discr_altitude_value = 50;
years = [2020];
%years = linspace(1990,2020,31);

[latitude_calibration, longitude_calibration, elevation_calibration, temperature_calibration, error_calibration, T_model_calibration, ...
 latitude_validation, longitude_validation, elevation_validation, temperature_validation, error_validation, T_model_validation, ...
 TRA, TRB, T_y_m, T_y_s]...
 = SRTM_down(years, region_str, discr_altitude_value);


%%
TRAm = movmean(TRA,365);
TRBm = movmean(TRB,365);

figure
yyaxis left
plot(movmean(TRA,365),'displayname','model')
hold on
plot(movmean(TRB,365),'displayname','stations')
ylim([-5 30])
yyaxis right
area(movmean(TRA,365)-movmean(TRB,365))
ylim([-5 30])
legend

figure
plot(movmean(TRA,365),'displayname','model')
hold on
plot(movmean(TRB,365),'displayname','stations')
legend

%     lati = linspace(min(latitude_era),max(latitude_era),40);
%     longi = linspace(min(longitude_era),max(longitude_era),40);
%     latu = linspace(min(latitude_era),max(latitude_era),50);
%     longu = linspace(min(longitude_era),max(longitude_era),50);
%
%     [lon, lat] = meshgrid(longi,lati);
%     err_grid = griddata(latitude_st,longitude_st,st_err,lat, lon, 'natural');
%     err_grid(isnan(err_grid)) = mean(err_grid,'all','omitnan');
%     [err_grid,  ~] = regrid_mask(lati,longi,latu,longu,err_grid,region, 'none', 'spline');
%     [err_grid,  ~] = regrid_mask(latu,longu,latitude_srtm,longitude_srtm,err_grid,region, 'none', 'nearest');
%     err_grid = err_grid .* mask_tot_high;
%
%     dev_grid = griddata(latitude_st,longitude_st,st_dev,lat, lon, 'natural');
%     dev_grid(isnan(dev_grid)) = mean(dev_grid,'all','omitnan');
%     [dev_grid,  ~] = regrid_mask(lati,longi,latu,longu,dev_grid,region, 'none', 'spline');
%     [dev_grid,  ~] = regrid_mask(latu,longu,latitude_srtm,longitude_srtm,dev_grid,region, 'none', 'nearest');
%     dev_grid = dev_grid .* mask_tot_high;
%
%
%
%     f2 = figure;
%     f2.Position = [90 90 1200 600];
%     t = tiledlayout(6,2);
%     t.TileSpacing = 'compact';
%
%     ax1 = nexttile([3 1]);
%     worldmap([44 46.5], ...  % Basemap
%         [6 10]);
%     pcolorm(latitude_srtm,longitude_srtm,err_grid);
%     colormap(ax1,whitejet)
%     colorbar
%     caxis([-3 3])
%     for i =1:length(region)
%         plotm(region(i).Y,region(i).X,'Color','k','LineWidth',2)
%         hold on
%     end
%     set(gca,'FontName','Calibri')
%     set(gca,'FontSize',18)
%     title('Error (uncorrected)')
%     xtickformat('degrees')
%     set(gca,'FontName','Calibri')
%     set(gca,'FontSize',18)
%     setm(gca,'mapprojection','giso')
%     setm(gca,'MLabelLocation',1)
%
%     ax2 = nexttile([3 1]);
%     worldmap([44 46.5], ...  % Basemap
%         [6 10]);
%     pcolorm(latitude_srtm,longitude_srtm,dev_grid);
%     colormap(ax2,flipud(hot))
%     colorbar
%     caxis([0 3])
%     for i =1:length(region)
%         plotm(region(i).Y,region(i).X,'Color','k','LineWidth',2)
%         hold on
%     end
%     set(gca,'FontName','Calibri')
%     set(gca,'FontSize',18)
%     title('STDE (uncorrected)')
%     xtickformat('degrees')
%     set(gca,'FontName','Calibri')
%     set(gca,'FontSize',18)
%     setm(gca,'mapprojection','giso')
%     setm(gca,'MLabelLocation',1)
%
%     nexttile
%     scatter(m_trend(:,1),m_trend(:,2),7,'k','filled')
%
%     nexttile
%     scatter(m_trend(:,1),m_trend(:,3),7,'k','filled')
%
%     nexttile
%     scatter(elevation_st,st_err,7,'k','filled')
%
%     nexttile
%     scatter(elevation_st,st_dev,7,'k','filled')
%
%     nexttile
%     scatter(fg,d_err,7,'k','filled')
%     hold on
%     plot(fg,cr(1).*fg.^2 + cr(2).*fg + cr(3) + ((cr(2)^2)/(4*cr(1))-cr(3)))
%
%     nexttile
%     scatter(fg,d_dev,7,'k','filled')




%         lati = linspace(min(latitude_era),max(latitude_era),40);
%     longi = linspace(min(longitude_era),max(longitude_era),40);
%     latu = linspace(min(latitude_era),max(latitude_era),50);
%     longu = linspace(min(longitude_era),max(longitude_era),50);
%
%     [lon, lat] = meshgrid(longi,lati);
%     err_grid = griddata(latitude_val,longitude_val,st_err_cor,lat, lon, 'natural');
%     err_grid(isnan(err_grid)) = mean(err_grid,'all','omitnan');
%     [err_grid,  ~] = regrid_mask(lati,longi,latu,longu,err_grid,region, 'none', 'spline');
%     [err_grid,  ~] = regrid_mask(latu,longu,latitude_srtm,longitude_srtm,err_grid,region, 'none', 'nearest');
%     err_grid = err_grid .* mask_tot_high;
%
%     dev_grid = griddata(latitude_val,longitude_val,st_dev_cor,lat, lon, 'natural');
%     dev_grid(isnan(dev_grid)) = mean(dev_grid,'all','omitnan');
%     [dev_grid,  ~] = regrid_mask(lati,longi,latu,longu,dev_grid,region, 'none', 'spline');
%     [dev_grid,  ~] = regrid_mask(latu,longu,latitude_srtm,longitude_srtm,dev_grid,region, 'none', 'nearest');
%     dev_grid = dev_grid .* mask_tot_high;
%     f2 = figure;
%     f2.Position = [90 90 1200 600];
%     t = tiledlayout(6,2);
%     t.TileSpacing = 'compact';
%
%     ax1 = nexttile([3 1]);
%     worldmap([44 46.5], ...  % Basemap
%         [6 10]);
%     pcolorm(latitude_srtm,longitude_srtm,err_grid);
%     colormap(ax1,whitejet)
%     colorbar
%     caxis([-3 3])
%     for i =1:length(region)
%         plotm(region(i).Y,region(i).X,'Color','k','LineWidth',2)
%         hold on
%     end
%     set(gca,'FontName','Calibri')
%     set(gca,'FontSize',18)
%     title('Error (corrected)')
%     xtickformat('degrees')
%     set(gca,'FontName','Calibri')
%     set(gca,'FontSize',18)
%     setm(gca,'mapprojection','giso')
%     setm(gca,'MLabelLocation',1)
%
%     ax2 = nexttile([3 1]);
%     worldmap([44 46.5], ...  % Basemap
%         [6 10]);
%     pcolorm(latitude_srtm,longitude_srtm,dev_grid);
%     colormap(ax2,flipud(hot))
%     colorbar
%     caxis([0 3])
%     for i =1:length(region)
%         plotm(region(i).Y,region(i).X,'Color','k','LineWidth',2)
%         hold on
%     end
%     set(gca,'FontName','Calibri')
%     set(gca,'FontSize',18)
%     title('STDE (corrected)')
%     xtickformat('degrees')
%     set(gca,'FontName','Calibri')
%     set(gca,'FontSize',18)
%     setm(gca,'mapprojection','giso')
%     setm(gca,'MLabelLocation',1)
%
%     nexttile
%     scatter(m_trend_cor(:,1),m_trend_cor(:,2),7,'k','filled')
%
%
%     nexttile
%     scatter(m_trend_cor(:,1),m_trend_cor(:,3),7,'k','filled')
%
%
%     nexttile
%     scatter(elevation_val,st_err_cor,7,'k','filled')
%
%     nexttile
%     scatter(elevation_val,st_dev_cor,7,'k','filled')
%
%     nexttile
%     scatter(fg,d_err_cor,7,'k','filled')
%
%     nexttile
%     scatter(fg,d_dev_cor,7,'k','filled')