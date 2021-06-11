create or
alter function is_table_booked(@table_id integer, @date datetime) returns bit
begin
    return iif(
            exists(
                    select *
                    from [order]
                    where booking_table_id = @table_id
                      and @date >= booking_start_time
                      and (booking_end_time is null or @date <= booking_end_time)
                ),
            1,
            0
        );
end

create or
alter function find_free_table(@start_time datetime, @end_time datetime, @seats_count integer) returns integer
begin
    declare @id integer = null;

    select top (1) @id = id
    from bookable_table
    where seats_count >= @seats_count
      and id not in (
        select booking_table_id
        from [order]
        where booking_table_id is not null
          and booking_end_time <= @start_time
          and booking_start_time >= @end_time
    );

    return @id;
end