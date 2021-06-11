create or
ALTER FUNCTION clients_by_type(@ClientType VARCHAR(10))
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT client.name, client.email
                FROM "client"
                WHERE @ClientType = client.client_type
            )

SELECT *
FROM clients_by_type('Private');
