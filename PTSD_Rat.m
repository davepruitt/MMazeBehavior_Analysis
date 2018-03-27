classdef PTSD_Rat
    %PTSD_Rat - defines a single rat's data, can contain multiple sessions.
    
    properties
        
        RatName
        Group
        Sessions
        
    end
    
    methods
        
        function obj = PTSD_Rat (ratname, group, sessions, varargin)
            %This function constructs a new PTSD_Rat object.
            
            obj.RatName = ratname;
            obj.Group = group;
            obj.Sessions = sessions;
            
            obj = obj.SortSessions();
            
        end
        
        function obj = SelectSessionsToAdd ( obj )
            %This function allows the user to select sessions in a file
            %selection window.  These sessions will then be added to the
            %rat.
            
            %Allow the user to select files.
            [file path] = uigetfile('*.PTSD', 'MultiSelect', 'on');
            
            if (iscell(file))
                %If multiple sessions were selected by the user
                sessions = [];
                for i=1:length(file)
                    file_name = file{i};
                    full_path = [path file_name];
                    new_session = PTSD_Session(path, file_name);
                    sessions = [sessions new_session];
                end
                
                obj = obj.AddSessions(sessions);
                
            else
                if (~isempty(file))
                    %If only one session was selected by the user
                    new_session = PTSD_Session(path, file);
                    obj = obj.AddSessions(new_session);
                end
            end
            
            
        end
        
        function obj = AddSessions ( obj, sessions )
            %This function adds new sessions to the current set of
            %sessions.  The sessions are sorted after they are inserted.
            
            %Add the new sessions to the array of sessions.
            obj.Sessions = [obj.Sessions sessions];
            
            %Sort the sessions.
            obj = obj.SortSessions();
            
        end
        
        function obj = SortSessions ( obj )
            %This function sorts all sessions by date.
            
            %Sort the array to make sure all sessions are in order.
            [~, idx] = sort([obj.Sessions.StartTime]);
            obj.Sessions = obj.Sessions(idx);
            
            %Remove duplicate sessions (if any).
            [~, idx] = unique([obj.Sessions.StartTime]);
            obj.Sessions = obj.Sessions(idx);
            
        end
        
        function sheet = ReadRatGoogleSpreadsheet ( obj )
            %Reads in this rat's spreadsheet from Google.
            index = find(strcmpi(PTSD_Utility.RatNameIndex, obj.RatName), 1, 'first');
            if (~isempty(index))
                url = PTSD_Utility.GoogleSheetsIndex{index};
                sheet = Read_Google_Spreadsheet(url);
            else
                disp(['No Google spreadsheet URL is on file for ' obj.RatName '. Please give a URL if you would like to verify session dates and generate annotations.']);
                sheet = [];
            end
        end
        
        function obj = VerifyDatesOfSessions ( obj, varargin )
            %This function verifies dates of all sessions based off of the
            %Google spreadsheet for this rat.
            
            p = inputParser;
            defaultReportResults = 1;
            defaultCreateDummySessions = 1;
            addOptional(p, 'ReportResultsInText', defaultReportResults);
            addOptional(p, 'CreateDummySessions', defaultCreateDummySessions);
            parse(p, varargin{:});
            report_results = p.Results.ReportResultsInText;
            add_dummy_sessions = p.Results.CreateDummySessions;
            
            %First, read in this rat's google spreadsheet.
            sheet = obj.ReadRatGoogleSpreadsheet();
            
            if (iscell(sheet) && ~isempty(sheet))
                %Verify that the sheet comes from the expected rat.
                observed_rat_name = sheet{1, 1};
                
                if (strcmpi(observed_rat_name, obj.RatName) == 1)
                    %If we have the right spreadsheet...
                    
                    %We will first look for expected dates of sessions.
                    %The first row of a spreadsheet is always the rat name.
                    %The second row of a spreadsheet is always a header
                    %row.
                    %Therefore, the 3rd row and below have actual data.
                    try
                       %Grab all dates from the spreadsheet
                       dates = {sheet{3:end, 1}};
                       
                       %Convert each date to a matlab datenum
                       date_numbers = [];
                       for i=1:length(dates)
                           new_date_num = datenum(dates{i});
                           if (isempty(new_date_num))
                               new_date_num = NaN;
                           end
                           
                           date_numbers(i) = new_date_num;
                       end
                       
                       %Now we must look for NaN dates. If a date is
                       %NaN, we will attempt to resolve the issue by
                       %simply using the date from the previous session.
                       %This assumes that if multiple sessions happened in
                       %a day, it is possible that the date was only
                       %entered for the first session of that day.
                       for i=1:length(date_numbers)
                           if (isnan(date_numbers(i)))
                               %Take the date of the previous session.
                               date_numbers(i) = date_numbers(i-1);
                               
                               %This code WILL throw an error if i == 1.
                               %This means that the user MUST provide a
                               %date for the first session in the
                               %spreadsheet. The error, however, will be
                               %caught, and an appropriate message will be
                               %displayed to the user.
                           end
                       end
                       
                       %Additionally, it is possible that the user of the
                       %spreadsheet may have entered dates for future
                       %sessions, and those rows have not yet been filled
                       %in.  Let's remove all future dates so we don't have
                       %to deal with them.
                       today_datenum = now;
                       for i=length(date_numbers):-1:1
                           if (today_datenum < date_numbers(i))
                               %Remove offending date numbers.
                               date_numbers(i) = [];
                           end
                       end
                        
                       %Now, let's grab the datenumbers for all of the
                       %loaded sessions.  We already have these, but let's
                       %put them in a form that is only the date (without
                       %the time).
                       session_datenums = [];
                       for s=1:length(obj.Sessions)
                           s_datevec = datevec(obj.Sessions(s).StartTime);
                           s_datevec(4:6) = 0;
                           s_datenum = datenum(s_datevec);
                           session_datenums = [session_datenums s_datenum];
                       end
                       
                       %Match up sessions
                       matched_sessions = MatchArrays(date_numbers, session_datenums);
                       
                       %Report missing sessions
                       indices_of_missing_sessions = find(isnan(matched_sessions(:, 2)));
                       non_unique_missing_datenums = matched_sessions(indices_of_missing_sessions, 1);
                       missing_datenums = unique(non_unique_missing_datenums);
                       
                       %Now, let's do a set difference to make sure all
                       %expected dates are present.
                       %missing_datenums = setdiff(date_numbers, session_datenums);
                       
                       %If the user wants to report results in text
                       if (report_results)
                           if (~isempty(missing_datenums))
                               disp(['Missing sessions for ' obj.RatName ' were observed for the following dates:']);
                               for i=1:length(missing_datenums)
                                   disp(datestr(missing_datenums(i)));
                               end
                           else
                               disp('No missing dates were found.');
                           end
                       end
                       
                       %Report extra sessions
                       indices_of_extra_sessions = find(isnan(matched_sessions(:, 1)));
                       extra_datenums = matched_sessions(indices_of_extra_sessions, 2);
                       extra_datenums = unique(extra_datenums);
                       
                       %And let's find sessions we have that may not occur
                       %on the spreadsheet.
                       %extra_datenums = setdiff(session_datenums, date_numbers);
                       
                      if (report_results)
                           if (~isempty(extra_datenums))
                               disp(['The following extra dates were found for ' obj.RatName ':']);
                               for i=1:length(extra_datenums)
                                   disp(datestr(extra_datenums(i)));
                               end
                           else
                               disp('No extra dates were found.');
                           end
                       end
                       
                       %Next, we want to verify that for all the dates that
                       %DO line up, we have the correct number of sessions
                       %for that date.
                       if (add_dummy_sessions)
                           new_sessions = [];
                           for i=1:length(non_unique_missing_datenums)
                               new_dummy_session = PTSD_Session([], 'DateNum', non_unique_missing_datenums(i), ...
                                   'RatName', obj.RatName);
                               new_sessions = [new_sessions new_dummy_session];
                           end
                           obj = obj.AddSessions(new_sessions);
                       end
                       
                    catch e
                        disp(['An error has occurred while attempting to verify session dates for ' obj.RatName '. Please verify the Google spreadsheet is correctly formatted.']);
                    end
                else
                    disp(['The rat found in the Google spreadsheet does not match the expected rat ' obj.RatName '. Please verify that the URL is correct.']);
                end
            else
                disp(['The Google spreadsheet for ' obj.RatName ' could not be loaded. Please verify that the URL is correct.']);
            end
        end
        
        function indices = GetIndicesOfTrainingSessions ( obj )
            indices = [];
            first_sound_session = find([obj.Sessions.IsSessionSound], 1, 'first');
            if (~isempty(first_sound_session))
                first_silent_training_session = first_sound_session - 1;
                if (first_silent_training_session > 0)
                    indices = first_silent_training_session:length(obj.Sessions);
                end
            end
        end
        
        function [times, session_indices, pre_times, pre_indices] = RetrieveData ( obj, varargin )
            
            pre_times = [];
            pre_indices = [];
            
            p = inputParser;
            
            defaultTransitType = 'FirstProxEnterToSecondProxEnterTransitTime';
            defaultMode = 'FirstSound';
            defaultSoundType = PTSD_EventType.UNKNOWN_EVENT;
            defaultSpecialTreatment = 0;
            defaultReplacementValue = NaN;
            defaultCalculateRatios = 0;
            defaultIncludeShapingData = 0;
            defaultNumDaysPre = 0;
            defaultGrabSegments = 0;
            defaultSegmentLength = 30;
            defaultSegmentType = '';
            defaultSuppressionRate = 0;
            
            addOptional(p, 'TransitType', defaultTransitType);
            addOptional(p, 'Mode', defaultMode);
            addOptional(p, 'Sound', defaultSoundType, @isnumeric);
            addOptional(p, 'SpecialTreatmentForNegatives', defaultSpecialTreatment, @isnumeric);
            addOptional(p, 'ReplacementValueForNegatives', defaultReplacementValue);
            addOptional(p, 'CalculateRatios', defaultCalculateRatios);
            addOptional(p, 'IncludeShapingData', defaultIncludeShapingData);
            addOptional(p, 'NumDaysPre', defaultNumDaysPre);
            addOptional(p, 'GrabSegments', defaultGrabSegments);
            addOptional(p, 'SegmentLength', defaultSegmentLength);
            addOptional(p, 'SegmentType', defaultSegmentType);
            addOptional(p, 'SuppressionRate', defaultSuppressionRate);
            parse(p, varargin{:});
            
            %Modes: FirstSound, AllSounds, AllTrials, LastSound
            mode = p.Results.Mode;
            transit_type = p.Results.TransitType;
            sound_to_use = p.Results.Sound;
            special_treatment = p.Results.SpecialTreatmentForNegatives;
            replacement_value = p.Results.ReplacementValueForNegatives;
            calculate_ratios = p.Results.CalculateRatios;
            include_shaping_data = p.Results.IncludeShapingData;
            num_days_pre = p.Results.NumDaysPre;
            is_grab_segments = p.Results.GrabSegments;
            segment_length = p.Results.SegmentLength;
            segment_type = p.Results.SegmentType;
            get_suppression_rate = p.Results.SuppressionRate;
            
            %Make sure that the mode works with the sessions being asked
            %for.
            valid_sound = PTSD_EventType.IsSoundEvent(sound_to_use);
            if (strcmpi(mode, 'FirstSoundMinusLastSound') && ~valid_sound)
                mode = 'AllTrials';
            end
            
            %Create a "silent sessions" array which will be used if we need
            %to calculate ratios
            silent_sessions = [];
            silent_sessions_to_grab = [];
            sessions = [];
            session_indices = [];
            pre_indices = [];
            
            %Identify which sessions we will analyze
            if (sound_to_use == PTSD_EventType.UNKNOWN_EVENT)
                %In this case, the user has requested to analyze all
                %sessions.
                if (include_shaping_data)
                    %If the user wants to include shaping data, then go
                    %ahead and return EVERY session
                    sessions = obj.Sessions;
                    session_indices = 1:length(obj.Sessions);
                else
                    %Otherwise, only return "training" sessions.
                    first_sound_session = find([obj.Sessions.IsSessionSound], 1, 'first');
                    if (~isempty(first_sound_session))
                        first_silent_training_session = first_sound_session - 1;
                        if (first_silent_training_session > 0)
                            %Get all sessions starting at the first silent
                            %training session (so this does not include
                            %silent SHAPING sessions).
                            sessions = obj.Sessions(first_silent_training_session:end);
                            session_indices = first_silent_training_session:length(obj.Sessions);
                        end
                    end
                end
            elseif (sound_to_use == PTSD_EventType.SILENT_SESSION)
                %In this case, the user has requested to analyze only
                %silent sessions.
                if (include_shaping_data)
                    %If the user wants to include shaping data, then grab
                    %every single silent session.
                    session_indices = find(~[obj.Sessions.IsSessionSound]);
                    sessions = obj.Sessions(session_indices);
                    
                else
                    %Otherwise, the user only wants training sessions, and
                    %not shaping sessions.  Here we will get all silent
                    %sessions that are training sessions.
                    first_sound_session = find([obj.Sessions.IsSessionSound], 1, 'first');
                    if (~isempty(first_sound_session))
                        first_silent_training_session = first_sound_session - 1;
                        if (first_silent_training_session > 0)
                            %Get all sessions starting at the first silent
                            %training session (so this does not include
                            %silent SHAPING sessions).
                            all_training_sessions = first_silent_training_session:length(obj.Sessions);
                            
                            %Now isolate out only silent sessions among all
                            %of the training sessions.
                            silent_session_indices = find(~[obj.Sessions.IsSessionSound]);
                            
                            %The intersection of these two vectors is the
                            %list of sessions that we want.
                            session_indices = intersect(all_training_sessions, silent_session_indices);
                            
                            sessions = obj.Sessions(session_indices);
                        end
                    end
                end
                
                %Force the "all trials" mode for silent sessions.
                mode = 'AllTrials';
            elseif (sound_to_use == PTSD_EventType.ANY_SOUND)
                %If the user is requesting sessions from this rat that
                %include ANY TYPE of sound, and not a specific kind of
                %sound.
                
                %First, find the sessions that contain a sound.
                indices_of_sound_sessions = find([obj.Sessions.IsSessionSound]);
                
                %Now we need to find the "silent" sessions that immediately
                %precede these "sound" sessions.  We are doing this in the
                %scenario that the user wants to analyze the ratio of
                %transit times between the sound sessions and the silent
                %sessions.
                indices_of_silent_sessions = [];
                for i=1:length(indices_of_sound_sessions)
                    index_of_current_sound_session = indices_of_sound_sessions(i);
                    preceding_sessions_is_sound = [obj.Sessions(1:index_of_current_sound_session).IsSessionSound];
                    index_of_immediately_preceding_silent_session = find(~preceding_sessions_is_sound, 1, 'last');
                    indices_of_silent_sessions = [indices_of_silent_sessions index_of_immediately_preceding_silent_session];
                end
                
                %Grab the silent sessions
                silent_sessions = obj.Sessions(indices_of_silent_sessions);
                
                %Grab the sound sessions
                session_indices = indices_of_sound_sessions;
                sessions = obj.Sessions(session_indices);
                
            elseif (sound_to_use == PTSD_EventType.PRE_POST)
                
                %In this case, the user is requesting session from this rat
                %that span the pre-AFC/post-AFC timeline.  We will grab a
                %number of pre-AFC sessions, and then all post-AFC
                %sessions.
                
                %First, find the sessions that contain a sound.
                indices_of_sound_sessions = find([obj.Sessions.IsSessionSound]);
                
                %Now we need to find the "silent" sessions that immediately
                %precede each of these "sound" sessions.  We are doing this in the
                %scenario that the user wants to analyze the ratio of
                %transit times between the sound sessions and the silent
                %sessions.
                indices_of_silent_sessions = [];
                for i=1:length(indices_of_sound_sessions)
                    index_of_current_sound_session = indices_of_sound_sessions(i);
                    preceding_sessions_is_sound = [obj.Sessions(1:index_of_current_sound_session).IsSessionSound];
                    index_of_immediately_preceding_silent_session = find(~preceding_sessions_is_sound, 1, 'last');
                    indices_of_silent_sessions = [indices_of_silent_sessions index_of_immediately_preceding_silent_session];
                end
                
                %Grab the silent sessions
                silent_sessions = obj.Sessions(indices_of_silent_sessions);
                
                %Grab the sound sessions
                session_indices = indices_of_sound_sessions;
                sessions = obj.Sessions(session_indices);
                
                if (isempty(indices_of_sound_sessions))
                    %In the case that no sound sessions are found, let's
                    %just grab silent sessions from the most recent one
                    if (num_days_pre > 0)
                        most_recent_pre_session = length(obj.Sessions);
                        start_index = most_recent_pre_session - num_days_pre + 1;
                        silent_indices = start_index:most_recent_pre_session;
                        
                        %Eliminate negative indices
                        silent_indices = silent_indices(silent_indices > 0);
                        
                        silent_sessions_to_grab = obj.Sessions(silent_indices);
                        pre_indices = silent_indices;
                        
                    end
                else
                    %Now grab the pre-AFC sessions
                    if (~isempty(indices_of_silent_sessions) && num_days_pre > 0)
                        most_recent_pre_session = indices_of_silent_sessions(1);

                        start_index = most_recent_pre_session - num_days_pre + 1;
                        silent_indices = start_index:most_recent_pre_session;

                        %Eliminate negative indices
                        silent_indices = silent_indices(silent_indices > 0);
                        
                        %Make sure that the indices of the sessions we are
                            %about to get are all in bounds.
                        if (all(silent_indices > 0))
                            %Now grab the sessions.
                            silent_sessions_to_grab = obj.Sessions(silent_indices);
                            pre_indices = silent_indices;
                        end
                    end    
                end
                
                
                
            else
                %If the user is requesting sessions from this rat that
                %include sounds
                
                %First, find the sessions that are the same sound that the
                %user has requested.
                indices_of_sound_sessions = find([obj.Sessions.SessionSoundType] == sound_to_use);
                
                %Now we need to find the "silent" sessions that immediately
                %precede these "sound" sessions.  We are doing this in the
                %scenario that the user wants to analyze the ratio of
                %transit times between the sound sessions and the silent
                %sessions.
                indices_of_silent_sessions = [];
                for i=1:length(indices_of_sound_sessions)
                    index_of_current_sound_session = indices_of_sound_sessions(i);
                    preceding_sessions_is_sound = [obj.Sessions(1:index_of_current_sound_session).IsSessionSound];
                    index_of_immediately_preceding_silent_session = find(~preceding_sessions_is_sound, 1, 'last');
                    indices_of_silent_sessions = [indices_of_silent_sessions index_of_immediately_preceding_silent_session];
                end
                
                %Grab the silent sessions
                silent_sessions = obj.Sessions(indices_of_silent_sessions);
                
                %Grab the sound sessions
                session_indices = indices_of_sound_sessions;
                sessions = obj.Sessions([obj.Sessions.SessionSoundType] == sound_to_use);
            end
            
            %Grab mean transit times from the selected sessions.
            times = [];
            for s = 1:length(sessions)
                
                %If this session is a silent session, then use the
                %AllTrials mode to retrieve transit times
                mode_this_session = mode;
                if (~sessions(s).IsSessionSound)
                    mode_this_session = 'AllTrials';
                end
                
                if (is_grab_segments)
                    %If the user wants to grab segments rather than transit
                    %times...
                    
                    %Calculate segment difference and return them for this
                    %session.
                    if (get_suppression_rate)
                        segment_differences = sessions(s).RetrieveSuppressionRate('SegmentLength', segment_length, 'Mode', mode);
                    else
                        segment_differences = sessions(s).RetrieveSegmentDifferences('SegmentLength', segment_length);
                    end
                    
                    
                    %Get the correct segment type.  The segment_type
                    %variable should be a string that matches a property
                    %name on the PTSD_SessionSegment class.
                    this_session_data = [segment_differences.(segment_type)];
                    
                    %Make sure the session data is of the appropriate
                    %length.  Nan-pad if needed.
                    if (strcmpi(mode, 'AllSoundsNoAveraging'))
                        if (length(this_session_data) < 5)
                            temp_session_data = nan(1, 5);
                            temp_session_data(1:length(this_session_data)) = this_session_data;
                            this_session_data = temp_session_data;
                        elseif (length(this_session_data) > 5)
                            this_session_data = this_session_data(1:5);
                        end
                    end
                    
                    first_time = this_session_data;
                else
                    %Otherwise, if the user wants to grab typical transit
                    %times...
                    
                    %If the mode is FirstSoundMinusLastSound
                    if (strcmpi(mode, 'FirstSoundMinusLastSound') && valid_sound)
                        if (s > 1)
                            t1 = sessions(s).RetrieveTransitTimes('TransitType', transit_type, 'Mean', 1, ...
                            'Mode', 'FirstSound');
                            t2 = sessions(s-1).RetrieveTransitTimes('TransitType', transit_type, 'Mean', 1, ...
                            'Mode', 'LastSound');
                            t = t1 - t2;
                        else
                            t = NaN;
                        end
                    else
                        
                        if (strcmpi(transit_type, 'TOTAL_FEEDS'))
                            t = sessions(s).TotalFeeds;
                        elseif (strcmpi(transit_type, 'TOTAL_NOSEPOKES'))
                            t = nnz(PTSD_EventType.IsNosepokeEnterEvent(sessions(s).EventType));
                        elseif (strcmpi(transit_type, 'LEFT_NOSEPOKES'))
                            t = nnz(sessions(s).EventType == PTSD_EventType.LEFT_NOSEPOKE_ENTER);
                        elseif (strcmpi(transit_type, 'RIGHT_NOSEPOKES'))
                            t = nnz(sessions(s).EventType == PTSD_EventType.RIGHT_NOSEPOKE_ENTER);
                        elseif (strcmpi(transit_type, 'LEFT_FEEDS'))
                            t = nnz(sessions(s).EventType == PTSD_EventType.LEFT_FEEDER_TRIGGERED);
                        elseif (strcmpi(transit_type, 'RIGHT_FEEDS'))
                            t = nnz(sessions(s).EventType == PTSD_EventType.RIGHT_FEEDER_TRIGGERED);
                        else
                            %Retrieve the mean and/or individual transit time for the session
                            t = sessions(s).RetrieveTransitTimes('TransitType', transit_type, 'Mean', 1, ...
                                'Mode', mode_this_session);    
                        end
                        
                        %Check to see if the user wants to calculate the ratio
                        %of this session compared to a preceding silent session
                        if (calculate_ratios)
                            %Check to see we have a corresponding silent
                            %session
                            if (length(silent_sessions) >= s)
                                %The mode is automatically "AllTrials" for this
                                %because we know it is a silent session.
                                t2 = silent_sessions(s).RetrieveTransitTimes('TransitType', transit_type, 'Mean', 1, ...
                                    'Mode', 'AllTrials');

                                %Calculate the ratio itself
                                t = t(1) / t2(1);
                            end
                        end
                    end

                    %Check to see if special treatment is needed
                    first_time = t(1);
                    if (special_treatment)
                        if (isscalar(first_time) && first_time < 0)
                            first_time = replacement_value;
                        end
                    end
                    
                end
                
                %Add the transit time to the list of transit times.
                times = [times first_time];
            end
            
            if (sound_to_use == PTSD_EventType.PRE_POST)
                %If this is a pre-post grab, let's grab the pre sessions
                %separately
                pre_times = [];
                
                if (is_grab_segments)
                    %If the user wants to grab segments rather than transit
                    %times...
                    
                    for s = 1:length(silent_sessions_to_grab)
                        %Calculate segment difference and return them for this
                        %session.
                        if (get_suppression_rate)
                            segment_differences = silent_sessions_to_grab(s).RetrieveSuppressionRate('SegmentLength', segment_length);
                        else
                            segment_differences = silent_sessions_to_grab(s).RetrieveSegmentDifferences('SegmentLength', segment_length);
                        end
                        

                        %Get the correct segment type.  The segment_type
                        %variable should be a string that matches a property
                        %name on the PTSD_SessionSegment class.
                        this_session_data = [segment_differences.(segment_type)];

                        %Make sure the session data is of the appropriate
                        %length.  Nan-pad if needed.
                        if (strcmpi(mode, 'AllSoundsNoAveraging'))
                            if (length(this_session_data) < 5)
                                temp_session_data = nan(1, 5);
                                temp_session_data(1:length(this_session_data)) = this_session_data;
                                this_session_data = temp_session_data;
                            elseif (length(this_session_data) > 5)
                                this_session_data = this_session_data(1:5);
                            end
                        end

                        pre_times = [pre_times this_session_data];
                    end
                    
                    %nan-pad, right-justify
                    if (~get_suppression_rate || (get_suppression_rate && strcmpi(mode, 'AllSoundsNoAveraging')))
                    
                        num_days_found = length(pre_times) / 5;
                        if (num_days_found < num_days_pre)
                            num_days_to_add = length(pre_times) - num_days_pre;
                            new_pre_times = nan(1, num_days_pre * 5);
                            starting_index = (num_days_to_add * 5) + 1;
                            new_pre_times(starting_index:end) = pre_times;
                            pre_times = new_pre_times;
                        end
                    else
                        
                        if (length(pre_times) < num_days_pre)
                            num_days_to_add = length(pre_times) - num_days_pre;
                            new_pre_times = nan(1, num_days_pre);
                            starting_index = num_days_to_add + 1;
                            new_pre_times(starting_index:end) = pre_times;
                            pre_times = new_pre_times;
                        end
                        
                    end
                    
                    
                    %This code is so disgusting... :'(
                    
                else
                    for s = 1:length(silent_sessions_to_grab)
                        %For these sessions, the mode can only be one thing...
                        mode_this_session = 'AllTrials';

                        if (strcmpi(transit_type, 'TOTAL_FEEDS'))
                            t = silent_sessions_to_grab(s).TotalFeeds;
                        elseif (strcmpi(transit_type, 'TOTAL_NOSEPOKES'))
                            t = nnz(PTSD_EventType.IsNosepokeEnterEvent(silent_sessions_to_grab(s).EventType));
                        elseif (strcmpi(transit_type, 'LEFT_NOSEPOKES'))
                            t = nnz(silent_sessions_to_grab(s).EventType == PTSD_EventType.LEFT_NOSEPOKE_ENTER);
                        elseif (strcmpi(transit_type, 'RIGHT_NOSEPOKES'))
                            t = nnz(silent_sessions_to_grab(s).EventType == PTSD_EventType.RIGHT_NOSEPOKE_ENTER);
                        elseif (strcmpi(transit_type, 'LEFT_FEEDS'))
                            t = nnz(silent_sessions_to_grab(s).EventType == PTSD_EventType.LEFT_FEEDER_TRIGGERED);
                        elseif (strcmpi(transit_type, 'RIGHT_FEEDS'))
                            t = nnz(silent_sessions_to_grab(s).EventType == PTSD_EventType.RIGHT_FEEDER_TRIGGERED);
                        else
                            %Retrieve the mean and/or individual transit time for the session
                            t = silent_sessions_to_grab(s).RetrieveTransitTimes('TransitType', transit_type, 'Mean', 1, ...
                                'Mode', mode_this_session);    
                        end
                        
                        %t(1) is the mean, t(2) is the std err
                        pre_times = [pre_times t(1)];
                    end
                
                    %Make sure to nan-pad right-justify these times
                    if (length(pre_times) < num_days_pre)
                        num_days_to_add = length(pre_times) - num_days_pre;
                        new_pre_times = nan(1, num_days_pre);
                        starting_index = num_days_to_add + 1;
                        new_pre_times(starting_index:end) = pre_times;
                        pre_times = new_pre_times;
                    end
                end
                
                
            end
            
        end
        
        function PlotRat ( obj, varargin )
            
            p = inputParser;
            defaultTransitType = 'FirstProxEnterToSecondProxEnterTransitTime';
            defaultMode = 'FirstSound';
            defaultSoundType = PTSD_EventType.UNKNOWN_EVENT;
            defaultGraphType = PTSD_Utility.RatGraphTypeSingleLine;
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
            
            %Look at the graph type the user wants
            if (graph_type == PTSD_Utility.RatGraphTypeSingleLine)
                %Get transit times of the individual sound the user wants
                [times, session_indices] = obj.RetrieveData('TransitType', transit_type, ...
                    'Mode', mode, ...
                    'Sound', sound_to_use, ...
                    'IncludeShapingData', include_shaping_data, ...
                    'SpecialTreatmentForNegatives', 1, ...
                    'ReplacementValueForNegatives', NaN);
                
                %Plot the data
                plot(times);
                
                %Change the x-axis tick labels to correspond to the session
                %indices
                x_ticks = get(gca, 'XTick');
                useable_x_ticks = intersect(x_ticks, 1:length(session_indices));
                x_tick_label_array = session_indices(useable_x_ticks);
                x_tick_labels = {};
                for i = 1:length(x_tick_label_array)
                    x_tick_labels{i} = num2str(x_tick_label_array(i));
                end
                set(gca, 'XTick', useable_x_ticks);
                set(gca, 'XTickLabel', x_tick_labels);
                
                %Plot filled circles over sessions that are sound sessions
                sounds_plotted = [];
                legend_elements = [];
                for i=1:length(times)
                    session_index = session_indices(i);
                    if (obj.Sessions(session_index).IsSessionSound)
                        sound_type = obj.Sessions(session_index).SessionSoundType;
                        color = PTSD_EventType.event_colors(sound_type, :);
                        h = plot(i, times(i), 'o', 'Color', color, 'MarkerFaceColor', color);
                        
                        if (isempty(find(sounds_plotted == sound_type, 1)))
                            legend_elements = [legend_elements; h];
                            sounds_plotted = [sounds_plotted; sound_type];
                        end
                    else
                        plot(i, times(i), 'ok');
                    end
                end
                
                if (~isempty(legend_elements))
                    legend_strings = {};
                    for i = 1:length(sounds_plotted)
                        legend_strings = [legend_strings PTSD_EventType.event_display_strings{sounds_plotted(i)}];
                    end
                    legend(legend_elements, legend_strings);
                end
                
                %Plot filled circles over the sessions that are "sound sessions"
