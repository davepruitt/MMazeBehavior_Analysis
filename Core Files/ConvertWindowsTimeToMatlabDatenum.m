function matlab_datenum = ConvertWindowsTimeToMatlabDatenum ( windows_datestring )

import java.util.*;
my_cal = Calendar.getInstance();

%The number of nanoseconds from 1 Jan, 1601 to 1 Jan, 1970.
%The incoming date is a Windows FileTime, and is based off of the number of
%nanoseconds since 1601.  We need to convert it to be based off of 1970,
%because that is how Java works.  So the following number of nanoseconds is
%how many we need to subtract in order to properly convert it.
nanos_to_subtract = int64(116444736000000000);

%The following lines are slow.  The str2num function uses the eval 
%function under the hood, which is quite slow:
%conversion_string = ['int64(' windows_datestring ')'];
%converted_number = str2num(conversion_string);

%This line is much faster than the previous lines that were commented out.
%It is about 30% faster. Testing with 84,000 function calls, the previous 
%lines were clocked at 12 seconds, while this line was clocked at 
%negligible time taken up:
converted_number = sscanf(windows_datestring, '%li');


nanos_since_1970 = converted_number - nanos_to_subtract;
millis_since_1970 = nanos_since_1970 / 10000;
my_cal.setTimeInMillis(millis_since_1970);

y1 = my_cal.get(my_cal.YEAR);
y2 = my_cal.get(my_cal.MONTH)+1;
y3 = my_cal.get(my_cal.DAY_OF_MONTH);
y4 = my_cal.get(my_cal.HOUR_OF_DAY);
y5 = my_cal.get(my_cal.MINUTE);
y6 = my_cal.get(my_cal.SECOND);

matlab_datevec = [ y1 y2 y3 y4 y5 y6 ];
milliseconds = double(my_cal.get(my_cal.MILLISECOND)) / 1000;
matlab_datevec(6) = matlab_datevec(6) + milliseconds;
matlab_datenum = datenum(matlab_datevec(1), ...
    matlab_datevec(2), ...
    matlab_datevec(3), ...
    matlab_datevec(4), ...
    matlab_datevec(5), ...
    matlab_datevec(6));

%% THE FOLLOWING CODE IS OLD AND SHOULD NOT BE USED!
%This code is specific to Windows machines, and it will not work on
%computers running OS X. This is because it requires .NET to run. It is
%unknown if having Mono installed on OS X would be sufficient to get this
%to run. The new code (above) requires Java to run correctly.

% windows_datetime = System.DateTime(converted_number);
% matlab_datevec = [ ...
%     double(windows_datetime.Year), ...
%     double(windows_datetime.Month), ...
%     double(windows_datetime.Day), ...
%     double(windows_datetime.Hour), ...
%     double(windows_datetime.Minute), ...
%     double(windows_datetime.Second) ...
%     ];
% milliseconds = double(windows_datetime.Millisecond) / 1000;
% matlab_datevec(6) = matlab_datevec(6) + milliseconds;
% matlab_datenum = datenum(matlab_datevec(1), ...
%     matlab_datevec(2), ...
%     matlab_datevec(3), ...
%     matlab_datevec(4), ...
%     matlab_datevec(5), ...
%     matlab_datevec(6));

%% END OF OLD CODE!

end

