
------------------------- orders & order_items

select * 
from orders
WHERE price_usd <= 0;


select * 
from order_items
WHERE price_usd <= 0;

select * 
from orders o
WHERE o.cogs_usd <= 0 OR o.cogs_usd > o.price_usd;

select * 
from order_items o
WHERE o.cogs_usd <= 0 OR o.cogs_usd > o.price_usd;

select * 
from order_items
where product_id <1 or product_id >4;

------------------------- website_sessions

select distinct(utm_source) 
from website_sessions;

select distinct(http_referer) 
from website_sessions;


select distinct(http_referer) , utm_source
from website_sessions;

--------------------------- website_pageviews 

select distinct(pageview_url)
from website_pageviews;


---------------------------- website_sessions && website_pageviews

-- views  that happen before the session even created 
Select *
FROM website_pageviews wp
JOIN website_sessions ws
    ON wp.website_session_id = ws.website_session_id
WHERE wp.created_at < ws.created_at;


------------------------------ order_item_refunds

select *
FROM order_item_refunds 
WHERE refund_amount_usd <= 0;

----------------------------- product 
select *
from products

