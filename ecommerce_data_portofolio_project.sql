USE mavenfuzzyfactory;

-- ANALYZING TRAFFIC SOURCES

-- Sizing the traffic sources
-- Understanding how well the traffic sources are converting to orders
SELECT 
	website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM website_sessions
	LEFT JOIN orders 
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC;

-- Site traffic breakdown
SELECT
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 1, 2, 3
ORDER BY sessions DESC;

-- Calculating the conversion rate(CVR) from session to order for the major traffic source
SELECT
	utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM website_sessions 
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < "2012-04-14"
	  AND utm_source = "gsearch"
      AND utm_campaign = "nonbrand";
      
-- Gsearch nonbrand trended session volume by week
SELECT
    MIN(DATE(created_at)) AS week_started_at,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE utm_source = "gsearch"
      AND utm_campaign = "nonbrand"
      AND created_at < "2012-05-10"
GROUP BY 
	YEAR(created_at),
	WEEK(created_at);
    
-- Analyzing device specific conversion rates
-- Is the desktop performance better than on mobile?
SELECT 
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id)  AS session_to_order_conversion_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < "2012-05-11"
	  AND utm_source = "gsearch"
      AND utm_campaign = "nonbrand"
GROUP BY device_type;

-- Weekly trends for both desktop and mobile
-- Gsearch device-level trends by week
SELECT 
    MIN(DATE(created_at)) AS week_started_at,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS desktop_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mobile_sessions
FROM website_sessions
WHERE
	created_at < '2012-06-09'
	AND created_at > '2012-04-15'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at) , WEEK(created_at);

-- Single item orders vs. two items orders
SELECT 
    primary_product_id,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 1 THEN order_id
            ELSE NULL
        END) AS orders_w_1_item,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 2 THEN order_id
            ELSE NULL
        END) AS orders_w_2_items,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders
WHERE
    order_id BETWEEN 31000 AND 32000
GROUP BY 1;


-- ANALYZING WEBSITE PERFORMANCE

-- Finding the most viewed pages
SELECT
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS views
FROM website_pageviews
-- WHERE website_pageview_id < 1000
GROUP BY pageview_url
ORDER BY views DESC;

-- Entry page analysis

-- Finding the first pageview for each session
CREATE TEMPORARY TABLE first_pv_per_session
SELECT
	website_session_id,
    MIN(website_pageview_id) AS first_pageview
FROM website_pageviews
WHERE created_at < "2012-06-12"
GROUP BY 1;
-- Finding the URL the customer saw on the first pageview
SELECT 
	website_pageviews.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_pv_per_session.website_session_id) AS sessions_hitting_page
FROM first_pv_per_session
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pv_per_session.first_pageview
GROUP BY website_pageviews.pageview_url;
   
-- Bounce rate analysis
-- the first website_pageview_id for relevant sessions
CREATE TEMPORARY TABLE first_pageviews
SELECT
	MIN(website_pageview_id) AS min_pageview_id,
    website_session_id
FROM website_pageviews
WHERE created_at < "2012-06-12"
GROUP BY website_session_id;

SELECT * FROM first_pageviews;

-- the landing page of each session
CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT 
	website_pageviews.pageview_url AS landing_page,
	first_pageviews.website_session_id
FROM first_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url = "/home";

SELECT * FROM sessions_w_home_landing_page;

-- counting page views for each session, to identify bounced_sessions
CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	sessions_w_home_landing_page.website_session_id,
    COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_pages_viewed,
    sessions_w_home_landing_page.landing_page
FROM sessions_w_home_landing_page
LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id
GROUP BY 
	sessions_w_home_landing_page.website_session_id,
	sessions_w_home_landing_page.landing_page
HAVING 
	COUNT(website_pageviews.website_pageview_id) =1;

-- summarizing total sessions and bounced sessions, by landing page
SELECT
	COUNT(bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(sessions_w_home_landing_page.website_session_id) AS total_sessions,
    COUNT(bounced_sessions.website_session_id) /  COUNT(sessions_w_home_landing_page.website_session_id) AS bounce_rate
FROM bounced_sessions
RIGHT JOIN sessions_w_home_landing_page
	ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id;
    
-- Analyzing Landing Page Tests
-- finding the first instance of /lander-1 to set analysis timeframe
SELECT 
    MIN(website_pageview_id) AS first_pageview_id,
    MIN(created_at) AS first_created_at
FROM website_pageviews
WHERE pageview_url = "/lander-1"
	  AND created_at IS NOT NULL;
-- first_pageview_id ='23504' 

-- finding the first website_pageview_id_ for relevant sessions
CREATE TEMPORARY TABLE first_test_pageviews
SELECT
    website_pageviews.website_session_id, 
	MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
        AND website_sessions.created_at < "2012-07-28"
        AND website_pageviews.website_pageview_id > "23504"
        AND utm_source = "gsearch"
        AND utm_campaign = "nonbrand"
GROUP BY 
	website_pageviews.website_session_id; 

-- identifying the landing page of each session(restricting to home or lander-1)
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT 
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = first_test_pageviews.website_session_id
WHERE website_pageviews.pageview_url IN ("/home", "/lander-1");

-- counting pageviews for each session, to identify "bounces"
CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT 
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_session_id) AS count_of_pages_viewed
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN website_pageviews
		ON nonbrand_test_sessions_w_landing_page.website_session_id = website_pageviews.website_session_id
GROUP BY 
	nonbrand_test_sessions_w_landing_page.landing_page,
	nonbrand_test_sessions_w_landing_page.website_session_id
HAVING 
	COUNT(website_pageviews.website_session_id) = 1;
    
-- summarizing total sessions and bounced sessions, by landing page
SELECT 
	nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) / COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS bounce_rate
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions
		ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
GROUP BY 
	nonbrand_test_sessions_w_landing_page.landing_page;
    
