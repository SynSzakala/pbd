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