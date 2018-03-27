function new_session = ChangeSessionDate ( session, new_year, new_month, new_day, new_start_hour )

new_session = session;
start_time = datevec(session.StartTime);
start_time(1) = new_year;
start_time(2) = new_month;
start_time(3) = new_day;

if (new_start_hour ~= -1)
    start_time(4) = new_start_hour;
end

session_elapsed_time = etime(datevec(session.EndTime), datevec(session.StartTime));
end_time = datetime(start_time) + seconds(session_elapsed_time);

new_session.StartTime = datenum(start_time);
new_session.EndTime = datenum(end_time);

if (~isempty(session.EventTime))

    for i = 1:length(session.EventTime)
        event_elapsed_time = etime(datevec(session.EventTime(i)), datevec(session.StartTime));
        event_time = datetime(start_time) + seconds(event_elapsed_time);
        new_session.EventTime(i) = datenum(event_time);
    end

end

end

