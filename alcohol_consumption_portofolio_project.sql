CREATE DATABASE alcohol_consumption;
USE alcohol_consumption;

CREATE TABLE beer_consumption(
	entity VARCHAR(100),
    the_year YEAR,
    litres_per_person DOUBLE
);
SELECT * FROM beer_consumption WHERE entity = 'Romania';

CREATE TABLE wine_consumption(
	entity VARCHAR(100),
    the_year VARCHAR(10),
    litres_per_person DOUBLE
);
SELECT * FROM wine_consumption WHERE entity = 'Romania';

CREATE TABLE spirits_consumption(
	entity VARCHAR(100),
    the_year VARCHAR(10),
    litres_per_person DOUBLE
);
SELECT * FROM spirits_consumption WHERE entity = 'Romania';

CREATE TABLE alcohol_disorders(
	entity VARCHAR(100),
    the_year VARCHAR(10),
    alcohol_disorders_dalys DOUBLE
);
SELECT * FROM alcohol_disorders WHERE entity = 'Romania';

-- EXPLORING THE DATA
SELECT CONCAT(MIN(litres_per_person), ' ', 'L') AS min_annual_beer_consumption,
       CONCAT(MAX(litres_per_person), ' ', 'L') AS max_annual_beer_consumption,
	   CONCAT(ROUND(AVG(litres_per_person), 2), ' ', 'L') AS avg_annual_beer_consumption
FROM beer_consumption;

SELECT CONCAT(MIN(litres_per_person), ' ', 'L') AS min_annual_wine_consumption,
       CONCAT(MAX(litres_per_person), ' ', 'L') AS max_annual_wine_consumption,
	   CONCAT(ROUND(AVG(litres_per_person), 2), ' ', 'L') AS avg_annual_wine_consumption
FROM wine_consumption;

SELECT CONCAT(MIN(litres_per_person), ' ', 'L') AS min_annual_spirits_consumption,
       CONCAT(MAX(litres_per_person), ' ', 'L') AS max_annual_spirits_consumption,
	   CONCAT(ROUND(AVG(litres_per_person), 2), ' ', 'L') AS avg_annual_spirits_consumption
FROM spirits_consumption;
       
-- HIGHEST ANNUAL ALCOHOL CONSUMPTION AROUND THE GLOBE (1961 - 2019)
-- BEER
SELECT *
FROM beer_consumption
WHERE litres_per_person IS NOT NULL
ORDER BY litres_per_person DESC;

-- WINE
SELECT *
FROM wine_consumption
WHERE litres_per_person IS NOT NULL
ORDER BY litres_per_person DESC;

-- SPIRITS
SELECT *
FROM spirits_consumption
WHERE litres_per_person IS NOT NULL
ORDER BY litres_per_person DESC;

-- ESWATINI, FRANCE AND MOLODVA: IS THE DATA POINTING TOWARDS A HIGH CONSUMPTION OF ALL ALCOHOL TYPES?
-- BETWEEN 1961 AND 2000
SELECT beer_consumption.entity AS entity,
       beer_consumption.the_year AS year,
	   beer_consumption.litres_per_person AS beer_litres_per_person,
       MAX(beer_consumption.litres_per_person) OVER( PARTITION BY entity) as maximum,
	   wine_consumption.litres_per_person AS wine_litres_per_person,
	   MAX(wine_consumption.litres_per_person) OVER( PARTITION BY entity) as maximum,
       spirits_consumption.litres_per_person AS spirits_litres_per_person,
	   MAX(spirits_consumption.litres_per_person) OVER( PARTITION BY entity) as maximum
