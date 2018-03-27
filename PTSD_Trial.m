classdef PTSD_Trial
    %PTSD_Trial
    %   Represents a single trial from a PTSD session.
    
    properties
        EventTime
        EventType
        IsInvalidTrial
        IsSoundTrial
        IsCatchTrial
        SoundType
        TrialDuration
        
        IsLeftToRight
        
        UnfilteredEventTime
        UnfilteredEventType
        
        NosepokeToNosepokeTransitTime
        NosepokeToFirstProxTransitTime
        NosepokeToSecondProxTransitTime
        FirstProxToSecondProxTransitTime
        FirstProxToSecondNosepokeTransitTime
        SecondProxToSecondNosepokeTransitTime
        FirstProxEnterToSecondProxEnterTransitTime
        
    end
    
    methods
        
        function obj = PTSD_Trial ( event_time, event_type, varargin )
            
            p = inputParser;
            
            defaultFilterSignal = 1;
            defaultModified = 0;
            defaultDirection = 0;
            addOptional(p, 'FilterSignal', defaultFilterSignal, @isnumeric);
            addOptional(p, 'Modified', defaultModified, @isnumeric);
            addOptional(p, 'Direction', defaultDirection);
            parse(p, varargin{:});
            filter_signal = p.Results.FilterSignal;
            modified = p.Results.Modified;
            is_left_right = p.Results.Direction;
            
            %Transfer over the signal and event times
            obj.EventTime = event_time;
            obj.EventType = event_type;
            obj.IsInvalidTrial = 0;
            obj.IsLeftToRight = is_left_right;
            obj.IsCatchTrial = 0;
            
            %Find out if this is a "sound trial" or not. 
            sound_index = find(PTSD_EventType.IsSoundEvent(obj.EventType), 1);
            obj.IsSoundTrial = ~isempty(sound_index);
            if (obj.IsSoundTrial)
                obj.SoundType = obj.EventType(sound_index);
            else
                is_catch_trial = find(PTSD_EventType.IsSilentEvent(obj.EventType), 1);
                if (~isempty(is_catch_trial))
                    obj.IsCatchTrial = 1;
                end
                obj.SoundType = PTSD_EventType.UNKNOWN_EVENT;
            end
            
            %Filter the signal
            if (filter_signal)
                obj = obj.FilterSignal();
            else
                obj.UnfilteredEventTime = obj.EventTime;
                obj.UnfilteredEventType = obj.EventType;
            end
            
            %Calculate transit times
            if (~modified)
                obj = obj.CalculateTransitTimes();
            else
                obj = obj.CalculateModifiedTransitTimes();
            end
        end
        
        function trial_array = SplitIntoMultipleTrials ( obj )
            trial_array = [];
            done = 0;
            all_events = obj.EventType;
            all_event_times = obj.EventTime;
            if (~isempty(all_event_times) && ~isempty(all_events))
                while (~done)
                    first_trial_event_time = datetime(datevec(all_event_times(1)));
                    end_of_trial_time = first_trial_event_time + seconds(300);

                    actual_end_of_trial_time_index = find(all_event_times <= datenum(end_of_trial_time), 1, 'last');
                    if (isempty(actual_end_of_trial_time_index))
                        actual_end_of_trial_time_index = length(all_event_times);
                    end
                    
                    this_trial_events = all_events(1:actual_end_of_trial_time_index);
                    this_trial_times = all_event_times(1:actual_end_of_trial_time_index);
                    all_events(1:actual_end_of_trial_time_index) = [];
                    all_event_times(1:actual_end_of_trial_time_index) = [];
                    this_trial = PTSD_Trial(this_trial_times, this_trial_events, 'Modified', 1, 'Direction', obj.IsLeftToRight);
                    trial_array = [trial_array this_trial];

                    if (isempty(all_event_times) || isempty(all_events))
                        done = 1;
                    end
                end

            end
            
        end
        
        function PlotTrial ( obj, varargin )
            
            p = inputParser;
            
            defaultRaw = 0;
            defaultFigure = 0;
            defaultUseTimeAsXAxis = 0;
            addOptional(p, 'RawData', defaultRaw, @isnumeric);
            addOptional(p, 'Figure', defaultFigure);
            addOptional(p, 'UseTime', defaultUseTimeAsXAxis, @isnumeric);
            parse(p, varargin{:});
            
            plot_raw_data = p.Results.RawData;
            use_time = p.Results.UseTime;
            
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
            
            %Decide what to use as our x values
            xvals = [];
            if (use_time)
                beginning_time = datevec(obj.EventTime(1));
                
                for t = 1:length(obj.EventTime)
                    new_time = etime(datevec(obj.EventTime(t)), beginning_time);
                    xvals = [xvals new_time];
                end
            else
                xvals = 1:length(obj.EventType);
            end
            
            %Decide what to use as our y values
            LEFTNP = 1;
            LEFTP = 2;
            RIGHTP = 3;
            RIGHTNP = 4;
            UNKNOWN = 5;
            
            yvals = [];
            if (plot_raw_data)
                yvals = obj.EventType;
            else
                for t = 1:length(obj.EventType)
                    cur_event = obj.EventType(t);
                    
                    if (cur_event == PTSD_EventType.LEFT_NOSEPOKE_ENTER || ...
                        cur_event == PTSD_EventType.LEFT_NOSEPOKE_LEAVE || ...
                        cur_event == PTSD_EventType.LEFT_FEEDER_TRIGGERED)
                        yvals = [yvals LEFTNP];
                    elseif (cur_event == PTSD_EventType.LEFT_PROX_ENTER || ...
                        cur_event == PTSD_EventType.LEFT_PROX_LEAVE)
                        yvals = [yvals LEFTP];
                    elseif (cur_event == PTSD_EventType.RIGHT_PROX_ENTER || ...
                        cur_event == PTSD_EventType.RIGHT_PROX_LEAVE)
                        yvals = [yvals RIGHTP];
                    elseif (cur_event == PTSD_EventType.RIGHT_NOSEPOKE_ENTER || ...
                        cur_event == PTSD_EventType.RIGHT_NOSEPOKE_LEAVE || ...
                        cur_event == PTSD_EventType.RIGHT_FEEDER_TRIGGERED)
                        yvals = [yvals RIGHTNP];
                    elseif (PTSD_EventType.IsSoundEvent(cur_event))
                        if (obj.IsLeftToRight)
                            yvals = [yvals LEFTNP];
                        else
                            yvals = [yvals RIGHTNP];
                        end
                    else
                        yvals = [yvals UNKNOWN];
                    end
                end
            end
            
            %Plot everything
            xlim([min(xvals)-0.5 max(xvals)+0.5]);
            if (plot_raw_data)
                plot(xvals, yvals, 'o');
                yticks = length(PTSD_EventType.event_display_strings);
                yticklabels = PTSD_EventType.event_display_strings;
                yticklabels = ['Unknown' 'Unknown' yticklabels];
                set(gca, 'YTick', -1:yticks);
                set(gca, 'YTickLabel', yticklabels);
                set(gca, 'TickLabelInterpreter', 'none');
                ylim([-1 max(yticks)]);
            else
                ylim([0 5]);
                set(gca, 'YTick', 1:5);
                set(gca, 'YTickLabel', {'Left Nosepoke', 'Left Prox', 'Right Prox', 'Right Nosepoke', 'Unknown'});
                if (use_time)
                    stairs(xvals, yvals, '-o');
                else
                    plot(xvals, yvals, '-o');
                end
            end
            
            if (use_time)
                xlabel('Seconds');
            else
                xlabel('Events');
            end
            
            %Plot a line for the sound being played
            if (obj.IsSoundTrial)
                color = PTSD_EventType.event_colors(obj.SoundType, :);
                
                xcoord = find(obj.EventType == obj.SoundType);
                if (use_time)
                    t = obj.EventTime(xcoord);
                    xcoord = etime(datevec(t), datevec(obj.EventTime(1)));
                end
                
                plot([xcoord xcoord], [min(ylim) max(ylim)], 'LineStyle', '--', 'Color', color);
            end
            
        end
        
        function PlotTrial2 ( obj, varargin )
            
            p = inputParser;
            
            defaultFigure = 0;
            addOptional(p, 'Figure', defaultFigure);
            parse(p, varargin{:});
            
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
            
            
            LEFTNP = 1;
            LEFTP = 2;
            RIGHTP = 3;
            RIGHTNP = 4;
            UNKNOWN = 5;
            
            events = obj.EventType;
            event_times = obj.EventTime;
            
            base_time = 0;
            end_time = 0;
            if (~isempty(obj.EventTime))
                base_time = datevec(obj.EventTime(1));
                end_time = datevec(obj.EventTime(end));
            end
            
            while (~isempty(events))
                
                %Pop the first event off the array
                cur_event = events(1);
                cur_event_time = datevec(event_times(1));
                
                events(1) = [];
                event_times(1) = [];
                
                if (cur_event == PTSD_EventType.LEFT_NOSEPOKE_LEAVE || ...
                        cur_event == PTSD_EventType.LEFT_FEEDER_TRIGGERED || ...
                        cur_event == PTSD_EventType.RIGHT_FEEDER_TRIGGERED || ...
                        cur_event == PTSD_EventType.RIGHT_NOSEPOKE_LEAVE || ...
                        cur_event == PTSD_EventType.LEFT_PROX_LEAVE || ...
                        cur_event == PTSD_EventType.RIGHT_PROX_LEAVE || ...
                        PTSD_EventType.IsSoundEvent(cur_event) || ...
                        cur_event == PTSD_EventType.UNKNOWN_EVENT)
                    end_event_time = cur_event_time;
                else
                    if (cur_event == PTSD_EventType.LEFT_NOSEPOKE_ENTER)
                        end_event_type = PTSD_EventType.LEFT_NOSEPOKE_LEAVE;
                    elseif (cur_event == PTSD_EventType.RIGHT_NOSEPOKE_ENTER)
                        end_event_type = PTSD_EventType.RIGHT_NOSEPOKE_LEAVE;
                    elseif (cur_event == PTSD_EventType.LEFT_PROX_ENTER)
                        end_event_type = PTSD_EventType.LEFT_PROX_LEAVE;
                    elseif (cur_event == PTSD_EventType.RIGHT_PROX_ENTER)
                        end_event_type = PTSD_EventType.RIGHT_PROX_LEAVE;
                    end
                    
                    end_event_index = find(events == end_event_type, 1, 'first');
                    
                    if (~isempty(end_event_index))
                        end_event_time = datevec(event_times(end_event_index));
                        
                        %Remove the end event from the events array
                        events(end_event_index) = [];
                        event_times(end_event_index) = [];
                    else
                        end_event_time = cur_event_time;
                    end
                    
                end
                
                if (cur_event == PTSD_EventType.LEFT_NOSEPOKE_LEAVE || ...
                        cur_event == PTSD_EventType.RIGHT_NOSEPOKE_LEAVE)
                    if (end_event_time == cur_event_time)
                        cur_event_time = base_time;
                    end
                end
                
                %Calculate x and y values for the beginning and ending
                %events
                start_x = etime(cur_event_time, base_time);
                end_x = etime(end_event_time, base_time);
                    
                draw_vertical_line = 0;
                
                if (cur_event == PTSD_EventType.LEFT_NOSEPOKE_ENTER || ...
                        cur_event == PTSD_EventType.LEFT_NOSEPOKE_LEAVE || ...
                        cur_event == PTSD_EventType.LEFT_FEEDER_TRIGGERED)
                        start_y = LEFTNP;
                elseif (cur_event == PTSD_EventType.LEFT_PROX_ENTER || ...
                    cur_event == PTSD_EventType.LEFT_PROX_LEAVE)
                    start_y = LEFTP;
                elseif (cur_event == PTSD_EventType.RIGHT_PROX_ENTER || ...
                    cur_event == PTSD_EventType.RIGHT_PROX_LEAVE)
                    start_y = RIGHTP;
                elseif (cur_event == PTSD_EventType.RIGHT_NOSEPOKE_ENTER || ...
                    cur_event == PTSD_EventType.RIGHT_NOSEPOKE_LEAVE || ...
                    cur_event == PTSD_EventType.RIGHT_FEEDER_TRIGGERED)
                    start_y = RIGHTNP;
                elseif (PTSD_EventType.IsSoundEvent(cur_event))
                    draw_vertical_line = 1;
                else
                    start_y = UNKNOWN;
                end
                
                line_style = '-';
                if (cur_event == PTSD_EventType.LEFT_FEEDER_TRIGGERED || ...
                        cur_event == PTSD_EventType.RIGHT_FEEDER_TRIGGERED)
                    draw_vertical_line = 1;
                    line_style = '-.';
                end
                
                end_y = start_y;
                if (draw_vertical_line)
                    start_y = 0;
                    end_y = UNKNOWN;
                end
                
                color = [0 0 1];
                if (start_y == RIGHTP || start_y == RIGHTNP)
                    color = [1 0 0];
                elseif (start_y == UNKNOWN)
                    color = [0 0 0];
                end
                
                if (draw_vertical_line)
                    color = PTSD_EventType.event_colors(cur_event, :);
                end
                
                plot([start_x end_x], [start_y end_y], 'Color', color, 'LineWidth', 2, ...
                    'MarkerFaceColor', color, 'LineStyle', line_style, 'Marker', 'o');

            end
            
            ylim([0 5]);
            set(gca, 'YTick', 1:5);
            set(gca, 'YTickLabel', {'Left Nosepoke', 'Left Prox', 'Right Prox', 'Right Nosepoke', 'Unknown'});
            xlim([min(xlim)-0.5 max(xlim)+0.5]);
            xlabel('Seconds');
            
        end
        
    end
    
    methods (Access = protected)
        
        function obj = FilterSignal ( obj )

            %Find the first nosepoke leave event
            %This technically should always be the first event of the trial
            nosepoke_leave_index = find(obj.EventType == PTSD_EventType.LEFT_NOSEPOKE_LEAVE | ...
                obj.EventType == PTSD_EventType.RIGHT_NOSEPOKE_LEAVE, 1, 'first');
            
            %Assuming we find a nosepoke leave event
            if (~isempty(nosepoke_leave_index))
            
                %Save unfiltered versions of the signal
                obj.UnfilteredEventTime = obj.EventTime;
                obj.UnfilteredEventType = obj.EventType;
                
                %Filter out some unwanted events from the trial.
                pre_nosepoke_events = obj.UnfilteredEventType(1:nosepoke_leave_index);
                unwanted_events = find(pre_nosepoke_events ~= PTSD_EventType.LEFT_NOSEPOKE_LEAVE & ...
                    pre_nosepoke_events ~= PTSD_EventType.RIGHT_NOSEPOKE_LEAVE & ...
                    pre_nosepoke_events ~= PTSD_EventType.LEFT_NOSEPOKE_ENTER & ...
                    pre_nosepoke_events ~= PTSD_EventType.RIGHT_NOSEPOKE_ENTER & ...
                    pre_nosepoke_events ~= PTSD_EventType.LEFT_FEEDER_TRIGGERED & ...
                    pre_nosepoke_events ~= PTSD_EventType.RIGHT_FEEDER_TRIGGERED);
                obj.EventTime(unwanted_events) = [];
                obj.EventType(unwanted_events) = [];
                
            end
            
        end
        
        function obj = CalculateModifiedTransitTimes ( obj )
            
            if (obj.IsLeftToRight)
                nosepoke_id = PTSD_EventType.LEFT_NOSEPOKE_LEAVE;
                second_nosepoke_id = PTSD_EventType.RIGHT_NOSEPOKE_ENTER;
                first_prox_id = PTSD_EventType.LEFT_PROX_ENTER;
                second_prox_id = PTSD_EventType.RIGHT_PROX_LEAVE;
                second_prox_id_2 = PTSD_EventType.RIGHT_PROX_ENTER;
            else
                nosepoke_id = PTSD_EventType.RIGHT_NOSEPOKE_LEAVE;
                second_nosepoke_id = PTSD_EventType.LEFT_NOSEPOKE_ENTER;
                first_prox_id = PTSD_EventType.RIGHT_PROX_ENTER;
                second_prox_id = PTSD_EventType.LEFT_PROX_LEAVE;
                second_prox_id_2 = PTSD_EventType.LEFT_PROX_ENTER;
            end
            
            %Find the indices of each event
            nosepoke_leave_index = find(obj.EventType == nosepoke_id, 1, 'first');
            second_np_index = find(obj.EventType == second_nosepoke_id, 1, 'last');
            first_prox_index = find(obj.EventType == first_prox_id, 1, 'first');
            second_prox_index = find(obj.EventType == second_prox_id, 1, 'last');
            second_prox_enter_index = find(obj.EventType == second_prox_id_2, 1, 'first');

            %Grab the times that each event occurred
            first_np_time = datevec(obj.EventTime(nosepoke_leave_index));
            second_np_time = datevec(obj.EventTime(second_np_index));
            first_prox_time = datevec(obj.EventTime(first_prox_index));
            second_prox_time = datevec(obj.EventTime(second_prox_index));
            second_prox_enter_time = datevec(obj.EventTime(second_prox_enter_index));

            %Set the transit times, mark with nan if they are invalid.
            np_to_np = nan;
            if (~isempty(second_np_time) && ~isempty(first_np_time))
                np_to_np = etime(second_np_time, first_np_time);
            end

            np_to_first_prox = nan;
            if (~isempty(first_prox_time) && ~isempty(first_np_time))
                np_to_first_prox = etime(first_prox_time, first_np_time);
            end

            np_to_second_prox = nan;
            if (~isempty(second_prox_time) && ~isempty(first_np_time))
                np_to_second_prox = etime(second_prox_time, first_np_time);
            end

            prox_to_prox = nan;
            if (~isempty(second_prox_time) && ~isempty(first_prox_time))
                prox_to_prox = etime(second_prox_time, first_prox_time);
            end

            prox_to_2nd_np = nan;
            if (~isempty(second_np_time) && ~isempty(first_prox_time))
                prox_to_2nd_np = etime(second_np_time, first_prox_time);
            end

            second_prox_to_2nd_np = nan;
            if (~isempty(second_np_time) && ~isempty(second_prox_time));
                second_prox_to_2nd_np = etime(second_np_time, second_prox_time);
            end

            first_prox_to_2nd_prox_enter = nan;
            if (~isempty(first_prox_time) && ~isempty(second_prox_enter_time))
                first_prox_to_2nd_prox_enter = etime(second_prox_enter_time, first_prox_time);
            end

            obj.NosepokeToNosepokeTransitTime = np_to_np;
            obj.NosepokeToFirstProxTransitTime = np_to_first_prox;
            obj.NosepokeToSecondProxTransitTime = np_to_second_prox;
            obj.FirstProxToSecondProxTransitTime = prox_to_prox;
            obj.FirstProxToSecondNosepokeTransitTime = prox_to_2nd_np;
            obj.SecondProxToSecondNosepokeTransitTime = second_prox_to_2nd_np;
            obj.FirstProxEnterToSecondProxEnterTransitTime = first_prox_to_2nd_prox_enter;

            first_event = datevec(obj.EventTime(1));
            last_event = datevec(obj.EventTime(end));
            obj.TrialDuration = etime(last_event, first_event);
            
            if (isnan(obj.NosepokeToNosepokeTransitTime))
                obj.NosepokeToNosepokeTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.NosepokeToFirstProxTransitTime))
                obj.NosepokeToFirstProxTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.NosepokeToSecondProxTransitTime))
                obj.NosepokeToSecondProxTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.FirstProxToSecondProxTransitTime))
                obj.FirstProxToSecondProxTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.FirstProxToSecondNosepokeTransitTime))
                obj.FirstProxToSecondNosepokeTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.SecondProxToSecondNosepokeTransitTime))
                obj.SecondProxToSecondNosepokeTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.FirstProxEnterToSecondProxEnterTransitTime))
                obj.FirstProxEnterToSecondProxEnterTransitTime = obj.TrialDuration;
            end
            
        end
        
        function obj = CalculateTransitTimes ( obj )
            
            %Start by initializing all transit times to NaN
            obj.NosepokeToNosepokeTransitTime = NaN;
            obj.NosepokeToFirstProxTransitTime = NaN;
            obj.NosepokeToSecondProxTransitTime = NaN;
            obj.FirstProxToSecondProxTransitTime = NaN;
            obj.FirstProxToSecondNosepokeTransitTime = NaN;
            obj.SecondProxToSecondNosepokeTransitTime = NaN;
            obj.FirstProxEnterToSecondProxEnterTransitTime = NaN;
            
            %Figure out whether this is a left or a right trial
            first_feeder_event = find(PTSD_EventType.IsFeederEvent(obj.EventType), 1, 'first');
            nosepoke_id = NaN;
            if (~isempty(first_feeder_event))
                obj.IsLeftToRight = (obj.EventType(first_feeder_event) == PTSD_EventType.LEFT_FEEDER_TRIGGERED);
                
                if (obj.IsLeftToRight)
                    nosepoke_id = PTSD_EventType.LEFT_NOSEPOKE_LEAVE;
                else
                    nosepoke_id = PTSD_EventType.RIGHT_NOSEPOKE_LEAVE;
                end
            else
                obj.IsLeftToRight = NaN;
                obj.IsInvalidTrial = 1;
            end
            
            %Set some variables to be some default values
            second_nosepoke_id = PTSD_EventType.RIGHT_NOSEPOKE_ENTER;
            first_prox_id = PTSD_EventType.LEFT_PROX_ENTER;
            second_prox_id = PTSD_EventType.RIGHT_PROX_LEAVE;
            second_prox_id_2 = PTSD_EventType.RIGHT_PROX_ENTER;

            %Change the values depending on what our first nosepoke is
            if (nosepoke_id == PTSD_EventType.RIGHT_NOSEPOKE_LEAVE)
                second_nosepoke_id = PTSD_EventType.LEFT_NOSEPOKE_ENTER;
                first_prox_id = PTSD_EventType.RIGHT_PROX_ENTER;
                second_prox_id = PTSD_EventType.LEFT_PROX_LEAVE;
                second_prox_id_2 = PTSD_EventType.LEFT_PROX_ENTER;
            end

            %Find the indices of each event
            nosepoke_leave_index = find(obj.EventType == nosepoke_id, 1, 'first');
            second_np_index = find(obj.EventType == second_nosepoke_id, 1, 'last');
            first_prox_index = find(obj.EventType == first_prox_id, 1, 'first');
            second_prox_index = find(obj.EventType == second_prox_id, 1, 'last');
            second_prox_enter_index = find(obj.EventType == second_prox_id_2, 1, 'first');

            %Grab the times that each event occurred
            first_np_time = datevec(obj.EventTime(nosepoke_leave_index));
            second_np_time = datevec(obj.EventTime(second_np_index));
            first_prox_time = datevec(obj.EventTime(first_prox_index));
            second_prox_time = datevec(obj.EventTime(second_prox_index));
            second_prox_enter_time = datevec(obj.EventTime(second_prox_enter_index));

            %Set the transit times, mark with nan if they are invalid.
            np_to_np = nan;
            if (~isempty(second_np_time) && ~isempty(first_np_time))
                np_to_np = etime(second_np_time, first_np_time);
            end

            np_to_first_prox = nan;
            if (~isempty(first_prox_time) && ~isempty(first_np_time))
                np_to_first_prox = etime(first_prox_time, first_np_time);
            end

            np_to_second_prox = nan;
            if (~isempty(second_prox_time) && ~isempty(first_np_time))
                np_to_second_prox = etime(second_prox_time, first_np_time);
            end

            prox_to_prox = nan;
            if (~isempty(second_prox_time) && ~isempty(first_prox_time))
                prox_to_prox = etime(second_prox_time, first_prox_time);
            end

            prox_to_2nd_np = nan;
            if (~isempty(second_np_time) && ~isempty(first_prox_time))
                prox_to_2nd_np = etime(second_np_time, first_prox_time);
            end

            second_prox_to_2nd_np = nan;
            if (~isempty(second_np_time) && ~isempty(second_prox_time));
                second_prox_to_2nd_np = etime(second_np_time, second_prox_time);
            end

            first_prox_to_2nd_prox_enter = nan;
            if (~isempty(first_prox_time) && ~isempty(second_prox_enter_time))
                first_prox_to_2nd_prox_enter = etime(second_prox_enter_time, first_prox_time);
            end

            obj.NosepokeToNosepokeTransitTime = np_to_np;
            obj.NosepokeToFirstProxTransitTime = np_to_first_prox;
            obj.NosepokeToSecondProxTransitTime = np_to_second_prox;
            obj.FirstProxToSecondProxTransitTime = prox_to_prox;
            obj.FirstProxToSecondNosepokeTransitTime = prox_to_2nd_np;
            obj.SecondProxToSecondNosepokeTransitTime = second_prox_to_2nd_np;
            obj.FirstProxEnterToSecondProxEnterTransitTime = first_prox_to_2nd_prox_enter;

            first_event = datevec(obj.EventTime(1));
            last_event = datevec(obj.EventTime(end));
            obj.TrialDuration = etime(last_event, first_event);
            
            if (isnan(obj.NosepokeToNosepokeTransitTime))
                obj.NosepokeToNosepokeTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.NosepokeToFirstProxTransitTime))
                obj.NosepokeToFirstProxTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.NosepokeToSecondProxTransitTime))
                obj.NosepokeToSecondProxTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.FirstProxToSecondProxTransitTime))
                obj.FirstProxToSecondProxTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.FirstProxToSecondNosepokeTransitTime))
                obj.FirstProxToSecondNosepokeTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.SecondProxToSecondNosepokeTransitTime))
                obj.SecondProxToSecondNosepokeTransitTime = obj.TrialDuration;
            end
            
            if (isnan(obj.FirstProxEnterToSecondProxEnterTransitTime))
                obj.FirstProxEnterToSecondProxEnterTransitTime = obj.TrialDuration;
            end
                
        end
        
    end
    
end

















