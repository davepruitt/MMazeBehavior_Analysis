function nan_padded_array = cell_2_nan_padded_numeric_array ( cell_array )

    max_elements = max(cellfun(@(x)numel(x), cell_array));
    nan_padded_array = cell2mat(cellfun(@(x)cat(2,x,nan(1,max_elements-length(x))), cell_array,'UniformOutput',false));

end
