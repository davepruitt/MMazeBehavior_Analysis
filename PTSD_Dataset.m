classdef PTSD_Dataset
    %PTSD_Dataset - handles a full dataset
    
    properties
        
        Rats
        GroupNames
        
    end
    
    methods
        
        function obj = PTSD_Dataset (rat_list, datapath, group, varargin)
            
            p = inputParser;
            
            defaultLoadBinaries = 1;
            defaultForceSaveBinaries = 1;
            defaultVerboseOutput = 0;
            defaultDisplayDateVerification = 1;
            defaultCreateDummySessions = 1;
            defaultGroupNames = {};
            addOptional(p, 'LoadBinaries', defaultLoadBinaries);
            addOptional(p, 'ForceSaveBinaries', defaultForceSaveBinaries);
            addOptional(p, 'VerboseOutput', defaultVerboseOutput);
            addOptional(p, 'DisplayDateVerification', defaultDisplayDateVerification);
            addOptional(p, 'CreateDummySessions', defaultCreateDummySessions);
            addOptional(p, 'GroupNames', defaultGroupNames);
            parse(p, varargin{:});
            load_binaries = p.Results.LoadBinaries;
            force_save_binaries = p.Results.ForceSaveBinaries;
            verbose_output = p.Results.VerboseOutput;
            date_verification_text_results = p.Results.DisplayDateVerification;
            create_dummy_sessions = p.Results.CreateDummySessions;
            group_names = p.Results.GroupNames;
            
            %Make sure that datapath ends with a slash character
            if (datapath(end) ~= '/' && datapath(end) ~= '\')
                datapath = [datapath '/'];
            end
           
            rats = [];
            
            %Iterate over each rat in the list
            for r = 1:length(rat_list)
                
                %Get the rat name
                rat_name = rat_list{r};
                
                %Create the fully qualified path for this rat
                fully_qualified_path = [datapath rat_name '/'];
                
                %Find all files that we would like to load in for this rat
                files = dir([fully_qualified_path '*.PTSD']);
                
                if (isempty(files))
                    disp(['No files could be found for rat ' rat_name ...
                        '.  Please check to make sure the path is correct.']);
                else
                    
                    %Display a message indicating what rat we are loading
                    disp(['Loading ' rat_name '...']);
                    
                    %Iterate over each file, and load each file in
                    
%                     sessions = [];
%                     for f=1:length(files)
%                         files(f).qualified_name = [fully_qualified_path files(f).name];
%                         disp(['Reading: ' files(f).name]);
%                         temp = PTSD_Session(fully_qualified_path, files(f).name, load_binaries, ...
%                             force_save_binaries);
%                         sessions = [sessions temp];
%                     end

                    %Check to see if dispstat exists - it is a useful
                    %display function.
                    dispstat_exists = exist('dispstat');

                    %Read each data file into a raw structure
                    raw_sessions = [];
                    for f=1:length(files)
                        %files(f).qualified_name = [fully_qualified_path files(f).name];
                        
                        %Output to the user what we are currently reading
                        if (dispstat_exists && ~verbose_output)
                            output_str = ['Reading file ' num2str(f) '/' num2str(length(files))];
                            if (f == 1)
                                dispstat(output_str, 'keepprev');
                            else
                                dispstat(output_str);
                            end
                        else
                            disp(['Reading: ' files(f).name]);
                        end
                        
                        %Read in the data file to a structure
                        temp = Read_PTSD_MMaze_File(fully_qualified_path, files(f).name, ...
                            'LoadBinaryCopiesIfAvailable', load_binaries, ...
                            'ForceSave', force_save_binaries);
                        
                        %Add the structure to an array
                        raw_sessions = [raw_sessions temp];
                    end
                    
                    %Display messages to the user
                    if (dispstat_exists)
                        dispstat(['Analyzing data... 1/' num2str(length(raw_sessions))], 'keepprev');
                    else
                        disp('Analyzing data...');
                    end
                    
                    sessions = [];
                    for f=1:length(raw_sessions)
                        
                        %Display message to the user
                        if (dispstat_exists)
                            dispstat(['Analyzing data...' num2str(f) '/' num2str(length(raw_sessions))]);
                        end
                        
                        %Create PTSD_Session object
                        temp_session = PTSD_Session(raw_sessions(f));
                        
                        %Add the session to an array
                        sessions = [sessions temp_session];
                    end

                    %Create a rat using all of the sessions we have
                    %created.
                    rat = PTSD_Rat(rat_name, group(r), sessions);
                    rat = rat.VerifyDatesOfSessions('ReportResultsInText', date_verification_text_results, ...
                        'CreateDummySessions', create_dummy_sessions);
                    
                    %Add the rat to the list of rats.
                    rats = [rats rat];
                    
                end
                
            end
            
            %Add the list of rats to our dataset.
            obj.Rats = rats;
            
            %Add the list of group names to our dataset.
            obj.GroupNames = group_names;
            
        end
        
        function obj = AddData ( obj, dataset2 )
            
            %Iterate through all rats in the second dataset
            for r = 1:length(dataset2.Rats)
                %See if the current rat already exists in the first dataset
                index_of_existing_rat = find(strcmpi({obj.Rats.RatName}, dataset2.Rats(r).RatName), 1, 'first');
                
                if (~isempty(index_of_existing_rat))
                    %If the rat doesn't 
                    obj.Rats(index_of_existing_rat).AddSessions(dataset2.Rats(r).Sessions);
                else
                    obj.Rats(end+1) = dataset2.Rats(r);
                end
            end
            
        end
        
        function data = RetrieveData ( obj, varargin )
            
            p = inputParser;
            defaultTransitType = 'FirstProxEnterToSecondProxEnterTransitTime';
            defaultMode = 'FirstSound';
            defaultSoundType = PTSD_EventType.FEAR;
            defaultSpecialTreatment = 0;
            defaultReplacementValue = NaN;
            defaultCalculateRatios = 0;
            defaultIncludeShapingData = 0;
            
            addOptional(p, 'TransitType', defaultTransitType);
            addOptional(p, 'Mode', defaultMode);
            addOptional(p, 'Sound', defaultSoundType, @isnumeric);
            addOptional(p, 'SpecialTreatmentForNegatives', defaultSpecialTreatment, @isnumeric);
            addOptional(p, 'ReplacementValueForNegatives', defaultReplacementValue);
            addOptional(p, 'CalculateRatios', defaultCalculateRatios);
            addOptional(p, 'IncludeShapingData', defaultIncludeShapingData);
            parse(p, varargin{:});
            
            mode = p.Results.Mode;
            transit_type = p.Results.TransitType;
            sound_to_use = p.Results.Sound;
            special_treatment = p.Results.SpecialTreatmentForNegatives;
            replacement_value = p.Results.ReplacementValueForNegatives;
            calculate_ratios = p.Results.CalculateRatios;
            include_shaping_data = p.Results.IncludeShapingData;
            
            %Fill a cell array with each individual rat's data
            rat_cell_data = {};
            for r = 1:length(obj.Rats)
                single_rat_data = obj.Rats(r).RetrieveData('TransitType', transit_type, ...
                    'Mode', mode, ...
                    'Sound', sound_to_use, ...
                    'SpecialTreatmentForNegatives', special_treatment, ...
                    'ReplacementValueForNegatives', replacement_value, ...
                    'CalculateRatios', calculate_ratios, ...
                    'IncludeShapingData', include_shaping_data);
                rat_cell_data{r, 1} = single_rat_data;
            end
            
            %Find the max sessions of any rat
            max_sessions = max(cellfun(@(x)numel(x), rat_cell_data));
            
            %Convert from a cell array to a nan-padded matrix
            rat_data = cell2mat(cellfun(@(x)cat(2,x,nan(1,max_sessions-length(x))), rat_cell_data,'UniformOutput',false));
            
            data = rat_data;
            
        end
        
        function PlotData ( obj, varargin )
            
            p = inputParser;
            defaultTransitType = 'FirstProxEnterToSecondProxEnterTransitTime';
            defaultMode = 'FirstSound';
            defaultSoundType = PTSD_EventType.MACHINE_GUN;
            defaultGraphType = PTSD_Utility.DatasetGraphTypeCompareAllSounds;
            defaultFigure = 0;
            defaultIncludeShapingData = 0;
            
            addOptional(p, 'TransitType', defaultTransitType);
            addOptional(p, 'Mode', defaultMode);
            addOptional(p, 'Sound', defaultSoundType, @isnumeric);
            addOptional(p, 'GraphType', defaultGraphType, @isnumeric);
            addOptional(p, 'Figure', defaultFigure);
            addOptional(p, 'IncludeShapingData', defaultIncludeShapingData);
            parse(p, varargin{:});
            
            mode = p.Results.Mode;
            transit_type = p.Results.TransitType;
            sound_to_use = p.Results.Sound;
            graph_type = p.Results.GraphType;
            include_shaping_data = p.Results.IncludeShapingData;
            
            %Grab the figure that the user passed in, or create a new figure.
            figure_to_use = p.Results.Figure;
            figure_class = class(figure_to_use);
            if (strcmpi(figure_class, 'matlab.graphics.axis.Axes'))
                axes(figure_to_use);
                hold(figure_to_use, 'on');
            elseif (strcmpi(figure_class, 'matlab.ui.Figure'))
                figure(figure_to_use);
                hold on;
            else
                figure_to_use = figure;
                hold on;
            end
            
            if (graph_type == PTSD_Utility.DatasetGraphTypeSingleSound)
                
                rat_data = obj.RetrieveData('TransitType', transit_type, ...
                    'Mode', mode, ...
                    'Sound', sound_to_use, ...
                    'SpecialTreatmentForNegatives', 1, ...
                    'ReplacementValueForNegatives', NaN, ...
                    'IncludeShapingData', include_shaping_data);
                
                data_mean = nanmean(rat_data, 1);
                data_err = std(rat_data, 0, 1, 'omitnan') / sqrt(size(rat_data, 1));
                
                colors = colormap(lines);
                
                for r = 1:size(rat_data, 1)
                    single_rat_data = rat_data(r, :);
                    plot(single_rat_data, 'Marker', 'o', 'MarkerFaceColor', colors(r, :));
                end
                
                errorbar(1:length(data_mean), data_mean, data_err, data_err, 'LineWidth', 2, 'Color', [0 0 0]);
                
                rat_names = {obj.Rats.RatName};
                legend(rat_names);
                xlabel('Sessions');
                ylabel('Seconds');
                
            else
                
                %Iterate through each sound type, gather data from all
                %rats, and calculate the mean and SEM for each sound type.
                sound_type = [ PTSD_EventType.MACHINE_GUN, ...
                        PTSD_EventType.TWITTER, ...
                        PTSD_EventType.NINE_KHZ, ...
                        PTSD_EventType.SILENT_SESSION];
                colors = [ PTSD_EventType.event_colors(PTSD_EventType.MACHINE_GUN, :); ...
                    PTSD_EventType.event_colors(PTSD_EventType.TWITTER, :); ...
                    PTSD_EventType.event_colors(PTSD_EventType.NINE_KHZ, :); ...
                    0 0 0];
                sound_types = {'Machine gun', 'Twitter', '9 khz tone', 'Silence'};
                plotted_lines = {};
                    
                means = {};
                errors = {};
                    
                calculate_ratios = (graph_type == PTSD_Utility.DatasetGraphTypeCompareRatios);
                if (calculate_ratios)
                    sound_type(4) = [];
                end
                
                %Fetch the data to be plotted.
                for s = 1:length(sound_type)
                    rat_data = obj.RetrieveData('TransitType', transit_type, ...
                        'Mode', mode, ...
                        'Sound', sound_type(s), ...
                        'SpecialTreatmentForNegatives', 1, ...
                        'ReplacementValueForNegatives', NaN, ...
                        'CalculateRatios', calculate_ratios, ...
                        'IncludeShapingData', include_shaping_data);
                    data_mean = nanmean(rat_data, 1);
                    data_err = std(rat_data, 0, 1, 'omitnan') / sqrt(size(rat_data, 1));
                    
                    means{s} = data_mean;
                    errors{s} = data_err;
                end
                
                %Plot each line
                for i = 1:length(means)
                    data_mean = means{i};
                    data_err = errors{i};
                    if (~isempty(data_mean))
                        errorbar(1:length(data_mean), data_mean, data_err, data_err, 'LineWidth', 2, 'Color', colors(i, :));
                        plotted_lines{end+1} = sound_types{i};
                    end
                end

                if (graph_type == PTSD_Utility.DatasetGraphTypeCompareRatios)
                    %Plot a line at y=1 to represent silent sessions.
                    plot(xlim, [1 1], 'Color', [0 0 0], 'LineWidth', 2);
                    plotted_lines{end+1} = sound_types{4};
                end

                rat_names = {obj.Rats.RatName};
                legend(plotted_lines);
                xlabel('Sessions');
                ylabel('Seconds');
                
            end
            
        end
        
        function PlotData2 ( obj, varargin )
           
            global data_table;
            global sound_table;
            global fear_table;
            data_table = {};
            sound_table = {};
            fear_table = {};
            
            p = inputParser;
            defaultTransitType = 'FirstProxToSecondNosepokeTransitTime';
            defaultTrialSelection = 'AllSounds';
            defaultFigure = 0;
            defaultPlotAnimals = 0;
            defaultDaysBeforeAFC = 0;
            defaultSegmentType = '';
            defaultSegmentLength = 30;
            defaultSuppressionRate = 0;
            defaultGrabSegments = 0;
            defaultGroups = 1:length(obj.GroupNames);
            addOptional(p, 'TransitType', defaultTransitType);
            addOptional(p, 'SelectTrials', defaultTrialSelection);
            addOptional(p, 'Figure', defaultFigure);
            addOptional(p, 'Groups', defaultGroups);
            addOptional(p, 'PlotIndividualAnimals', defaultPlotAnimals);
            addOptional(p, 'DaysBeforeAFC', defaultDaysBeforeAFC);
            addOptional(p, 'GrabSegments', defaultGrabSegments);
            addOptional(p, 'SegmentType', defaultSegmentType);
            addOptional(p, 'SegmentLength', defaultSegmentLength);
            addOptional(p, 'SuppressionRate', defaultSuppressionRate);
            parse(p, varargin{:});
            
            trials_to_select = p.Results.SelectTrials;
            transit_type = p.Results.TransitType;
            groups = p.Results.Groups;
            plot_individual_animals = p.Results.PlotIndividualAnimals;
            pre_afc_days = p.Results.DaysBeforeAFC;
            segment_type = p.Results.SegmentType;
            segment_length = p.Results.SegmentLength;
            use_suppression_rate = p.Results.SuppressionRate;
            grab_segments = p.Results.GrabSegments;
            
            %Grab the figure that the user passed in, or create a new figure.
            figure_to_use = p.Results.Figure;
            figure_class = class(figure_to_use);
            if (strcmpi(figure_class, 'matlab.graphics.axis.Axes'))
                axes(figure_to_use);
                hold(figure_to_use, 'on');
            elseif (strcmpi(figure_class, 'matlab.ui.Figure'))
                figure(figure_to_use);
                hold on;
            else
                figure_to_use = figure;
                hold on;
            end
            
            %Create a variable to store each group's data
            all_groups_data = {};
            all_groups_sound_type = {};
            all_groups_rat_names = {};
            all_groups_fear = {};
            included_group_names = {};
            colors = lines(length(obj.GroupNames));
            
            %Iterate over each group to be used in the plot
            for g = groups
                
                %Get the name of this group
                if (g <= length(obj.GroupNames))
                    included_group_names{end+1} = obj.GroupNames{g};
                else
                    %included_group_names{end+1} = 'Unknown group';
                    continue;
                end
                
                %We need to retrieve the data for the rats in this group
                
                %First, let's select all the rats that are part of the
                %group
                this_group_rat_indices = find([obj.Rats.Group] == g);
                
                %Define a variable to temporarily store this group's data
                this_group_data_cell = {};
                
                %Define a variable to hold the sound type at each point in
                %time
                this_group_data_cell_sound_type = {};
                
                %Define a variable to hold rat names for this group
                this_group_rat_names = {};
                
                %Define a variable to hold whether rats were significantly
                %fearful on certain days
                this_group_data_cell_fear = {};
                
                %Now that we know who the correct rats are, let's iterate
                %over each rat to get each rat's data
                for r = this_group_rat_indices
                    
                    [this_rat_data, this_rat_session_indices, pre_data, pre_data_session_indices] = obj.Rats(r).RetrieveData( ...
                        'TransitType', transit_type, ...
                        'Mode', trials_to_select, ...
                        'NumDaysPre', pre_afc_days, ...
                        'Sound', PTSD_EventType.PRE_POST, ...
                        'GrabSegments', grab_segments, ...
                        'SegmentLength', segment_length, ...
                        'SegmentType', segment_type, ...
                        'SuppressionRate', use_suppression_rate);
                    
                    %Get the name of this rat
                    rat_name = obj.Rats(r).RatName;
                    this_group_rat_names = [this_group_rat_names; rat_name];
                   
                    %Get the sounds associated with each session
                    all_session_sound_types = [obj.Rats(r).Sessions.SessionSoundType];
                    
                    %Get the sound types for the sessions at hand
                    try
                        retrieved_session_sound_types = all_session_sound_types([pre_data_session_indices this_rat_session_indices]);
                    catch e
                        e
                    end
                    
                    %Join the pre and post afc data
                    new_this_rat_data = [pre_data this_rat_data];
                    
                    %Add this data to the matrix that holds data from all
                    %rats
                    this_group_data_cell = [this_group_data_cell; new_this_rat_data];
                    
                    %Add the sound type data to the appropriate matrix
                    this_group_data_cell_sound_type = [this_group_data_cell_sound_type; retrieved_session_sound_types];
                    
                    %Discover whether this rat is showing significant fear
                    %at each timepoint
                    sessions_to_look_at_for_fear = [pre_data_session_indices this_rat_session_indices];
                    this_rat_fear = [];
                    for si = sessions_to_look_at_for_fear
                        [stat, p, ~, ~] = obj.Rats(r).Sessions(si).GetSessionStats('Statistic', PTSD_Utility.SessionStatsTTestEarly, 'TransitType', transit_type);
                        this_rat_fear = [this_rat_fear stat];
                    end
                    this_group_data_cell_fear = [this_group_data_cell_fear; this_rat_fear];
                    
                end
                
                this_group_data = cell_2_nan_padded_numeric_array(this_group_data_cell);
                all_groups_data = [all_groups_data; this_group_data];
                
                this_group_data_sound_type = cell_2_nan_padded_numeric_array(this_group_data_cell_sound_type);
                all_groups_sound_type = [all_groups_sound_type; this_group_data_sound_type];
                
                all_groups_rat_names{end+1} = this_group_rat_names;
                
                this_group_data_fear = cell_2_nan_padded_numeric_array(this_group_data_cell_fear);
                all_groups_fear = [all_groups_fear; this_group_data_fear];
                
            end
            
            max_group_means = 1;
            legend_lines = [];
            sound_marker_flags = [1 1 1];
            saved_sound_markers = {};
            sound_marker_descriptions = {};
            
            %Let's create some tables that we can return to Rimenez if he
            %wants to take the data into Excel to create his own plots or
            %do stats in Excel
            if (~isempty(all_groups_data))
                for i=1:length(all_groups_rat_names)
                    
                    group_rats = all_groups_rat_names{i};
                    group_data = all_groups_data{i};
                    group_sound_data = all_groups_sound_type{i};
                    group_fear_data = all_groups_fear{i};
                    
                    for r = 1:length(group_rats)
                        
                        this_row_data = group_data(r, :);
                        this_row.RatName = group_rats(r);
                        this_row.GroupName = included_group_names(i);
                        
                        sound_row_data = group_sound_data(r, :);
                        sound_row.RatName = group_rats(r);
                        sound_row.GroupName = included_group_names(i);
                        
                        fear_row_data = group_fear_data(r, :);
                        fear_row.RatName = group_rats(r);
                        fear_row.GroupName = included_group_names(i);
                        
                        for d = 1:length(this_row_data)
                            day_name = ['Day' num2str(d)];
                            %this_row.(day_name) = num2str(this_row_data(d));
                            idx = randi(2);
                            if (idx == 1)
                                this_row.(day_name) = NaN;
                            else
                                this_row.(day_name) = 1;
                            end
                        end
                        
                        for d = 1:length(sound_row_data)
                            day_name = ['Day' num2str(d)];
                            this_sound = sound_row_data(d);
                            this_sound_str = '';
                            if (~isnan(this_sound) && this_sound > 0)
                                try
                                    this_sound_str = PTSD_EventType.event_display_strings(this_sound);
                                catch
                                    this_sound_str = cellstr('None');
                                end
                            else
                                this_sound_str = cellstr('None');
                            end
                            sound_row.(day_name) = this_sound_str;
                        end
                        
                        for d = 1:length(fear_row_data)
                            day_name = ['Day' num2str(d)];
                            fear_row.(day_name) = fear_row_data(d);
                        end
                        
                        this_row_table = struct2cell(this_row)';
                        this_row_sound_table = struct2cell(sound_row)';
                        this_row_fear_table = struct2cell(fear_row)';

                        try
                            data_table{end+1} = this_row_table;
                            sound_table{end+1} = this_row_sound_table;
                            fear_table{end+1} = this_row_fear_table;
                            %data_table = [data_table; this_row_table];    
                            %sound_table = [sound_table; this_row_sound_table];
                        catch e
                            e
                        end
                        
                    end
                    
                end
            end
            
            data_table = big_cell_matrix_to_table(data_table, 0);
            sound_table = big_cell_matrix_to_table(sound_table, 1);
            fear_table = big_cell_matrix_to_table(fear_table, 0);
            
            %Let's run some stats between groups
            num_groups = length(all_groups_data);
            if (num_groups >= 2)
                %Get the number of timepoints by counting the number of
                %columns in the first group of rats
                first_group = all_groups_data{1};
                num_timepoints = size(first_group, 2);
                
                %Get the first day of post-AFC "testing"
                starting_testing_index = pre_afc_days + 1;
                
                %Create an array that will store the resultinv p-values of
                %our stats tests
                p_values = nan(num_timepoints, 1);
                
                %At each timepoint, do a statistical test to compare the
                %groups
                if (num_groups == 2)
                    %If we have 2 groups, just do an unpaired t-test at each
                    %timepoint
                    first_group = all_groups_data{1};
                    second_group = all_groups_data{2};
                    
                    for t = starting_testing_index:num_timepoints
                        %Get group 1's data
                        [h, p] = ttest2(first_group(:, t), second_group(:, t));
                        p_values(t) = p;
                    end
                else
                    %If we have more than 2 groups, so a one-way ANOVA
                    %First, iterate over each timepoint
                    for t = starting_testing_index:num_timepoints
                        stats_data = struct('group', {}, 'datapoint', {});
                        for g = 1:length(all_groups_data)
                            this_group_data = all_groups_data{g};
                            
                            if (size(this_group_data, 2) >= t)
                                this_group_data = this_group_data(:, t);
                                
                                for r = 1:size(this_group_data, 1)
                                    stats_data(end+1) = struct('group', g, 'datapoint', this_group_data(r));
                                end
                            end
                        end
                        
                        dep_vars = [stats_data.datapoint];
                        ind_vars = {[stats_data.group]};
                        [p, table, stats] = anovan(dep_vars, ind_vars, 'display', 'off', 'model', 'full', 'varnames', {'Group'});
                        p_values(t) = p;
                    end
                    
                end
            end
            
            %Now that we have each group's data, let's plot it.
            for d = 1:length(all_groups_data)
                
                this_group_data = all_groups_data{d};
                this_group_data_sound_type = all_groups_sound_type{d};
                group_means = nanmean(this_group_data, 1);
                group_sems = nanstd(this_group_data, 1) / sqrt(size(this_group_data, 1));
                color = colors(groups(d), :);
                sound_type_to_plot = mode(this_group_data_sound_type, 1);
                
                legend_lines(d) = errorbar(1:length(group_means), group_means, group_sems, group_sems, 'LineStyle', '-', 'Marker', 'none', 'Color', color, 'LineWidth', 2);
                
                %Fill in the markers for the post-AFC days, also plot the
                %correct kind of marker depending on sound type
                starting_index = pre_afc_days + 1;
                post_afc_group_data = group_means(:, starting_index:end);
                post_x_indices = (1:length(post_afc_group_data)) + pre_afc_days;
                
                for i = 1:length(post_x_indices)
                    i2 = post_x_indices(i);
                    marker_to_use = 'o';
                    if (sound_type_to_plot(i2) == PTSD_EventType.MACHINE_GUN)
                        marker_to_use = 's';
                    elseif (sound_type_to_plot(i2) == PTSD_EventType.GUNFIRE_30SECONDS)
                        marker_to_use = 's';
                    elseif (sound_type_to_plot(i2) == PTSD_EventType.TWITTER)
                        marker_to_use = 'x';
                    elseif (sound_type_to_plot(i2) == PTSD_EventType.NINE_KHZ)
                        marker_to_use = 'o';
                    elseif (sound_type_to_plot(i2) == PTSD_EventType.NINE_KHZ_30SECONDS)
                        marker_to_use = 'o';
                    else
                        marker_to_use = 'none';
                    end
                    
                    
                    %Before plotting the marker for this datapoint, let's
                    %run some "within-group" stats.  These stats will
                    %determine whether the marker is filled or empty.
                    marker_face_color = color;
%                     marker_face_color = [1 1 1];
%                     if (strcmpi(marker_to_use, 'none') == 0)
%                         try 
%                             this_timepoint_data = this_group_data(:, i2);
%                             previous_timepoint_data = this_group_data(:, i2-1);
%                             
%                             [h, p] = ttest(this_timepoint_data, previous_timepoint_data);
%                             if (h)
%                                 marker_face_color = color;
%                             end
%                             
%                         catch
%                             %If the catch statement is reached, then we
%                             %will not fill the marker
%                         end
%                     end
                    
                    sound_marker_on_plot = plot(post_x_indices(i), post_afc_group_data(i), 'LineStyle', 'none', ...
                        'Marker', marker_to_use, ...
                        'MarkerSize', 12, ...
                        'MarkerFaceColor', marker_face_color, ...
                        'Color', color', ...
                        'LineWidth', 2);
                    if (marker_to_use == 's' && sound_marker_flags(1) == 1)
                        sound_marker_flags(1) = 0;
                        saved_sound_markers = [saved_sound_markers sound_marker_on_plot];
                        sound_marker_descriptions = [sound_marker_descriptions 'gunfire'];
                    elseif (marker_to_use == 'x' && sound_marker_flags(2) == 1)
                        sound_marker_flags(2) = 0;
                        saved_sound_markers = [saved_sound_markers sound_marker_on_plot];
                        sound_marker_descriptions = [sound_marker_descriptions 'twitter'];
                    elseif (marker_to_use == 'o' && sound_marker_flags(3) == 1)
                        sound_marker_flags(3) = 0;
                        saved_sound_markers = [saved_sound_markers sound_marker_on_plot];
                        sound_marker_descriptions = [sound_marker_descriptions '9 khz'];
                    end
                end
                %plot(post_x_indices, post_afc_group_data, 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', color, 'Color', color', 'LineWidth', 2);
                
                if (plot_individual_animals == 1)
                    for r = 1:size(this_group_data, 1)
                        plot(1:size(this_group_data, 2), this_group_data(r, :), 'LineStyle', ':', 'Marker', 'none', 'Color', color, 'LineWidth', 1);
                    end
                end
                
                if (length(group_means) > max_group_means)
                    max_group_means = length(group_means);
                end
                
            end
            
            %Calculate where to place significance markers
            range = max(ylim) - min(ylim);
            upper95 = (0.95 * range) + min(ylim);
            for i=1:length(p_values)
                if (p_values(i) < 0.05)
                    plot(i, upper95, '*', 'MarkerSize', 12, 'Color', 'k');
                end
            end
            
            %Draw a pre-post separation line if necessary
%             if (pre_afc_days > 0 && ~isempty(groups))
%                 x1 = pre_afc_days + 0.25;
%                 x2 = pre_afc_days + 0.75;
%                 y1 = min(ylim);
%                 y2 = max(ylim);
%                 
%                 patch('XData', [x1 x1 x2 x2], 'YData', [y1 y2 y2 y1], 'CData', [0.7 0.7 0.7], 'FaceAlpha', 0.3, 'LineStyle', 'none', 'EdgeColor', 'none');
%                 
%                 text_x = x1 + 0.25;
%                 text_y = nanmean([y1 y2]);
%                 text('position', [text_x text_y], 'string', 'AFC', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial', 'Rotation', 90, 'Color', [1 1 1]);
%                 
%             end

            line(xlim, [30 30], 'LineStyle', '--', 'Color', [0 0 0]);
            ylim([0 300]);
            
            set(gca, 'FontSize', 18);
            set(gca, 'XTick', 1:max_group_means);
            xlabel('Days');
            ylabel('Transit Time');
            
            legend_lines = [legend_lines saved_sound_markers];
            included_group_names = [included_group_names sound_marker_descriptions];
            
            legend(legend_lines, included_group_names);
            
        end
        
        function PlotData3 ( obj, varargin )
            
            p = inputParser;
            defaultTransitType = 'FirstProxToSecondNosepokeTransitTime';
            defaultTrialSelection = 'AllSounds';
            defaultFigure = 0;
            defaultPlotAnimals = 1;
            defaultDaysBeforeAFC = 0;
            defaultSegmentType = '';
            defaultSegmentLength = 30;
            defaultSuppressionRate = 0;
            defaultGroups = 1:length(obj.GroupNames);
            addOptional(p, 'TransitType', defaultTransitType);
            addOptional(p, 'SelectTrials', defaultTrialSelection);
            addOptional(p, 'Figure', defaultFigure);
            addOptional(p, 'Groups', defaultGroups);
            addOptional(p, 'PlotIndividualAnimals', defaultPlotAnimals);
            addOptional(p, 'DaysBeforeAFC', defaultDaysBeforeAFC);
            addOptional(p, 'SegmentType', defaultSegmentType);
            addOptional(p, 'SegmentLength', defaultSegmentLength);
            addOptional(p, 'SuppressionRate', defaultSuppressionRate);
            parse(p, varargin{:});
            
            trials_to_select = p.Results.SelectTrials;
            transit_type = p.Results.TransitType;
            groups = p.Results.Groups;
            plot_individual_animals = p.Results.PlotIndividualAnimals;
            pre_afc_days = p.Results.DaysBeforeAFC;
            segment_type = p.Results.SegmentType;
            segment_length = p.Results.SegmentLength;
            use_suppression_rate = p.Results.SuppressionRate;
            
            %Grab the figure that the user passed in, or create a new figure.
            figure_to_use = p.Results.Figure;
            figure_class = class(figure_to_use);
            if (strcmpi(figure_class, 'matlab.graphics.axis.Axes'))
                axes(figure_to_use);
                hold(figure_to_use, 'on');
            elseif (strcmpi(figure_class, 'matlab.ui.Figure'))
                figure(figure_to_use);
                hold on;
            else
                figure_to_use = figure;
                hold on;
            end
            
            %Create a variable to store each group's data
            all_groups_data = {};
            included_group_names = {};
            colors = lines(length(obj.GroupNames));
            
            %Iterate over each group to be used in the plot
            for g = groups
                
                %Get the name of this group
                if (g <= length(obj.GroupNames))
                    included_group_names{end+1} = obj.GroupNames{g};
                else
                    included_group_names{end+1} = 'Unknown group';
                end
                
                %We need to retrieve the data for the rats in this group
                
                %First, let's select all the rats that are part of the
                %group
                this_group_rat_indices = find([obj.Rats.Group] == g);
                
                %Define a variable to temporarily store this group's data
                this_group_data_cell = {};
                
                %Now that we know who the correct rats are, let's iterate
                %over each rat to get each rat's data
                for r = this_group_rat_indices
                    
                    [this_rat_data, ~, pre_data, ~] = obj.Rats(r).RetrieveData( ...
                        'TransitType', transit_type, ...
                        'Mode', trials_to_select, ...
                        'NumDaysPre', pre_afc_days, ...
                        'Sound', PTSD_EventType.PRE_POST, ...
                        'GrabSegments', 1, ...
                        'SegmentLength', segment_length, ...
                        'SegmentType', segment_type, ...
                        'SuppressionRate', use_suppression_rate);
                    
                    %Join the pre and post afc data
                    new_this_rat_data = [pre_data this_rat_data];
                    
                    %Add this data to the matrix that holds data from all
                    %rats
                    this_group_data_cell = [this_group_data_cell; new_this_rat_data];
                    
                end
                
                this_group_data = cell_2_nan_padded_numeric_array(this_group_data_cell);
                all_groups_data = [all_groups_data; this_group_data];
                
            end
            
            max_group_means = 1;
            legend_lines = [];
            num_days = 0;
            
            %Now that we have each group's data, let's plot it.
            for d = 1:length(all_groups_data)
                
                this_group_data = all_groups_data{d};
                group_means = nanmean(this_group_data, 1);
                group_sems = nanstd(this_group_data, 1) / sqrt(size(this_group_data, 1));
                color = colors(groups(d), :);
                
                x_vals_base = [0.8 0.9 1.0 1.1 1.2];
                num_days = length(group_means) / 5;
                x_vals = [];
                for i=1:num_days
                    this_day = x_vals_base + (i - 1);
                    x_vals = [x_vals this_day];
                end
                
                for x=1:num_days
                    si = ((x-1) * 5) + 1;
                    se = ((x-1) * 5) + 5;
                    legend_lines(d) = errorbar(x_vals(si:se), group_means(si:se), group_sems(si:se), group_sems(si:se), ...
                        'LineStyle', '-', 'Marker', '^', 'MarkerFaceColor', color, 'Color', color, 'LineWidth', 2);
                end
                
                
                %Fill in the markers for the post-AFC days
%                 starting_index = pre_afc_days + 1;
%                 post_afc_group_data = group_means(:, starting_index:end);
%                 post_x_indices = (1:length(post_afc_group_data)) + pre_afc_days;
%                 plot(post_x_indices, post_afc_group_data, 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', color, 'Color', color', 'LineWidth', 2);
%                 
%                 for r = 1:size(this_group_data, 1)
%                     plot(1:size(this_group_data, 2), this_group_data(r, :), 'LineStyle', ':', 'Marker', 'none', 'Color', color, 'LineWidth', 1);
%                 end
                
                if (length(group_means) > max_group_means)
                    max_group_means = length(group_means);
                end
                
            end
            
            %Draw a pre-post separation line if necessary
%             if (pre_afc_days > 0 && ~isempty(groups))
%                 x1 = pre_afc_days + 0.25;
%                 x2 = pre_afc_days + 0.75;
%                 y1 = min(ylim);
%                 y2 = max(ylim);
%                 
%                 patch('XData', [x1 x1 x2 x2], 'YData', [y1 y2 y2 y1], 'CData', [0.7 0.7 0.7], 'FaceAlpha', 0.3, 'LineStyle', 'none', 'EdgeColor', 'none');
%                 
%                 text_x = x1 + 0.25;
%                 text_y = nanmean([y1 y2]);
%                 text('position', [text_x text_y], 'string', 'AFC', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Arial', 'Rotation', 90, 'Color', [1 1 1]);
%                 
%             end
            

            line(xlim, [30 30], 'LineStyle', '--', 'Color', [0 0 0]);
            ylim([0 300]);

            set(gca, 'XTick', 1:num_days);
            xlabel('Days');
            ylabel('Events (Before - After)');
            legend(legend_lines, included_group_names);
            
        end
        
        function [fear_table, sound_table] = GenerateFearTable ( obj, varargin )
           
            fear_table = {};
            sound_table = {};
            
            p = inputParser;
            
            defaultTransitType = 'FirstProxToSecondNosepokeTransitTime';
            defaultGroups = 1:length(obj.GroupNames);
            defaultFearMethod = 0;
            
            addOptional(p, 'TransitType', defaultTransitType);
            addOptional(p, 'Groups', defaultGroups);
            addOptional(p, 'FearMethod', defaultFearMethod);
            
            parse(p, varargin{:});
            
            transit_type = p.Results.TransitType;
            groups = p.Results.Groups;
            fear_method = p.Results.FearMethod;
            
            %Create a variable to store each group's data
            all_groups_rat_names = {};
            all_groups_sound_type = {};
            all_groups_fear = {};
            included_group_names = {};
            
            %Iterate over each group to be used in the plot
            for g = groups
                
                %Get the name of this group
                if (g <= length(obj.GroupNames))
                    included_group_names{end+1} = obj.GroupNames{g};
                else
                    continue;
                end
                
                %We need to retrieve the data for the rats in this group
                
                %First, let's select all the rats that are part of the
                %group
                this_group_rat_indices = find([obj.Rats.Group] == g);
                
                %Define a variable to hold rat names for this group
                this_group_rat_names = {};
                
                %Define a variable to hold the sound type at each point in %time
                this_group_data_cell_sound_type = {};
                
                %Define a variable to hold whether rats were significantly
                %fearful on certain days
                this_group_data_cell_fear = {};
                
                %Now that we know who the correct rats are, let's iterate
                %over each rat to get each rat's data
                for r = this_group_rat_indices
                    
                    %Get the name of this rat
                    rat_name = obj.Rats(r).RatName;
                    this_group_rat_names = [this_group_rat_names; rat_name];

                    %Get the sounds associated with each session
                    all_session_sound_types = [obj.Rats(r).Sessions.SessionSoundType];
                    
                    %Add the sound type data to the appropriate matrix
                    this_group_data_cell_sound_type = [this_group_data_cell_sound_type; all_session_sound_types];
                    
                    %Discover whether this rat is showing significant fear
                    %at each timepoint
                    sessions_to_look_at_for_fear = 1:length(obj.Rats(r).Sessions);
                    this_rat_fear = [];
                    for si = sessions_to_look_at_for_fear
                        stat = NaN;
                        switch(fear_method)
                            case 0
                                %Method 0 does a t-test looking at the transit times during sound trials compared to the transit times of the 10 trials that preceded the
                                %first sound trial.  If the t-test is significant, then we indicate that the rat was showing fear.
                                [stat, p, ~, ~] = obj.Rats(r).Sessions(si).GetSessionStats('Statistic', PTSD_Utility.SessionStatsTTestEarly, 'TransitType', transit_type, ...
                                    'IncludeNonSoundSessions', 1);
                            case 1
                                %Method 1 takes the mean transit time of all sound trials.  If the mean is over 30 seconds, then we indicate that the rat was showing fear.
                                transit_times = obj.Rats(r).Sessions(si).RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'AllSoundsPlus', 'Mean', 0);
                                t_mean = nanmean(transit_times);
                                if (~isempty(t_mean))
                                    if (t_mean >= 30)
                                        stat = 1;
                                    end
                                end
                            case 2
                                %Method 2 takes the first transit time of a sound trial in the session.  If it is over 30 seconds, then we indicate the rat was showing fear.
                                transit_times = obj.Rats(r).Sessions(si).RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'AllSoundsPlus', 'Mean', 0);
                                if (~isempty(transit_times))
                                    t_transit = transit_times(1);
                                    if (t_transit >= 30)
                                        stat = 1;
                                    end
                                end
                            case 3
                                %Method 3 takes the transit times of all sound trials in the session and does a t-test with catch trials from the previous session.
                                if (si > 1)
                                    this_session_transit_times = obj.Rats(r).Sessions(si).RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'AllSoundsPlus', 'Mean', 0);
                                    prev_session_transit_times = obj.Rats(r).Sessions(si - 1).RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'AllSoundsPlus', 'Mean', 0);
                                    
                                    if (~isempty(this_session_transit_times) && length(this_session_transit_times) > 1 && ...
                                            ~isempty(prev_session_transit_times) && length(prev_session_transit_times) > 1)
                                        [stat, p, ~, ~] = ttest2(this_session_transit_times, prev_session_transit_times);
                                    else
                                        stat = NaN;
                                    end
                                else
                                    stat = NaN;
                                end
                            otherwise
                                stat = NaN;
                        end
                        this_rat_fear = [this_rat_fear stat];
                    end
                    this_group_data_cell_fear = [this_group_data_cell_fear; this_rat_fear];
                    
                end
                
                this_group_data_sound_type = cell_2_nan_padded_numeric_array(this_group_data_cell_sound_type);
                all_groups_sound_type = [all_groups_sound_type; this_group_data_sound_type];
                
                all_groups_rat_names{end+1} = this_group_rat_names;
                
                this_group_data_fear = cell_2_nan_padded_numeric_array(this_group_data_cell_fear);
                all_groups_fear = [all_groups_fear; this_group_data_fear];
                
            end
            
            %Let's create some tables that we can return to Rimenez if he
            %wants to take the data into Excel to create his own plots or
            %do stats in Excel
            for i=1:length(all_groups_rat_names)

                group_rats = all_groups_rat_names{i};
                group_fear_data = all_groups_fear{i};
                group_sound_data = all_groups_sound_type{i};

                for r = 1:length(group_rats)

                    sound_row_data = group_sound_data(r, :);
                    sound_row.RatName = group_rats(r);
                    sound_row.GroupName = included_group_names(i);

                    fear_row_data = group_fear_data(r, :);
                    fear_row.RatName = group_rats(r);
                    fear_row.GroupName = included_group_names(i);

                    for d = 1:length(sound_row_data)
                        day_name = ['Day' num2str(d)];
                        this_sound = sound_row_data(d);
                        this_sound_str = '';
                        if (~isnan(this_sound) && this_sound > 0)
                            try
                                this_sound_str = PTSD_EventType.event_display_strings(this_sound);
                            catch
                                this_sound_str = cellstr('None');
                            end
                        else
                            this_sound_str = cellstr('None');
                        end
                        sound_row.(day_name) = this_sound_str;
                    end
                    
                    for d = 1:length(fear_row_data)
                        day_name = ['Day' num2str(d)];
                        fear_row.(day_name) = fear_row_data(d);
                    end

                    this_row_fear_table = struct2cell(fear_row)';
                    this_row_sound_table = struct2cell(sound_row)';

                    try
                        fear_table{end+1} = this_row_fear_table;
                        sound_table{end+1} = this_row_sound_table;
                    catch e
                        e
                    end

                end

            end
            
            fear_table = big_cell_matrix_to_table(fear_table, 0);
            sound_table = big_cell_matrix_to_table(sound_table, 1);
            
        end
        
    end
    
end



























