
-- =========================================================
-- Скрипт наполнения учебной базы данных retail-системы
-- Совместим со схемой updated_retail_schema.sql
-- Предполагается, что структура таблиц уже создана.
--
-- Что создаётся:
-- - 5 категорий товаров
-- - 15 подкатегорий
-- - 60 товаров
-- - 3 магазина
-- - 6 POS-терминалов
-- - 24 person / customer
-- - остатки по каждому товару в каждом магазине
-- - 90 заказов
-- - 270 строк заказов
--
-- Скрипт подходит для учебных запросов:
-- - JOIN / GROUP BY / ORDER BY
-- - агрегаты и CTE
-- - оконные функции
-- - аналитика по магазинам, категориям, терминалам, клиентам
-- - анализ остатков и продаж
-- =========================================================

BEGIN;

-- =========================================================
-- Очистка данных
-- =========================================================
TRUNCATE TABLE
    sales.salesorderdetail,
    sales.salesorderheader,
    inventory.storeinventory,
    sales.posterminal,
    sales.customer,
    person.person,
    sales.store,
    production.product,
    production.productsubcategory,
    production.productcategory
RESTART IDENTITY CASCADE;

-- =========================================================
-- 1. Категории
-- =========================================================
INSERT INTO production.productcategory (name)
VALUES
    ('Beverages'),
    ('Bakery'),
    ('Dairy'),
    ('Snacks'),
    ('Household');

-- =========================================================
-- 2. Подкатегории
-- =========================================================
INSERT INTO production.productsubcategory (productcategoryid, name)
SELECT pc.productcategoryid, v.subcategory_name
FROM (
    VALUES
        ('Beverages', 'Water'),
        ('Beverages', 'Juice'),
        ('Beverages', 'CoffeeTea'),

        ('Bakery', 'Bread'),
        ('Bakery', 'Pastry'),
        ('Bakery', 'Cookies'),

        ('Dairy', 'Milk'),
        ('Dairy', 'Cheese'),
        ('Dairy', 'Yogurt'),

        ('Snacks', 'Chips'),
        ('Snacks', 'Chocolate'),
        ('Snacks', 'Nuts'),

        ('Household', 'Cleaning'),
        ('Household', 'Paper'),
        ('Household', 'Hygiene')
) AS v(category_name, subcategory_name)
JOIN production.productcategory pc
  ON pc.name = v.category_name;

-- =========================================================
-- 3. Товары
-- =========================================================
INSERT INTO production.product
    (name, productnumber, color, standardcost, listprice, size, weight, class, style, productsubcategoryid, sellstartdate, isactive)
SELECT
    v.name,
    v.productnumber,
    v.color,
    v.standardcost,
    v.listprice,
    v.size,
    v.weight,
    v.class,
    v.style,
    ps.productsubcategoryid,
    v.sellstartdate,
    v.isactive
