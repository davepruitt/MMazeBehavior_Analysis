function PTSDChangeDate ( )

disp('Please select a PTSD M-Maze file to change the date of that file.');
[load_file load_path] = uigetfile('*.PTSD');
disp('Now, please choose a file name for the new file that will be saved.');
[save_file save_path] = uiputfile('*.PTSD');

old_data = Read_PTSD_MMaze_File(load_path, load_file, 'LoadBinaryCopiesIfAvailable', 0, 'SaveBinaryCopiesAsNecessary', 0);
old_session = PTSD_Session(old_data);

disp('You must now specify the NEW date for this session.');

new_year = input('Please type the new year (ex: 2016): ');
new_month = input('Please type the new month (as a number, example: 4): ');
new_day = input('Please type the day of the month (as a number, typically 1 to 31): ');
new_hour = input('Please type the hour of the day the session began \n(as a number from 0 to 24, or -1 to leave the hour unchanged from the original): ');

new_session = ChangeSessionDate(old_session, new_year, new_month, new_day, new_hour);

disp('Saving session to file...');

Save_PTSD_MMaze_File([save_path save_file], new_session);

disp('Finished');

end

