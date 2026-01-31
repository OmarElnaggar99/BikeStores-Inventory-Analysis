-- BikeStores SQL Assignment (Curated & Cleaned)
-- Author: Omar M. Elnaggar
-- Notes: Each question includes the intended grain and avoids accidental row multiplication.
USE BikeStore;
GO

-- 1) Products with brand and category (grain: 1 row per product)
SELECT
    pp.product_id,
    pp.product_name,
    pb.brand_name,
    pc.category_name
FROM production.products pp
JOIN production.brands pb ON pp.brand_id = pb.brand_id
JOIN production.categories pc ON pp.category_id = pc.category_id;

-- 2) Total number of products in each category (catalog count; grain: 1 row per category)
SELECT
    pc.category_name,
    COUNT(pp.product_id) AS product_count
FROM production.products pp
JOIN production.categories pc ON pp.category_id = pc.category_id
GROUP BY pc.category_name
ORDER BY product_count DESC;

-- 3) Products priced above $500 with brand and category (grain: 1 row per product)
SELECT
    pp.product_name,
    pb.brand_name,
    pc.category_name,
    pp.model_year,
    pp.list_price
FROM production.products pp
JOIN production.brands pb ON pp.brand_id = pb.brand_id
JOIN production.categories pc ON pp.category_id = pc.category_id
WHERE pp.list_price > 500
ORDER BY pp.list_price DESC;

-- 4) Average price per brand (grain: 1 row per brand)
SELECT
    b.brand_id,
    b.brand_name,
    AVG(p.list_price) AS avg_price
FROM production.products p
JOIN production.brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_id, b.brand_name
ORDER BY avg_price DESC;

-- 5) Most expensive product in each category
-- 5.1) Window function approach (ROW_NUMBER: returns exactly 1 row per category; ties broken arbitrarily unless secondary sort added)
WITH ranked_products AS (
    SELECT
        pc.category_id,
        pc.category_name,
        pp.product_id,
        pp.product_name,
        pb.brand_name,
        pp.model_year,
        pp.list_price,
        ROW_NUMBER() OVER (
            PARTITION BY pc.category_id
            ORDER BY pp.list_price DESC, pp.product_id ASC
        ) AS rn
    FROM production.products pp
    JOIN production.categories pc ON pp.category_id = pc.category_id
    JOIN production.brands pb ON pp.brand_id = pb.brand_id
)
SELECT
    category_name,
    product_name,
    brand_name,
    model_year,
    list_price
FROM ranked_products
WHERE rn = 1
ORDER BY list_price DESC;

-- 5.2) Correlated subquery approach (returns multiple rows per category if max price ties)
SELECT
    pc.category_name,
    pp.product_name,
    pb.brand_name,
    pp.model_year,
    pp.list_price
FROM production.products pp
JOIN production.categories pc ON pp.category_id = pc.category_id
JOIN production.brands pb ON pp.brand_id = pb.brand_id
WHERE pp.list_price = (
    SELECT MAX(p2.list_price)
    FROM production.products p2
    WHERE p2.category_id = pp.category_id
)
ORDER BY pp.list_price DESC;

-- 6) Categories with no associated products (anti-join; grain: 1 row per empty category)
SELECT
    pc.category_id,
    pc.category_name
FROM production.categories pc
LEFT JOIN production.products pp ON pc.category_id = pp.category_id
WHERE pp.product_id IS NULL;

-- 7) Top 3 most expensive products with brand and category (WITH TIES includes price ties at the cutoff)
SELECT TOP (3) WITH TIES
    pp.product_name,
    pb.brand_name,
    pc.category_name,
    pp.model_year,
    pp.list_price
FROM production.products pp
JOIN production.brands pb ON pp.brand_id = pb.brand_id
JOIN production.categories pc ON pp.category_id = pc.category_id
ORDER BY pp.list_price DESC;

-- 8) Percent of total products contributed by each brand (grain: 1 row per brand)
WITH counts AS (
    SELECT
        pb.brand_id,
        pb.brand_name,
        COUNT(pp.product_id) AS product_count
    FROM production.products pp
    JOIN production.brands pb ON pp.brand_id = pb.brand_id
    GROUP BY pb.brand_id, pb.brand_name
)
SELECT
    brand_name,
    product_count,
    100.0 * product_count / SUM(product_count) OVER () AS pct_of_all_products
FROM counts
ORDER BY pct_of_all_products DESC;

-- 9) Products that appear in multiple categories (data quality check; may return 0 rows if product_id is unique)
SELECT
    pp.product_name,
    COUNT(DISTINCT pp.category_id) AS category_count
FROM production.products pp
GROUP BY pp.product_name
HAVING COUNT(DISTINCT pp.category_id) > 1
ORDER BY category_count DESC, pp.product_name;

-- 10) Products introduced after 2018, with category-level count (window count on filtered set)
SELECT
    pc.category_name,
    pp.product_name,
    pp.model_year,
    pp.list_price,
    COUNT(*) OVER (PARTITION BY pc.category_id) AS new_products_in_category
FROM production.products pp
JOIN production.categories pc ON pp.category_id = pc.category_id
WHERE pp.model_year > 2018
ORDER BY pp.list_price DESC;
