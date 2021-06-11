CREATE OR
ALTER FUNCTION ranged_report(@StartDate DATETIME, @EndDate DATETIME, @Type VARCHAR(10) = 'Order')
    RETURNS TABLE
        AS
        RETURN
        SELECT client.name, [order].*
        FROM [order]
                 JOIN client
                      ON client.id = "order".client_id
        WHERE (@Type = 'Booking' AND @StartDate <= "order".booking_start_time AND @EndDate >= "order".booking_end_time)
           OR (@Type = 'Order' AND @StartDate <= "order".ready_time AND @EndDate >= "order".ready_time)
GO

-- TODO dodać wyspecjalizowane funkcje do miesięcznych i tygodniowych

select *
from ranged_report('2021-04-20 00:00:00', '2021-06-15 00:00:00', default);