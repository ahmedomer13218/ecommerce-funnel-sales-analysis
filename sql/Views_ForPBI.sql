use MavenFuzzyFactory ;
-- /////////////////  Experiment definition table /////////////////

DROP TABLE IF EXISTS ab_tests;

CREATE TABLE ab_tests (
    experiment_id INT PRIMARY KEY,
    experiment_name VARCHAR(100),
    test_type VARCHAR(50),
    control_page VARCHAR(50),
    variant_page VARCHAR(50),
    start_date DATETIME2,
    end_date DATETIME2,
    outcome VARCHAR(20)
);

INSERT INTO ab_tests (
    experiment_id,
    experiment_name,
    test_type,
    control_page,
    variant_page,
    start_date,
    end_date,
    outcome
)
VALUES
-- Lander 1
(1, 'Home vs Lander 1', 'Landing Page',
 '/home', '/lander-1',
 '2012-06-19', '2013-03-10',
 'Positive'),

-- Lander 2
(2, 'Home vs Lander 2', 'Landing Page',
 '/home', '/lander-2',
 '2013-01-14', '2014-12-27',
 'Positive'),

-- Lander 3
(3, 'Home vs Lander 3', 'Landing Page',
 '/home', '/lander-3',
 '2013-07-09', '2015-03-19',
 'Negative'),

-- Lander 4
(4, 'Home vs Lander 4', 'Landing Page',
 '/home', '/lander-4',
 '2014-02-02', '2014-04-19',
 'Negative'),

-- Lander 5
(5, 'Home vs Lander 5', 'Landing Page',
 '/home', '/lander-5',
 '2014-08-02', '2015-03-19',
 'Positive'),

-- Billing 2
(6, 'Billing vs Billing 2', 'Billing Page',
 '/billing', '/billing-2',
 '2012-09-10', '2013-01-05',
 'Positive');



-- /////////////////  Create the metrics table /////////////////

DROP TABLE IF EXISTS ab_test_metrics;

CREATE TABLE ab_test_metrics
(
    metric_id INT IDENTITY(1,1) PRIMARY KEY,

    experiment_id INT NOT NULL,

    pageview_url VARCHAR(50) NOT NULL,

    sessions INT,

    orders INT,

    cvr DECIMAL(10,2),

    FOREIGN KEY (experiment_id)
        REFERENCES ab_tests(experiment_id)
);

WITH experiment_pageviews AS
(
    SELECT
        e.experiment_id,
        e.control_page,
        e.variant_page,
        wp.website_session_id,
        wp.pageview_url,
        wp.created_at
    FROM ab_tests e

    INNER JOIN website_pageviews wp
        ON wp.created_at >= e.start_date
        AND wp.created_at <= e.end_date

    WHERE wp.pageview_url IN
    (
        e.control_page,
        e.variant_page
    )
),

session_pages AS
(
    SELECT
        experiment_id,
        website_session_id,
        pageview_url,

        ROW_NUMBER() OVER
        (
            PARTITION BY
                experiment_id,
                website_session_id

            ORDER BY created_at
        ) AS rn

    FROM experiment_pageviews
),

assigned_sessions AS
(
    SELECT
        experiment_id,
        website_session_id,
        pageview_url

    FROM session_pages

    WHERE rn = 1
),

metrics AS
(
    SELECT
        s.experiment_id,
        s.pageview_url,

        COUNT(DISTINCT s.website_session_id) AS sessions,

        COUNT(DISTINCT o.order_id) AS orders

    FROM assigned_sessions s

    LEFT JOIN orders o
        ON s.website_session_id = o.website_session_id

    GROUP BY
        s.experiment_id,
        s.pageview_url
)

INSERT INTO ab_test_metrics
(
    experiment_id,
    pageview_url,
    sessions,
    orders,
    cvr
)

SELECT
    experiment_id,

    pageview_url,

    sessions,

    orders,

    ROUND(
        orders * 100.0 /
        NULLIF(sessions, 0),
        2
    ) AS cvr

FROM metrics;




-- ///////////////////////// AB testing View  //////////////////////

CREATE OR ALTER VIEW vw_ab_testing
AS

