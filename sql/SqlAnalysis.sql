use MavenFuzzyFactory;
-- ////////////////////  KPIs //////////////////
SELECT
    -- Website KPIs

    -- Unique visitors
    (
        SELECT COUNT(DISTINCT user_id)
        FROM website_sessions
    ) AS unique_visitors,

    -- Conversion rate
    (
        SELECT
            COUNT(DISTINCT o.website_session_id) * 100.0
            / COUNT(DISTINCT ws.website_session_id)
        FROM website_sessions ws
        LEFT JOIN orders o
            ON ws.website_session_id = o.website_session_id
    ) AS conversion_rate,

    -- Average pages per session
    (
        SELECT AVG(pageviews * 1.0)
        FROM (
            SELECT
                website_session_id,
                COUNT(*) AS pageviews
            FROM website_pageviews
            GROUP BY website_session_id
        ) x
    ) AS avg_pages_per_session,

    -- Bounce rate
    (
        SELECT
            SUM(CASE WHEN pageviews = 1 THEN 1 ELSE 0 END) * 100.0
            / COUNT(*)
        FROM (
            SELECT
                website_session_id,
                COUNT(*) AS pageviews
            FROM website_pageviews
            GROUP BY website_session_id
        ) x
    ) AS bounce_rate,

    -- Refund rate
    (
        SELECT
            COUNT(DISTINCT r.order_item_id) * 100.0
            / COUNT(DISTINCT oi.order_item_id)
        FROM order_items oi
        LEFT JOIN order_item_refunds r
            ON oi.order_item_id = r.order_item_id
    ) AS refund_rate,

    -- E-commerce KPIs
    (
        SELECT ROUND(SUM(price_usd), 0)
        FROM orders
    ) AS total_revenue,

    (
        SELECT ROUND(SUM(price_usd - cogs_usd), 0)
        FROM orders
    ) AS total_profit,

    (
        SELECT ROUND(AVG(price_usd), 2)
        FROM orders
    ) AS avg_order_value,

    (
        SELECT COUNT(*)
        FROM orders
    ) AS total_orders;


-- /////////////////// 1- UTM Source Analysis /////////////

SELECT 
    ws.utm_source,

    COUNT(DISTINCT ws.website_session_id) AS sessions,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate,

    ROUND(AVG(o.price_usd), 2) AS avg_order_value,

    ROUND(SUM(o.price_usd), 0) AS total_revenue,

    ROUND(SUM(o.price_usd - o.cogs_usd), 0) AS total_profit,

    ROUND(
        SUM(o.price_usd - o.cogs_usd) / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS profit_per_order

FROM website_sessions ws

LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

GROUP BY ws.utm_source

ORDER BY total_profit DESC;

-- /////////////////// 2- UTM Campaign Analysis ///////////// 
SELECT 
    ws.utm_campaign,

    COUNT(DISTINCT ws.website_session_id) AS sessions,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate,

    ROUND(AVG(o.price_usd), 2) AS avg_order_value,

    ROUND(SUM(o.price_usd), 0) AS total_revenue,

    ROUND(SUM(o.price_usd - o.cogs_usd), 0) AS total_profit

FROM website_sessions ws

LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

WHERE ws.utm_campaign IS NOT NULL

GROUP BY ws.utm_campaign

ORDER BY total_profit DESC;

-- /////////////////// 3- Source + Campaign Analysis ///////////// 

SELECT 
    ws.utm_source,
    ws.utm_campaign,

    COUNT(DISTINCT ws.website_session_id) AS sessions,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate,

    ROUND(AVG(o.price_usd), 2) AS avg_order_value,

    ROUND(SUM(o.price_usd), 0) AS total_revenue,

    ROUND(SUM(o.price_usd - o.cogs_usd), 0) AS total_profit

FROM website_sessions ws

LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

WHERE ws.utm_source IS NOT NULL

GROUP BY 
    ws.utm_source,
    ws.utm_campaign

ORDER BY total_profit DESC;

-- /////////////////// 4- Device Type Analysis ///////////// 

SELECT 
    ws.device_type,

    COUNT(DISTINCT ws.website_session_id) AS sessions,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate,

    ROUND(AVG(o.price_usd), 2) AS avg_order_value,

    ROUND(SUM(o.price_usd), 0) AS total_revenue,

    ROUND(SUM(o.price_usd - o.cogs_usd), 0) AS total_profit

FROM website_sessions ws

LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

GROUP BY ws.device_type

ORDER BY total_profit DESC;

-- /////////////////// 5- UTM Source + Device Type ///////////// 

SELECT 
    ws.utm_source,
    ws.device_type,

    COUNT(DISTINCT ws.website_session_id) AS sessions,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate,

    ROUND(AVG(o.price_usd), 2) AS avg_order_value,

    ROUND(SUM(o.price_usd - o.cogs_usd), 0) AS total_profit

FROM website_sessions ws

LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

GROUP BY 
    ws.utm_source,
    ws.device_type

ORDER BY total_profit DESC;

-- /////////////////// 6- UTM Content Analysis ///////////// 

SELECT 
    ws.utm_source,
    ws.utm_campaign,
    ws.utm_content,

    COUNT(DISTINCT ws.website_session_id) AS sessions,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate,

    ROUND(AVG(o.price_usd), 2) AS avg_order_value,

    ROUND(SUM(o.price_usd - o.cogs_usd), 0) AS total_profit

FROM website_sessions ws

LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

WHERE ws.utm_content IS NOT NULL

GROUP BY 
    ws.utm_source,
    ws.utm_campaign,
    ws.utm_content

ORDER BY total_profit DESC;

-- /////////////////// 6- HTTP Referrer Analysis ///////////// 

SELECT 
    ws.http_referer,

    COUNT(DISTINCT ws.website_session_id) AS sessions,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate,

    ROUND(SUM(o.price_usd), 0) AS total_revenue,

    ROUND(SUM(o.price_usd - o.cogs_usd), 0) AS total_profit

FROM website_sessions ws

LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

WHERE ws.http_referer IS NOT NULL

GROUP BY ws.http_referer

ORDER BY total_profit DESC;

-- /////////////////// 7- Repeat vs New Visitors ///////////// 

SELECT 
    ws.is_repeat_session,

    COUNT(DISTINCT ws.website_session_id) AS sessions,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        COUNT(DISTINCT o.website_session_id) * 100.0
        / COUNT(DISTINCT ws.website_session_id),
        2
    ) AS conversion_rate,

    ROUND(AVG(o.price_usd), 2) AS avg_order_value,

    ROUND(SUM(o.price_usd - o.cogs_usd), 0) AS total_profit