-- Landing Page Trend Analysis
-- finding the first website_pageview_id for relevant sessions, counting pageviews for each session
CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count
SELECT
	website_sessions.website_session_id,
	MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE 
	website_sessions.created_at > "2012-06-01"
    AND website_sessions.created_at < "2012-08-31"
    AND website_sessions.utm_source = "gsearch"
    AND website_sessions.UTM_CAMPAIGN = "nonbrand"
GROUP BY 
	website_sessions.website_session_id;
   
-- indentifying the landing page of each session
CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT 
	sessions_w_min_pv_id_and_view_count.website_session_id,
    sessions_w_min_pv_id_and_view_count.first_pageview_id,
    sessions_w_min_pv_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_id_and_view_count
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = sessions_w_min_pv_id_and_view_count.first_pageview_id;
    
-- summarizing by week (bounce rate, sessions to each lander)
SELECT 
	MIN(DATE(session_created_at)) AS week_start_date,
--  COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = "/home" THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = "/lander-1" THEN website_session_id ELSE NULL END) AS lander_sessions,
--  COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS bounce_rate
FROM sessions_w_counts_lander_and_created_at
GROUP BY 
	YEARWEEK(session_created_at);
    
-- Analyzing Conversion Funnels
-- selecting all pageviews for relevant sessions
-- identifying each pageview as the specific funnel step
SELECT 
	website_pageviews.pageview_url,
    website_sessions.website_session_id,
    CASE WHEN pageview_url = "/products" THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = "/the-original-mr-fuzzy" THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = "/cart" THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = "/shipping" THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = "/billing" THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = "/thank-you-for-your-order" THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
	website_sessions.created_at > "2012-08-05" 
    AND website_sessions.created_at < "2012-09-05"
    AND website_sessions.utm_source = "gsearch"
    AND website_sessions.utm_campaign = "nonbrand"
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at;

-- session-level conversion funnel view: how far the session made it 
SELECT
    website_session_id,
    MAX(products_page) AS products_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS tankyou_made_it
FROM 
	(
    SELECT 
		website_pageviews.pageview_url,
		website_sessions.website_session_id,
		CASE WHEN pageview_url = "/products" THEN 1 ELSE 0 END AS products_page,
		CASE WHEN pageview_url = "/the-original-mr-fuzzy" THEN 1 ELSE 0 END AS mrfuzzy_page,
		CASE WHEN pageview_url = "/cart" THEN 1 ELSE 0 END AS cart_page,
		CASE WHEN pageview_url = "/shipping" THEN 1 ELSE 0 END AS shipping_page,
		CASE WHEN pageview_url = "/billing" THEN 1 ELSE 0 END AS billing_page,
		CASE WHEN pageview_url = "/thank-you-for-your-order" THEN 1 ELSE 0 END AS thankyou_page
	FROM website_sessions
		LEFT JOIN website_pageviews
			ON website_pageviews.website_session_id = website_sessions.website_session_id
	WHERE
		website_sessions.created_at > "2012-08-05" 
        AND website_sessions.created_at < "2012-09-05"
		AND website_sessions.utm_source = "gsearch"
		AND website_sessions.utm_campaign = "nonbrand"
	ORDER BY 
		website_sessions.website_session_id,
		website_pageviews.created_at
    ) AS pageview_level
 GROUP BY  website_session_id;  
    
 -- Creating a temporary table
 CREATE TEMPORARY TABLE session_level_made_it_flagss
 SELECT
    website_session_id,
    MAX(products_page) AS products_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM 
	(
    SELECT 
		website_pageviews.pageview_url,
		website_sessions.website_session_id,
		CASE WHEN pageview_url = "/products" THEN 1 ELSE 0 END AS products_page,
		CASE WHEN pageview_url = "/the-original-mr-fuzzy" THEN 1 ELSE 0 END AS mrfuzzy_page,
		CASE WHEN pageview_url = "/cart" THEN 1 ELSE 0 END AS cart_page,
		CASE WHEN pageview_url = "/shipping" THEN 1 ELSE 0 END AS shipping_page,
		CASE WHEN pageview_url = "/billing" THEN 1 ELSE 0 END AS billing_page,
		CASE WHEN pageview_url = "/thank-you-for-your-order" THEN 1 ELSE 0 END AS thankyou_page
	FROM website_sessions
		LEFT JOIN website_pageviews
			ON website_pageviews.website_session_id = website_sessions.website_session_id
	WHERE
		website_sessions.created_at > "2012-08-05" 
        AND website_sessions.created_at < "2012-09-05"
		AND website_sessions.utm_source = "gsearch"
		AND website_sessions.utm_campaign = "nonbrand"
	ORDER BY 
		website_sessions.website_session_id,
		website_pageviews.created_at
    ) AS pageview_level
 GROUP BY  website_session_id; 

-- aggregating the data to assess funnel performance
SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flagss;

-- converting into click rates
SELECT 
    COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) /COUNT(DISTINCT website_session_id) AS lander_click_rate,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rate,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rate,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) /COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rate,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rate
FROM session_level_made_it_flagss;
	
    
-- /billing vs /billing-2: what % of sessions on these pages end up placing an order
-- finding the first time /billing-2 was seen
SELECT
	MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = "/billing-2";
-- first_pageview_id = 53550


-- identifying /billing and /billing-2 sessions and orders
SELECT
	website_pageviews.pageview_url AS billing_version_seen,
    website_pageviews.website_session_id,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders 
		ON website_pageviews.website_session_id = orders.website_session_id
WHERE 
	website_pageviews.website_pageview_id >= 53550 
    AND website_pageviews.created_at <  "2012-11-10"
    AND website_pageviews.pageview_url IN ("/billing", "/billing-2");
    
