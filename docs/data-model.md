# Data Model

This document describes the Power BI data model used in the **E-commerce Funnel & Sales Analysis** report, generated directly from the model's exported metadata (tables, columns, measures, and relationships).

## Model Overview

The model is a **star schema** built around five core tables loaded from the source database (`website_sessions`, `website_pageviews`, `orders`, `order_items`, `products`), one calculated dimension table (`Customers`), a single centralized measures table (`_Measures`), six **disconnected, pre-aggregated SQL-view tables** used directly in visuals, and five **disconnected field-parameter selector tables** that drive dynamic toggle visuals.

## Core Tables (loaded from source)

### `website_sessions`

| Column                        | Type         | Source / Notes                                                                                           |
| ----------------------------- | ------------ | -------------------------------------------------------------------------------------------------------- |
| `website_session_id`          | Whole Number | Primary key                                                                                              |
| `created_at`                  | Date/Time    | Session start timestamp                                                                                  |
| `user_id`                     | Whole Number | Links to `Customers` (via `orders`)                                                                      |
| `is_repeat_session`           | Whole Number | 0/1 flag for repeat sessions                                                                             |
| `utm_source`                  | Text         | Campaign source parameter                                                                                |
| `utm_campaign`                | Text         | Campaign name parameter                                                                                  |
| `utm_content`                 | Text         | Campaign content/ad parameter                                                                            |
| `device_type`                 | Text         | Desktop / Mobile                                                                                         |
| `http_referer`                | Text         | Referring URL                                                                                            |
| `visited_pageviews` _(calc.)_ | Whole Number | `CALCULATE(COUNT(website_pageviews[website_pageview_id]))` — pageviews in the session                    |
| `Traffic Type` _(calc.)_      | Text         | Classifies the session as Paid, Organic, Direct, Referral, etc. based on `utm_source` and `http_referer` |
| `Session Duration` _(calc.)_  | Decimal      | Time between the session's first and last pageview                                                       |
| `Through Billing` _(calc.)_   | Whole Number | Flags which billing page variant (if any) the session reached                                            |
| `Through Landing` _(calc.)_   | Whole Number | Flags which landing page variant the session reached                                                     |

### `website_pageviews`

| Column                        | Type         | Source / Notes                                                                   |
| ----------------------------- | ------------ | -------------------------------------------------------------------------------- |
| `website_pageview_id`         | Whole Number | Primary key                                                                      |
| `created_at`                  | Date/Time    | Pageview timestamp                                                               |
| `website_session_id`          | Whole Number | Links to `website_sessions`                                                      |
| `pageview_url`                | Text         | Raw URL visited                                                                  |
| `pageview_category` _(calc.)_ | Text         | Groups `pageview_url` into funnel stages (landing, product, cart, billing, etc.) |
| `Day Name` _(calc.)_          | Text         | `FORMAT(website_pageviews[created_at], "ddd")`                                   |
| `Hour` _(calc.)_              | Whole Number | `HOUR(website_pageviews[created_at])` — powers the weekly traffic heatmap        |

### `orders`

| Column               | Type         | Source / Notes              |
| -------------------- | ------------ | --------------------------- |
| `order_id`           | Whole Number | Primary key                 |
| `created_at`         | Date/Time    | Order timestamp             |
| `website_session_id` | Whole Number | Links to `website_sessions` |
| `user_id`            | Whole Number | Links to `Customers`        |
| `primary_product_id` | Whole Number | The order's primary product |
| `items_purchased`    | Whole Number | Item count on the order     |
| `price_usd`          | Decimal      | Order revenue               |
| `cogs_usd`           | Decimal      | Order cost of goods sold    |

### `order_items`

| Column            | Type         | Source / Notes                                                      |
| ----------------- | ------------ | ------------------------------------------------------------------- |
| `order_item_id`   | Whole Number | Primary key                                                         |
| `created_at`      | Date/Time    | Line-item timestamp                                                 |
| `order_id`        | Whole Number | Links to `orders`                                                   |
| `product_id`      | Whole Number | Links to `products`                                                 |
| `is_primary_item` | Whole Number | 1 if this line item is the order's primary product, 0 if cross-sold |
| `price_usd`       | Decimal      | Line-item revenue                                                   |
| `cogs_usd`        | Decimal      | Line-item cost                                                      |

### `order_item_refunds`

| Column                 | Type         | Source / Notes                                                                          |
| ---------------------- | ------------ | --------------------------------------------------------------------------------------- |
| `order_item_refund_id` | Whole Number | Primary key                                                                             |
| `created_at`           | Date/Time    | Refund timestamp                                                                        |
| `order_item_id`        | Whole Number | Present on the table, but **not** used in an active model relationship (see note below) |
| `order_id`             | Whole Number | Links to `orders`                                                                       |
| `refund_amount_usd`    | Decimal      | Refund amount                                                                           |