FROM (
    VALUES
        -- Water
        ('Still Water 0.5L',      'P0001', NULL,      0.18, 0.49, '0.5L', 0.500, 'A1', 'ST', 'Water',      TIMESTAMP '2024-01-01', TRUE),
        ('Still Water 1.5L',      'P0002', NULL,      0.32, 0.89, '1.5L', 1.500, 'A1', 'ST', 'Water',      TIMESTAMP '2024-01-01', TRUE),
        ('Sparkling Water 0.5L',  'P0003', NULL,      0.20, 0.55, '0.5L', 0.500, 'A1', 'SP', 'Water',      TIMESTAMP '2024-01-01', TRUE),
        ('Sparkling Water 1.5L',  'P0004', NULL,      0.35, 0.95, '1.5L', 1.500, 'A1', 'SP', 'Water',      TIMESTAMP '2024-01-01', TRUE),

        -- Juice
        ('Orange Juice 1L',       'P0005', 'Orange',  0.70, 1.79, '1L',   1.000, 'A1', 'JU', 'Juice',      TIMESTAMP '2024-01-15', TRUE),
        ('Apple Juice 1L',        'P0006', 'Gold',    0.68, 1.69, '1L',   1.000, 'A1', 'JU', 'Juice',      TIMESTAMP '2024-01-15', TRUE),
        ('Multivitamin Juice 1L', 'P0007', 'Orange',  0.74, 1.89, '1L',   1.000, 'A1', 'JU', 'Juice',      TIMESTAMP '2024-02-01', TRUE),
        ('Cherry Juice 1L',       'P0008', 'Red',     0.82, 2.09, '1L',   1.000, 'A1', 'JU', 'Juice',      TIMESTAMP '2024-02-01', TRUE),

        -- CoffeeTea
        ('Black Tea 25 bags',     'P0009', NULL,      0.95, 2.49, '25',   0.100, 'B1', 'TE', 'CoffeeTea',  TIMESTAMP '2024-01-20', TRUE),
        ('Green Tea 25 bags',     'P0010', 'Green',   1.00, 2.69, '25',   0.100, 'B1', 'TE', 'CoffeeTea',  TIMESTAMP '2024-01-20', TRUE),
        ('Ground Coffee 250g',    'P0011', 'Brown',   2.40, 5.99, '250g', 0.250, 'B1', 'CF', 'CoffeeTea',  TIMESTAMP '2024-02-10', TRUE),
        ('Instant Coffee 200g',   'P0012', 'Brown',   2.80, 6.49, '200g', 0.200, 'B1', 'CF', 'CoffeeTea',  TIMESTAMP '2024-02-10', TRUE),

        -- Bread
        ('White Bread',           'P0013', NULL,      0.55, 1.39, '500g', 0.500, 'A1', 'BR', 'Bread',      TIMESTAMP '2024-01-01', TRUE),
        ('Wholegrain Bread',      'P0014', 'Brown',   0.68, 1.69, '500g', 0.500, 'A1', 'BR', 'Bread',      TIMESTAMP '2024-01-01', TRUE),
        ('Toast Bread',           'P0015', NULL,      0.60, 1.49, '500g', 0.500, 'A1', 'BR', 'Bread',      TIMESTAMP '2024-01-01', TRUE),
        ('Baguette',              'P0016', NULL,      0.48, 1.19, '250g', 0.250, 'A1', 'BR', 'Bread',      TIMESTAMP '2024-01-01', TRUE),

        -- Pastry
        ('Butter Croissant',      'P0017', NULL,      0.42, 0.99, '1pc',  0.080, 'A1', 'PS', 'Pastry',     TIMESTAMP '2024-02-01', TRUE),
        ('Chocolate Donut',       'P0018', 'Brown',   0.55, 1.29, '1pc',  0.090, 'A1', 'PS', 'Pastry',     TIMESTAMP '2024-02-01', TRUE),
        ('Blueberry Muffin',      'P0019', 'Blue',    0.62, 1.49, '1pc',  0.100, 'A1', 'PS', 'Pastry',     TIMESTAMP '2024-02-01', TRUE),
        ('Cinnamon Roll',         'P0020', 'Brown',   0.58, 1.39, '1pc',  0.095, 'A1', 'PS', 'Pastry',     TIMESTAMP '2024-02-01', TRUE),

        -- Cookies
        ('Butter Cookies 200g',   'P0021', NULL,      0.88, 2.19, '200g', 0.200, 'A1', 'CK', 'Cookies',    TIMESTAMP '2024-01-10', TRUE),
        ('Chocolate Cookies 200g','P0022', 'Brown',   0.92, 2.29, '200g', 0.200, 'A1', 'CK', 'Cookies',    TIMESTAMP '2024-01-10', TRUE),
        ('Oat Cookies 200g',      'P0023', 'Brown',   0.84, 2.09, '200g', 0.200, 'A1', 'CK', 'Cookies',    TIMESTAMP '2024-01-10', TRUE),
        ('Ginger Cookies 180g',   'P0024', 'Brown',   0.90, 2.39, '180g', 0.180, 'A1', 'CK', 'Cookies',    TIMESTAMP '2024-01-10', TRUE),

        -- Milk
        ('Whole Milk 1L',         'P0025', 'White',   0.62, 1.39, '1L',   1.000, 'A1', 'MK', 'Milk',       TIMESTAMP '2024-01-05', TRUE),
        ('Low Fat Milk 1L',       'P0026', 'White',   0.60, 1.35, '1L',   1.000, 'A1', 'MK', 'Milk',       TIMESTAMP '2024-01-05', TRUE),
        ('Lactose Free Milk 1L',  'P0027', 'White',   0.88, 1.99, '1L',   1.000, 'A1', 'MK', 'Milk',       TIMESTAMP '2024-01-05', TRUE),
        ('Chocolate Milk 1L',     'P0028', 'Brown',   0.84, 1.89, '1L',   1.000, 'A1', 'MK', 'Milk',       TIMESTAMP '2024-01-05', TRUE),

        -- Cheese
        ('Gouda 250g',            'P0029', 'Yellow',  1.75, 3.99, '250g', 0.250, 'A1', 'CH', 'Cheese',     TIMESTAMP '2024-02-15', TRUE),
        ('Cheddar 250g',          'P0030', 'Yellow',  1.92, 4.29, '250g', 0.250, 'A1', 'CH', 'Cheese',     TIMESTAMP '2024-02-15', TRUE),
        ('Mozzarella 125g',       'P0031', 'White',   0.85, 1.99, '125g', 0.125, 'A1', 'CH', 'Cheese',     TIMESTAMP '2024-02-15', TRUE),
        ('Camembert 200g',        'P0032', 'White',   1.65, 3.89, '200g', 0.200, 'A1', 'CH', 'Cheese',     TIMESTAMP '2024-02-15', TRUE),

        -- Yogurt
        ('Natural Yogurt 150g',   'P0033', 'White',   0.22, 0.59, '150g', 0.150, 'A1', 'YG', 'Yogurt',     TIMESTAMP '2024-01-12', TRUE),
        ('Strawberry Yogurt 150g','P0034', 'Pink',    0.24, 0.65, '150g', 0.150, 'A1', 'YG', 'Yogurt',     TIMESTAMP '2024-01-12', TRUE),
        ('Peach Yogurt 150g',     'P0035', 'Orange',  0.24, 0.65, '150g', 0.150, 'A1', 'YG', 'Yogurt',     TIMESTAMP '2024-01-12', TRUE),
        ('Greek Yogurt 150g',     'P0036', 'White',   0.36, 0.89, '150g', 0.150, 'A1', 'YG', 'Yogurt',     TIMESTAMP '2024-01-12', TRUE),

        -- Chips
        ('Salted Chips 150g',     'P0037', 'Yellow',  0.78, 1.99, '150g', 0.150, 'A1', 'SN', 'Chips',      TIMESTAMP '2024-03-01', TRUE),
        ('Paprika Chips 150g',    'P0038', 'Red',     0.80, 2.09, '150g', 0.150, 'A1', 'SN', 'Chips',      TIMESTAMP '2024-03-01', TRUE),
        ('Sour Cream Chips 150g', 'P0039', 'White',   0.82, 2.19, '150g', 0.150, 'A1', 'SN', 'Chips',      TIMESTAMP '2024-03-01', TRUE),
        ('Tortilla Chips 200g',   'P0040', 'Yellow',  1.10, 2.69, '200g', 0.200, 'A1', 'SN', 'Chips',      TIMESTAMP '2024-03-01', TRUE),

        -- Chocolate
        ('Dark Chocolate 100g',   'P0041', 'Brown',   0.68, 1.79, '100g', 0.100, 'A1', 'CH', 'Chocolate',  TIMESTAMP '2024-03-05', TRUE),
        ('Milk Chocolate 100g',   'P0042', 'Brown',   0.64, 1.69, '100g', 0.100, 'A1', 'CH', 'Chocolate',  TIMESTAMP '2024-03-05', TRUE),
        ('Hazelnut Chocolate 100g','P0043','Brown',   0.72, 1.89, '100g', 0.100, 'A1', 'CH', 'Chocolate',  TIMESTAMP '2024-03-05', TRUE),
        ('White Chocolate 100g',  'P0044', 'White',   0.70, 1.85, '100g', 0.100, 'A1', 'CH', 'Chocolate',  TIMESTAMP '2024-03-05', TRUE),

        -- Nuts
        ('Salted Peanuts 200g',   'P0045', 'Brown',   1.40, 3.29, '200g', 0.200, 'A1', 'NT', 'Nuts',       TIMESTAMP '2024-02-20', TRUE),
        ('Almond Mix 200g',       'P0046', 'Brown',   2.30, 4.99, '200g', 0.200, 'A1', 'NT', 'Nuts',       TIMESTAMP '2024-02-20', TRUE),
        ('Cashews 200g',          'P0047', 'Brown',   2.45, 5.29, '200g', 0.200, 'A1', 'NT', 'Nuts',       TIMESTAMP '2024-02-20', TRUE),
        ('Walnuts 200g',          'P0048', 'Brown',   2.10, 4.69, '200g', 0.200, 'A1', 'NT', 'Nuts',       TIMESTAMP '2024-02-20', TRUE),

        -- Cleaning
        ('Dish Soap 500ml',       'P0049', 'Green',   0.95, 2.49, '500ml',0.500, 'B1', 'CL', 'Cleaning',   TIMESTAMP '2024-01-18', TRUE),
        ('Laundry Detergent 2L',  'P0050', 'Blue',    3.80, 8.99, '2L',   2.000, 'B1', 'CL', 'Cleaning',   TIMESTAMP '2024-01-18', TRUE),
        ('Glass Cleaner 750ml',   'P0051', 'Blue',    1.10, 2.89, '750ml',0.750, 'B1', 'CL', 'Cleaning',   TIMESTAMP '2024-01-18', TRUE),
        ('Floor Cleaner 1L',      'P0052', 'Green',   1.25, 3.19, '1L',   1.000, 'B1', 'CL', 'Cleaning',   TIMESTAMP '2024-01-18', TRUE),

        -- Paper
        ('Toilet Paper 8 rolls',  'P0053', 'White',   2.20, 4.99, '8',    0.900, 'B1', 'PP', 'Paper',      TIMESTAMP '2024-01-08', TRUE),
        ('Kitchen Towels 4 rolls','P0054', 'White',   1.50, 3.49, '4',    0.700, 'B1', 'PP', 'Paper',      TIMESTAMP '2024-01-08', TRUE),
        ('Paper Napkins 100pcs',  'P0055', 'White',   0.65, 1.59, '100',  0.250, 'B1', 'PP', 'Paper',      TIMESTAMP '2024-01-08', TRUE),
        ('Facial Tissues 80pcs',  'P0056', 'White',   0.72, 1.79, '80',   0.220, 'B1', 'PP', 'Paper',      TIMESTAMP '2024-01-08', TRUE),

        -- Hygiene
        ('Liquid Soap 300ml',     'P0057', 'White',   0.98, 2.39, '300ml',0.300, 'B1', 'HG', 'Hygiene',    TIMESTAMP '2024-02-28', TRUE),
        ('Shampoo 400ml',         'P0058', 'Blue',    1.85, 4.49, '400ml',0.400, 'B1', 'HG', 'Hygiene',    TIMESTAMP '2024-02-28', TRUE),
        ('Toothpaste 100ml',      'P0059', 'White',   0.95, 2.49, '100ml',0.100, 'B1', 'HG', 'Hygiene',    TIMESTAMP '2024-02-28', TRUE),
        ('Toothbrush Medium',     'P0060', 'Blue',    0.70, 1.99, '1pc',  0.050, 'B1', 'HG', 'Hygiene',    TIMESTAMP '2024-02-28', TRUE)
) AS v(name, productnumber, color, standardcost, listprice, size, weight, class, style, subcategory_name, sellstartdate, isactive)
JOIN production.productsubcategory ps
  ON ps.name = v.subcategory_name;

