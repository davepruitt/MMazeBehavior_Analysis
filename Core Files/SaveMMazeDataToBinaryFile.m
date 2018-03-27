function SaveMMazeDataToBinaryFile ( original_path, original_file, data )

%Create a file name for the binary file
file_name_minus_extension = strsplit(original_file, '.');
new_file = [original_path file_name_minus_extension{1} '_binary.PTSDB'];

%Open the new file
fid = fopen(new_file, 'w');

%Write the version number of the file
fwrite(fid, 1, 'int8');

%Write the number of characters in the rat name, followed by the rat name.
fwrite(fid,length(data.name),'uint8'); 
fwrite(fid,data.name,'uchar');

%Write the number of characters in the stage name, followed by the stage.
fwrite(fid, length(data.stage), 'uint8');
fwrite(fid, data.stage, 'uchar');

%Write out the start time of the session
fwrite(fid, data.start_timestamp, 'double');

%Write out the end time of the session
fwrite(fid, data.end_timestamp, 'double');

%Write out the number of events
fwrite(fid, length(data.event_timestamp), 'int32');

%Write out each event
for i=1:length(data.event_timestamp)
    fwrite(fid, data.event_timestamp(i), 'double');
    fwrite(fid, data.event_type(i), 'int32');
end

fclose(fid);

end







