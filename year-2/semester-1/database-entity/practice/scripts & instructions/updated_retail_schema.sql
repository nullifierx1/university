-- =========================================================
-- Учебный пример более строгой реляционной схемы для PostgreSQL
-- Изменения по сравнению с исходным вариантом:
-- 1) Добавлены IDENTITY-ключи
-- 2) Заменён MONEY на NUMERIC(19,4)
-- 3) Добавлены UNIQUE и CHECK ограничения
-- 4) Уточнены NULL / NOT NULL
-- 5) Добавлены новые сущности:
--    - sales.store             : магазин
--    - sales.posterminal       : кассовый POS-терминал
--    - inventory.storeinventory: остатки товара в магазине
-- =========================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS production;
CREATE SCHEMA IF NOT EXISTS sales;
CREATE SCHEMA IF NOT EXISTS person;
CREATE SCHEMA IF NOT EXISTS inventory;

-- =========================================================
-- PERSON
-- =========================================================

CREATE TABLE person.person (
    personid            BIGINT GENERATED ALWAYS AS IDENTITY,
    firstname           VARCHAR(100) NOT NULL,
    middlename          VARCHAR(100),
    lastname            VARCHAR(100) NOT NULL,
    emailaddress        VARCHAR(255),
    phone               VARCHAR(30),
    rowguid             UUID NOT NULL DEFAULT gen_random_uuid(),
    modifieddate        TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT pk_person_person PRIMARY KEY (personid),
    CONSTRAINT uq_person_person_rowguid UNIQUE (rowguid),
    CONSTRAINT uq_person_person_emailaddress UNIQUE (emailaddress)
);

-- =========================================================
-- PRODUCTION
-- =========================================================

CREATE TABLE production.productcategory (
    productcategoryid   BIGINT GENERATED ALWAYS AS IDENTITY,
    name                VARCHAR(100) NOT NULL,
    rowguid             UUID NOT NULL DEFAULT gen_random_uuid(),
    modifieddate        TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT pk_productcategory PRIMARY KEY (productcategoryid),
    CONSTRAINT uq_productcategory_name UNIQUE (name),
    CONSTRAINT uq_productcategory_rowguid UNIQUE (rowguid)
);

