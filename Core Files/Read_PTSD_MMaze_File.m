function data = Read_PTSD_MMaze_File ( path, file, varargin )

%IMPORTANT: This function depends on the PTSD_EventType class.  If this
%class is not in your path, this function will NOT work.

k = strfind(file, 'transitTimes');
j = strfind(file, 'VideoTimestamps');
if (~isempty(k) || ~isempty(j))
    data = [];
    return;
end


p = inputParser;
defaultSave = 1;
defaultLoad = 1;
defaultForceSave = 0;
addOptional(p, 'SaveBinaryCopiesAsNecessary', defaultSave, @isnumeric);
addOptional(p, 'LoadBinaryCopiesIfAvailable', defaultLoad, @isnumeric);
addOptional(p, 'ForceSave', defaultForceSave, @isnumeric);
parse(p, varargin{:});
save_copy = p.Results.SaveBinaryCopiesAsNecessary;
load_copy = p.Results.LoadBinaryCopiesIfAvailable;
force_save = p.Results.ForceSave;

%This is a special variable to see if the rat comes from "cohort 2".
is_rat_cohort2 = 0;

%Define the structure we will use to hold the data
data = struct('name', '', 'stage', '', 'start_timestamp', 0, 'end_timestamp', 0, 'event_timestamp', [], 'event_type', [], 'return_code', 0);

%Check to see if a binary file already exists
does_binary_exist = CheckIfBinaryFileExists(path, file);

if (does_binary_exist && load_copy)
    %Load data from the binary file for speed.
    data = LoadMMazeDataFromBinaryFile(path, file, 'ConvertFileName', 1);
else
    %Open the data file
    filename = [path file];
    fid = fopen(filename, 'r');
    currently_in_data_section = 0;
    timestamp_id = 0;

    %Read the first line from the file
    file_line = fgetl(fid);

    %Loop through the file
    while ischar(file_line)                                                 

        if (~currently_in_data_section)
            %Check to see if the current line is the tag for the animal's name
            if(strcmp(file_line, 'ANIMAL NAME'))
                %If it was get the next line which contains the animals name
                data.name = fgetl(fid);
                
                %Check to see if this is a cohort 2 rat
                is_rat_cohort2 = ~isempty(strfind(data.name, 'C2'));
                
            elseif(strcmp(file_line, 'TIMESTAMP'))
                %If this line is a timestamp label
                %Grab the next line which contains the timestamp
                session_time = fgetl(fid);

                matlab_datenum = ConvertWindowsTimeToMatlabDatenum(session_time);

                if (timestamp_id == 0)
                    %If this is the "start of session" timestamp
                    data.start_timestamp = matlab_datenum;
                    timestamp_id = 1;
                else
                    %If this is the "end of session" timestamp
                    data.end_timestamp = matlab_datenum;

                    %At this point, set the return code to 0, indicating that
                    %all data was successfully read from the file.
                    data.return_code = 0;
                end
            elseif(strcmp(file_line, 'STAGE'))
                %If this line contains the "stage" label
                %Grab the current stage from the file
                data.stage = fgetl(fid);
            elseif(strcmp(file_line,'BEGIN DATA'))
                %If this line indicates the beginning of the "data" section
                currently_in_data_section = 1;
            end
        else
            %If we are inside of the "data" section
            if (strcmp(file_line, 'END DATA'))
                %If this line indicates the end of the "data" section
                %Set the data flag to be false
                currently_in_data_section = 0;
            elseif (~isempty(strfind(file_line, 'TIMESTAMP')))
                %The first line of the data section is simply a header line

                %In this case, simply do nothing.  We will fall out of the
                %if-statement and grab the next line, which should be real
                %data.
            else
                %If none of the above cases were satisfied, then this must be a
                %true data line.

                %Data is in the form of: TIMESTAMP EVENT_TYPE
                %TIMESTAMP and EVENT_TYPE are separated by white space, usually
                %a tab character (\t).

                %We will parse out the event time and the event type by simply
                %asking for the first two "tokens" in the string.
                event_data = strsplit(file_line);
                
                %Convert the event time string to a Matlab datenum
                event_time = event_data{1};
                matlab_datenum = ConvertWindowsTimeToMatlabDatenum(event_time);
                data.event_timestamp(end+1) = matlab_datenum;
                
                %Figure out what type of event we are looking at
                try
                    event_type = event_data{2};
                    index = find(strcmpi(PTSD_EventType.event_input_strings, event_type));
                    if (isempty(index))
                        index = PTSD_EventType.UNKNOWN_EVENT;
                    end
                catch e
                    index = PTSD_EventType.UNKNOWN_EVENT;
                end
                
                %Convert FEAR/TRAUMA/NAIVE events from "cohort 2" animals
                %to TWITTER/GUN/TONE.  All other animals get converted to
                %GUN/TWITTER/TONE.
                if (is_rat_cohort2)
                    switch (index)
                        case PTSD_EventType.FEAR
                            index = PTSD_EventType.TWITTER;
                        case PTSD_EventType.TRAUMA
                            index = PTSD_EventType.MACHINE_GUN;
                        case PTSD_EventType.NAIVE
                            index = PTSD_EventType.NINE_KHZ;
                    end
                else
                    switch (index)
                        case PTSD_EventType.FEAR
                            index = PTSD_EventType.MACHINE_GUN;
                        case PTSD_EventType.TRAUMA
                            index = PTSD_EventType.TWITTER;
                        case PTSD_EventType.NAIVE
                            index = PTSD_EventType.NINE_KHZ;
                    end
                end
                
                %Save the event to the list of events.
                data.event_type(end+1) = index;
            end
        end

        file_line = fgetl(fid);
    end

    %Save data to a binary-formatted file for faster loading in the future.
    if (force_save || (~does_binary_exist && save_copy))
        SaveMMazeDataToBinaryFile(path, file, data);
    end
    
    %close the file
    fclose(fid);
    
end





end

