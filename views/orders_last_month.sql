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
CREATE OR
ALTER FUNCTION last_week()
    RETURNS TABLE
        AS
        RETURN
        SELECT client.name, [order].*
        FROM [order]
                 JOIN client
                      ON client.id = "order".client_id
        WHERE (DATEDIFF("order".booking_start_time, GETDATE()) <= 7)
GO

CREATE OR
ALTER FUNCTION this_month()
    RETURNS TABLE
        AS
        RETURN
        SELECT client.name, [order].*
        FROM [order]
                 JOIN client
                      ON client.id = "order".client_id
        WHERE (MONTH("order".booking_start_time) = MONTH(GETDATE()))
GO

CREATE OR
ALTER FUNCTION last_month()
    RETURNS TABLE
        AS
        RETURN
        SELECT client.name, [order].*
        FROM [order]
                 JOIN client
                      ON client.id = "order".client_id
        WHERE (MONTH("order".booking_start_time) = MONTH(GETDATE()))
GO

CREATE
OR ALTER FUNCTION to_do_asap()
    RETURNS TABLE
        AS
        RETURN
        SELECT "order".id, price_netto, client.name
        FROM "order"
                 INNER JOIN client ON client.id = "order".client_id
        WHERE "order".status = "Accepted"
        ORDER BY "order".min_ready_time ASC
GO

select *
from ranged_report('2021-04-20 00:00:00', '2021-06-15 00:00:00', default);