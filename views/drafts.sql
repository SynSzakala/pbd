
CREATE FUNCTION last_trn (@ClientID INTEGER)
    RETURNS TABLE
    AS
RETURN
(
    SELECT TOP 1 *
    FROM [order]
    ORDER BY [order].created_time DESC
)

CREATE FUNCTION clients_by_type (@Status VARCHAR(10))
    RETURNS TABLE
    AS
RETURN
(
    SELECT client.name, client.email, "order".created_time
    FROM "client"
    JOIN [order]
    ON [order].client_id = client.id
    (
    SELECT TOP 1 [order]
    FROM [order]
    ORDER BY [order].created_time DESC
    )
)

ALTER FUNCTION clients_by_type (@ClientType VARCHAR(10))
    RETURNS TABLE
    AS
    RETURN
    (
    SELECT TOP 1 "order".created_time, client.name, client.email
    FROM client
    JOIN [order]
    ON [order].client_id = client.id
    WHERE @ClientType = client.client_type
    )

select * from clients_by_type('Private');

ALTER FUNCTION clients_by_type (@ClientType VARCHAR(10))
    RETURNS TABLE
    AS
    RETURN
    (
    SELECT "order".created_time, client.name, client.email
    FROM client
    JOIN [order]
    ON [order].client_id = client.id
    WHERE @ClientType = client.client_type AND "order".created_time =
    (SELECT TOP 1 "order".created_time FROM "order")
    GROUP BY "order".created_time, client.name, client.email
    )