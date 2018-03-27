%Grab the fear table that has been calculate by previous code

% Method 0 = t-test of transit times of sound trials compared to transit times of 10 non-sound trials, considered to be "fearful" if t-test is significant
% Method 1 = mean of transit times of sound trials, considered to be "fearful" if mean is >= 30 seconds
% Method 2 = transit time of first sound trial, considered to be "fearful" if it is >= 30 seconds
% Method 3 = t-test of each session's "sound trial" transit times with the previous session's "catch trial" transit times.

[fear_table, sound_table] = dataALL.GenerateFearTable('FearMethod', 3);

plot_style = 2;

%% Plot style 1

if (plot_style == 1)

    rat_name_column = 1;
    group_name_column = 2;
    start_of_testing_column = 6;

    group_names = {};
    number_of_days = size(fear_table, 2) - start_of_testing_column + 1;
    number_of_groups = size(unique(fear_table(:, group_name_column)), 1);

    group_sum_of_rats_with_fear = zeros(number_of_groups, number_of_days);
    group_sum_of_all_rats = zeros(number_of_groups, number_of_days);

    %Iterate over each row in the table
    for row = 1:size(fear_table, 1)

        this_rat_group = table2cell(fear_table(row, group_name_column));

        %Check to see if we have seen this group yet
        this_group_name_index = find(strcmpi(group_names, this_rat_group), 1, 'first');
        if (isempty(this_group_name_index))
            group_names = [group_names; this_rat_group];
            this_group_name_index = length(group_names);
        end

        d = 1;
        for i = start_of_testing_column:size(fear_table, 2)
            scalar_value = table2array(fear_table(row, i));
            if (isscalar(scalar_value) && ~isnan(scalar_value))
                group_sum_of_rats_with_fear(this_group_name_index, d) = group_sum_of_rats_with_fear(this_group_name_index, d) + scalar_value;
            end
            group_sum_of_all_rats(this_group_name_index, d) = group_sum_of_all_rats(this_group_name_index, d) + 1;
            d = d + 1;
        end

    end

    fear_percents = group_sum_of_rats_with_fear ./ group_sum_of_all_rats;

    % Plotting code
    
    figure;
    hold on;
    colors = colormap(jet(100));

    for r = 1:size(fear_percents, 1)

        lower_points_x = [];
        lower_points_y = [];
        upper_points_x = [];
        upper_points_y = [];
        lower_colors = [];
        upper_colors = [];

        y_lower = r - 0.25;
        y_upper = r + 0.25;

        for d = 1:size(fear_percents, 2)

            x_val = d;
            percent_val = fear_percents(r, d) * 100;
            %color_val = colors(min(100, max(1, round(percent_val))), :);
            color_val = min(100, max(1, round(percent_val)));

            lower_points_x = [lower_points_x; x_val];
            lower_points_y = [lower_points_y; y_lower];
            upper_points_x = [upper_points_x; x_val];
            upper_points_y = [upper_points_y; y_upper];
            lower_colors = [lower_colors; color_val];
            upper_colors = [upper_colors; color_val];
        end

        upper_points_x = flipud(upper_points_x);
        upper_points_y = flipud(upper_points_y);
        upper_colors = flipud(upper_colors);

        all_points_x = [lower_points_x; upper_points_x];
        all_points_y = [lower_points_y; upper_points_y];
        all_colors = [lower_colors; upper_colors];

        patch(all_points_x, all_points_y, all_colors);

    end

    set(gca, 'YTick', 1:length(group_names));
    set(gca, 'YTickLabel', group_names);
    set(gca, 'XTick', 1:number_of_days);
    xlabel('Training Day');

    h = colorbar;
    ylabel(h, 'Percent animals displaying fear');

end

%% Plot style 2

if (plot_style == 2)

    rat_name_column = 1;
    group_name_column = 2;
    start_of_testing_column = 6;

    group_names = {};
    number_of_days = size(fear_table, 2);
    number_of_groups = size(unique(fear_table(:, group_name_column)), 1);

    group_sum_of_rats_with_fear = zeros(number_of_groups, number_of_days);
    group_sum_of_all_rats = zeros(number_of_groups, number_of_days);
    
    %Iterate over each row in the table
    for row = 1:size(fear_table, 1)

        this_rat_group = table2cell(fear_table(row, group_name_column));

        %Check to see if we have seen this group yet
        this_group_name_index = find(strcmpi(group_names, this_rat_group), 1, 'first');
        if (isempty(this_group_name_index))
            group_names = [group_names; this_rat_group];
            this_group_name_index = length(group_names);
        end

        d = 1;
        for i = 3:size(fear_table, 2)
            scalar_value = table2array(fear_table(row, i));
            if (isscalar(scalar_value) && ~isnan(scalar_value))
                group_sum_of_rats_with_fear(this_group_name_index, d) = group_sum_of_rats_with_fear(this_group_name_index, d) + scalar_value;
            end
            group_sum_of_all_rats(this_group_name_index, d) = group_sum_of_all_rats(this_group_name_index, d) + 1;
            d = d + 1;
        end

    end

    fear_percents = (group_sum_of_rats_with_fear ./ group_sum_of_all_rats) * 100;

    
    sum_of_all_rats_that_heard_sounds = zeros(1, number_of_days);
    for row = 1:size(sound_table, 1)
        for col = 3:size(sound_table, 2)
            this_cell_value = table2array(sound_table(row, col));
            if (~strcmpi(this_cell_value, 'None'))
                sum_of_all_rats_that_heard_sounds(col - 2) = sum_of_all_rats_that_heard_sounds(col - 2) + 1;
            end
        end
    end
    
    percent_of_all_rats_that_heard_sounds = sum_of_all_rats_that_heard_sounds ./ size(sound_table, 1);
    
    %Plotting code
    
    figure;
    hold on;
    
    for row = 1:size(fear_percents, 1)
        g(row) = plot(fear_percents(row, :));
    end
    
    for col = 1:length(percent_of_all_rats_that_heard_sounds)
        if (percent_of_all_rats_that_heard_sounds(col) > 0)
            x1 = col - 0.5;
            x2 = col + 0.5;
            y1 = min(ylim);
            y2 = max(ylim);
            c = [1 1 1] - percent_of_all_rats_that_heard_sounds(col);
            p = patch('XData', [x1 x2 x2 x1], 'YData', [y1 y1 y2 y2], 'FaceColor', c, 'FaceAlpha', 0.25, 'EdgeColor', 'none');
        end
    end
    
    legend(g, group_names);
    xlabel('Training day');
    ylabel('Percentage of rats showing fear in each group');
    
end