-- =========================================================
-- 4. Магазины
-- =========================================================
INSERT INTO sales.store
    (storename, storecode, addressline1, addressline2, city, postalcode, country, isactive, openeddate)
VALUES
    ('Aachen Center Store',   'STR-AAC-01', 'Markt 12',          NULL, 'Aachen',  '52062', 'Germany', TRUE, DATE '2022-03-15'),
    ('Cologne Riverside',     'STR-CGN-01', 'Rheinufer 44',      NULL, 'Cologne', '50667', 'Germany', TRUE, DATE '2021-09-01'),
    ('Dusseldorf Central',    'STR-DUS-01', 'Konigsallee 101',   NULL, 'Dusseldorf', '40212', 'Germany', TRUE, DATE '2023-05-10');

-- =========================================================
-- 5. POS-терминалы
-- =========================================================
INSERT INTO sales.posterminal
    (storeid, terminalcode, serialnumber, modelname, installedat, lastservicedat, isactive)
SELECT s.storeid, v.terminalcode, v.serialnumber, v.modelname, v.installedat, v.lastservicedat, v.isactive
FROM (
    VALUES
        ('STR-AAC-01', 'POS-01', 'SN-AAC-1001', 'Verifone X990', TIMESTAMP '2024-01-10 08:00:00', TIMESTAMP '2025-12-15 10:00:00', TRUE),
        ('STR-AAC-01', 'POS-02', 'SN-AAC-1002', 'Ingenico DX8000', TIMESTAMP '2024-01-12 08:30:00', TIMESTAMP '2025-12-18 09:00:00', TRUE),
        ('STR-CGN-01', 'POS-01', 'SN-CGN-2001', 'Verifone X990', TIMESTAMP '2024-02-01 09:00:00', TIMESTAMP '2026-01-15 11:00:00', TRUE),
        ('STR-CGN-01', 'POS-02', 'SN-CGN-2002', 'Ingenico DX8000', TIMESTAMP '2024-02-03 09:30:00', TIMESTAMP '2026-01-16 11:30:00', TRUE),
        ('STR-DUS-01', 'POS-01', 'SN-DUS-3001', 'PAX A920', TIMESTAMP '2024-03-01 08:45:00', TIMESTAMP '2026-02-02 10:15:00', TRUE),
        ('STR-DUS-01', 'POS-02', 'SN-DUS-3002', 'PAX A920', TIMESTAMP '2024-03-02 08:45:00', TIMESTAMP '2026-02-02 10:45:00', TRUE)
) AS v(storecode, terminalcode, serialnumber, modelname, installedat, lastservicedat, isactive)
JOIN sales.store s
  ON s.storecode = v.storecode;