FROM beer_consumption
JOIN wine_consumption ON beer_consumption.entity = wine_consumption.entity
JOIN spirits_consumption ON beer_consumption.entity = spirits_consumption.entity
WHERE (beer_consumption.entity = 'Eswatini' OR
       wine_consumption.entity = 'Eswatini'OR
       spirits_consumption.entity = 'Eswatini' OR
       beer_consumption.entity = 'France' OR
       wine_consumption.entity = 'France'OR
       spirits_consumption.entity = 'France' OR
       beer_consumption.entity = 'Moldova' OR
       wine_consumption.entity = 'Moldova'OR
       spirits_consumption.entity = 'Moldova') 
       AND (beer_consumption.litres_per_person AND wine_consumption.litres_per_person AND spirits_consumption.litres_per_person) IS NOT NULL
       AND beer_consumption.the_year = wine_consumption.the_year
       AND beer_consumption.the_year = spirits_consumption.the_year
       AND beer_consumption.the_year BETWEEN 1961 AND 2000
       AND wine_consumption.the_year BETWEEN 1961 AND 2000
       AND spirits_consumption.the_year BETWEEN 1961 AND 2000
ORDER BY entity, year;

-- BETWEEN 2001 AND 2019
SELECT beer_consumption.entity AS entity,
       beer_consumption.the_year AS year,
	   beer_consumption.litres_per_person AS beer_litres_per_person,
       MAX(beer_consumption.litres_per_person) OVER( PARTITION BY entity) as maximum,
	   wine_consumption.litres_per_person AS wine_litres_per_person,
	   MAX(wine_consumption.litres_per_person) OVER( PARTITION BY entity) as maximum,
       spirits_consumption.litres_per_person AS spirits_litres_per_person,
	   MAX(spirits_consumption.litres_per_person) OVER( PARTITION BY entity) as maximum
FROM beer_consumption
JOIN wine_consumption ON beer_consumption.entity = wine_consumption.entity
JOIN spirits_consumption ON beer_consumption.entity = spirits_consumption.entity
WHERE (beer_consumption.entity = 'Eswatini' OR
       wine_consumption.entity = 'Eswatini'OR
       spirits_consumption.entity = 'Eswatini' OR
       beer_consumption.entity = 'France' OR
       wine_consumption.entity = 'France'OR
       spirits_consumption.entity = 'France' OR
       beer_consumption.entity = 'Moldova' OR
       wine_consumption.entity = 'Moldova'OR
       spirits_consumption.entity = 'Moldova') 
       AND (beer_consumption.litres_per_person AND wine_consumption.litres_per_person AND spirits_consumption.litres_per_person) IS NOT NULL
       AND beer_consumption.the_year = wine_consumption.the_year
       AND beer_consumption.the_year = spirits_consumption.the_year
       AND beer_consumption.the_year >= 2001
       AND wine_consumption.the_year >= 2001
       AND spirits_consumption.the_year >= 2001
ORDER BY entity, year;

-- ANNUAL LOWEST ALCOHOL CONSUMPTION (1961 - 2019)
-- BEER
SELECT *
FROM beer_consumption
WHERE litres_per_person IS NOT NULL
ORDER BY litres_per_person;

-- WINE
SELECT *
FROM wine_consumption
WHERE litres_per_person IS NOT NULL
ORDER BY litres_per_person;

-- SPIRITS
SELECT *
FROM spirits_consumption
WHERE litres_per_person IS NOT NULL
ORDER BY litres_per_person;

-- MAXIMUM  ALCOHOL CONSUMPTION BY COUNTRY vs ANNUAL ALCOHOL CONSUMPTION PER CAPITA TOP 20
-- BEER
SELECT entity,
       the_year,
       litres_per_person,
       MAX(litres_per_person) OVER(PARTITION BY entity) AS max_annual_consumption
FROM beer_consumption
WHERE litres_per_person IS NOT NULL
ORDER BY litres_per_person DESC, max_annual_consumption DESC LIMIT 20;

-- WINE
SELECT entity,
       the_year,
       litres_per_person,
       MAX(litres_per_person) OVER(PARTITION BY entity) AS max_by_country
FROM wine_consumption
WHERE litres_per_person IS NOT NULL
ORDER BY litres_per_person DESC, max_by_country DESC LIMIT 20;

