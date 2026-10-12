# E-commerce Funnel & Sales Analysis

An end-to-end business intelligence project analyzing e-commerce website traffic, conversion behavior, sales performance, product attachment, cross-selling, and A/B test results using **SQL Server** and **Power BI**.

> **Project status:** Portfolio project. Add your final dashboard screenshots and Power BI report file before publishing. Only include findings and numerical results that you have validated in your analysis.

## Project Overview

The goal of this project is to turn raw e-commerce data into a structured analytical solution that helps explore website performance and business outcomes.

The workflow covers data validation in SQL Server, analytical SQL queries and reusable views, Power Query transformations, dimensional modeling, DAX measures, and an interactive multi-page Power BI report.

## Data Source

The dataset was obtained from Maven Analytics' Data Playground:

- [Toy Store E-commerce Database — Maven Analytics](https://mavenanalytics.io/data-playground/toy-store-e-commerce-database)

**Before publishing:** Verify that this source URL matches the data actually used in the project. The current SQL scripts reference tables such as `website_sessions`, `website_pageviews`, `orders`, `order_items`, `order_item_refunds`, and `products`, and the analysis script uses a database named `MavenFuzzyFactory`. Make sure the source attribution and database naming accurately describe your files and dataset.

Please follow the dataset's license and sharing terms. Do not commit private, restricted, or unnecessarily large raw data files.

## Tools & Technologies

- **SQL Server** — data-quality checks, KPI calculations, segmentation, traffic and product analysis, cross-selling analysis, and A/B test analysis
- **Power BI** — interactive reporting and dashboard development
- **Power Query (M)** — data transformation and preparation
- **DAX** — measures and business KPIs
- **Dimensional modeling** — star schema design

## Project Workflow

1. **Data loading:** Loaded the source tables into a SQL Server database.
2. **Data-quality checks:** Wrote SQL checks for invalid or unexpected prices and costs, product IDs outside the expected range, distinct traffic-source/referrer values, page-view URL values, page views occurring before session creation, and non-positive refund amounts.
3. **SQL analysis:** Queried website, traffic, customer-session, order, refund, and product data to calculate KPIs and investigate business questions.
4. **Reusable SQL views:** Prepared analysis outputs for Power BI, including product attachment, cross-selling, and A/B testing. Add the corresponding view-definition scripts to `sql/views/`.
5. **Power Query transformations:** Loaded the data into Power BI and performed additional preparation using the M language.
6. **Data modeling:** Designed a star schema to organize the reporting model.
7. **DAX measures:** Created measures grouped around acquisition, e-commerce performance, engagement, and other reporting needs.
8. **Dashboard development:** Built an interactive report with dedicated pages for different business areas.

## Dashboard Pages

The report is organized into the following analytical areas:

| Page                            | What it explores                                                                                                |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Overview**                    | High-level business KPIs and an overall view of e-commerce performance                                          |
| **Traffic Analysis**            | Weekly traffic patterns, conversion funnel, repeat-session behavior, and session engagement                     |
| **Customer Analysis**           | Customer/session segmentation and behavioral comparisons                                                        |
| **Product Analysis**            | Product performance, seasonality, product pairs, and product attachment                                         |
| **Cross-Selling Analysis**      | Before-and-after cross-selling comparisons, including order and revenue trends relative to the observed periods |
| **A/B Testing Analysis**        | Experiment duration, control-versus-variant conversion rates, conversion-rate differences, and uplift           |
| **Channels & Devices Analysis** | Traffic and performance trends by acquisition channel and device, including combined segment analysis           |

The report uses interactive visuals and dynamic filtering to support exploration across the different business dimensions.

## Repository Structure

```text
ecommerce-funnel-sales-analysis/
├── README.md
├── .gitignore
├── sql/
│   ├── DataCleaningCheck.sql
│   ├── SqlAnalysis.sql
│   └── Views_ForPBI.sql
├── powerbi/
│   ├── README.md
│   └── screenshots/
│       └── Overview.png
│       └── Traffic.png
│       └── Product.png
│       └── Customer.png
│       └── Cross-Selling.png
│       └── Channel&Devices.png
│       └── AB-Testing.png
└── docs/
    └── data-model.md
    └── data-model.png
    └── Maven Fuzzy Factory — Dashboard Insights.docx
```

## How to Explore This Project

1. Review `sql/DataCleaningCheck.sql` to see the data-quality validation queries.
2. Review `sql/SqlAnalysis.sql` for KPI, traffic, customer-session, product, cross-selling, and A/B test analyses.
3. Check `sql/Views_ForPBI.sql` for the reusable view definitions used by Power BI.
4. Review `powerbi/README.md` for dashboard access and report details.
5. Open the dashboard screenshots in `powerbi/screenshots/` to preview the report.

The SQL scripts are written for SQL Server. You may need to adjust database names or table names to match your local setup.

## Key Business Questions

- How much website traffic converts into orders, and where in the funnel (Landing Page → Products → Product Detail → Cart → Shipping → Billing → Thank You) does the biggest drop-off occur?
- How do conversion rate, average order value, revenue, and profit vary by traffic source (Google, Bing, Organic, Direct, Social) and by device (desktop vs. mobile)?
- Is there a meaningful conversion-rate gap between desktop and mobile, and does it hold consistently across channels?
- How do repeat sessions and repeat customers compare with new/one-time sessions and customers in terms of volume and spend?
- Which products contribute most to revenue, order volume, and profit margin — and do the two rankings agree?
- Which product combinations are commonly purchased together, and how strong is the attachment rate between them?
- How did order volume, AOV, and revenue differ before and after cross-selling was introduced, relative to the pre-existing organic growth trend?
- Which tested landing or billing page variants had higher observed conversion rates, and by how much relative to their control?
- Does order volume follow a seasonal pattern across the year, and does that pattern hold across all products?

## Results & Insights

_(Values below reflect the project's dashboard output at time of writing — re-verify against the final published report before presenting externally, since these are observational, not causally tested, findings.)_

- **Overall funnel:** Of all sessions, 6.83% convert to an order. The steepest single drop in the funnel is from Product Detail (44.45%) to Cart (20.08%) — a ~24-point loss, larger than any other single funnel stage.
- **Bounce rate:** 44.76% of sessions leave after a single page — nearly half of all traffic never gets past the landing page.
- **Device gap:** Desktop drives 86.05% of all orders despite not dominating total traffic by nearly that margin, and it converts meaningfully better than mobile across every channel tested (e.g., Organic 9.96% desktop vs. 2.94% mobile; Direct 9.81% vs. 3.44%; Google 8.43% vs. 3.17%).
- **Channel concentration:** Google is the dominant channel at 66.02% of orders and ~$1.28M in revenue — more than 4x the next channel (Bing).
- **Product concentration:** The Original Mr. Fuzzy accounts for the large majority of order volume and revenue (24,226 of 32,313 total orders; ~$1.46M of ~$1.94M total revenue) but has the _lowest_ profit margin (62.03%) of the four products, while the lowest-volume product (Birthday Sugar Panda) has the _highest_ margin (66.16%).
- **Repeat behavior:** Of 31.7K unique customers, only 591 are repeat customers — a 1.86% repeat purchase rate. Revenue by customer segment is still volume-weighted: the "Low" revenue segment (20.0K customers) contributes 62.95% of total revenue, while the "High" segment (4.3K customers) contributes only 13.6%, despite having the highest AOV ($98.83 vs. $49.09 for Low).
- **Cross-selling before/after comparison:** Comparing the period before and after the cross-selling launch date (Sept 25, 2013), AOV rose from $51.09 to $62.59 and average annual order volume rose from roughly 5K to roughly 17K. This is an observational before-and-after comparison, not a controlled test — seasonality and overall site growth over the same period are confounding factors.
- **A/B tests:** Of 6 tested page variants, 2 showed a clear positive lift over control (`/billing-2` at +37.03% CVR lift; `/lander-5` at +29.55% CVR lift), 1 showed a small lift (+2.39%), and 3 underperformed control, including one substantial loss (`/lander-3` at −56.09%). No formal statistical significance testing has been documented for these comparisons yet.
- **Seasonality:** Order volume shows a consistent dip from January through April and a steady climb from August through December across all four products, suggesting the seasonal pattern is store-wide rather than product-specific.

## Selected Insights & Business Recommendations

The analyses are designed to connect observed website and product behavior to practical business questions. The following are the most relevant insight areas from the project. Validate the final values against the published dashboard and SQL output before presenting them as definitive findings.

### 1. Funnel drop-off is concentrated at Product Detail → Cart

The conversion funnel loses the largest share of sessions moving from Product Detail (44.45%) to Cart (20.08%) — a bigger drop than any other funnel stage, including the initial landing-page bounce.

**Recommendation:** Prioritize investigating the product detail page experience (page load speed, add-to-cart visibility, pricing clarity, trust signals) before optimizing earlier or later funnel stages, since this is where the largest share of otherwise-engaged visitors is lost.

### 2. A persistent desktop-vs-mobile conversion gap

Desktop out-converts mobile by a wide margin on every channel examined (roughly 3x on Organic, Direct, and Google), and this pattern repeats independently across the Overview, Traffic, and Channel & Device pages.

**Recommendation:** Treat mobile conversion as a priority optimization area rather than a one-off observation, since the gap holds consistently across channels rather than being isolated to one traffic source. Audit the mobile checkout flow specifically, since that is typically where friction compounds.

### 3. Landing-page and billing-page A/B test results

In the project's A/B test comparisons, `/lander-5` showed a conversion rate of 10.17% against a `/home` baseline of 7.85% (an observed +29.55% relative uplift), and `/billing-2` showed a Thank You completion rate of 62.04% against a `/billing` baseline of 45.29% (an observed +37.03% relative uplift). Conversely, `/lander-3` underperformed its baseline substantially (observed conversion of 3.39% vs. a baseline of 7.72%).

**Recommendation:** Investigate the content, traffic mix, and user journey associated with the stronger and weaker variants. Use properly defined, time-bounded A/B tests with comparable audiences and a documented significance method before declaring a winner or estimating revenue impact — the uplift percentages above describe what was observed, not a statistically validated effect.

### 4. Product attachment and cross-selling opportunities

The product-attachment analysis identifies which secondary products are purchased with each primary product and calculates attachment rate and additional profit. The strongest observed pairing is The Original Mr. Fuzzy + The Hudson River Mini Bear (sold together in a meaningful share of Mr. Fuzzy orders), while the highest attachment _rate_ belongs to the Birthday Sugar Panda + Hudson River Mini Bear pairing.

**Recommendation:** Use the strongest product pairs to form hypotheses for complementary-product recommendations or bundles. Evaluate any resulting test using attachment rate, average order value, and incremental profit — not revenue alone.

### 5. Product profitability, not revenue alone

The product analysis compares total profit, margin percentage, and profit per order, which surfaces a mismatch: the highest-revenue product (The Original Mr. Fuzzy) carries the lowest profit margin among the four products, while the lowest-volume product (Birthday Sugar Panda) carries the highest margin.

**Recommendation:** Use both revenue and profitability when prioritizing merchandising, promotions, and product placement. Check the impact on margin before scaling discounts or bundles involving the top-revenue product, since it already has the thinnest margin.

### 6. Refund rate varies meaningfully by product

Refund rates range from 3.61% (The Forever Love Bear) to 8.24% (Birthday Sugar Panda) — more than a 2x difference across products, against a blended site-wide refund rate of 4.32%.

**Recommendation:** Investigate whether the elevated refund rate on specific products reflects a quality, sizing, or expectation-setting issue (e.g., product photos/descriptions) before scaling marketing spend on that product.

### 7. Acquisition and device segmentation

The SQL analysis compares sessions, orders, conversion rate, average order value, revenue, and profit across traffic sources, campaigns, devices, referrers, and source-device combinations. The strongest single combination observed is Desktop + Google, which accounts for the largest share of both order volume and revenue of any channel/device pairing.

**Recommendation:** Investigate high-traffic segments with relatively low conversion (e.g., mobile across all channels) and profitable segments with room to grow (e.g., Social, which has a smaller order volume but the highest AOV observed). Use the segmented findings to guide further analysis and controlled marketing experiments rather than assuming a channel or device is best based on traffic volume alone.

### 8. Cross-selling before-and-after comparison

The cross-selling analysis compares order volume, average order value, revenue, profit, and daily/annualized averages before and after the selected cross-selling launch date (September 25, 2013). AOV increased from $51.09 to $62.59 and annualized order volume increased roughly 3.5x in the "after" period.

**Recommendation:** Compare normalized daily performance and account for seasonality and changes in traffic mix. Treat this as an observational before-and-after analysis; it does not isolate cross-selling as the sole cause of the change, since overall site growth was also accelerating over the same period.

## Screenshots

Add clear, readable screenshots of the Overview page and the most insightful analysis pages to `powerbi/screenshots/`. Use descriptive filenames such as:

- `overview.png`
- `traffic-analysis.png`
- `product-analysis.png`
- `cross-selling-analysis.png`
- `ab-testing-analysis.png`
- `channels-devices-analysis.png`

If you share a public Power BI report, add its link in `powerbi/README.md`. Do not publish confidential information or private credentials.

## Limitations & Interpretation Notes

- Before-and-after comparisons (e.g., cross-selling) can be affected by seasonality, traffic mix, and other changes; they do not establish that cross-selling alone caused a change.
- A higher observed A/B test conversion rate does not automatically mean a variant is statistically significant. Document the test design and statistical method if significance is assessed.
- The desktop-vs-mobile conversion gap is consistent across channels, but the underlying cause (page speed, checkout friction, device-specific UX) has not been isolated in this project and would require further investigation.
- Document assumptions, exclusions, date ranges, and KPI definitions so readers can interpret results correctly.

## Author

**[Your Name]**

- LinkedIn: [Add your LinkedIn profile]
- GitHub: [Add your GitHub profile]
