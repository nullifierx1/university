/* 1 */
SELECT productid, name, productnumber, listprice FROM production.product LIMIT 20

/* 2 */
SELECT storeid, storename AS store_name, city, country AS country_name FROM sales.store

/* 3 */
SELECT name, listprice, standardcost, listprice - standardcost AS margin FROM production.product

/* 4 */
SELECT salesorderid, subtotal, taxamt, freight, subtotal + taxamt + freight AS calculated_total FROM sales.salesorderheader

/* 5 */
SELECT personid, CONCAT_WS(' ', firstname, middlename, lastname) AS full_name FROM person.person

/* 6 */
SELECT personid, firstname, middlename, lastname, COALESCE(middlename, 'без отчества') AS middlename_display FROM person.person

/* 7 */
SELECT productid, name, listprice, COALESCE(listprice, 0) AS listprice_norm FROM production.product

/* 8 */
SELECT
  productid,
  name,
  listprice,
  standardcost,
  listprice - standardcost AS margin,
  (listprice - standardcost) / NULLIF(listprice, 0) AS margin_rate
FROM production.product

/* 9 */
SELECT DISTINCT country
FROM sales.store

/* 10 */
SELECT DISTINCT city, country
FROM sales.store
ORDER BY country, city

/* 11 */
SELECT 
    productid, 
    name, 
    listprice 
FROM production.product 
ORDER BY listprice DESC;

/* 12 */
SELECT 
  productid, 
  name, 
  listprice, 
  listprice * 0.85 AS discounted_price
FROM production.product
ORDER BY discounted_price DESC;

/* 13 */
SELECT storename, city, country FROM sales.store ORDER BY country, city, storename;

/* 14 */
SELECT name, listprice, 'product' AS object_type FROM production.product LIMIT 25;

/* 15 */
SELECT p.productid, p.name, p.listprice, p.standardcost FROM production.product AS p ORDER BY 2;