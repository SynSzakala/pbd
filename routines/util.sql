create or
alter function inline_max_date(@a datetime, @b datetime) returns datetime
begin
    return iif(@a > @b, @a, @b);
end
go

create or
alter function inline_min_date(@a datetime, @b datetime) returns datetime
begin
    return iif(@a < @b, @a, @b);
end
go