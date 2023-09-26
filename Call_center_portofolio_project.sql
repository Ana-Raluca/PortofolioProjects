CREATE DATABASE CallCenterProject;
USE CallCenterProject;

CREATE TABLE calls(
id VARCHAR(100),
customer_name VARCHAR(50),	
sentiment VARCHAR(25),		
csat_score INT,
call_date VARCHAR(15),
reason VARCHAR(25),	
city VARCHAR(25),
state VARCHAR(25),
communication_channel VARCHAR(25),		
response_time VARCHAR(25),	
call_duration INT,	
call_center VARCHAR(25)	
);

-- STANDARDIZE DATE FORMAT
SET SQL_SAFE_UPDATES = 0;

UPDATE calls 
SET call_date = STR_TO_DATE(call_date, '%m/%d/%Y');

SET SQL_SAFE_UPDATES = 1;
SELECT * FROM calls;

-- OVERVIEW
SELECT COUNT(*) AS row_num,
       (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'calls') AS cols_num
FROM calls;

SELECT ROUND(AVG(csat_score), 2) AS average_csat,
       ROUND(AVG(call_duration), 2) AS average_call_duration,
       COUNT(*) AS number_of_calls
FROM calls;
       
-- THE BUSIEST CALL CENTER
SELECT DISTINCT call_center FROM calls;
SELECT call_center,
       COUNT(*) AS total,
       CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM calls)) * 100, 1), '%') AS percentage
FROM calls
GROUP BY call_center
ORDER BY total DESC;

-- CALLS WITHIN, BELOW OR ABOVE THE SERVICE LEVEL AGREEMENT TIME
SELECT call_center,
	   response_time,
       COUNT(*) AS total_responses
FROM calls
GROUP BY call_center,
         response_time
ORDER BY call_center, 
         COUNT(*) DESC;
         
-- THE USER WITH THE HIGHEST NUMBER OF CALLS
SELECT id, 
       customer_name,
       COUNT(*) AS total_calls
FROM calls
GROUP BY 1,2
ORDER BY 3 DESC;

-- WHICH DAY HAS THE MOST CALLS?
SELECT DAYNAME(call_date) AS day_of_call,
	   COUNT(*) AS number_of_calls
FROM calls
GROUP BY day_of_call
ORDER BY number_of_calls DESC;

-- FAVOURITE CHANNEL OF COMMUNICATION
SELECT DISTINCT communication_channel FROM calls;
SELECT communication_channel,
       COUNT(*) AS total,
       CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM calls)) * 100, 1), '%') AS percentage
FROM calls
GROUP BY communication_channel
ORDER BY percentage DESC;

-- THE MOST COMMON REASON FOR CALLING
SELECT DISTINCT reason FROM calls;
SELECT reason,
       COUNT(*) AS total,
       CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM calls)) * 100, 1), '%') AS percentage
FROM calls
GROUP BY reason
ORDER BY percentage DESC;

-- NUMBER OF CALL CENTERS BY STATE
SELECT state,
       COUNT(*) as total
FROM calls
GROUP BY state ORDER BY total DESC;

-- STATES AND THEIR MOST COMMON REASONS FOR CALLING
SELECT state,
       reason,
       COUNT(*) AS total
FROM calls
GROUP BY state, reason
ORDER BY  state, total;

-- COMMON REASONS FOR CALLING BY CITY
SELECT city,
       state,
	   reason,
       COUNT(*) AS total_calls
FROM calls 
GROUP BY 1, 2, 3
ORDER BY 1, 3;

-- SENTIMENTS ACROSS STATES
SELECT state,
	   sentiment,
       COUNT(*) AS total
FROM calls
GROUP BY state, sentiment
ORDER BY state, total DESC;

-- STATES BY CUSTOMER SATISFACTION
SELECT state,
       ROUND(AVG(csat_score),2) AS average_csat
FROM calls
GROUP BY state ORDER BY average_csat DESC;

-- CUSTOMER SATISFACTION OVERVIEW
SELECT MIN(csat_score) as min_score,
	   MAX(csat_score) as max_score,
       ROUND(AVG(csat_score), 2) as avg_score
FROM calls WHERE csat_score IS NOT NULL;

--  AVERAGE CALL DURATION IN MINUTES BY CALL CENTER
SELECT call_center,
	   AVG(call_duration) AS average_call 
FROM calls
GROUP BY call_center ORDER BY average_call;

-- ARE SHORT CALLS SPECIFIC TO POSITIVE CONVERSATIONS?
SELECT sentiment,
	   ROUND(AVG(call_duration),2) as call_duration
FROM calls
GROUP BY 1 ORDER BY 2;

-- THE LONGEST CALL: month and year
SELECT MONTHNAME(call_date) AS month,
       YEAR(call_date) as year,
       CONCAT(MAX(call_duration) OVER(PARTITION BY call_date), ' ', 'minutes') AS call_duration
FROM calls
ORDER BY 2 DESC LIMIT 1;


