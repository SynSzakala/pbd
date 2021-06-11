CREATE or alter VIEW today_bookings AS
SELECT "order".id, price_netto, client.name
FROM "order"
         INNER JOIN client ON client.id = "order".client_id
WHERE booking_table_id IS NOT NULL
  AND booking_start_time <= GETDATE()
  AND booking_start_time <= DATEADD(day, 1, GETDATE());