-- wrapping a subquery and summarizing
SELECT
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS billing_to_order_rate
FROM 
	(
    SELECT
		website_pageviews.pageview_url AS billing_version_seen,
		website_pageviews.website_session_id,
		orders.order_id
	FROM website_pageviews
		LEFT JOIN orders 
			ON website_pageviews.website_session_id = orders.website_session_id
	WHERE 
		website_pageviews.website_pageview_id >= 53550 
		AND  website_pageviews.created_at <  "2012-11-10"
		AND website_pageviews.pageview_url IN ("/billing", "/billing-2")
    ) AS sessions_and_orders
GROUP BY billing_version_seen;




-- Telling the company's growth story over the first 8 months, using trended performance data

-- QUESTION 1: monthly trends for gsearch sessions and orders
SELECT
    MIN(DATE(website_sessions.created_at)) AS dates,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE 
	website_sessions.utm_source = "gsearch"
	AND website_sessions.created_at < "2012-11-27"
GROUP BY 
	YEAR(website_sessions.created_at),
    MONTH(website_sessions.created_at);
 
-- QUESTION 2: monthly trend for gsearch - splitting out nonbrand and brand campaigns separately
SELECT
    MIN(DATE(website_sessions.created_at)) AS dates,
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = "brand" THEN  website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = "brand" THEN  orders.order_id ELSE NULL END) AS brand_orders,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = "nonbrand" THEN  website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = "nonbrand" THEN  orders.order_id ELSE NULL END) AS nonbrand_orders,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = "nonbrand" THEN  orders.order_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = "nonbrand" THEN  website_sessions.website_session_id ELSE NULL END) AS nonbrand_conv_rate,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = "brand" THEN  orders.order_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = "brand" THEN  website_sessions.website_session_id ELSE NULL END) AS brand_conv_rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE 
	website_sessions.utm_source = "gsearch"
	AND website_sessions.created_at < "2012-11-27"
GROUP BY 
	YEAR(website_sessions.created_at),
    MONTH(website_sessions.created_at);
    
-- QUESTION 3: monthly trend for gsearch - sessions and orders split by device type
SELECT 
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type = "mobile" THEN  website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = "mobile" THEN  orders.order_id ELSE NULL END) AS mobile_orders,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = "desktop" THEN  website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type = "desktop" THEN  orders.order_id ELSE NULL END) AS desktop_orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE 
	website_sessions.utm_source = "gsearch"
	AND website_sessions.created_at < "2012-11-27"
    AND website_sessions.utm_campaign = "nonbrand"
GROUP BY 
	YEAR(website_sessions.created_at),
    MONTH(website_sessions.created_at);
    
