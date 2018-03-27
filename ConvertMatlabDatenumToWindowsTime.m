function windows_datestring = ConvertMatlabDatenumToWindowsTime ( matlab_datenum )

import java.util.*;
my_cal = Calendar.getInstance();

%The number of nanoseconds from 1 Jan, 1601 to 1 Jan, 1970.
%The incoming date is a Windows FileTime, and is based off of the number of
%nanoseconds since 1601.  We need to convert it to be based off of 1970,
%because that is how Java works.  So the following number of nanoseconds is
%how many we need to add in order to properly convert it.
nanos_to_add = int64(116444736000000000);

matlab_datevec = datevec(matlab_datenum);

seconds = matlab_datevec(6);
fractional_second = round(abs(seconds - fix(seconds)) * 1000);

my_cal.set(my_cal.YEAR, matlab_datevec(1));
my_cal.set(my_cal.MONTH, matlab_datevec(2)-1);
my_cal.set(my_cal.DAY_OF_MONTH, matlab_datevec(3));
my_cal.set(my_cal.HOUR_OF_DAY, matlab_datevec(4));
my_cal.set(my_cal.MINUTE, matlab_datevec(5));
my_cal.set(my_cal.SECOND, floor(matlab_datevec(6)));
my_cal.set(my_cal.MILLISECOND, fractional_second);

millis_since_1970 = int64(my_cal.getTimeInMillis());
nanos_since_1970 = millis_since_1970 * int64(10000);
windows_datetime_number = nanos_to_add + nanos_since_1970;

windows_datestring = num2str(windows_datetime_number);

end