FROM website_sessions ws

LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id

GROUP BY ws.is_repeat_session

ORDER BY ws.is_repeat_session;


-- /////////////////// 8- product profit ///////////// 

SELECT 
    p.product_name,
    ROUND(SUM(oi.price_usd - oi.cogs_usd), 0) AS total_profit,
    ROUND((SUM(oi.price_usd - oi.cogs_usd) / SUM(oi.price_usd)) * 100, 2) AS margin_percent,
    ROUND(SUM(oi.price_usd - oi.cogs_usd) / COUNT(DISTINCT oi.order_id), 2) AS profit_per_order
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_profit DESC;

-- /////////////////// 9- Product Attachment Analysis ///////////// 

SELECT 
    p1.product_name AS primary_product,
    p2.product_name AS cross_sell_product,
    COUNT(*) AS times_sold_together,
    ROUND(COUNT(*) * 100.0 / total.primary_count, 2) AS attachment_rate,
    ROUND(AVG(oi2.price_usd - oi2.cogs_usd), 2) AS avg_extra_profit,
    ROUND(COUNT(*) * AVG(oi2.price_usd - oi2.cogs_usd), 0) AS total_extra_profit
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id
JOIN products p1 ON oi1.product_id = p1.product_id
JOIN products p2 ON oi2.product_id = p2.product_id
JOIN (
    SELECT product_id, COUNT(*) AS primary_count
    FROM order_items
    WHERE is_primary_item = 1
    GROUP BY product_id
) total ON oi1.product_id = total.product_id
WHERE oi1.is_primary_item = 1 
  AND oi2.is_primary_item = 0
GROUP BY p1.product_name, p2.product_name, total.primary_count
ORDER BY times_sold_together DESC;



-- /////////////////// 10- Cross-Selling Analysis ///////////// 