-- SPIRITS
SELECT entity,
       the_year,
       litres_per_person,
       MAX(litres_per_person) OVER(PARTITION BY entity) AS max_by_country
FROM spirits_consumption
WHERE litres_per_person IS NOT NULL
ORDER BY litres_per_person DESC, max_by_country DESC LIMIT 20;

-- MAXIMUM TOTAL ALCOHOL CONSUMPTION PER CAPITA 1961 - 2019
-- TOP 20 BEER 
 SELECT entity,
        ROUND(SUM(litres_per_person), 2) AS litres_of_beer
FROM beer_consumption
GROUP BY 1 
ORDER BY 2 DESC LIMIT 20;

-- TOP 20 WINE
 SELECT entity,
        ROUND(SUM(litres_per_person), 2) AS litres_of_wine
FROM wine_consumption
GROUP BY 1 
ORDER BY 2 DESC LIMIT 20;

-- TOP 20 SPIRITS
 SELECT entity,
        ROUND(SUM(litres_per_person), 2) AS litres_of_spirits
FROM spirits_consumption
GROUP BY 1 
ORDER BY 2 DESC LIMIT 20;

-- COUNTRIES BY ANY ALCOHOL TYPE
 SELECT entity,
        ROUND(SUM(beer_litres_per_person + wine_litres_per_person + spirits_litres_per_person), 2) AS litres_of_alcohol
FROM alcohol_consumption
GROUP BY 1 
ORDER BY 2 DESC;

-- CREATING A VIEW IN ORDER TO COMPARE THE THREE ALCOHOL CATEGORIES
CREATE VIEW alcohol_consumption AS
SELECT  beer_consumption.entity,
		beer_consumption.the_year,
        beer_consumption.litres_per_person AS beer_litres_per_person,
        wine_consumption.litres_per_person AS wine_litres_per_person,
        spirits_consumption.litres_per_person AS spirits_litres_per_person
FROM beer_consumption 
JOIN wine_consumption ON beer_consumption.entity = wine_consumption.entity
JOIN spirits_consumption ON beer_consumption.entity = spirits_consumption.entity
WHERE 
	beer_consumption.litres_per_person AND wine_consumption.litres_per_person AND spirits_consumption.litres_per_person IS NOT NULL
	AND beer_consumption.the_year = wine_consumption.the_year
    AND beer_consumption.the_year = spirits_consumption.the_year;
 
 -- ALCOHOL CONSUMPTION PER CAPITA BETWEEN 2000 AND 2019
 SELECT entity,
	    the_year,
        ROUND(beer_litres_per_person + wine_litres_per_person + spirits_litres_per_person, 3) AS alcohol_quantity_per_capita
 FROM alcohol_consumption
 WHERE the_year < 2000
 ORDER BY alcohol_quantity_per_capita desc;
 
 -- TOTAL ALCOHOL CONSUMPTION BY COUNTRY 
 -- 1961 - 1999
  SELECT entity,
        ROUND(SUM(beer_litres_per_person + wine_litres_per_person + spirits_litres_per_person), 3) AS alcohol_quantity
 FROM alcohol_consumption
 WHERE the_year < 2000
 GROUP BY entity
 ORDER BY alcohol_quantity desc;
 
 -- 2000- 2019
SELECT entity,
        ROUND(SUM(beer_litres_per_person + wine_litres_per_person + spirits_litres_per_person), 3) AS alcohol_quantity
 FROM alcohol_consumption
 WHERE the_year >= 2000
 GROUP BY entity
 ORDER BY alcohol_quantity desc;
 
-- MAXIMUM ANNUAL ALCOHOL CONSUMPTION PER CAPITA
SELECT  
		MAX(beer_litres_per_person + wine_litres_per_person + spirits_litres_per_person) AS alcohol_consumption_per_capita_yearly
FROM alcohol_consumption;

