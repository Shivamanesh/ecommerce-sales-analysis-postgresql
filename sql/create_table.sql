CREATE TABLE ecommerce_sales (
    order_id INTEGER 
            PRIMARY KEY,
    order_date DATE 
             NOT NULL,
    customer_id INTEGER 
             NOT NULL,
    product_category VARCHAR(50) 
            NOT NULL,
    region VARCHAR(50) 
            NOT NULL,
    quantity INTEGER 
            NOT NULL
            CHECK(quantity > 0),
    unit_price NUMERIC(10, 2)
            NOT NULL
            CEHCK(unit_price >= 0),
    discount NUMERIC(4, 2)
            NOT NULL
            CHECK(discount BETWEEN 0 and 1),
    payment_method VARCHAR(50)
            NOT NULL,
    delivery_days INTEGER
            NOT NULL
            CHECK(delivery_days >= 0),
    customer_rating NUMERIC(2,1)
            CHECK(customer_rating BETWEEN 1 AND 5),
    revenue NUMERIC(10, 2)
            NOT NULL
            CHECK(revenue >= 0)
);