-- =========================================================
-- 6. Люди
-- =========================================================
INSERT INTO person.person (firstname, middlename, lastname, emailaddress, phone)
VALUES
    ('Anna',   NULL, 'Schmidt',   'anna.schmidt@example.com',   '+49-151-000-0001'),
    ('Lukas',  NULL, 'Meyer',     'lukas.meyer@example.com',    '+49-151-000-0002'),
    ('Emma',   NULL, 'Fischer',   'emma.fischer@example.com',   '+49-151-000-0003'),
    ('Noah',   NULL, 'Weber',     'noah.weber@example.com',     '+49-151-000-0004'),
    ('Mia',    NULL, 'Wagner',    'mia.wagner@example.com',     '+49-151-000-0005'),
    ('Paul',   NULL, 'Becker',    'paul.becker@example.com',    '+49-151-000-0006'),
    ('Lea',    NULL, 'Hoffmann',  'lea.hoffmann@example.com',   '+49-151-000-0007'),
    ('Finn',   NULL, 'Schulz',    'finn.schulz@example.com',    '+49-151-000-0008'),
    ('Lena',   NULL, 'Koch',      'lena.koch@example.com',      '+49-151-000-0009'),
    ('Jonas',  NULL, 'Richter',   'jonas.richter@example.com',  '+49-151-000-0010'),
    ('Sophie', NULL, 'Klein',     'sophie.klein@example.com',   '+49-151-000-0011'),
    ('Ben',    NULL, 'Wolf',      'ben.wolf@example.com',       '+49-151-000-0012'),
    ('Laura',  NULL, 'Schroder',  'laura.schroder@example.com', '+49-151-000-0013'),
    ('Leon',   NULL, 'Neumann',   'leon.neumann@example.com',   '+49-151-000-0014'),
    ('Marie',  NULL, 'Schwarz',   'marie.schwarz@example.com',  '+49-151-000-0015'),
    ('Elias',  NULL, 'Zimmermann','elias.zimmermann@example.com','+49-151-000-0016'),
    ('Clara',  NULL, 'Braun',     'clara.braun@example.com',    '+49-151-000-0017'),
    ('Tim',    NULL, 'Kruger',    'tim.kruger@example.com',     '+49-151-000-0018'),
    ('Nina',   NULL, 'Hartmann',  'nina.hartmann@example.com',  '+49-151-000-0019'),
    ('David',  NULL, 'Lange',     'david.lange@example.com',    '+49-151-000-0020'),
    ('Julia',  NULL, 'Werner',    'julia.werner@example.com',   '+49-151-000-0021'),
    ('Felix',  NULL, 'Schmitz',   'felix.schmitz@example.com',  '+49-151-000-0022'),
    ('Sarah',  NULL, 'Krause',    'sarah.krause@example.com',   '+49-151-000-0023'),
    ('Max',    NULL, 'Lehmann',   'max.lehmann@example.com',    '+49-151-000-0024');

