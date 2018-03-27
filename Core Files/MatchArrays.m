function matched = MatchArrays ( a, b )

    matched = [];
    done = 0;
    i = 1;
    j = 1;
    
    while (~done)
        
        new_row = [];
        if (i > length(a) && j > length(b))
            done = 1;
        elseif (i > length(a))
            new_row = [NaN b(j)];
            j = j + 1;
        elseif (j > length(b))
            new_row = [a(i) NaN];
            i = i + 1;
        elseif (a(i) == b(j))
            new_row = [a(i) b(j)];
            i = i + 1;
            j = j + 1;
        elseif (a(i) < b(j))
            new_row = [a(i) NaN];
            i = i + 1;
        else
            new_row = [NaN b(j)];
            j = j + 1;
        end
        
        matched = [matched; new_row];
        
    end

end