-- EXPLORING DATA ABOUT DISABILITY ADJUSTED LIFE FROM ALCOHOL USE DISORDERS
-- DALYs: the sum of the Years of Life Lost (YLL) due to premature mortality in the population 
--        and the Years Lost due to Disability (YLD) for incident cases of the health condition.
SELECT MIN(alcohol_disorders_dalys) AS min_dalys,
       MAX(alcohol_disorders_dalys) AS max_dalys,
	   ROUND(AVG(alcohol_disorders_dalys), 2) AS avg_dalys
FROM alcohol_disorders;

-- COUNTRIES BY THEIR DALYs
SELECT entity,
       ROUND(SUM(alcohol_disorders_dalys), 2) AS age_standardised_dalys
FROM alcohol_disorders
WHERE the_year >= 2000
GROUP BY 1 
ORDER BY 2 DESC;

SELECT entity,
       ROUND(SUM(alcohol_disorders_dalys), 2) AS age_standardised_dalys
FROM alcohol_disorders
WHERE the_year < 2000
GROUP BY 1 
ORDER BY 2 DESC;

-- GUATEMALA HAD THE HIGHEST DALY IN 1993. LET'S EXPLORE THE DATA ABOUT THEIR ALCOHOL CONSUMPTION
SELECT alcohol_consumption.entity,
       alcohol_consumption.the_year,
       ROUND((beer_litres_per_person + wine_litres_per_person + spirits_litres_per_person), 2) AS alcohol_consumption,
       alcohol_disorders.alcohol_disorders_dalys
FROM alcohol_consumption
JOIN alcohol_disorders ON alcohol_consumption.entity = alcohol_disorders.entity
WHERE alcohol_consumption.entity = 'Guatemala' AND alcohol_consumption.the_year = alcohol_disorders.the_year
ORDER BY alcohol_disorders_dalys DESC;

-- LOWEST ANNUAL ALCOHOL DISORDERS DALYs vs ALCOHOL COMSUMPTION AROUND THE GLOBE
SELECT alcohol_consumption.entity,
       alcohol_consumption.the_year,
       ROUND((beer_litres_per_person + wine_litres_per_person + spirits_litres_per_person), 2) AS alcohol_consumption,
       alcohol_disorders.alcohol_disorders_dalys
FROM alcohol_consumption
JOIN alcohol_disorders ON alcohol_consumption.entity = alcohol_disorders.entity
WHERE alcohol_consumption.the_year = alcohol_disorders.the_year
ORDER BY alcohol_disorders_dalys;

-- ESWATINI, FRANCE AND MOLODVA: ALCOHOL DISORDERS DALYs AND ALCOHOL COMSUMPTION 1961- 2019
SELECT alcohol_consumption.entity,
       ROUND(SUM((beer_litres_per_person + wine_litres_per_person + spirits_litres_per_person)), 2) AS alcohol_consumption,
       ROUND(SUM(alcohol_disorders.alcohol_disorders_dalys), 2) AS alcohol_disorders_dalys
FROM alcohol_consumption
JOIN alcohol_disorders ON alcohol_consumption.entity = alcohol_disorders.entity
WHERE alcohol_consumption.entity = 'Eswatini'
	  OR alcohol_consumption.entity = 'France' 
      OR alcohol_consumption.entity = 'Moldova' 
      AND alcohol_consumption.the_year = alcohol_disorders.the_year
GROUP BY 1
ORDER BY alcohol_disorders_dalys DESC;

--  ALCOHOL DISORDERS DALYs AND ALCOHOL COMSUMPTION 1961- 2019
SELECT alcohol_consumption.entity,
       ROUND(SUM((beer_litres_per_person + wine_litres_per_person + spirits_litres_per_person)), 2) AS alcohol_consumption,
       ROUND(SUM(alcohol_disorders.alcohol_disorders_dalys), 2) AS alcohol_disorders_dalys
FROM alcohol_consumption
JOIN alcohol_disorders ON alcohol_consumption.entity = alcohol_disorders.entity
WHERE alcohol_consumption.the_year = alcohol_disorders.the_year
GROUP BY 1
ORDER BY alcohol_disorders_dalys DESC;