-- =========================================================
-- 7. Клиенты
-- =========================================================
INSERT INTO sales.customer (personid, customertype, accountnumber, isactive, createdat)
SELECT
    p.personid,
    CASE WHEN p.personid % 8 = 0 THEN 'W' ELSE 'R' END,
    'CUST-' || LPAD(p.personid::text, 5, '0'),
    TRUE,
    TIMESTAMP '2025-01-01 09:00:00' + (p.personid || ' days')::interval
FROM person.person p
ORDER BY p.personid;

-- =========================================================
-- 8. Остатки товаров по магазинам
-- =========================================================
INSERT INTO inventory.storeinventory
    (storeid, productid, quantityonhand, reorderpoint, safetystocklevel, laststocktakeat)
SELECT
    s.storeid,
    p.productid,
    ((p.productid * 7 + s.storeid * 13) % 180 + 20)::numeric(14,3) AS quantityonhand,
    ((p.productid * 3 + s.storeid * 2) % 25 + 5)::numeric(14,3) AS reorderpoint,
    (((p.productid * 3 + s.storeid * 2) % 25 + 5) + ((p.productid + s.storeid) % 20 + 10))::numeric(14,3) AS safetystocklevel,
    TIMESTAMP '2026-04-01 06:00:00' + (s.storeid * 2 || ' hours')::interval
