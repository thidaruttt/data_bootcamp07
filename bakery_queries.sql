.open bakery_cafe.db

DROP TABLE customer;
DROP TABLE promotion;
DROP TABLE menu;
DROP TABLE employee;
DROP TABLE cus_order;

CREATE TABLE IF NOT EXISTS customer(
  cus_id int PRIMARY KEY
  ,cus_name text
  ,age int
  ,gender varchar
  ,dob date
  ,cus_tel varchar
);

INSERT INTO customer VALUES
    (121, 'Mind Thidarut', 26, 'female', 1996-02-10, '06413'),
    (122, 'Lisa Lalisa', 25, 'female', 1997-03-10, '06077'),
    (123, 'Eleanor Mann', 27, 'female', 1995-04-10, '09114'),
    (124, 'Adrian Snyder', 26, 'male', 1996-05-10, '03796'),
    (125, 'Brooke Daniel', 25, 'male', 1997-06-10, '02359');

CREATE TABLE IF NOT EXISTS promotion(
  promotion_id int PRIMARY KEY
  ,promotion_name varchar
  ,start_date DATE NOT NULL
  ,end_date DATE
);

INSERT INTO promotion VALUES
    (111, 'discount 5 percent', '2023-01-01', '2023-01-30');

CREATE TABLE IF NOT EXISTS menu(
  menu_id int PRIMARY KEY
  ,menu_name text NOT NULL 
  ,price int
  ,type text
  ,promotion_id int
  ,FOREIGN KEY (promotion_id) REFERENCES promotion(promotion_id)
);

INSERT INTO menu VALUES
    (1, 'Banana Cake', 55, 'bakery', null),
    (2, 'Cake Roll', 50, 'bakery', null),
    (3, 'Honey Toast', 70, 'bakery', 111),
    (4, 'Americano', 40, 'coffee', null),
    (5, 'Cappuccino', 40, 'coffee', null);


CREATE TABLE IF NOT EXISTS employee(
  employee_id int PRIMARY KEY
  ,employee_name text
  ,position text
  ,employee_tel varchar
  ,email varchar
);

INSERT INTO employee VALUES
    (1, 'Isabella', 'manager', '06789', 'isabella@email.com'),
    (2, 'Madison', 'waitress', '06896', 'madison@email.com'),
    (3, 'Victoria', 'waitress', '07686', 'victoria@email.com'),
    (4, 'Olivia', 'pastry chef', '03443', 'olivia@email.com');


CREATE TABLE IF NOT EXISTS cus_order(
  order_id int PRIMARY KEY
  ,order_date DATETIME NOT NULL
  ,employee_id int
  ,cus_id int
  ,menu_id int
  ,amount int
  ,status text
  ,pay_date DATETIME
  ,FOREIGN KEY (employee_id) REFERENCES employe(employee_id)
  ,FOREIGN KEY (cus_id) REFERENCES customer(cus_id)
  ,FOREIGN KEY (menu_id) REFERENCES menu(menu_id)
);

INSERT INTO cus_order VALUES
    (11, '2023-01-25 12:00:00', 2, 121, 1, 1, "paid", '2023-01-25 13:00:00'),
    (22, '2023-01-25 13:00:00', 2, 122, 2, 1, "paid", '2023-01-25 14:00:00'),
    (33, '2023-01-25 14:00:00', 3, 123, 3, 1, "paid", '2023-01-25 15:00:00'),
    (44, '2023-01-25 14:00:00', 3, 124, 4, 2, "paid", '2023-01-25 15:00:00'),
    (55, '2023-01-25 14:00:00', 3, 125, 4, 3, "paid", '2023-01-25 15:00:00');


  
.mode column
.header on

.print 'What menu customers order?'
SELECT 
	orders.order_id AS order_id
	,orders.order_date AS order_date
	,customer.cus_name AS cus_name
	,menu.menu_name AS menu_name
	,orders.amount AS amount
	FROM cus_order orders
	LEFT JOIN menu ON orders.menu_id = menu.menu_id
  LEFT JOIN customer ON orders.cus_id = customer.cus_id
  ORDER BY orders.amount DESC;

.print ''
.print 'Most Popular Order'
SELECT 
	orders.menu_id AS menu_id
	,menu.menu_name AS menu_name
	,SUM(orders.amount) AS sum_amount
	FROM cus_order orders
	LEFT JOIN menu ON orders.menu_id = menu.menu_id
  LEFT JOIN customer ON orders.cus_id = customer.cus_id
  GROUP BY orders.menu_id
  ORDER BY orders.amount DESC;


.print ''
.print 'revenue'
  
WITH revenue AS (SELECT 
  orders.order_id AS order_id
  ,orders.cus_id AS cus_id
  ,menu.menu_name AS menu_name
  ,menu.type AS type
  ,orders.amount AS amount
  ,case when menu.promotion_id = 111 THEN (menu.price * 0.95)* orders.amount ELSE menu.price*orders.amount end AS price_total
  FROM cus_order orders
  LEFT JOIN menu ON orders.menu_id = menu.menu_id)
  
SELECT 
  r.type AS type
  ,SUM(r.amount) AS amount_total
  ,SUM(r.price_total) AS revenue
from revenue r
group by r.type;

