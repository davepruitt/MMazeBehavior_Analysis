function does_it_exist = CheckIfBinaryFileExists ( path, file )

    %Create a file name for the binary file
    file_name_minus_extension = strsplit(file, '.');
    new_file = [path file_name_minus_extension{1} '_binary.PTSDB'];

    does_it_exist = (exist(new_file, 'file') == 2);
    
end