FROM sales.store s
CROSS JOIN production.product p;

-- Сделаем несколько товаров с особенно низким остатком для учебных задач
UPDATE inventory.storeinventory
SET quantityonhand = reorderpoint - 1
WHERE (storeid, productid) IN ((1, 5), (1, 17), (2, 29), (2, 50), (3, 41), (3, 58));

UPDATE inventory.storeinventory
SET quantityonhand = 0
WHERE (storeid, productid) IN ((1, 60), (2, 12), (3, 24));

-- =========================================================
-- 9. Заказы (90 штук)
-- customerid иногда NULL для имитации анонимных покупок
-- =========================================================
INSERT INTO sales.salesorderheader
    (customerid, posterminalid, orderdate, status, paymentmethod, subtotal, taxamt, freight, comment)
SELECT
    CASE
        WHEN gs % 7 = 0 THEN NULL
        ELSE ((gs - 1) % 24) + 1
    END AS customerid,
    ((gs - 1) % 6) + 1 AS posterminalid,
    TIMESTAMP '2026-03-01 09:00:00'
        + ((gs - 1) / 3) * INTERVAL '1 day'
        + ((gs * 17) % 540) * INTERVAL '1 minute' AS orderdate,
    CASE
        WHEN gs % 20 = 0 THEN 4
        WHEN gs % 9 = 0 THEN 2
        ELSE 1
    END AS status,
    CASE
        WHEN gs % 10 = 0 THEN 'ONLINE'
        WHEN gs % 4 = 0 THEN 'CASH'
        WHEN gs % 6 = 0 THEN 'MIXED'
        ELSE 'CARD'
    END AS paymentmethod,
    0, 0, 0,
    CASE
        WHEN gs % 15 = 0 THEN 'Promotional sale'
        WHEN gs % 11 = 0 THEN 'Evening basket'
        ELSE NULL
    END AS comment
