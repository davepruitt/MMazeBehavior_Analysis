function data = LoadMMazeDataFromBinaryFile ( path, file, varargin )

    %Initialize data
    data = [];
    
    %Simple variable to keep track of if this animal is from cohort 2.
    is_rat_cohort2 = 0;
    
    %Parse optional inputs
    p = inputParser;
    defaultConvertFileName = 0;
    addOptional(p, 'ConvertFileName', defaultConvertFileName, @isnumeric);
    parse(p, varargin{:});
    convert_file_name = p.Results.ConvertFileName;

    if (convert_file_name)
        %Create a file name for the binary file
        file_name_minus_extension = strsplit(file, '.');
        new_file = [path file_name_minus_extension{1} '_binary.PTSDB'];
    else
        new_file = [path file];
    end
    
    %Open the file to read
    fid = fopen(new_file, 'r');
    
    %Read the version of the file
    version = fread(fid, 1, 'int8');
    
    %Read how many characters there are in the rat's name, and then the
    %rat's name
    N = fread(fid,1,'uint8');
    data.name = fread(fid,N,'*char')';
    
    %Check to see if this is a cohort 2 rat
    is_rat_cohort2 = ~isempty(strfind(data.name, 'C2'));
    
    %Read how many characters there are in the stage's name, and then read
    %the stage
    N = fread(fid, 1, 'uint8');
    data.stage = fread(fid, N, '*char');
    
    %Read in the start time of the session
    data.start_timestamp = fread(fid, 1, 'double');
    
    %Read in the end time of the session
    data.end_timestamp = fread(fid, 1, 'double');
    
    %Read in the number of events
    num_events = fread(fid, 1, 'int32');
    data.event_timestamp = [];
    data.event_type = [];
    for i=1:num_events
        %Read in the event timestamp and the event type.
        data.event_timestamp(end+1) = fread(fid, 1, 'double');
        etype = fread(fid, 1, 'int32');
            
        %Convert FEAR/TRAUMA/NAIVE events from "cohort 2" animals
        %to TWITTER/GUN/TONE.  All other animals get converted to
        %GUN/TWITTER/TONE.
        if (is_rat_cohort2)
            switch (etype)
                case PTSD_EventType.FEAR
                    etype = PTSD_EventType.TWITTER;
                case PTSD_EventType.TRAUMA
                    etype = PTSD_EventType.MACHINE_GUN;
                case PTSD_EventType.NAIVE
                    etype = PTSD_EventType.NINE_KHZ;
            end
        else
            switch (etype)
                case PTSD_EventType.FEAR
                    etype = PTSD_EventType.MACHINE_GUN;
                case PTSD_EventType.TRAUMA
                    etype = PTSD_EventType.TWITTER;
                case PTSD_EventType.NAIVE
                    etype = PTSD_EventType.NINE_KHZ;
            end
        end
           
        data.event_type(end+1) = etype;
        
    end
    
    data.return_code = 0;
    
    fclose(fid);
    
end






















