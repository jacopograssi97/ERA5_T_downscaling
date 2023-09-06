function [T_mean] = down_grid(Tr,Zr,latitude_era,longitude_era,latitude_tot,longitude_tot,region,mask,elevation_h,level_e)

k = 1;
for i = 1:4:size(Tr,4)

    T_ERA5 = Tr(:,:,:,i:i+3);
    z_ERA5 = Zr(:,:,:,i:i+3);

    [z_reg, ~] = regrid_mask(latitude_era,longitude_era,latitude_tot,longitude_tot,z_ERA5,region, 'none', 'nearest');
    [T_reg, ~] = regrid_mask(latitude_era,longitude_era,latitude_tot,longitude_tot,T_ERA5,region, 'none', 'nearest');

    for i = 1:size(T_reg,1)
        for j = 1:size(T_reg,2)
            for t = 1:size(z_reg,4)
                [c in] = min(abs(z_reg(i,j,:,t)-elevation_h(i,j)));
                if in == 18
                    lev = linspace(level_e(in-1),level_e(in),100)';
                elseif in == 1
                    lev = linspace(level_e(in),level_e(in+1),100)';
                else
                    lev = linspace(level_e(in-1),level_e(in+1),100)';
                end
                z_reg_n = interp1(level_e,squeeze(z_reg(i,j,:,t)),lev,'linear');
                T_reg_n = interp1(level_e,squeeze(T_reg(i,j,:,t)),lev,'linear');
                [c indi] = min(abs(z_reg_n-elevation_h(i,j)));
                T(i,j,t) = T_reg_n(indi);
            end
        end
    end

    T_mean(:,:,k) = mean(T,3,'omitnan');
    k = k+1;

end

end