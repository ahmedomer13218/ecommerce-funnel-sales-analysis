# Power BI Report

This folder contains the Power BI report screenshots for the **E-commerce Funnel & Sales Analysis** project.

## Report File

Contact me on linkedIn if you want the .pbix file

## Data Source

The report connects to a SQL Server database (`MavenFuzzyFactory`) built from the Maven Analytics Toy Store E-commerce dataset. See the main project [README](../README.md) and [`sql/`](../sql/) folder for the data-loading and view-creation scripts this report depends on.

## Data Model

The report uses a star schema with `orders` and `order_items` as the core fact tables, `website_sessions` and `website_pageviews` capturing on-site behavior, and `products` / `Customers` as dimension tables, plus disconnected measure and selector tables for dynamic, user-togglable visuals.

See [`docs/data-model.md`](../docs/data-model.md) for the full table-by-table breakdown, relationship diagram, and design notes.

## Measures

Measures are grouped by analytical area to keep the Fields pane organized:

See [`docs/data-model.md`](../docs/data-model.md) for more details

## Report Pages

| Page                 | What it shows                                                                                                                                                                                                    |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Overview**         | Headline KPIs (revenue, profit, orders, conversion rate, AOV), conversion rate by traffic type, sessions/orders over time, revenue by product, orders seasonality, and orders/revenue by device & channel        |
| **Traffic**          | Site-wide KPIs (unique visitors, pageviews, sessions, session duration, bounce rate), pages viewed per session, website sessions trend, top landing pages, conversion funnel, and weekly traffic pattern heatmap |
| **Customer**         | Unique vs. repeat customers over time, repeat purchase rate, customer lifetime value, AOV by customer segment, customer source (device/channel), and revenue distribution by segment                             |
| **Product**          | Seasonality by product, product pairs attachment table, refund rate by product, profit margin by product, product orders & revenue, and a full product summary table                                             |
| **Cross-Selling**    | Primary vs. cross-sold orders by year, average orders/order value before and after the cross-sell launch date, organic growth trend vs. observed cross-selling effect, and a full before/after summary table     |
| **A/B Testing**      | Conversion rate over time with test start/end markers, a full test summary table (control vs. variant, CVR uplift), and detailed funnel comparisons for the billing and landing page tests                       |
| **Channel & Device** | Device and channel trend over time, sessions/orders/conversion rate/revenue/AOV by channel and device (with a Device/Channel toggle), and a combined Channel × Device performance table                          |

All pages share the same navigation sidebar and support cross-filtering; several visuals use field-parameter toggles (e.g., switching between Device and Channel views, or Orders and Revenue) rather than separate static visuals.

## Screenshots

| File                              | Page             |
| --------------------------------- | ---------------- |
| `screenshots/Overview.png`        | Overview         |
| `screenshots/Traffic.png`         | Traffic          |
| `screenshots/Customer.png`        | Customer         |
| `screenshots/Product.png`         | Product          |
| `screenshots/Cross-Selling.png`   | Cross-Selling    |
| `screenshots/AB-Testing.png`      | A/B Testing      |
| `screenshots/Channel&Devices.png` | Channel & Device |

## Known Limitations

- The data reflects a fixed historical window from the source dataset; there is no live/real-time connection.
- Field-parameter selector tables (e.g., `Segmentation_Selector`, `Revenue-Conversion_Selector`) are intentionally disconnected from the data model and exist only to drive toggle visuals — do not relate them to fact or dimension tables.
- See the main project [README](../README.md#limitations--interpretation-notes) for interpretation notes on the Cross-Selling and A/B Testing pages specifically, since both involve before/after or control/variant comparisons that have not been tested for statistical significance.