FROM generate_series(1, 90) AS gs;

-- =========================================================
-- 10. Строки заказов (по 3 строки на заказ = 270 строк)
-- Подбираем товар, количество и скидку по формуле, чтобы данные были разнообразными
-- =========================================================
INSERT INTO sales.salesorderdetail
    (salesorderid, productid, orderqty, unitprice, unitpricediscount)
SELECT
    oh.salesorderid,
    p.productid,
    ((oh.salesorderid + item.line_no) % 4) + 1 AS orderqty,
    p.listprice,
    CASE
        WHEN (oh.salesorderid + item.line_no) % 13 = 0 THEN 0.1500
        WHEN (oh.salesorderid + item.line_no) % 9 = 0 THEN 0.1000
        WHEN (oh.salesorderid + item.line_no) % 5 = 0 THEN 0.0500
        ELSE 0.0000
    END AS unitpricediscount
FROM sales.salesorderheader oh
CROSS JOIN LATERAL (
    VALUES (1), (2), (3)
) AS item(line_no)
JOIN production.product p
  ON p.productid = (((oh.salesorderid * 7 + item.line_no * 11) % 60) + 1);

-- Добавим несколько повторных покупок одних и тех же товаров в отдельных заказах
INSERT INTO sales.salesorderdetail
    (salesorderid, productid, orderqty, unitprice, unitpricediscount)
SELECT
    extra.salesorderid,
    p.productid,
    extra.qty,
    p.listprice,
    extra.discount
FROM (
    VALUES
        (5,  1,  2, 0.0000),
        (12, 5,  3, 0.0500),
        (18, 11, 1, 0.0000),
        (22, 25, 2, 0.1000),
        (33, 37, 2, 0.0000),
        (41, 41, 4, 0.1500),
        (54, 53, 1, 0.0000),
        (66, 58, 2, 0.0500),
        (73, 29, 3, 0.0000),
        (88, 60, 2, 0.0000)
) AS extra(salesorderid, productid, qty, discount)
JOIN production.product p
  ON p.productid = extra.productid;

-- =========================================================
-- 11. Пересчёт итогов заголовков заказов
-- totaldue считается автоматически как subtotal + taxamt + freight
-- =========================================================
UPDATE sales.salesorderheader h
SET
    subtotal = d.subtotal,
    taxamt   = ROUND(d.subtotal * 0.19, 4),
    freight  = CASE
                  WHEN h.paymentmethod = 'ONLINE' THEN 4.9900
                  WHEN h.salesorderid % 12 = 0 THEN 2.5000
                  ELSE 0.0000
               END,
    modifieddate = clock_timestamp()
FROM (
    SELECT salesorderid, ROUND(SUM(linetotal), 4) AS subtotal
    FROM sales.salesorderdetail
    GROUP BY salesorderid
) d
WHERE h.salesorderid = d.salesorderid;

-- =========================================================
-- 12. Небольшая корректировка активности товаров
-- Несколько товаров неактивны, но остаются в справочнике
-- =========================================================
UPDATE production.product
SET isactive = FALSE,
    sellenddate = TIMESTAMP '2026-02-28 23:59:59',
    discontinueddate = TIMESTAMP '2026-03-15 00:00:00',
    modifieddate = clock_timestamp()
WHERE productid IN (8, 24, 44);

COMMIT;

-- =========================================================
-- Примеры учебных идей для запросов:
-- 1. Продажи по магазинам
-- 2. Продажи по терминалам
-- 3. Топ-10 товаров по выручке
-- 4. Категории с наибольшим объёмом продаж
-- 5. Средний чек по магазину
-- 6. Анонимные продажи vs продажи зарегистрированным клиентам
-- 7. Товары с остатком ниже точки заказа
-- 8. Товары без продаж
-- 9. Покупатели с наибольшей суммой покупок
-- 10. Доля скидочных продаж
-- =========================================================