-- QUESTION 4: monthly trend for gsearch alongside monthly trends for the other channels
SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
	COUNT( DISTINCT CASE WHEN website_sessions.utm_source = "gsearch" THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT( DISTINCT CASE WHEN website_sessions.utm_source = "bsearch" THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT( DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
	COUNT( DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_session
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < "2012-11-27"
GROUP BY
	YEAR(website_sessions.created_at),
    MONTH(website_sessions.created_at);
    
-- QUESTIONS 5: session to order conversion rates, by month
SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < "2012-11-27"
GROUP BY 
	YEAR(website_sessions.created_at),
    MONTH(website_sessions.created_at);
    
-- QUESTION 6: gsearch lander test estimated revenue
-- looking for the first instance of the page view url
SELECT
	MIN(website_pageview_id) AS first_test_pv
FROM website_pageviews
WHERE pageview_url = "/lander-1";
-- first pv id = 23504

-- creating a temporary table for the first test page views
CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	MIN(website_pageviews.website_pageview_id) AS min_pv_id,
    website_pageviews.website_session_id
FROM website_pageviews
	JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_pageviews.website_pageview_id >= 23504
        AND website_sessions.created_at < "2012-07-28"
	    AND website_sessions.utm_source = "gsearch"
        AND website_sessions.utm_campaign = "nonbrand"
GROUP BY website_pageviews.website_session_id;

-- bringing in the landing page to each sessions
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT
    first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageviews.min_pv_id
WHERE 
	website_pageviews.pageview_url IN ("/home", "/lander-1");
    
-- bringing in the orders
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT
	nonbrand_test_sessions_w_landing_pages.landing_page,
	nonbrand_test_sessions_w_landing_pages.website_session_id,
    orders.order_id
FROM nonbrand_test_sessions_w_landing_pages
	LEFT JOIN orders
		ON orders.website_session_id = nonbrand_test_sessions_w_landing_pages.website_session_id;

-- conversion rates for the relevant landing pages
SELECT
	landing_page,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS conversion_rate
FROM nonbrand_test_sessions_w_orders
GROUP BY landing_page;
-- we observe that /lander-1 is fairly better - approximately 0.0088% orders per session
 
-- finding the most recent pageview for gsearch nonbrand where the traffic was sent to ‘/home’
-- since then, all of the traffic has been rerouted to ‘/lander-1’
SELECT
	MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_session
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE 
	website_sessions.created_at < "2012-11-27"
	AND website_sessions.utm_source = "gsearch"
	AND website_sessions.utm_campaign = "nonbrand"
    AND website_pageviews.pageview_url = "/home";
-- max website session id =  17145

-- checking how many sessions we've had since the traffic reroute
SELECT
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE
	created_at < "2012-11-27"
    AND utm_source = "gsearch"
    AND utm_campaign = "nonbrand"
    AND website_session_id > 17145;
-- we had 22972 sessions since after rerouting all traffic to /lander-1
-- 22972 sessions * 0.0088 incremental CVR =  202 incremental orders since the home page A/B test concluded

-- QUESTION 7: for the previous landing page test: full conversion funnel from each of the two pages to orders
-- selecting all pageviews for relevant sessions
-- identifying each pageview as the specific funnel step
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    CASE WHEN pageview_url = "/home" THEN 1 ELSE 0 END AS home_page,
    CASE WHEN pageview_url = "/lander-1" THEN 1 ELSE 0 END AS custom_lander_page,
     CASE WHEN pageview_url = "/products" THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = "/the-original-mr-fuzzy" THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = "/cart" THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = "/shipping" THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = "/billing" THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = "/thank-you-for-your-order" THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
	website_sessions.created_at > "2012-06-19" 
    AND website_sessions.created_at < "2012-07-28"
    AND website_sessions.utm_source = "gsearch"
    AND website_sessions.utm_campaign = "nonbrand"
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at;
    
-- checking how far the session made it 
 CREATE TEMPORARY TABLE session_level_madeit_flags
SELECT
	website_session_id,
    MAX(home_page) AS saw_homepage,
    MAX(custom_lander_page) AS saw_custom_lander,
    MAX(products_page) AS products_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM
	(
    SELECT
	website_sessions.website_session_id,
    CASE WHEN pageview_url = "/home" THEN 1 ELSE 0 END AS home_page,
    CASE WHEN pageview_url = "/lander-1" THEN 1 ELSE 0 END AS custom_lander_page,
	CASE WHEN pageview_url = "/products" THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = "/the-original-mr-fuzzy" THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = "/cart" THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = "/shipping" THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = "/billing" THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = "/thank-you-for-your-order" THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE
	website_sessions.created_at > "2012-06-19" 
    AND website_sessions.created_at < "2012-07-28"
    AND website_sessions.utm_source = "gsearch"
    AND website_sessions.utm_campaign = "nonbrand"
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at
    ) AS pageview_level
GROUP BY website_session_id;

-- did they see the home page or did they see the custom lander page?
-- aggregating the data
SELECT
	CASE
		WHEN saw_homepage = 1 THEN "saw_homepage"
        WHEN saw_custom_lander THEN "saw_custom_lander"
        ELSE "check logic"
	END AS segment,
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
	COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
	COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
	COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_madeit_flags
GROUP BY segment;

-- converting to click rates
SELECT
	CASE
		WHEN saw_homepage = 1 THEN "saw_homepage"
        WHEN saw_custom_lander THEN "saw_custom_lander"
        ELSE "check logic"
	END AS segment,
	COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS lander_click_rate,
	COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rate,
	COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rate,
	COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rate,
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rate
FROM session_level_madeit_flags
GROUP BY segment;

-- QUESTION 8: quantify the impact of the billing test
-- the first time billing 2 was used
SELECT
	*
FROM website_pageviews
WHERE 
	pageview_url IN ("/billing-2");
-- first_pageview_id = 53550

-- billing and billing 2 sessions and orders
SELECT
	website_pageviews.pageview_url AS billing_version,
	website_pageviews.website_session_id,
    orders.order_id,
    orders.price_usd
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id 
WHERE 
	pageview_url IN ("/billing", "/billing-2")
    AND website_pageviews.created_at > "2012-09-10"
     AND website_pageviews.created_at < "2012-11-10"
GROUP BY 1, 2, 3;

 -- identifying the revenue per billing page
SELECT 
	billing_version,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd) / COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM 
	(
    SELECT
	website_pageviews.pageview_url AS billing_version,
	website_pageviews.website_session_id,
    orders.order_id,
    orders.price_usd
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id 
WHERE 
	pageview_url IN ("/billing", "/billing-2")
    AND website_pageviews.created_at > "2012-09-10"
     AND website_pageviews.created_at < "2012-11-10"
    ) AS billing_data
GROUP BY billing_version;
-- LIFT: $8.51 per billing page view

-- checking how many sessions we've had where somebody hit the billing page in the past month
SELECT
	COUNT(website_session_id) AS number_of_sessions
FROM website_pageviews
WHERE 
	pageview_url IN ("/billing", "/billing-2")
    AND created_at BETWEEN "2012-10-27" AND "2012-11-27";
-- 1193 sessions * $8.51 = $10,153 over the past month




-- ANALYSIS FOR CHANNEL PORTOFOLIO MANAGEMENT

-- Weekly trended session volume:  gsearch vs bsearch
SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = "gsearch" THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = "bsearch" THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions
WHERE 
	created_at > "2012-08-22"
    AND created_at < "2012-11-29"
    AND utm_campaign = "nonbrand"
GROUP BY 
	YEARWEEK(created_at);
    
-- diving further into the bsearch nonbrand campaign
-- bsearch vs gsearch traffic % coming from mobile
SELECT
	utm_source, 
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN device_type = "mobile" THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = "mobile" THEN website_session_id ELSE NULL END) /  COUNT(DISTINCT website_session_id) AS mobile_percentage 
FROM website_sessions
WHERE 
	created_at > "2012-08-22"
    AND created_at < "2012-11-30"
    AND utm_campaign = "nonbrand"
GROUP BY utm_source;

-- analyzing if bsearch nonbrand should have the same bids as gsearch
-- nonbrand CVR from session to order for gsearch and bsearch, slicing the data by device type
SELECT
	website_sessions.device_type,
	website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE 	
	website_sessions.created_at > "2012-08-22"
    AND website_sessions.created_at < "2012-09-19"
    AND website_sessions.utm_campaign = "nonbrand"
GROUP BY 1, 2;

-- weekly session volume for gsearch and bsearch nonbrand, broken down by device
-- showing bsearch as a percent of gsearch, for each device
SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN utm_source = "gsearch" AND device_type = "mobile" THEN website_session_id ELSE NULL END) AS gsearch_mobile_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = "bsearch" AND device_type = "mobile" THEN website_session_id ELSE NULL END) AS bsearch_mobile_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = "bsearch" AND device_type = "mobile" THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN utm_source = "gsearch" AND device_type = "mobile" THEN website_session_id ELSE NULL END) AS bsearch_percentage_of_gsearch_mobile,
    COUNT(DISTINCT CASE WHEN utm_source = "gsearch" AND device_type = "desktop" THEN website_session_id ELSE NULL END) AS gsearch_desktop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = "bsearch" AND device_type = "desktop" THEN website_session_id ELSE NULL END) AS bsearch_desktop_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = "bsearch" AND device_type = "desktop" THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN utm_source = "gsearch" AND device_type = "desktop" THEN website_session_id ELSE NULL END) AS bsearch_percentage_of_gsearch_desktop
