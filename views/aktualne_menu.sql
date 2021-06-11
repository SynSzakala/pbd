CREATE VIEW aktualne_menu AS
SELECT item.name, item.price_netto
FROM menu_position
INNER JOIN item ON item.id = menu_position.item_id
LEFT JOIN menu ON menu.id = menu_position.menu_id
WHERE GETDATE() >= menu.start_date AND GETDATE() <= menu.end_date;