SELECT
    e.experiment_id,

    e.experiment_name,

    e.test_type,

    e.control_page,

    e.variant_page,

    e.start_date,

    e.end_date,

    control.sessions AS control_sessions,

    control.orders AS control_orders,

    control.cvr AS control_cvr,

    variant.sessions AS variant_sessions,

    variant.orders AS variant_orders,

    variant.cvr AS variant_cvr,

    ROUND(
        variant.cvr - control.cvr,
        2
    ) AS cvr_difference,

    ROUND(
        (variant.cvr - control.cvr)
        * 100.0
        / NULLIF(control.cvr, 0),
        2
    ) AS cvr_lift_percent

FROM ab_tests e

LEFT JOIN ab_test_metrics control
    ON e.experiment_id = control.experiment_id
    AND control.pageview_url = e.control_page

LEFT JOIN ab_test_metrics variant
    ON e.experiment_id = variant.experiment_id
    AND variant.pageview_url = e.variant_page;
GO



-- ///////////////////////// Cross-Selling View  //////////////////////

CREATE OR ALTER VIEW vw_cross_selling_analysis
AS

WITH period_data AS
(
    SELECT
        CASE
            WHEN o.created_at < '2013-09-25'
                THEN 'Before Cross-sell'
            ELSE 'After Cross-sell'
        END AS period,

        MIN(CAST(o.created_at AS DATE)) AS start_date,

        MAX(CAST(o.created_at AS DATE)) AS end_date,

        COUNT(DISTINCT o.order_id) AS orders,

        ROUND(
            AVG(o.price_usd),
            2
        ) AS avg_order_value,

        ROUND(
            SUM(o.price_usd),
            2
        ) AS total_revenue,

        ROUND(
            SUM(o.price_usd - o.cogs_usd),
            2
        ) AS total_profit

    FROM orders o

    GROUP BY
        CASE
            WHEN o.created_at < '2013-09-25'
                THEN 'Before Cross-sell'
            ELSE 'After Cross-sell'
        END
)

SELECT
    period,

    start_date,

    end_date,

    DATEDIFF(
        DAY,
        start_date,
        end_date
    ) + 1 AS duration_days,

    orders,

    avg_order_value,

    total_revenue,

    total_profit,

    ROUND(
        total_profit / NULLIF(orders, 0),
        2
    ) AS profit_per_order,

    -- Daily metrics

    ROUND(
        orders * 1.0 /
        NULLIF(
            DATEDIFF(DAY, start_date, end_date) + 1,
            0
        ),
        2
    ) AS avg_orders_per_day,

    ROUND(
        total_revenue * 1.0 /
        NULLIF(
            DATEDIFF(DAY, start_date, end_date) + 1,
            0
        ),
        2
    ) AS avg_revenue_per_day,

    ROUND(
        total_profit * 1.0 /
        NULLIF(
            DATEDIFF(DAY, start_date, end_date) + 1,
            0
        ),
        2
    ) AS avg_profit_per_day,

    -- Annualized metrics

    ROUND(
        orders * 365.0 /
        NULLIF(
            DATEDIFF(DAY, start_date, end_date) + 1,
            0
        ),
        2
    ) AS avg_orders_per_year,

    ROUND(
        total_revenue * 365.0 /
        NULLIF(
            DATEDIFF(DAY, start_date, end_date) + 1,
            0
        ),
        2
    ) AS avg_revenue_per_year,

    ROUND(
        total_profit * 365.0 /
        NULLIF(
            DATEDIFF(DAY, start_date, end_date) + 1,
            0
        ),
        2
    ) AS avg_profit_per_year

FROM period_data;
GO



-- ///////////////////////// Product Attachment View  //////////////////////

CREATE OR ALTER VIEW vw_product_attachment
AS

WITH primary_product_sales AS
(
    SELECT
        product_id,
        COUNT(DISTINCT order_id) AS primary_orders
    FROM order_items
    WHERE is_primary_item = 1
    GROUP BY product_id
),

