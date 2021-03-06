CREATE
or alter
    VIEW aktualne_menu ("Nazwa dania", "Cena dania")
    AS
    SELECT item.name, item.price_netto
    FROM menu_position
    INNER JOIN item ON item.id = menu_position.item_id
    LEFT JOIN menu ON menu.id = menu_position.menu_id
    WHERE menu.id = dbo.find_active_menu_id(sysdatetime());