CREATE TABLE production.productsubcategory (
    productsubcategoryid BIGINT GENERATED ALWAYS AS IDENTITY,
    productcategoryid    BIGINT NOT NULL,
    name                 VARCHAR(100) NOT NULL,
    rowguid              UUID NOT NULL DEFAULT gen_random_uuid(),
    modifieddate         TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT pk_productsubcategory PRIMARY KEY (productsubcategoryid),
    CONSTRAINT uq_productsubcategory_category_name UNIQUE (productcategoryid, name),
    CONSTRAINT uq_productsubcategory_rowguid UNIQUE (rowguid),
    CONSTRAINT fk_productsubcategory_productcategory
        FOREIGN KEY (productcategoryid)
        REFERENCES production.productcategory (productcategoryid)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE production.product (
    productid            BIGINT GENERATED ALWAYS AS IDENTITY,
    name                 VARCHAR(255) NOT NULL,
    productnumber        VARCHAR(50) NOT NULL,
    color                VARCHAR(50),
    standardcost         NUMERIC(19,4) NOT NULL,
    listprice            NUMERIC(19,4) NOT NULL,
    size                 VARCHAR(10),
    weight               NUMERIC(10,3),
    class                CHAR(2),
    style                CHAR(2),
    productsubcategoryid BIGINT NOT NULL,
    sellstartdate        TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    sellenddate          TIMESTAMP,
    discontinueddate     TIMESTAMP,
    isactive             BOOLEAN NOT NULL DEFAULT TRUE,
    rowguid              UUID NOT NULL DEFAULT gen_random_uuid(),
    modifieddate         TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT pk_product PRIMARY KEY (productid),
    CONSTRAINT uq_product_productnumber UNIQUE (productnumber),
    CONSTRAINT uq_product_rowguid UNIQUE (rowguid),
    CONSTRAINT ck_product_standardcost_nonnegative CHECK (standardcost >= 0),
    CONSTRAINT ck_product_listprice_nonnegative CHECK (listprice >= 0),
    CONSTRAINT ck_product_weight_nonnegative CHECK (weight IS NULL OR weight >= 0),
    CONSTRAINT ck_product_sell_dates CHECK (sellenddate IS NULL OR sellenddate >= sellstartdate),
    CONSTRAINT ck_product_discontinued_date CHECK (discontinueddate IS NULL OR discontinueddate >= sellstartdate),
    CONSTRAINT fk_product_productsubcategory
        FOREIGN KEY (productsubcategoryid)
        REFERENCES production.productsubcategory (productsubcategoryid)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- =========================================================
-- SALES: STORE / TERMINAL / CUSTOMER / ORDERS
-- =========================================================

CREATE TABLE sales.store (
    storeid              BIGINT GENERATED ALWAYS AS IDENTITY,
    storename            VARCHAR(200) NOT NULL,
    storecode            VARCHAR(30) NOT NULL,
    addressline1         VARCHAR(255) NOT NULL,
    addressline2         VARCHAR(255),
    city                 VARCHAR(100) NOT NULL,
    postalcode           VARCHAR(20),
    country              VARCHAR(100) NOT NULL DEFAULT 'Germany',
    isactive             BOOLEAN NOT NULL DEFAULT TRUE,
    openeddate           DATE,
    rowguid              UUID NOT NULL DEFAULT gen_random_uuid(),
    modifieddate         TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT pk_store PRIMARY KEY (storeid),
    CONSTRAINT uq_store_storecode UNIQUE (storecode),
    CONSTRAINT uq_store_rowguid UNIQUE (rowguid)
);

CREATE TABLE sales.posterminal (
    posterminalid        BIGINT GENERATED ALWAYS AS IDENTITY,
    storeid              BIGINT NOT NULL,
    terminalcode         VARCHAR(30) NOT NULL,
    serialnumber         VARCHAR(100),
    modelname            VARCHAR(100),
    installedat          TIMESTAMP,
    lastservicedat       TIMESTAMP,
    isactive             BOOLEAN NOT NULL DEFAULT TRUE,
    rowguid              UUID NOT NULL DEFAULT gen_random_uuid(),
    modifieddate         TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT pk_posterminal PRIMARY KEY (posterminalid),
    CONSTRAINT uq_posterminal_store_terminalcode UNIQUE (storeid, terminalcode),
    CONSTRAINT uq_posterminal_serialnumber UNIQUE (serialnumber),
    CONSTRAINT uq_posterminal_rowguid UNIQUE (rowguid),
    CONSTRAINT ck_posterminal_service_date CHECK (
        lastservicedat IS NULL OR installedat IS NULL OR lastservicedat >= installedat
    ),
    CONSTRAINT fk_posterminal_store
        FOREIGN KEY (storeid)
        REFERENCES sales.store (storeid)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE sales.customer (
    customerid           BIGINT GENERATED ALWAYS AS IDENTITY,
    personid             BIGINT,
    customertype         CHAR(1) NOT NULL DEFAULT 'R',
    accountnumber        VARCHAR(30) NOT NULL,
    isactive             BOOLEAN NOT NULL DEFAULT TRUE,
    createdat            TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    rowguid              UUID NOT NULL DEFAULT gen_random_uuid(),
    modifieddate         TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT pk_customer PRIMARY KEY (customerid),
    CONSTRAINT uq_customer_accountnumber UNIQUE (accountnumber),
    CONSTRAINT uq_customer_personid UNIQUE (personid),
    CONSTRAINT uq_customer_rowguid UNIQUE (rowguid),
    CONSTRAINT ck_customer_customertype CHECK (customertype IN ('R','W')),
    CONSTRAINT fk_customer_person
        FOREIGN KEY (personid)
        REFERENCES person.person (personid)
        ON UPDATE RESTRICT
        ON DELETE SET NULL
);

CREATE TABLE sales.salesorderheader (
    salesorderid         BIGINT GENERATED ALWAYS AS IDENTITY,
    customerid           BIGINT,
    posterminalid        BIGINT NOT NULL,
    orderdate            TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    status               SMALLINT NOT NULL DEFAULT 1,
    paymentmethod        VARCHAR(20) NOT NULL DEFAULT 'CARD',
    subtotal             NUMERIC(19,4) NOT NULL DEFAULT 0,
    taxamt               NUMERIC(19,4) NOT NULL DEFAULT 0,
    freight              NUMERIC(19,4) NOT NULL DEFAULT 0,
    totaldue             NUMERIC(19,4) GENERATED ALWAYS AS (subtotal + taxamt + freight) STORED,
    comment              VARCHAR(255),
    rowguid              UUID NOT NULL DEFAULT gen_random_uuid(),
    modifieddate         TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT pk_salesorderheader PRIMARY KEY (salesorderid),
    CONSTRAINT uq_salesorderheader_rowguid UNIQUE (rowguid),
    CONSTRAINT ck_salesorderheader_status CHECK (status IN (1, 2, 3, 4, 5)),
    CONSTRAINT ck_salesorderheader_paymentmethod CHECK (
        paymentmethod IN ('CARD', 'CASH', 'MIXED', 'ONLINE')
    ),
    CONSTRAINT ck_salesorderheader_subtotal_nonnegative CHECK (subtotal >= 0),
    CONSTRAINT ck_salesorderheader_taxamt_nonnegative CHECK (taxamt >= 0),
    CONSTRAINT ck_salesorderheader_freight_nonnegative CHECK (freight >= 0),
    CONSTRAINT fk_salesorderheader_customer
        FOREIGN KEY (customerid)
        REFERENCES sales.customer (customerid)
        ON UPDATE RESTRICT
        ON DELETE SET NULL,
    CONSTRAINT fk_salesorderheader_posterminal
        FOREIGN KEY (posterminalid)
        REFERENCES sales.posterminal (posterminalid)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

CREATE TABLE sales.salesorderdetail (
    salesorderdetailid   BIGINT GENERATED ALWAYS AS IDENTITY,
    salesorderid         BIGINT NOT NULL,
    productid            BIGINT NOT NULL,
    orderqty             INTEGER NOT NULL,
    unitprice            NUMERIC(19,4) NOT NULL,
    unitpricediscount    NUMERIC(5,4) NOT NULL DEFAULT 0,
    linetotal            NUMERIC(19,4) GENERATED ALWAYS AS (
                            orderqty * unitprice * (1 - unitpricediscount)
                         ) STORED,
    rowguid              UUID NOT NULL DEFAULT gen_random_uuid(),
    modifieddate         TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT pk_salesorderdetail PRIMARY KEY (salesorderdetailid),
    CONSTRAINT uq_salesorderdetail_rowguid UNIQUE (rowguid),
    CONSTRAINT ck_salesorderdetail_orderqty_positive CHECK (orderqty > 0),
    CONSTRAINT ck_salesorderdetail_unitprice_nonnegative CHECK (unitprice >= 0),
    CONSTRAINT ck_salesorderdetail_discount_range CHECK (
        unitpricediscount >= 0 AND unitpricediscount <= 1
    ),
    CONSTRAINT fk_salesorderdetail_salesorderheader
        FOREIGN KEY (salesorderid)
        REFERENCES sales.salesorderheader (salesorderid)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT fk_salesorderdetail_product
        FOREIGN KEY (productid)
        REFERENCES production.product (productid)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- =========================================================
-- INVENTORY
-- =========================================================

CREATE TABLE inventory.storeinventory (
    storeinventoryid     BIGINT GENERATED ALWAYS AS IDENTITY,
    storeid              BIGINT NOT NULL,
    productid            BIGINT NOT NULL,
    quantityonhand       NUMERIC(14,3) NOT NULL DEFAULT 0,
    reorderpoint         NUMERIC(14,3) NOT NULL DEFAULT 0,
    safetystocklevel     NUMERIC(14,3) NOT NULL DEFAULT 0,
    laststocktakeat      TIMESTAMP,
    rowguid              UUID NOT NULL DEFAULT gen_random_uuid(),
    modifieddate         TIMESTAMP NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT pk_storeinventory PRIMARY KEY (storeinventoryid),
    CONSTRAINT uq_storeinventory_store_product UNIQUE (storeid, productid),
    CONSTRAINT uq_storeinventory_rowguid UNIQUE (rowguid),
    CONSTRAINT ck_storeinventory_quantity_nonnegative CHECK (quantityonhand >= 0),
    CONSTRAINT ck_storeinventory_reorderpoint_nonnegative CHECK (reorderpoint >= 0),
    CONSTRAINT ck_storeinventory_safetystocklevel_nonnegative CHECK (safetystocklevel >= 0),
    CONSTRAINT ck_storeinventory_reorder_vs_safety CHECK (safetystocklevel >= reorderpoint),
    CONSTRAINT fk_storeinventory_store
        FOREIGN KEY (storeid)
        REFERENCES sales.store (storeid)
        ON UPDATE RESTRICT
        ON DELETE CASCADE,
    CONSTRAINT fk_storeinventory_product
        FOREIGN KEY (productid)
        REFERENCES production.product (productid)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- =========================================================
-- Комментарии по модели
-- =========================================================
-- 1. customerid в salesorderheader допускает NULL:
--    это позволяет хранить "анонимные" розничные продажи.
-- 2. POS-терминал обязателен для каждого заказа.
-- 3. Остатки товара хранятся отдельно по каждому магазину.
-- 4. Итоги строки заказа и шапки заказа заданы как STORED GENERATED.
-- 5. Индексы намеренно не создаются, так как это было отдельно оговорено.