%                 if (sound_to_use == PTSD_EventType.UNKNOWN_EVENT)
%                     if (~include_shaping_data)
%                         training_indices = obj.GetIndicesOfTrainingSessions();
%                     else
%                         training_indices = 1:length(obj.Sessions);
%                     end
%                     
%                     for i=1:length(training_indices)
%                         index = training_indices(i);
%                         
%                         if (obj.Sessions(index).IsSessionSound)
%                             color = PTSD_EventType.event_colors(obj.Sessions(index).SessionSoundType, :);
%                             try
%                                 plot(i, times(i), 'o', 'Color', color, 'MarkerFaceColor', color);
%                             catch
%                                 e
%                             end
%                         else
%                             plot(i, times(i), 'ok');
%                         end
%                     end
%                 end
                
                %Set a y-label
                ylabel('Seconds');
                
            else
                
                if (graph_type == PTSD_Utility.RatGraphTypeMultipleLines)

                    %Get transit times of all sounds
                    gun_time = obj.RetrieveData('TransitType', transit_type, ...
                        'Mode', mode, ...
                        'Sound', PTSD_EventType.MACHINE_GUN);
                    twitter_times = obj.RetrieveData('TransitType', transit_type, ...
                        'Mode', mode, ...
                        'Sound', PTSD_EventType.TWITTER);
                    tone_times = obj.RetrieveData('TransitType', transit_type, ...
                        'Mode', mode, ...
                        'Sound', PTSD_EventType.NINE_KHZ);
                    silent_times = obj.RetrieveData('TransitType', transit_type, ...
                        'Mode', mode, ...
                        'Sound', PTSD_EventType.SILENT_SESSION);
                    
                    plot(gun_time, 'Color', PTSD_EventType.event_colors(PTSD_EventType.MACHINE_GUN, :));
                    plot(twitter_times, 'Color', PTSD_EventType.event_colors(PTSD_EventType.TWITTER, :));
                    plot(tone_times, 'Color', PTSD_EventType.event_colors(PTSD_EventType.NINE_KHZ, :));
                    plot(silent_times, 'Color', [0 0 0]);
                    legend('Machine gun', 'Twitter', '9 khz tone', 'Silent');
                    ylabel('Seconds');
                    
                else
                    
                    %Get transit times of all sounds
                    gun_ratios = obj.RetrieveData('TransitType', transit_type, ...
                        'Mode', mode, ...
                        'Sound', PTSD_EventType.MACHINE_GUN, ...
                        'CalculateRatios', 1);
                    twitter_ratios = obj.RetrieveData('TransitType', transit_type, ...
                        'Mode', mode, ...
                        'Sound', PTSD_EventType.TWITTER, ...
                        'CalculateRatios', 1);
                    tone_ratios = obj.RetrieveData('TransitType', transit_type, ...
                        'Mode', mode, ...
                        'Sound', PTSD_EventType.NINE_KHZ, ...
                        'CalculateRatios', 1);
                    
                    plot(gun_ratios, 'Color', PTSD_EventType.event_colors(PTSD_EventType.MACHINE_GUN, :));
                    plot(twitter_ratios, 'Color', PTSD_EventType.event_colors(PTSD_EventType.TWITTER, :));
                    plot(tone_ratios, 'Color', PTSD_EventType.event_colors(PTSD_EventType.NINE_KHZ, :));
                    
                    %Plot a line at 1 to represent the silent sessions
                    plot(xlim, [1 1], 'Color', [0 0 0]);
                    
                    legend('Machine gun', 'Twitter', '9 khz tone', 'Silent');
                    ylabel('Ratio compared to silence');
                    
                end
                
            end
            
            xlabel('Session');
            ylim([0 max(ylim)]);
            
        end
        
        function [stat, p] = GetRatStats ( obj, varargin )
            
            p = inputParser;
            defaultStat = PTSD_Utility.SessionStatsCorrelation;
            defaultTransitType = 'FirstProxToSecondNosepokeTransitTime';
            defaultSoundType = PTSD_EventType.UNKNOWN_EVENT;
            defaultMode = 'AllTrials';
            defaultCalculateRatios = 0;
            defaultIncludeShapingData = 0;
            addOptional(p, 'Statistic', defaultStat);
            addOptional(p, 'TransitType', defaultTransitType);
            addOptional(p, 'Sound', defaultSoundType, @isnumeric);
            addOptional(p, 'Mode', defaultMode);
            addOptional(p, 'CalculateRatios', defaultCalculateRatios);
            addOptional(p, 'IncludeShapingData', defaultIncludeShapingData);
            parse(p, varargin{:});
            stat_to_use = p.Results.Statistic;
            transit_type = p.Results.TransitType;
            sessions_to_use = p.Results.Sound;
            trials_to_consider = p.Results.Mode;
            calculate_ratios = p.Results.CalculateRatios;
            include_shaping_data = p.Results.IncludeShapingData;
            
            stat = NaN;
            p = NaN;
            
            switch (stat_to_use)
                case PTSD_Utility.RatStatsCorrelation
                    %Find the correlation coefficient of several sessions
                    t = obj.RetrieveData('TransitType', transit_type, 'Sound', sessions_to_use, 'Mode', trials_to_consider, ...
                        'CalculateRatios', calculate_ratios, 'IncludeShapingData', include_shaping_data);
                    xvals = 1:length(t);
                    [stat, p] = corr(xvals', t');
                case PTSD_Utility.RatStatsTTest
                    t1 = obj.RetrieveData('TransitType', transit_type, 'Sound', sessions_to_use, 'Mode', trials_to_consider, ...
                        'CalculateRatios', calculate_ratios, 'IncludeShapingData', include_shaping_data);
                    t2 = obj.RetrieveData('TransitType', transit_type, 'Sound', PTSD_EventType.SILENT_SESSION, 'Mode', 'AllTrials', ...
                        'CalculateRatios', calculate_ratios, 'IncludeShapingData', include_shaping_data);
                    try
                        [stat, p] = ttest2(t1, t2);
                    catch e
                        disp('t-test for this rat failed under the current conditions');
                    end
                case PTSD_Utility.RatStatsTTestPreceding
                    %TO DO: Write this code
                case PTSD_Utility.RatStatsANOVA_All
                    
                    %Get indices of sessions to use in our statistics
                    session_indices = 1:length(obj.Sessions);
                    if (~include_shaping_data)
                        session_indices = obj.GetIndicesOfTrainingSessions();
                    end
                    
                    %Create a structure for our anova data
                    anova_data = struct('session', {}, 'transit_time', {}, 'session_type', {});
                    
                    %Iterate over each session, add the data to our anova
                    %structure
                    for i = session_indices
                        session = obj.Sessions(i);
                        
                        if (session.IsSessionSound)
                            t = session.RetrieveTransitTimes('TransitType', transit_type, 'Mode', trials_to_consider, 'Mean', 0);
                        else
                            t = session.RetrieveTransitTimes('TransitType', transit_type, 'Mode', 'AllTrials', 'Mean', 0);
                        end
                        
                        for j = 1:length(t)
                            if (~isnan(t(j)))
                                anova_data(end+1) = struct('session', i, 'transit_time', t(j), 'session_type', session.SessionSoundType);
                            end
                        end
                    end
                    
                    X = [anova_data.transit_time];
                    group = {[anova_data.session] [anova_data.session_type]};
                    [p, table, stats] = anovan(X, group, 'display', 'off', 'model', 'full', 'varnames', {'Session Number', 'Session Type'});
                    
                case PTSD_Utility.RatStatsANOVA_Sound
            end
            
            
        end
        
    end
    
end

