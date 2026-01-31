# BikeStores — SQL Product & Pricing Analysis (T‑SQL)

## Business question
BikeStores management needs a quick audit of the product catalog to understand pricing, catalog composition by brand/category, and to spot basic data quality issues (e.g., empty categories, products incorrectly mapped across categories).

## Stakeholders & decisions supported
- **Merchandising / Category Managers:** Identify premium products and category price ceilings (supports assortment strategy).
- **Pricing / Finance:** Compare average price positions by brand (supports pricing guardrails).
- **Data / BI:** Validate integrity checks (empty categories, duplicate category mappings).

## Dataset
- Sample database: **BikeStores** (schemas used: `production`, `sales`).

## What I delivered
A curated set of 10 SQL queries that answer common catalog questions:
1. Product list enriched with brand and category.
2. Product counts per category.
3. Products priced above $500 with details.
4. Average price per brand.
5. Most expensive product per category (2 approaches: `ROW_NUMBER()` and correlated subquery).
6. Categories with no products (anti-join).
7. Top 3 most expensive products (with ties).
8. Percent of total products contributed by each brand.
9. Data quality check: product names appearing in multiple categories.
10. Post‑2018 products with category-level counts (window function).

## Technical highlights
- Joins across dimensions (`brands`, `categories`) to keep the correct grain (one row per product).
- Window functions (`ROW_NUMBER()`, `COUNT() OVER`) for “top‑N per group” and “detail + aggregate” outputs.
- Anti-join pattern (`LEFT JOIN` + `IS NULL`) to find missing relationships.

## How to run
1. Open `01_bikestores_assignment_curated.sql` in SSMS / Azure Data Studio.
2. Ensure you have the BikeStores database restored.
3. Execute the script section by section (each query is independent).

## Validation checklist
- **Row counts:** Q1 should return exactly one row per product (no sales joins).
- **Tie behavior:** Q5.1 returns exactly one row per category; Q5.2 returns all ties.
- **Percent totals:** Q8 `pct_of_all_products` should sum to ~100% (floating point rounding expected).

## Next improvements
- Add inventory “available quantity” using `production.stocks` (different from “quantity sold” in `sales.order_items`).
- Add indexing notes / query plans for performance discussion.
