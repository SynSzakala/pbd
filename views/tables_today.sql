CREATE OR ALTER VIEW tables_today ("TABLE ID", "CLIENT NAME", "NO OF GUESTS", "ORDER ID", "START DATE", "END_DATE") AS
SELECT bookable_table.id,
       client.name,
       "bookable_table"."seats_count",
       "order".id,
       "order".booking_start_time,
       "order".booking_end_time
FROM bookable_table
         JOIN "order"
              ON "order"."booking_table_id" = bookable_table.id
         JOIN client
              ON "client".id = "order"."client_id"
WHERE booking_table_id IS NOT NULL