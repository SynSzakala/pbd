CREATE or alter VIEW top_customers("Klient", "Liczba zamówień")
AS
SELECT TOP (20) client.name, COUNT(client.id) as count
FROM [order]
         JOIN client ON client.id = [order].client_id
GROUP BY client.name
order by count desc
go;

SELECT *
FROM top_customers;