WITH period_data AS (
    SELECT 
        CASE 
            WHEN o.created_at < '2013-09-25'
                THEN 'Before Cross-sell'
            ELSE 'After Cross-sell'
        END AS period,

        MIN(CAST(o.created_at AS DATE)) AS start_date,
        MAX(CAST(o.created_at AS DATE)) AS end_date,

        COUNT(DISTINCT o.order_id) AS orders,

        ROUND(AVG(o.price_usd), 2) AS avg_order_value,

        ROUND(SUM(o.price_usd), 0) AS total_revenue,

        ROUND(SUM(o.price_usd - o.cogs_usd), 0) AS total_profit

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

    -- Duration
    DATEDIFF(DAY, start_date, end_date) + 1 AS duration_days,

    orders,

    avg_order_value,

    total_revenue,

    total_profit,

    -- Average per day
    ROUND(
        orders * 1.0 / 
        (DATEDIFF(DAY, start_date, end_date) + 1),
        2
    ) AS avg_orders_per_day,

    ROUND(
        total_revenue * 1.0 /
        (DATEDIFF(DAY, start_date, end_date) + 1),
        2
    ) AS avg_revenue_per_day,

    -- Annualized averages
    ROUND(
        orders * 365.0 /
        (DATEDIFF(DAY, start_date, end_date) + 1),
        2
    ) AS avg_orders_per_year,

    ROUND(
        total_revenue * 365.0 /
        (DATEDIFF(DAY, start_date, end_date) + 1),
        2
    ) AS avg_revenue_per_year

FROM period_data
ORDER BY start_date;



-- ///////////////////////////////////////  A/B Testing  //////////////

select MIN(created_at) started , MAX(created_at) ended , pageview_url
from website_pageviews
group by pageview_url
order by pageview_url


-- //////////    /lander-1    ////////////      +Negative result 
SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/lander-1';

SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/home';

-- End Date of the Experiment 
SELECT MAX(created_at) FROM website_pageviews 
WHERE pageview_url = '/home' 
  AND created_at < (SELECT MAX(created_at) FROM website_pageviews WHERE pageview_url = '/lander-1');

-- CVR 
SELECT 
    wp.pageview_url,
    COUNT(DISTINCT wp.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 / COUNT(DISTINCT wp.website_session_id), 2) AS cvr
FROM website_pageviews wp
LEFT JOIN orders o ON wp.website_session_id = o.website_session_id
WHERE wp.pageview_url IN ('/home', '/lander-1')
  AND wp.created_at BETWEEN '2012-06-19' AND '2013-03-10'
GROUP BY wp.pageview_url;


-- //////////    /lander-2    ////////////       +positive result
SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/lander-2';

SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/home';

-- End Date of the Experiment 
SELECT MAX(created_at) FROM website_pageviews 
WHERE pageview_url = '/home' 
  AND created_at < (SELECT MAX(created_at) FROM website_pageviews WHERE pageview_url = '/lander-2');


-- CVR 
SELECT 
    wp.pageview_url,
    COUNT(DISTINCT wp.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 / COUNT(DISTINCT wp.website_session_id), 2) AS cvr
FROM website_pageviews wp
LEFT JOIN orders o ON wp.website_session_id = o.website_session_id
WHERE wp.pageview_url IN ('/home', '/lander-2')
  AND wp.created_at BETWEEN '2013-01-14' AND '2014-12-27'
GROUP BY wp.pageview_url;


-- //////////    /lander-3    ////////////          -negative result
SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/lander-3';

SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/home';

-- End Date of the Experiment 
SELECT MAX(created_at) FROM website_pageviews 
WHERE pageview_url = '/home' 
  AND created_at < (SELECT MAX(created_at) FROM website_pageviews WHERE pageview_url = '/lander-3');


-- CVR 
SELECT 
    wp.pageview_url,
    COUNT(DISTINCT wp.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 / COUNT(DISTINCT wp.website_session_id), 2) AS cvr
FROM website_pageviews wp
LEFT JOIN orders o ON wp.website_session_id = o.website_session_id
WHERE wp.pageview_url IN ('/home', '/lander-3')
  AND wp.created_at BETWEEN '2013-07-09' AND '2015-03-19'
GROUP BY wp.pageview_url;




-- //////////    /lander-4    ////////////        -negative result
SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/lander-4';

SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/home';

-- End Date of the Experiment 
SELECT MAX(created_at) FROM website_pageviews 
WHERE pageview_url = '/home' 
  AND created_at < (SELECT MAX(created_at) FROM website_pageviews WHERE pageview_url = '/lander-4');


-- CVR 
SELECT 
    wp.pageview_url,
    COUNT(DISTINCT wp.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 / COUNT(DISTINCT wp.website_session_id), 2) AS cvr
FROM website_pageviews wp
LEFT JOIN orders o ON wp.website_session_id = o.website_session_id
WHERE wp.pageview_url IN ('/home', '/lander-4')
  AND wp.created_at BETWEEN '2014-02-02' AND '2014-04-19'
GROUP BY wp.pageview_url;





-- //////////    /lander-5    ////////////        -Positive result
SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/lander-5';

SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/home';

-- End Date of the Experiment 
SELECT MAX(created_at) FROM website_pageviews 
WHERE pageview_url = '/home' 
  AND created_at < (SELECT MAX(created_at) FROM website_pageviews WHERE pageview_url = '/lander-5');


-- CVR 
SELECT 
    wp.pageview_url,
    COUNT(DISTINCT wp.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 / COUNT(DISTINCT wp.website_session_id), 2) AS cvr
FROM website_pageviews wp
LEFT JOIN orders o ON wp.website_session_id = o.website_session_id
WHERE wp.pageview_url IN ('/home', '/lander-5')
  AND wp.created_at BETWEEN '2014-08-02' AND '2015-03-19'
GROUP BY wp.pageview_url;





-- //////////    /billing-2   ////////////
SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/billing-2';

SELECT MIN(created_at), MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/billing';

-- End Date of the Experiment 
SELECT MAX(created_at) FROM website_pageviews 
WHERE pageview_url = '/billing' 
  AND created_at < (SELECT MAX(created_at) FROM website_pageviews WHERE pageview_url = '/billing-2');


-- CVR 
SELECT 
    wp.pageview_url,
    COUNT(DISTINCT wp.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(COUNT(DISTINCT o.order_id) * 100.0 / COUNT(DISTINCT wp.website_session_id), 2) AS cvr
FROM website_pageviews wp
LEFT JOIN orders o ON wp.website_session_id = o.website_session_id
WHERE wp.pageview_url IN ('/billing', '/billing-2')
  AND wp.created_at BETWEEN '2012-09-10' AND '2013-01-05'
GROUP BY wp.pageview_url;