FROM website_sessions
WHERE 	
	created_at > "2012-11-04"
    AND created_at < "2012-12-22"
    AND utm_campaign = "nonbrand"
GROUP BY YEARWEEK(created_at);

-- Site traffic breakdown
-- identifying organic search, direct type in and brand search sessions by month
SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN utm_campaign= "nonbrand" THEN website_session_id ELSE NULL END) AS paid_nonbrand,
	COUNT(DISTINCT CASE WHEN utm_campaign= "brand" THEN website_session_id ELSE NULL END) AS paid_brand,
    COUNT(DISTINCT CASE WHEN utm_campaign= "brand" THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN utm_campaign= "nonbrand" THEN website_session_id ELSE NULL END) AS brand_percentage_of_nonbrand,
	COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS  NULL THEN website_session_id ELSE NULL END) AS direct_search,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS  NULL THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN utm_campaign= "nonbrand" THEN website_session_id ELSE NULL END) AS direct_percentage_of_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) AS organic_search,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN utm_campaign= "nonbrand" THEN website_session_id ELSE NULL END) AS organic_percentage_of_nonbrand
FROM website_sessions
WHERE 
	created_at < "2012-12-23"
GROUP BY
	YEAR(created_at),
    MONTH(created_at);
    
-- ANALYZING BUSINESS PATTERNS AND SEASONALITY
-- 2012's monthly volume patterns
SELECT
	YEAR(website_sessions.created_at) AS yr,
	MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE YEAR(website_sessions.created_at) = "2012"
GROUP BY 
	YEAR(website_sessions.created_at),
	MONTH(website_sessions.created_at);
    
-- 2012's weekly volume patterns
SELECT
	MIN(DATE(website_sessions.created_at)) AS week_start_date,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE YEAR(website_sessions.created_at) = "2012"
GROUP BY 
	YEARWEEK(website_sessions.created_at);
    
-- analyzing the average website session volume, by hour of day and by day of week
SELECT
	hour_of_day,
    ROUND(AVG(sessions), 1) AS avg_sessions,
    ROUND(AVG(CASE WHEN day_of_week = 0 THEN sessions ELSE NULL END), 1) AS Monday,
    ROUND(AVG(CASE WHEN day_of_week = 1 THEN sessions ELSE NULL END), 1) AS Tuesday,
    ROUND(AVG(CASE WHEN day_of_week = 2 THEN sessions ELSE NULL END), 1) AS Wednesday,
    ROUND(AVG(CASE WHEN day_of_week = 3 THEN sessions ELSE NULL END), 1) AS Thursday,
    ROUND(AVG(CASE WHEN day_of_week = 4 THEN sessions ELSE NULL END), 1) AS Friday,
    ROUND(AVG(CASE WHEN day_of_week = 5 THEN sessions ELSE NULL END), 1) AS Saturday,
    ROUND(AVG(CASE WHEN day_of_week = 6 THEN sessions ELSE NULL END), 1) AS Sunday
FROM
	(
SELECT
	DATE(created_at) AS created_date,
	HOUR(created_at) AS hour_of_day,
    WEEKDAY(created_at) AS day_of_week,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at BETWEEN "2012-09-15" AND "2012-11-15"
GROUP BY 1, 2, 3
	) AS daily_hourly_sessions
GROUP BY 1;


-- PRODUCT ANALYSIS

