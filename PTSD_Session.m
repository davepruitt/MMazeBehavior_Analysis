classdef PTSD_Session
    %PTSD_SESSION This class holds a single session of PTSD M-Maze data and
    %provides methods to analyze the data.
    %The following functions are currently available:
    %   RetrieveTransitTimes
    %   PlotSession
    %
    %Type "help PTSD_Session.(function name)" to read more about each
    %individual function.
    %
    %More functions may be added in the future.
    
    properties (Constant)
        
        
        
    end
    
    properties
        RatName
        Stage
        StartTime
        EndTime
        EventTime
        EventType
        SessionStatus
        
        IsSessionSound
        SessionSoundType
        
        Trials
        TotalFeeds
        
        SessionSegmentsBeforeSounds
        SessionSegmentsAfterSounds
        
        IsDummySession
        
    end
    
    methods
        
        function obj = PTSD_Session ( varargin )
            %This function expects either a string (the file name of a
            %session to load), or a data structure that contains the data
            %from a loaded file (the data structure returned from the
            %Read_PTSD_MMaze_File function).
            use_max_trial_length = 1;
            
            if (isempty(varargin{1}))
                %If the user passes an empty array as the first parameter.
                %Create a dummy session.
                p = inputParser;
                
                defaultDateNum = now;
                defaultRatName = '';
                default_use_max_trial_length = 1;
                addOptional(p, 'DateNum', defaultDateNum);
                addOptional(p, 'RatName', defaultRatName);
                addOptional(p, 'UseMaxTrialLength', default_use_max_trial_length);
                parse(p, varargin{2:end});
                date_num = p.Results.DateNum;
                rat_name = p.Results.RatName;
                use_max_trial_length = p.Results.UseMaxTrialLength;
                
                obj = obj.CreateDummySession(date_num, rat_name);
                return;
            else
                if (nargin == 1)
                    data = varargin{1};
                elseif (nargin == 2)
                    path = varargin{1};
                    file = varargin{2};
                    data = Read_PTSD_MMaze_File(path, file);
                elseif (nargin == 3)
                    path = varargin{1};
                    file = varargin{2};
                    load_binary = varargin{3};
                    data = Read_PTSD_MMaze_File(path, file, 'LoadBinaryCopiesIfAvailable', load_binary);
                elseif (nargin == 4)
                    path = varargin{1};
                    file = varargin{2};
                    load_binary = varargin{3};
                    force_save_binaries = varargin{4};
                    data = Read_PTSD_MMaze_File(path, file, 'LoadBinaryCopiesIfAvailable', load_binary, ...
                        'ForceSave', force_save_binaries);
                else
                    data = [];
                end
            end
            
            %If the user passed in a filename to load, load it in.
            %if (ischar(data))
            %    data = Read_PTSD_MMaze_File(data);
            %end
            
            %At this point, data should be a structure.
            obj.RatName = data.name;
            obj.Stage = data.stage;
            obj.StartTime = data.start_timestamp;
            obj.EndTime = data.end_timestamp;
            obj.EventTime = data.event_timestamp;
            obj.EventType = data.event_type;
            obj.SessionStatus = data.return_code;
            obj.IsDummySession = 0;
            obj.SessionSegmentsBeforeSounds = [];
            obj.SessionSegmentsAfterSounds = [];
            
            %Retrieve feeder times
            %Each time there is a feed, that begins a new "trial".
            feeder_indices = find(obj.EventType == PTSD_EventType.LEFT_FEEDER_TRIGGERED | ...
                obj.EventType == PTSD_EventType.RIGHT_FEEDER_TRIGGERED);

            obj.Trials = [];
            
            for i=1:length(feeder_indices)
                p1 = feeder_indices(i);
                if (i == length(feeder_indices))
                    p2 = length(obj.EventType);
                else
                    p2 = feeder_indices(i+1) - 1;
                end

                t_sig = obj.EventType(p1:p2);
                t_times = obj.EventTime(p1:p2);

                trial = PTSD_Trial(t_times, t_sig);

                if (~use_max_trial_length)
                    obj.Trials = [obj.Trials trial];
                else
                    trial_array = trial.SplitIntoMultipleTrials();
                    obj.Trials = [obj.Trials trial_array];
                end

            end
            
            obj.TotalFeeds = length(feeder_indices);
            
            if (~isempty(obj.Trials))
                sound_trial_indices = find([obj.Trials.IsSoundTrial] == 1);
                if (~isempty(sound_trial_indices))
                    obj.IsSessionSound = 1;
                    obj.SessionSoundType = obj.Trials(sound_trial_indices(1)).SoundType;
                else
                    obj.IsSessionSound = 0;
                    obj.SessionSoundType = PTSD_EventType.UNKNOWN_EVENT;
                end
            else
                obj.IsSessionSound = 0;
                obj.SessionSoundType = PTSD_EventType.UNKNOWN_EVENT;
            end
            
            %Create 30-second session segments for sessions with sounds
            if (obj.IsSessionSound)
                
                %Find the index of each sound in the series of all events
                %for this session
                sound_indices = find(PTSD_EventType.IsSoundEvent(obj.EventType));
                
                %Iterate over each sound
                for k = 1:length(sound_indices)
                    
                    %Get the index of this sound
                    this_sound_index = sound_indices(k);
                    
                    %Find the time of this sound
                    this_sound_time = obj.EventTime(this_sound_index);
                    
                    %Subtract 30 seconds, and add 30 seconds
                    sound_minus_30 = addtodate(this_sound_time, -30, 'second');
                    sound_plus_30 = addtodate(this_sound_time, 30, 'second');
                    
                    %Find the nearest event <= 30 seconds away in each
                    %direction
                    earliest_event_minus_30_index = find(obj.EventTime >= sound_minus_30, 1, 'first');
                    last_event_plus_30_index = find(obj.EventTime <= sound_plus_30, 1, 'last');
                    
                    %Get all events in the interval
                    all_events_before_sound = obj.EventType(earliest_event_minus_30_index:this_sound_index);
                    event_times_before_sound = obj.EventTime(earliest_event_minus_30_index:this_sound_index);
                    
                    all_events_after_sound = obj.EventType(this_sound_index:last_event_plus_30_index);
                    event_times_after_sound = obj.EventTime(this_sound_index:last_event_plus_30_index);
                    
                    %Create the new segment
                    new_segment_pre = PTSD_Session_Segment(all_events_before_sound, event_times_before_sound);
                    new_segment_post = PTSD_Session_Segment(all_events_after_sound, event_times_after_sound);
                    
                    %Add it to our list of segments
                    obj.SessionSegmentsBeforeSounds = [obj.SessionSegmentsBeforeSounds new_segment_pre];
                    obj.SessionSegmentsAfterSounds = [obj.SessionSegmentsAfterSounds new_segment_post];
                    
                end
                
            end
                
        end
        
        function obj = CreateDummySession ( obj, date_num, rat_name )
            obj.RatName = rat_name;
            obj.Stage = '';
            obj.StartTime = date_num;
            obj.EndTime = NaN;
            obj.EventTime = [];
            obj.EventType = [];
            obj.SessionStatus = -1;
            obj.IsSessionSound = 0;
            obj.SessionSoundType = -1;
            obj.Trials = [];
            obj.TotalFeeds = NaN;
            obj.IsDummySession = 1;
        end
        
        function [data_values, beginning_final_excluded_trial, ending_first_excluded_trial] = RetrieveTransitTimes ( obj, varargin )
            %Retrieves transit times for this session, both raw times and
            %averages.  The following options are available for this
            %function:
            %
            % TransitType: the value of this option MUST be a string, and
            % it MUST be equal to the variable name of one of the transit
            % type variables in PTSD_Trial. Default value: FirstProxEnterToSecondProxEnterTransitTime
            %
            % Mode: the value of this option can be any of the following
            % strings: AllTrials, AllSounds, FirstSound, LastSound. 
            % Default value: FirstSound.
            %
            % Mean: this is a numeric value (can be a 1 or a 0), and it
            % determines whether this function returns the list of raw
            % transit times, or returns the mean.  If the mean is chosen,
            % a 2-element array containing the mean and SEM will be
            % returned. Defalut value: 1.
            
            p = inputParser;
            
            trialExclusionMethods = {'None', 'Raw', 'Relative'};
            trialExclusionTiming = {'None', 'TimeBased', 'TrialBased'};
            beginning_final_excluded_trial = NaN;
            ending_first_excluded_trial = NaN;
            
            defaultTransitType = 'FirstProxEnterToSecondProxEnterTransitTime';
            defaultMode = 'FirstSound';
            defaultUseMean = 1;
            defaultTrialExclusionMethod = 'None';
            defaultTrialExclusionTiming = 'None';
            defaultStartExclusion = NaN;
            defaultEndExclusion = NaN;
            
            addOptional(p, 'TransitType', defaultTransitType);
            addOptional(p, 'Mode', defaultMode);
            addOptional(p, 'Mean', defaultUseMean, @isnumeric);
            addOptional(p, 'TrialExclusionMethod', defaultTrialExclusionMethod);
            addOptional(p, 'TrialExclusionTiming', defaultTrialExclusionTiming);
            addOptional(p, 'StartExclusion', defaultStartExclusion);
            addOptional(p, 'EndExclusion', defaultEndExclusion);
            parse(p, varargin{:});
            
            mode = p.Results.Mode;
            transit_type = p.Results.TransitType;
            use_mean = p.Results.Mean;
            exclusion_method = p.Results.TrialExclusionMethod;
            exclusion_timing = p.Results.TrialExclusionTiming;
            start_exclusion = p.Results.StartExclusion;
            end_exclusion = p.Results.EndExclusion;
            
            %Return an empty array if no trials were found.
            data_values = NaN;
            if (isempty(obj.Trials))
                return;
            end
            
            trials = [];
            all_sounds_plus_trials = [];
            
            if (strcmpi(transit_type, 'TOTAL_FEEDS'))
                data_values = obj.TotalFeeds;
                return;
            elseif (strcmpi(transit_type, 'TOTAL_NOSEPOKES'))
                data_values = nnz(PTSD_EventType.IsNosepokeEnterEvent(obj.EventType));
                return;
            elseif (strcmpi(transit_type, 'LEFT_NOSEPOKES'))
                data_values = nnz(obj.EventType == PTSD_EventType.LEFT_NOSEPOKE_ENTER);
                return;
            elseif (strcmpi(transit_type, 'RIGHT_NOSEPOKES'))
                data_values = nnz(obj.EventType == PTSD_EventType.RIGHT_NOSEPOKE_ENTER);
                return;
            elseif (strcmpi(transit_type, 'LEFT_FEEDS'))
                data_values = nnz(obj.EventType == PTSD_EventType.LEFT_FEEDER_TRIGGERED);
                return;
            elseif (strcmpi(transit_type, 'RIGHT_FEEDS'))
                data_values = nnz(obj.EventType == PTSD_EventType.RIGHT_FEEDER_TRIGGERED);
                return;
            end
            
            %Modes: FirstSound, AllSounds, AllTrials, LastSound
            switch (mode)
                case 'AllTrials'
                    trials = obj.Trials;
                case 'AllSounds'
                    trials = obj.Trials([obj.Trials.IsSoundTrial]);
                    if (isempty(trials))
                        trials = obj.Trials(find([obj.Trials.IsCatchTrial]));
                    end
                case 'AllSoundsPlus'
                    trials = obj.Trials([obj.Trials.IsSoundTrial]);
                    trial_indices = find([obj.Trials.IsSoundTrial]);
                    if (isempty(trials))
                        trials = obj.Trials(find([obj.Trials.IsCatchTrial]));
                        trial_indices = find([obj.Trials.IsCatchTrial]);
                    end
                    
                    if (~isempty(trial_indices))
                        trial_indices = trial_indices + 1;
                        trial_indices = trial_indices(trial_indices <= length(obj.Trials));
                        
                        try
                            all_sounds_plus_trials = obj.Trials(trial_indices);
                        catch e
                            e
                        end
                    end
                    
                case 'EarlyTrials'
                    
                    %Initially set the trials object to be empty.  No
                    %trials are included
                    trials = [];
                    
                    %Find the index of the first sound trial
                    first_sound_trial_index = find([obj.Trials.IsSoundTrial], 1, 'first');
                    
                    if (isempty(first_sound_trial_index))
                        first_sound_trial_index = find([obj.Trials.IsCatchTrial]);
                    end
                    
                    %Grab all trials up to the first sound trial (excluding
                    %the first sound trial
                    if (first_sound_trial_index > 1)
                        
                        %Grab all trials that occurred before the sound
                        %trial
                        trials_before_sound_trial = obj.Trials(1:(first_sound_trial_index - 1));
                        
                        %Now, we only want the last 10 trials that occurred
                        %before the first sound trial, so let's grab those
                        if (length(trials_before_sound_trial) > 10)
                            %Get the indices of the last 10 trials
                            count = 1:length(trials_before_sound_trial);
                            last_10_trials_indices = find(count == count, 10, 'last');
                            trials_before_sound_trial = trials_before_sound_trial(last_10_trials_indices);
                        end
                        
                        trials = trials_before_sound_trial;
                        
                        %Later we will exclude the largest and smallest
                        %trials, but we will not do that at this point,
                        %because we don't even know what we are getting
                        %yet.
                        
                    end
                    
                case 'AllTrialsExceptSounds'
                    
                    %Initially set the trials object to include all trials
                    %from this session
                    trials = obj.Trials;
                    
                    %Exclude some trials based on the exclusion criteria specified
                    %by the user
                    if (strcmpi(mode, 'AllTrialsExceptSounds') == 1)
                        start_exclusion = p.Results.StartExclusion;
                        end_exclusion = p.Results.EndExclusion;

                        if (~isnan(start_exclusion) && ~isnan(end_exclusion))
                            if (strcmpi(exclusion_method, 'None') ~= 1)
                                if (strcmpi(exclusion_timing, 'None') ~= 1)

                                    if (strcmpi(exclusion_method, 'Raw') == 1 && strcmpi(exclusion_timing, 'TimeBased') == 1)

                                        %Calculate the elapsed time that each trial begins
                                        %since the start of the session.
                                        trial_start_times = [];
                                        reference_point = datevec(obj.StartTime);
                                        for i = 1:length(trials)
                                            dv = datevec(trials(i).EventTime(1));
                                            elapsed_sec = etime(dv, reference_point);
                                            elapsed_minutes = elapsed_sec / 60;
                                            trial_start_times = [trial_start_times elapsed_minutes];
                                        end

                                        trials_to_keep = find(trial_start_times > start_exclusion & ...
                                            trial_start_times < end_exclusion);
                                        trials = trials(trials_to_keep);
                                        beginning_final_excluded_trial = trials_to_keep(1) - 1;
                                        ending_first_excluded_trial = trials_to_keep(end) + 1;

                                    elseif (strcmpi(exclusion_method, 'Raw') == 1 && strcmpi(exclusion_timing, 'TrialBased') == 1)
                                        
                                        if (start_exclusion < 1)
                                            start_exclusion = 1;
                                        end
                                        
                                        if (end_exclusion > length(trials))
                                            end_exclusion = length(trials);
                                        end
                                        
                                        beginning_final_excluded_trial = start_exclusion;
                                        ending_first_excluded_trial = end_exclusion;
                                        s = start_exclusion + 1;
                                        f = end_exclusion - 1;
                                        
                                        trials = trials(s:f);
                                        
                                    elseif (strcmpi(exclusion_method, 'Relative') == 1 && strcmpi(exclusion_timing, 'TimeBased') == 1)
                                        
                                        first_sound_index = find([trials.IsSoundTrial], 1, 'first');
                                        last_sound_index = find([trials.IsSoundTrial], 1, 'last');
                                        first_sound_time = datevec(trials(first_sound_index).EventTime(1));
                                        last_sound_time = datevec(trials(last_sound_index).EventTime(1));
                                        
                                        diff_first = [];
                                        diff_last = [];
                                        
                                        for i = 1:length(trials)
                                            dv = datevec(trials(i).EventTime(1));
                                            df = etime(dv, first_sound_time) / 60;
                                            dl = etime(dv, last_sound_time) / 60;
                                            diff_first = [diff_first df];
                                            diff_last = [diff_last dl];
                                        end
                                        
                                        trials_to_keep = find(diff_first > (-start_exclusion) & ...
                                            diff_last < end_exclusion);
                                        trials = trials(trials_to_keep);
                                        beginning_final_excluded_trial = trials_to_keep(1) - 1;
                                        ending_first_excluded_trial = trials_to_keep(end) + 1;
                                        
                                        
                                    elseif (strcmpi(exclusion_method, 'Relative') == 1 && strcmpi(exclusion_timing, 'TrialBased') == 1)
                                        
                                        first_sound_index = find([trials.IsSoundTrial], 1, 'first');
                                        last_sound_index = find([trials.IsSoundTrial], 1, 'last');
                                        
                                        beginning_final_excluded_trial = first_sound_index - start_exclusion;
                                        ending_first_excluded_trial = last_sound_index + end_exclusion;
                                        
                                        s = beginning_final_excluded_trial + 1;
                                        f = ending_first_excluded_trial - 1;
                                        
                                        trials = trials(s:f);
                                        
                                    end

                                end
                            end
                        end
                    end

                    %Now exclude all "sound" trials
                    trials = trials(~[trials.IsSoundTrial]);
                case 'TrialsDirectlyPrecedingSounds'
                    trial_indices = find([obj.Trials.IsSoundTrial]);
                    if (~isempty(trial_indices))
                        %Subtract 1 from each index to get the preceding
                        %trial
                        trial_indices = trial_indices - 1;
                        for i = 1:length(trial_indices)
                            done = 0;
                            while (~done)
                                if (trial_indices(i) <= 0)
                                    done = 1;
                                elseif (~obj.Trials(trial_indices(i)).IsSoundTrial)
                                    done = 1;
                                else
                                    trial_indices(i) = trial_indices(i) - 1;
                                end
                            end
                        end
                        
                        %Make sure all indices are positive
                        trial_indices = trial_indices(trial_indices > 0);
                        
                        %Get the trials
                        trials = obj.Trials(trial_indices);
                    end
                case 'FirstSound'
                    first_sound_trial = find([obj.Trials.IsSoundTrial], 1, 'first');
                    if (isempty(first_sound_trial))
                        first_sound_trial = find([obj.Trials.IsCatchTrial], 1, 'first');
                    end
                    trials = obj.Trials(first_sound_trial);
                case 'LastSound'
                    last_sound_trial = find([obj.Trials.IsSoundTrial], 1, 'last');
                    if (isempty(last_sound_trial))
                        last_sound_trial = find([obj.Trials.IsCatchTrial], 1, 'last');
                    end
                    trials = obj.Trials(last_sound_trial);
            end
            
            %Get the transit times for all trials involved in the analysis.
            if (~isempty(trials))
                transit_times = [trials.(transit_type)];
            else
                transit_times = [];
            end
            
            %Now let's exclude the largest and smallest trials if that is
            %something the user wants to do
            if (strcmpi(mode, 'EarlyTrials') == 1)
                %Delete the largest element
                if (~isempty(transit_times))
                    index_of_largest = find(transit_times == max(transit_times), 1, 'first');
                    if (~isempty(index_of_largest))
                        transit_times(index_of_largest) = [];        
                    end
                    
                    %Delete the smallest element
                    index_of_smallest = find(transit_times == min(transit_times), 1, 'first');
                    if (~isempty(index_of_smallest))
                        transit_times(index_of_smallest) = [];
                    end
                end
            elseif (strcmpi(mode, 'AllSoundsPlus') == 1)
                %If "AllSoundsPlus" is the mode, then we need to compare
                %the transit times that we retrieved with the transit times
                %of the immediately post-ceding trials, and take the max of
                %each as the transit time to return.
                %This is the transit time = max(i, i+1) code.
                if (~isempty(all_sounds_plus_trials))
                    alternate_transit_times = [all_sounds_plus_trials.(transit_type)];
                    if (length(alternate_transit_times) == length(transit_times))
                        for i = 1:length(transit_times)
                            transit_times(i) = max(transit_times(i), alternate_transit_times(i));
                        end
                    end
                end
            end
            
            mean_transit_time = nanmean(transit_times);
            sem_transit_time = std(transit_times) / sqrt(length(transit_times));
            
            if (~use_mean)
                %Return the raw transit times of each trial
                data_values = transit_times;
            else
                %Return the mean and SEM in a 2-element array.
                data_values = [mean_transit_time sem_transit_time];
            end
            
        end

        function differences = RetrieveSegmentDifferences ( obj, varargin )
            
            p = inputParser;
            
            defaultSegmentLength = 30;
            
            addOptional(p, 'SegmentLength', defaultSegmentLength);
            parse(p, varargin{:});
            
            segment_length = p.Results.SegmentLength;
            
            [before, after] = obj.RetrieveSegments('SegmentLength', segment_length);
            
            %We subtract after from before so that any reduction in events
            %will be an increase in "differences", essentially showing an
            %"increase" in freezing behavior.
            for i = 1:length(before)
                differences(i) = PTSD_Session_Segment.SubtractSegments(before(i), after(i));
            end
            
        end
        
        function sr = RetrieveSuppressionRate ( obj, varargin )
            
            p = inputParser;
            
            defaultSegmentLength = 30;
            defaultMode = 'FirstSound';
            
            addOptional(p, 'SegmentLength', defaultSegmentLength);
            addOptional(p, 'Mode', defaultMode);
            parse(p, varargin{:});
            
            segment_length = p.Results.SegmentLength;
            mode = p.Results.Mode;
            
            [before, after] = obj.RetrieveSegments('SegmentLength', segment_length);
            
            if (strcmpi(mode, 'FirstSound'))
                
                before = before(1);
                after = after(1);
                
            elseif (strcmpi(mode, 'LastSound'))
                
                before = before(1);
                after = after(end);
                
            elseif (strcmpi(mode, 'AverageOfAllSounds'))
                
                before = before(1);
                new_after = after(1);
                for i = 2:length(after)
                    new_after = PTSD_Session_Segment.AddSegments(new_after, after(i));
                end
                after = new_after;
                
            else
                %Anything here?
            end
            
            for i = 1:length(before)
                
                numerator = PTSD_Session_Segment.SubtractSegments(before(i), after(i));
                denominator = PTSD_Session_Segment.AddSegments(before(i), after(i));
                sr(i) = PTSD_Session_Segment.DivideSegments(numerator, denominator);
                
            end
            
            
        end
        
        function [before_segments, after_segments] = RetrieveSegments ( obj, varargin )
            
            p = inputParser;
            
            defaultSegmentLength = 30;
            
            addOptional(p, 'SegmentLength', defaultSegmentLength);
            parse(p, varargin{:});
            
            segment_length = p.Results.SegmentLength;
            before_segments = [];
            after_segments = [];
            
            %Create 30-second session segments for sessions with sounds
            if (obj.IsSessionSound)
                %Find the index of each sound in the series of all events
                %for this session
                sound_indices = find(PTSD_EventType.IsSoundEvent(obj.EventType));
            else
                %Currently, silent "catch trials" are listed as
                %PTSD_EventType.UNKNOWN_EVENT.  Let's just grab the first
                %five of these from the session.
                sound_indices = find(obj.EventType == PTSD_EventType.UNKNOWN_EVENT, 5, 'first');
            end

            %Iterate over each sound
            for k = 1:length(sound_indices)

                %Get the index of this sound
                this_sound_index = sound_indices(k);

                %Find the time of this sound
                this_sound_time = obj.EventTime(this_sound_index);

                %Subtract 30 seconds, and add 30 seconds
                sound_minus_30 = addtodate(this_sound_time, -segment_length, 'second');
                sound_plus_30 = addtodate(this_sound_time, segment_length, 'second');

                %Find the nearest event <= 30 seconds away in each
                %direction
                earliest_event_minus_30_index = find(obj.EventTime >= sound_minus_30, 1, 'first');
                last_event_plus_30_index = find(obj.EventTime <= sound_plus_30, 1, 'last');

                %Get all events in the interval
                all_events_before_sound = obj.EventType(earliest_event_minus_30_index:this_sound_index);
                event_times_before_sound = obj.EventTime(earliest_event_minus_30_index:this_sound_index);

                all_events_after_sound = obj.EventType(this_sound_index:last_event_plus_30_index);
                event_times_after_sound = obj.EventTime(this_sound_index:last_event_plus_30_index);

                %Create the new segment
                new_segment_pre = PTSD_Session_Segment(all_events_before_sound, event_times_before_sound);
                new_segment_post = PTSD_Session_Segment(all_events_after_sound, event_times_after_sound);

                %Add it to our list of segments
                before_segments = [before_segments new_segment_pre];
                after_segments = [after_segments new_segment_post];

            end
                
        end
        
        function PlotSession ( obj, varargin )

            p = inputParser;
            
            defaultFigure = 0;
            defaultTransitType = 'FirstProxEnterToSecondProxEnterTransitTime';
            defaultAreaPlot = 0;
            defaultCompareLeftRight = 0;
            
            addOptional(p, 'Figure', defaultFigure);
            addOptional(p, 'AreaPlot', defaultAreaPlot, @isnumeric);
            addOptional(p, 'TransitType', defaultTransitType);
            addOptional(p, 'CompareLeftAndRight', defaultCompareLeftRight, @isnumeric);
            parse(p, varargin{:});
            
            use_area_plot = p.Results.AreaPlot;
            transit_type = p.Results.TransitType;
            compare_left_right = p.Results.CompareLeftAndRight;
            
            %Grab the figure that the user passed in, or create a new
            %figure.
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
            
            if (isempty(obj.Trials))
                text(10, 10, 'No trials found for this session.', 'FontSize', 14);
                xlim([0 30]);
                ylim([0 30]);
                return;
            end
            
            %Check to see whether the user wants to compare left-start
            %trials with right-start trials
            if (~compare_left_right)
                %Get the data to be plotted
                y_vals = [obj.Trials.(transit_type)];
                is_sound_trial = [obj.Trials.IsSoundTrial];
                sound_type = [obj.Trials.SoundType];

                %Plot everything
                if (use_area_plot)
                    h = area(y_vals);
                    h(1).FaceColor = [0.7 0.7 1.0];
                else
                    plot(y_vals, 'Color', 'b');
                end
                xlim([0 length(y_vals)]);

                for i=1:length(is_sound_trial)
                    if (is_sound_trial(i))

                        color = [0 0 0];
                        if (PTSD_EventType.IsSoundEvent(sound_type(i)))
                            color = PTSD_EventType.event_colors(sound_type(i), :);
                        end

                        line([i i], [min(ylim) max(ylim)], 'LineStyle', '--', 'Color', color);
                    end
                end
            else
                
                left_right_trials = [obj.Trials.IsLeftToRight];
                left_trials = obj.Trials(left_right_trials);
                right_trials = obj.Trials(~left_right_trials);
                
                y_vals_left = [left_trials.(transit_type)];
                is_sound_left = [left_trials.IsSoundTrial];
                sound_type_left = [left_trials.SoundType];
                
                y_vals_right = [right_trials.(transit_type)];
                is_sound_right = [right_trials.IsSoundTrial];
                sound_type_right = [right_trials.SoundType];
                
                %Plot everything
                plot(y_vals_left, 'Color', 'b');
                plot(y_vals_right, 'Color', 'r');
                
                xlim([0 max([length(y_vals_left) length(y_vals_right)])]);
                
                for i=1:length(is_sound_left)
                    if (is_sound_left(i))

                        color = [0 0 0];
                        if (PTSD_EventType.IsSoundEvent(sound_type_left(i)))
                            color = PTSD_EventType.event_colors(sound_type_left(i), :);
                        end

                        line([i i], [min(ylim) max(ylim)], 'LineStyle', '--', 'Color', color);
                    end
                end
                
                for i=1:length(is_sound_right)
                    if (is_sound_right(i))

                        color = [0 0 0];
                        if (PTSD_EventType.IsSoundEvent(sound_type_right(i)))
                            color = PTSD_EventType.event_colors(sound_type_right(i), :);
                        end

                        line([i i], [min(ylim) max(ylim)], 'LineStyle', '--', 'Color', color);
                    end
                end
                
                legend('Left Trials', 'Right Trials');
            end

            ylabel('Seconds');
            xlabel('Trial');
            
        end
        
        function [stat, p, fic, lic] = GetSessionStats ( obj, varargin )
            
                p = inputParser;
                defaultStat = PTSD_Utility.SessionStatsCorrelation;
                defaultTransitType = 'FirstProxEnterToSecondProxEnterTransitTime';
                defaultTrialExclusionMethod = 'None';
                defaultTrialExclusionTiming = 'None';
                defaultStartExclusion = 0;
                defaultEndExclusion = 0;
                defaultIncludeNonSoundSessions = 0;
                
                addOptional(p, 'Statistic', defaultStat);
                addOptional(p, 'TransitType', defaultTransitType);
                
                addOptional(p, 'TrialExclusionMethod', defaultTrialExclusionMethod);
                addOptional(p, 'TrialExclusionTiming', defaultTrialExclusionTiming);
                addOptional(p, 'StartExclusion', defaultStartExclusion);
                addOptional(p, 'EndExclusion', defaultEndExclusion);
                addOptional(p, 'IncludeNonSoundSessions', defaultIncludeNonSoundSessions);
                
                parse(p, varargin{:});
                stat_to_use = p.Results.Statistic;
                transit_type = p.Results.TransitType;
                exclusion_method = p.Results.TrialExclusionMethod;
                exclusion_timing = p.Results.TrialExclusionTiming;
                start_exclusion = p.Results.StartExclusion;
                end_exclusion = p.Results.EndExclusion;
                include_non_sound = p.Results.IncludeNonSoundSessions;
                
                stat = NaN;
                p = NaN;
                fic = NaN;
                lic = NaN;
                
                if (include_non_sound || obj.IsSessionSound)
                    if (stat_to_use == PTSD_Utility.SessionStatsCorrelation)
                        %Get the correlation coefficient of all sound
                        %trials
                        t = obj.RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'AllSounds', 'Mean', 0);
                        xvals = 1:length(t);
                        xvals = xvals';
                        t = t';
                        [stat, p] = corr(xvals, t);
                    elseif (stat_to_use == PTSD_Utility.SessionStatsTTest)
                        %Run a t-test of transit times of sound trials vs
                        %non-sound trials
                        t1 = obj.RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'AllSounds', 'Mean', 0);
                        [t2, fic, lic] = obj.RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'AllTrialsExceptSounds', 'Mean', 0, ...
                            'TrialExclusionMethod', exclusion_method, 'TrialExclusionTiming', exclusion_timing, 'StartExclusion', start_exclusion, 'EndExclusion', end_exclusion);
                        [stat, p] = ttest2(t1, t2);
                    elseif (stat_to_use == PTSD_Utility.SessionStatsTTestPreceding)
                        %Run a t-test of transit times of sound trials vs
                        %trials immediately preceding sound trials
                        t1 = obj.RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'AllSounds', 'Mean', 0);
                        t2 = obj.RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'TrialsDirectlyPrecedingSounds', 'Mean', 0);
                        [stat, p] = ttest2(t1, t2);
                    elseif (stat_to_use == PTSD_Utility.SessionStatsTTestEarly)
                        t1 = obj.RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'AllSoundsPlus', 'Mean', 0);
                        t2 = obj.RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'EarlyTrials', 'Mean', 0);
                        
                        %We cannot use a paired t-test.  Paired t-test
                        %groups must be of equal size.  Despite this data
                        %being from the same subject at different
                        %timepoints, we will use an unpaired t-test.
                        stat = NaN;
                        p = NaN;
                        if (~isempty(t1) && ~isempty(t2))
                            if (length(t1) >= 2 && length(t2) >= 2)
                                [stat, p] = ttest2(t1, t2, 'tail', 'right');
                            end
                        end
                    end
                end
            
        end
        
    end
    
end