attachment_data AS
(
    SELECT
        oi1.product_id AS primary_product_id,
        oi2.product_id AS cross_sell_product_id,

        COUNT(DISTINCT oi1.order_id) AS times_sold_together,

        AVG(
            oi2.price_usd - oi2.cogs_usd
        ) AS avg_extra_profit,

        SUM(
            oi2.price_usd - oi2.cogs_usd
        ) AS total_extra_profit

    FROM order_items oi1

    INNER JOIN order_items oi2
        ON oi1.order_id = oi2.order_id

    WHERE oi1.is_primary_item = 1
      AND oi2.is_primary_item = 0

    GROUP BY
        oi1.product_id,
        oi2.product_id
)

SELECT
    a.primary_product_id,

    p1.product_name AS primary_product,

    a.cross_sell_product_id,

    p2.product_name AS cross_sell_product,

    a.times_sold_together,

    ps.primary_orders,

    ROUND(
        a.times_sold_together * 100.0 /
        NULLIF(ps.primary_orders, 0),
        2
    ) AS attachment_rate,

    ROUND(
        a.avg_extra_profit,
        2
    ) AS avg_extra_profit,

    ROUND(
        a.total_extra_profit,
        2
    ) AS total_extra_profit

FROM attachment_data a

INNER JOIN products p1
    ON a.primary_product_id = p1.product_id

INNER JOIN products p2
    ON a.cross_sell_product_id = p2.product_id

INNER JOIN primary_product_sales ps
    ON a.primary_product_id = ps.product_id;
GO


-- ///////////////////////// UTM-SCC_referer_Device View  ////////////////////// we can consider it as aggregated table

CREATE OR ALTER VIEW vw_UtmSCC_referer_Device
AS
SELECT 
    ws.utm_source,
    ws.utm_campaign,
    ws.utm_content,
    ws.http_referer,
    ws.device_type,

    COUNT(DISTINCT ws.website_session_id) AS sessions,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0),
        2
    ) AS conversion_rate,

    ROUND(AVG(o.price_usd), 2) AS avg_order_value,

    ROUND(SUM(o.price_usd), 2) AS total_revenue,

    ROUND(SUM(o.price_usd - o.cogs_usd), 2) AS total_profit,

    ROUND(
        SUM(o.price_usd - o.cogs_usd)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS profit_per_order

FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

WHERE ws.utm_source IS NOT NULL

GROUP BY 
    ws.utm_source,
    ws.http_referer,
    ws.device_type,
    ws.utm_content,
    ws.utm_campaign;
GO

-- ///////////////////////// New_vs_Repeat_Analysis View  //////////////////////

CREATE OR ALTER VIEW vw_new_vs_repeat
AS
SELECT 
    ws.is_repeat_session,

    CASE
        WHEN ws.is_repeat_session = 1 THEN 'Repeat'
        ELSE 'New'
    END AS visitor_type,

    COUNT(DISTINCT ws.website_session_id) AS sessions,

    COUNT(DISTINCT ws.user_id) AS unique_customers,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0),
        2
    ) AS conversion_rate,

    ROUND(AVG(o.price_usd), 2) AS avg_order_value,

    ROUND(SUM(o.price_usd), 2) AS total_revenue,

    ROUND(SUM(o.price_usd - o.cogs_usd), 2) AS total_profit,

    ROUND(
        SUM(o.price_usd - o.cogs_usd)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS profit_per_order

FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

GROUP BY 
    ws.is_repeat_session;
GO
-- ///////////////////////// Product_Profit_Analysis View  //////////////////////
CREATE OR ALTER VIEW vw_product_profit
AS
SELECT 
    p.product_id,
    p.product_name,

    COUNT(DISTINCT oi.order_id) AS orders,

    SUM(oi.price_usd) AS total_revenue,

    SUM(oi.cogs_usd) AS total_cogs,

    SUM(oi.price_usd - oi.cogs_usd) AS total_profit,

    ROUND(
        SUM(oi.price_usd - oi.cogs_usd)
        * 100.0
        / NULLIF(SUM(oi.price_usd), 0),
        2
    ) AS margin_percent,

    ROUND(
        SUM(oi.price_usd - oi.cogs_usd)
        / NULLIF(COUNT(DISTINCT oi.order_id), 0),
        2
    ) AS profit_per_order

FROM order_items oi

INNER JOIN products p
    ON oi.product_id = p.product_id

GROUP BY
    p.product_id,
    p.product_name;
GO