### `products`

| Column         | Type         | Source / Notes                |
| -------------- | ------------ | ----------------------------- |
| `product_id`   | Whole Number | Primary key                   |
| `created_at`   | Date/Time    | Product creation/listing date |
| `product_name` | Text         | Product display name          |

### `Customers` _(calculated table)_

Built as a calculated table (one row per `user_id`) from `orders`, so lifetime and segmentation metrics are computed once rather than recalculated per visual.

| Column                  | Notes                                                                    |
| ----------------------- | ------------------------------------------------------------------------ |
| `user_id`               | Primary key                                                              |
| `First Order Date`      | Customer's earliest order date                                           |
| `Lifetime Order Count`  | Total distinct orders placed                                             |
| `Lifetime Revenue`      | Total revenue across all orders                                          |
| `Lifetime Profit`       | Total profit across all orders                                           |
| `Lifetime Segmentation` | Segment (e.g., Low/Medium/High) based on lifetime order count or revenue |
| `AOV`                   | Average order value for the customer                                     |
| `AOV Segmentation`      | Segment based on the customer's average order value                      |

## Relationships

| From                                    | Cardinality | To                                     | Active | Cross-filter        |
| --------------------------------------- | ----------- | -------------------------------------- | ------ | ------------------- |
| `order_items[order_id]`                 | Many → One  | `orders[order_id]`                     | ✅     | **Both directions** |
| `order_item_refunds[order_id]`          | Many → One  | `orders[order_id]`                     | ✅     | Single direction    |
| `orders[website_session_id]`            | Many → One  | `website_sessions[website_session_id]` | ✅     | Single direction    |
| `website_pageviews[website_session_id]` | Many → One  | `website_sessions[website_session_id]` | ✅     | Single direction    |
| `order_items[product_id]`               | Many → One  | `products[product_id]`                 | ✅     | Single direction    |
| `orders[user_id]`                       | Many → One  | `Customers[user_id]`                   | ✅     | Single direction    |

```
Customers (1) ──< orders (*) >── website_sessions (1) >── website_pageviews (*)
                      ∧
                      │ (both-direction)
                order_items (*)
                      │
                      ∨
                 products (1)

orders (1) ──< order_item_refunds (*)
```

**Note — `order_item_refunds` is not related to `order_items`:** the table carries an `order_item_id` column, but there is no active relationship built on it in the model; refunds only connect to the model through `order_id` → `orders`. If a report page needs refunds broken out at the line-item level, that relationship would need to be added explicitly.

**Note — `order_items` → `orders` is the only bidirectional relationship in the model.** Every other relationship filters in a single direction (dimension → fact). This bidirectional setting lets filters placed on `order_items` (e.g., filtering to cross-sold items only) flow back up to filter `orders`, `website_sessions`, and `Customers` — worth keeping in mind since it changes how slicers on product-level fields affect session- and customer-level totals elsewhere in the report.

## Measures (`_Measures` table)

All 32 DAX measures in the report live in a single centralized table, organized into display folders so they're easy to find in the Fields pane:

**Acquisition**

- `Unique Visitors` — `DISTINCTCOUNT(website_sessions[user_id])`
- `Total Sessions` — `COUNT(website_sessions[website_session_id])`
- `Conversion Rate` — distinct sessions with an order ÷ total sessions
- `Total Pageviews` — `COUNT(website_pageviews[website_pageview_id])`

**Engagement**

- `Avg Pages per Session` — `AVERAGE(website_sessions[visited_pageviews])`
- `Bounce Rate` — share of sessions with exactly 1 pageview
- `Avg Session Duration` — average of the `Session Duration` calculated column
- `Avg Session Duration Display` — formats `Avg Session Duration` as `mm:ss`

**E-commerce**

- `Avg Order Value`, `Total Orders`, `Total Revenue`, `Total Profit`, `Total COGS`
- `Refund Rate` — refunded line items ÷ total line items
- `Profit Margin`, `Profit per Order`

**Customer**

- `Unique Customers`, `Customer Lifetime Value`, `Customer Lifetime Profit`
- `Repeat Customers`, `One-Time Customers`, `Repeat Purchase Rate`

**Product**

- `Product Revenue`, `Product COGS`, `Product Profit`, `Product Margin`

**DivergingBarCharts** _(supports the desktop-vs-mobile diverging bar visual on the Channel & Device page)_

- `Desktop Conversion`, `Mobile Conversion (Positive)`, `Mobile Conversion (Negative)`, `Conversion Rate (Negative)`

