function [latitude,longitude,variable] = load_data(filename, field, conf_mi, conf_ma)

lat = ncread(filename,'latitude');
lon = ncread(filename,'longitude');
variable_p = ncread(filename,field);

for i = 1:size(variable_p,4)
    for j = 1:size(variable_p,3)
        variable_p1(:,:,j,i) = variable_p(:,:,j,i)';
    end
end

if lat(1)>lat(end)
    lat = sort(lat);
    for i = 1:size(variable_p1,4)
        for j = 1:size(variable_p1,3)
            variable_p1(:,:,j,i) = flipud(variable_p1(:,:,j,i));
        end
    end
end


i_lon_min = find(lon>conf_mi(1));
i_lon_max = find(lon<conf_ma(1));

i_lat_min = find(lat>conf_mi(2));
i_lat_max = find(lat<conf_ma(2));

longitude = double(lon(i_lon_min(1):i_lon_max(end)));
latitude = double(lat(i_lat_min(1):i_lat_max(end)));

for i = 1:size(variable_p1,4)
    variable(:,:,:,i) = double(variable_p1(i_lat_min(1):i_lat_max(end),i_lon_min(1):i_lon_max(end),:,i));
end

end
