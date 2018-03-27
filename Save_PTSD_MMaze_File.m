function Save_PTSD_MMaze_File ( fully_qualified_path, session )

%Open file for writing
fid = fopen(fully_qualified_path, 'w+');

%Write everything
if (fid ~= -1)
    
    fprintf(fid, 'BEGIN HEADER\n');
    fprintf(fid, 'TIMESTAMP\n');
    
    win_str = ConvertMatlabDatenumToWindowsTime(session.StartTime);
    fprintf(fid, '%s\n', win_str);
    
    fprintf(fid, 'ANIMAL NAME\n');
    fprintf(fid, '%s\n', session.RatName);
    
    fprintf(fid, 'END HEADER\n');
    fprintf(fid, 'BEGIN DATA\n');
    fprintf(fid, 'TIMESTAMP\tEVENT_LABEL\n');
    
    for i = 1:length(session.EventType)
        if (session.EventType(i) > 0 && session.EventType(i) <= length(PTSD_EventType.event_input_strings))
            evt_string = PTSD_EventType.event_input_strings{session.EventType(i)};
        else
            evt_string = '';
        end
        evt_time_string = ConvertMatlabDatenumToWindowsTime(session.EventTime(i));
        fprintf(fid, '%s\t%s\n', evt_time_string, evt_string);
    end
    
    fprintf(fid, 'END DATA\n');
    fprintf(fid, 'BEGIN HEADER\n');
    fprintf(fid, 'TIMESTAMP\n');
    
    win_str_2 = ConvertMatlabDatenumToWindowsTime(session.EndTime);
    fprintf(fid, '%s\n', win_str_2);
    
    fprintf(fid, 'END HEADER\n');
    
    fclose(fid);
    
end

end