**CrossSelling**

- `Primary` — count of order lines where `is_primary_item = 1`
- `Cross_selled` — count of order lines where `is_primary_item = 0`

## Disconnected SQL-View Tables (pre-aggregated, loaded from SQL views)

These tables are **not joined to the rest of the model** — they're loaded directly from pre-aggregated SQL views and used as self-contained data sources for specific visuals (field values, not measures over the star schema).

### `vw_ab_testing`

`experiment_id`, `experiment_name`, `test_type`, `control_page`, `variant_page`, `start_date`, `end_date`, `control_sessions`, `control_orders`, `control_cvr`, `variant_sessions`, `variant_orders`, `variant_cvr`, `cvr_difference`, `cvr_lift_percent`
→ Powers the A/B Testing page's test summary table and CVR uplift visuals.

### `vw_cross_selling`

`period`, `start_date`, `end_date`, `duration_days`, `orders`, `avg_order_value`, `total_revenue`, `total_profit`, `profit_per_order`, `avg_orders_per_day`, `avg_revenue_per_day`, `avg_profit_per_day`, `avg_orders_per_year`, `avg_revenue_per_year`, `avg_profit_per_year`
→ Powers the Cross-Selling page's before/after summary table.

### `vw_product_attachment`

`primary_product_id`, `primary_product`, `cross_sell_product_id`, `cross_sell_product`, `times_sold_together`, `primary_orders`, `attachment_rate`, `avg_extra_profit`, `total_extra_profit`
→ Powers the Product page's product-pairs attachment table.

### `vw_product_profit`

`product_id`, `product_name`, `orders`, `total_revenue`, `total_cogs`, `total_profit`, `margin_percent`, `profit_per_order`
→ Powers product-level profitability visuals (profit margin by product).

### `vw_new_vs_repeat`

`is_repeat_session`, `visitor_type`, `sessions`, `unique_customers`, `orders`, `conversion_rate`, `avg_order_value`, `total_revenue`, `total_profit`, `profit_per_order`
→ Powers new-vs-repeat session/customer comparison visuals.

### `vw_UtmSCC_referer_Device`

`utm_source`, `utm_campaign`, `utm_content`, `http_referer`, `device_type`, `sessions`, `orders`, `conversion_rate`, `avg_order_value`, `total_revenue`, `total_profit`, `profit_per_order`
→ All columns are hidden; used as backing data for a visual without exposing the raw fields directly in the Fields pane.

## Selector Tables (disconnected — field parameters)

Each follows the standard Power BI field-parameter pattern: a visible display-name column plus two hidden columns (`Fields`, `Order`) that control which measure/field is shown and in what order.

| Table                             | Purpose                                                                |
| --------------------------------- | ---------------------------------------------------------------------- |
| `Revenue-Conversion_Selector`     | Toggles visuals between Revenue and Conversion Rate                    |
| `Order_Revenue_Selector_Types`    | Toggles visuals between Orders and Revenue                             |
| `Orders_Revenue_Selector_product` | Toggles Product Analysis visuals between Orders and Revenue by product |
| `Device_TrafficType_Selector`     | Toggles the Channel & Device page between Device and Channel views     |
| `Segmentation_Selector`           | Toggles the Customer Analysis page between segmentation views          |

## Design Notes

- **`Customers` is a calculated table**, built once at refresh time from `orders` — this keeps lifetime value, order count, and both segmentation columns (`Lifetime Segmentation` by order count/revenue, `AOV Segmentation` by average order value) consistent across every report page without per-visual `ALL()` logic.
- **All 32 measures live in one `_Measures` table**, organized by `DisplayFolder` (Acquisition, Engagement, E-commerce, Customer, Product, DivergingBarCharts, CrossSelling) rather than being split across several measure-only tables — this keeps the Fields pane grouped by business area while avoiding unnecessary extra tables in the model.
- **The disconnected SQL-view tables are intentionally not modeled as facts/dimensions** — they're pre-aggregated at the SQL layer specifically to back certain visuals (A/B testing, cross-selling, product attachment, product profit, new-vs-repeat, and a hidden UTM/referrer/device summary) without adding join complexity to the core star schema.
- **Selector tables must stay disconnected** — they exist purely to drive field-parameter toggle visuals and should never be related to a fact or dimension table.
- **Only one relationship in the model is bidirectional** (`order_items` ↔ `orders`); every other relationship is single-direction. Keep this in mind when debugging unexpected filter propagation from product-level slicers.
- **`order_item_refunds` has no relationship to `order_items`** despite carrying an `order_item_id` column — refunds can currently only be filtered/sliced at the order level, not the line-item level.