-- Product-Level Sales Analysis
-- monthly trends for number of sales, total revenue and total margin generated for the business
SELECT
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(DISTINCT order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM orders
WHERE created_at < "2013-01-04"
GROUP BY
	YEAR(created_at),
    MONTH(created_at);
 
 
 -- Analyzing Product Launches
-- monthly order volume, overall CVR, revenue per session and a breakdown of sales by product
SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate,
    SUM(price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE WHEN primary_product_id = "1" THEN order_id ELSE NULL END) AS product_one_orders,
    COUNT(DISTINCT CASE WHEN primary_product_id = "2" THEN order_id ELSE NULL END) AS product_two_orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN "2012-04-01" AND "2013-04-01"
GROUP BY
	YEAR(website_sessions.created_at),
    MONTH(website_sessions.created_at);


-- Analyzing Product-Level Website Pathing
-- identifying the sessions which hit the /product page in order to see where they went next
-- finding the relevant /products pageviews with website_session_id
CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at,
	CASE 
		WHEN created_at < "2013-01-06" THEN "A.Pre_Product_2"
        WHEN created_at >= "2013-01-06" THEN "B.Post_Product_2"
        ELSE "check logic"
	END AS time_period
FROM website_pageviews
WHERE
	created_at < "2013-04-06"
    AND created_at > "2012-10-06"
    AND pageview_url = "/products";

-- identifying the next pageview id that occurs after the product pageview
CREATE TEMPORARY TABLE sessions_with_next_pageview_id
 SELECT 
	products_pageviews.time_period,
	products_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
FROM products_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = products_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
GROUP BY 1, 2;
 
-- finding the pageview_url associated with any applicable next pageview id
CREATE TEMPORARY TABLE sessions_with_next_pageview_url
SELECT
	sessions_with_next_pageview_id.time_period,
    sessions_with_next_pageview_id.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url
FROM sessions_with_next_pageview_id
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = sessions_with_next_pageview_id.min_next_pageview_id;
        
-- summarizing the data
-- analyzing pre vs post periods
SELECT 
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS sessions_w_next_page,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS percentage_w_next_page,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS percentage_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS percentage_to_lovebear
FROM sessions_with_next_pageview_url
GROUP BY time_period;


-- Building Product-Level Conversion Funnels 
-- identifying  all pageviews for relevant sessions
CREATE TEMPORARY TABLE sessions_seeing_product_pages
SELECT
	website_pageview_id,
    website_session_id,
    pageview_url AS product_page_seen
FROM website_pageviews
WHERE 
	created_at > "2013-01-06"
    AND created_at < "2013-04-10"
    AND pageview_url IN ("/the-original-mr-fuzzy", "/the-forever-love-bear");
    
-- figuring out which pageview urls to look for
SELECT
	website_pageviews.pageview_url
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id;

-- pulling all pageviews and identifying the funnel steps
SELECT
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
ORDER BY 
	sessions_seeing_product_pages.website_session_id,
    website_pageviews.created_at;

-- creating the session-level conversion funnel view
CREATE TEMPORARY TABLE session_level_conversion_funnel
SELECT
	website_session_id,
	CASE
		WHEN product_page_seen = "/the-original-mr-fuzzy" THEN "mrfuzzy" 
		WHEN product_page_seen = "/the-forever-love-bear" THEN "lovebear"
		ELSE "check logic.."
	END AS product_seen,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shippingt_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM
	(
    SELECT
	sessions_seeing_product_pages.website_session_id,
    sessions_seeing_product_pages.product_page_seen,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM sessions_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
ORDER BY 
	sessions_seeing_product_pages.website_session_id,
    website_pageviews.created_at
    ) AS pageview_level
GROUP BY 1, 2;
    
-- aggregating the data to assess funnel performance
SELECT
	product_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN cart_made_it= 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shippingt_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_conversion_funnel
GROUP BY 1;

-- converting into click rates
SELECT
	product_seen,
	COUNT(DISTINCT CASE WHEN cart_made_it= 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS product_click_rate,
    COUNT(DISTINCT CASE WHEN shippingt_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN cart_made_it= 1 THEN website_session_id ELSE NULL END) AS cart_click_rate,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN shippingt_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rate
FROM session_level_conversion_funnel
GROUP BY 1;


-- Cross-Selling Performance Analysis
-- identifying the relevant /cart page views and their sessions
CREATE TEMPORARY TABLE sessions_seeing_cart
SELECT
	website_session_id AS cart_session_id,
    website_pageview_id AS cart_pageview_id,
    CASE 
		WHEN created_at < "2013-09-25" THEN "A.Pre_Cross_Sell" 
		WHEN created_at >= "2013-09-25" THEN "B.Post_Cross_Sell"
	ELSE NULL
	END AS time_period
FROM website_pageviews
WHERE 
	pageview_url = "/cart"
	AND created_at >= "2013-08-25"
    AND created_at < "2013-10-25";
 
 -- identifying which of those sessions clicked through to the shipping page
 CREATE TEMPORARY TABLE cart_sessions_seeing_another_page
 SELECT
	sessions_seeing_cart.cart_session_id,
    sessions_seeing_cart.time_period,
    MIN(website_pageviews.website_pageview_id) AS pageview_id_after_cart
FROM sessions_seeing_cart
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = sessions_seeing_cart.cart_session_id
        AND website_pageviews.website_pageview_id > sessions_seeing_cart.cart_pageview_id
GROUP BY 1, 2
HAVING MIN(website_pageviews.website_pageview_id) IS NOT NULL;

-- finding the orders associated with the /cart sessions
-- analyzing the purchased products, AOV
CREATE TEMPORARY TABLE pre_post_sessions_and_orders
SELECT
	sessions_seeing_cart.time_period,
	sessions_seeing_cart.cart_session_id,
    orders.order_id,
    orders.items_purchased,
    orders.price_usd
FROM sessions_seeing_cart
	JOIN orders
		ON orders.website_session_id = sessions_seeing_cart.cart_session_id;


-- joining the new tables
SELECT
	sessions_seeing_cart.time_period,
	sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_sessions_and_orders.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_sessions_and_orders.items_purchased,
    pre_post_sessions_and_orders.price_usd
FROM sessions_seeing_cart
	LEFT JOIN cart_sessions_seeing_another_page
		ON cart_sessions_seeing_another_page.cart_session_id = sessions_seeing_cart.cart_session_id
	LEFT JOIN pre_post_sessions_and_orders
		ON pre_post_sessions_and_orders.cart_session_id = sessions_seeing_cart.cart_session_id
ORDER BY cart_session_id;

-- Summarizing the data
SELECT
	time_period,
	COUNT(DISTINCT cart_session_id) AS cart_sessions,
    SUM(clicked_to_another_page) AS clickthroughs,
	SUM(clicked_to_another_page) / COUNT(DISTINCT cart_session_id) AS cart_ctr,
    -- SUM(placed_order) AS orders_placed,
    -- SUM(items_purchased) AS products_purchased,
    SUM(items_purchased) /  SUM(placed_order) AS products_per_order,
    -- SUM(price_usd) AS revenue,
    SUM(price_usd) / SUM(placed_order) AS average_order_value,
    SUM(price_usd) / COUNT(DISTINCT cart_session_id) AS rev_per_cart_session
    
FROM
	(
    SELECT
		sessions_seeing_cart.time_period,
		sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_sessions_and_orders.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
		pre_post_sessions_and_orders.items_purchased,
		pre_post_sessions_and_orders.price_usd
	FROM sessions_seeing_cart
		LEFT JOIN cart_sessions_seeing_another_page
			ON cart_sessions_seeing_another_page.cart_session_id = sessions_seeing_cart.cart_session_id
		LEFT JOIN pre_post_sessions_and_orders
			ON pre_post_sessions_and_orders.cart_session_id = sessions_seeing_cart.cart_session_id
	ORDER BY cart_session_id
    ) AS full_data
GROUP BY time_period;


-- Product Portofolio Expansion
-- pre-post analysis for the impact of launching of a new product
SELECT
    CASE
		WHEN website_sessions.created_at < "2013-12-12" THEN "A.Pre_Birthday_Bear"
        WHEN website_sessions.created_at >= "2013-12-12" THEN "B.Post_Birthday_Bear"
		ELSE NULL
	END AS time_period,
    -- COUNT(DISTINCT website_sessions.website_session_id)  AS sessions,
    -- COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate,
	-- SUM(orders.price_usd) AS revenue
    SUM(orders.price_usd) / COUNT(DISTINCT orders.order_id) AS AOV,
    -- COUNT(DISTINCT orders.items_purchased) AS products_purchased,
    SUM(orders.items_purchased) / COUNT(DISTINCT orders.order_id) AS products_per_order,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at between "2013-11-12" AND "2014-01-12"
GROUP BY time_period;
   
   
-- Analyzing Product Refund Rates
-- monthly product refund rates, by product
SELECT 
	YEAR(order_items.created_at) AS yr,
    MONTH(order_items.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_orders,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN order_item_refunds.order_item_id ELSE NULL END)  
			/ COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_refunds,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_orders,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN order_item_refunds.order_item_id ELSE NULL END)  
			/ COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_refunds,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_orders, 
	COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN order_item_refunds.order_item_id ELSE NULL END)  
			/ COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_refunds,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_orders,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN order_item_refunds.order_item_id ELSE NULL END)  
			/ COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_refunds
