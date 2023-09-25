--checking stuff
use bikes;
select * from bikes;
select * from customers;
select * from rentals;

--refreshing stuff
update bikes set available = 1 where available = 0;
delete from rentals;
delete from customers;

--trying stuff if it even works as it should 
--at least directly in the db
INSERT INTO rentals(customer_id, bike_id) VALUES(23, 22);
UPDATE rentals SET date_returned = NULL WHERE rental_id = 10;

SELECT b.bike_id, b.type, b.size
FROM bikes b
INNER JOIN rentals r ON b.bike_id = r.bike_id
INNER JOIN customers c ON r.customer_id = c.customer_id
WHERE r.date_returned IS NULL;

SELECT customer_id FROM customers WHERE phone= *;