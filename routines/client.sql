create or alter function is_client_company(@client_id integer) returns bit
begin
    declare @type varchar(10);
    select @type = client_type from client where id = @client_id
    return iif(@type = 'Company', 1, 0)
end
go;