FROM order_items
	LEFT JOIN order_item_refunds
		ON order_item_refunds.order_item_id = order_items.order_item_id
WHERE order_items.created_at < "2014-10-15"
GROUP BY
	YEAR(order_items.created_at),
    MONTH(order_items.created_at);
    

-- USER ANALYSIS

-- Identifying repeat visitors
-- identifying the relevant new sessions
SELECT 
	user_id,
    website_session_id
FROM website_sessions
WHERE 
	created_at BETWEEN "2014-01-01" AND "2014-11-01"
    AND is_repeat_session = 0;

-- identifying the user_id values to find any repeat sessions those users had
CREATE TEMPORARY TABLE sessions_w_repeats
SELECT
	new_sessions.user_id,
	new_sessions.website_session_id AS new_session_id,
	website_sessions.website_session_id AS repeat_session_id
FROM
(
SELECT 
	user_id,
    website_session_id
FROM website_sessions
WHERE 
	created_at BETWEEN "2014-01-01" AND "2014-11-01"
    AND is_repeat_session = 0
) AS new_sessions
	LEFT JOIN website_sessions
		ON website_sessions.user_id = new_sessions.user_id
		AND website_sessions.is_repeat_session = 1
        -- AND website_sessions.website_session_id > new_sessions.website_session_id
		AND website_sessions.created_at BETWEEN "2014-01-01" AND "2014-11-01";
        
-- analyzing the data at the user level: how many sessions did each user have?
SELECT
	user_id,
    COUNT(DISTINCT new_session_id) AS new_sessions,
    COUNT(DISTINCT repeat_session_id) AS repeat_sessions
FROM sessions_w_repeats
GROUP BY user_id
ORDER BY 3 DESC;

-- aggregating the user-level analysis to generate the behavioral analysis
SELECT
	repeat_sessions,
    COUNT(DISTINCT user_id) AS users
FROM
(
SELECT
	user_id,
    COUNT(DISTINCT new_session_id) AS new_sessions,
    COUNT(DISTINCT repeat_session_id) AS repeat_sessions
FROM sessions_w_repeats
GROUP BY user_id
ORDER BY 3 DESC
) AS user_level
GROUP BY 1;

-- Analyzing time to repeat
-- identifying the new sessions and when they were created
SELECT
	website_session_id AS new_session_id, 
    created_at,
    user_id
FROM website_sessions
WHERE 
	created_at BETWEEN "2014-01-01" AND "2014-11-03"
	AND is_repeat_session = 0;
    
-- identifying the second session and its created_at
CREATE TEMPORARY TABLE first_and_second_session
SELECT
	new_sessions.user_id,
	new_session_id,
    website_sessions.website_session_id AS second_session_id,
    new_sessions.created_at AS new_session_created_at,
    website_sessions.created_at AS second_session_created_at
FROM
(
SELECT
	website_session_id AS new_session_id, 
    created_at,
    user_id
FROM website_sessions
WHERE 
	created_at >= "2014-01-01" 
    AND created_at < "2014-11-03"
	AND is_repeat_session = 0
) AS new_sessions
	LEFT JOIN website_sessions
		ON website_sessions.user_id = new_sessions.user_id
        AND website_sessions.is_repeat_session = 1
        AND website_sessions.website_session_id > new_sessions.new_session_id
        AND website_sessions.created_at >= "2014-01-01" 
        AND website_sessions.created_at < "2014-11-03";

-- calculating the difference
CREATE TEMPORARY TABLE users_first_to_second
SELECT
	user_id,
    DATEDIFF(second_sess_created_at, first_sess_created_at) AS days_first_to_second_sess
FROM
(
SELECT
	user_id,
    new_session_id AS first_sess_id,
    MIN(second_session_id) AS second_sess_id,
    new_session_created_at AS first_sess_created_at,
    MIN(second_session_created_at) AS second_sess_created_at
FROM first_and_second_session
WHERE second_session_id IS NOT NULL
GROUP BY 1, 2, 4
) AS first_second;

