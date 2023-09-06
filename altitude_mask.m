function [altitude_mean,altitude_error] = altitude_mask(variable_field,altitude_field,n_bin)

for i=2:n_bin
    altitude_mean(i) = mean(variable_field(altitude_field<(5000/n_bin)*i & altitude_field>(5000/n_bin)*(i-1)),'omitnan');
    altitude_error(i) = std(variable_field(altitude_field<(5000/n_bin)*i & altitude_field>(5000/n_bin)*(i-1)),'omitnan');
end

end
