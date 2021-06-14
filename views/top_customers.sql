CREATE
    OR ALTER
    VIEW top_customers("Klient","Liczba zamówień")
    AS SELECT client.name,COUNT(client.id)
     FROM [order]
            JOIN client ON client.id = [order].client_id
    GROUP BY client.name;
GO

SELECT * FROM top_customers;