-- aggregating the data
SELECT
	AVG(days_first_to_second_sess) AS avg_days_first_to_second,
	MIN(days_first_to_second_sess) AS min_days_first_to_second,
	MAX(days_first_to_second_sess) AS max_days_first_to_second
FROM users_first_to_second;

-- Analyzing Repeat Channel Behavior
-- comparing new vs repeat sessions by channel
SELECT 
	CASE 
		WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN "organic_search"
		WHEN utm_campaign = "brand" THEN "paid_brand"
        WHEN utm_campaign IS NULL AND http_referer IS NULL THEN "direct_type_in"
        WHEN utm_campaign = "nonbrand" THEN "paid_nonbrand"
        WHEN utm_source = "socialbook" THEN "paid_social"
	ELSE "check logic.."
    END AS channel_group,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE 
	created_at BETWEEN "2014-01-01" AND "2014-11-05"
GROUP BY 1;
    
-- Analyzing new & repeat conversion rates
-- CVR & revenue comparison: new vs repeat sessions
SELECT
	website_sessions.is_repeat_session,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    -- COUNT(DISTINCT orders.order_id) AS orders,
    ROUND(COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id), 2) AS conv_rate,
    -- SUM(orders.price_usd) AS revenue,
    ROUND(SUM(orders.price_usd) /  COUNT(DISTINCT website_sessions.website_session_id), 2) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		on orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN "2014-01-01" AND "2014-11-08"
GROUP BY 1;




-- Telling the company's growth story over the first 3 years, using trended performance data

-- Question 1: pulling overall session and order volume, trended by quarter
SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < "2015-01-01"
GROUP BY
	YEAR(website_sessions.created_at),
    QUARTER(website_sessions.created_at);
    
-- Question 2: quarterly figures: session-to-order CVR, revenue per order/ per session
SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    ROUND(COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id), 2) AS conversion_rate,
    ROUND(SUM(orders.price_usd) / COUNT(DISTINCT orders.order_id), 2) AS revenue_per_order,
	ROUND(SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id), 2) AS revenue_per_session
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < "2015-01-01"
GROUP BY
	YEAR(website_sessions.created_at),
    QUARTER(website_sessions.created_at);
    
-- Question 3: quarterly view of orders by channel
SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT CASE WHEN utm_source = "gsearch" AND utm_campaign = "nonbrand" THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN utm_source = "bsearch" AND utm_campaign = "nonbrand" THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = "brand" THEN orders.order_id ELSE NULL END) AS brand_search_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_type_in_orders 
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < "2015-01-01"
GROUP BY
	YEAR(website_sessions.created_at),
    QUARTER(website_sessions.created_at);
    
-- Question 4: quarterly session-to-order CVR trends by channel
SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qtr,
    COUNT(DISTINCT CASE WHEN utm_source = "gsearch" AND utm_campaign = "nonbrand" THEN orders.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_source = "gsearch" AND utm_campaign = "nonbrand" THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rate,
    COUNT(DISTINCT CASE WHEN utm_source = "bsearch" AND utm_campaign = "nonbrand" THEN orders.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_source = "bsearch" AND utm_campaign = "nonbrand" THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rate,
	COUNT(DISTINCT CASE WHEN utm_campaign = "brand" THEN orders.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_campaign = "brand" THEN website_sessions.website_session_id ELSE NULL END) AS brand_search_conv_rate,
	COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_conv_rate,
    COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conv_rate 
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < "2015-01-01"
GROUP BY
	YEAR(website_sessions.created_at),
    QUARTER(website_sessions.created_at);
    
-- Question 5: pulling monthly trends for revenue and margin by product, along with total sales and total margin
SELECT
	YEAR(order_items.created_at) AS yr,
    MONTH(order_items.created_at) AS mo,
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items
GROUP BY
	YEAR(order_items.created_at),
    MONTH(order_items.created_at)
ORDER BY 1, 2;


-- Question 6: monthly sessions to the /products page
-- showing how the % of those sessions clicking through another page has changed over time
-- along with a view of how conversion from /products to placing an order has improved
CREATE TEMPORARY TABLE products_pv
SELECT
    created_at AS saw_product_page_at,
    website_session_id,
    website_pageview_id
FROM website_pageviews
WHERE pageview_url = "/products";
-- aggregating the data
SELECT
	YEAR(saw_product_page_at) AS yr,
    MONTH(saw_product_page_at) AS mo,
    COUNT(DISTINCT products_pv.website_session_id) AS sessions_to_product_page,
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,
    COUNT(DISTINCT website_pageviews.website_session_id) / COUNT(DISTINCT products_pv.website_session_id) AS clickthrough_rate,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT products_pv.website_session_id) AS cv_rate_products_to_order
FROM products_pv
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = products_pv.website_session_id
        AND website_pageviews.website_pageview_id > products_pv.website_pageview_id
	LEFT JOIN orders 
		ON orders.website_session_id = products_pv.website_session_id
GROUP BY
	YEAR(saw_product_page_at),
    MONTH(saw_product_page_at);
    
-- Question 7: pulling sales data since the 4th product has been launched as a primary product
-- showing how well each product cross-sells from one another

-- identifying the relevant orders
CREATE TEMPORARY TABLE primary_products
SELECT
		order_id,
        primary_product_id,
        created_at AS ordered_at
FROM orders
WHERE created_at >= "2014-12-05";
-- identifying the cross-sells
CREATE TEMPORARY TABLE primary_w_cross_sells
SELECT
	primary_products.order_id,
    primary_products.ordered_at,
    primary_products.primary_product_id,
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0;
-- aggregating the data
SELECT
	primary_product_id,
	COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p1_xsale_rate,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p2_xsale_rate,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p3_xsale_rate,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS xsold_p4,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p4_xsale_rate
FROM primary_w_cross_sells
GROUP BY 1;