CREATE DATABASE formula1;
USE formula1;

CREATE TABLE drivers(
	driver_id	INT,
	driver_ref	VARCHAR(50),
    driver_code	VARCHAR(10),
    forename VARCHAR(25),
    surname	VARCHAR(25),
    date_of_birth DATE,
    nationality VARCHAR(25)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/f1_drivers.csv' INTO TABLE drivers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM drivers;

CREATE TABLE races(
	race_id	INT,
    race_year YEAR,
    rounds INT,
    circuit_id INT,
    race_name VARCHAR(50),	
    race_date DATE,
    race_time TIME,
    fp1_date DATE,
    fp1_time TIME,
    fp2_date DATE,
    fp2_time TIME,
    fp3_date DATE,
    fp3_time TIME,
    quali_date DATE,
    quali_time TIME
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/f1_races.csv' INTO TABLE races
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\r\n"
IGNORE 1 LINES
(race_id, race_year, rounds, circuit_id, race_name, race_date, @race_time, @fp1_date, @fp1_time, @fp2_date, @fp2_time, @fp3_date, @fp3_time, @quali_date, @quali_time)
SET race_time = NULLIF(@race_time, ''),
	fp1_date = NULLIF(@fp1_date, ''),
    fp1_time = NULLIF(@fp1_time, ''),
    fp2_date = NULLIF(@fp2_date, ''),
    fp2_time = NULLIF(@fp2_time, ''),
    fp3_date = NULLIF(@fp3_date, ''),	
    fp3_time = NULLIF(@fp3_time, ''),
    quali_date = NULLIF(@quali_date, ''),
    quali_time = NULLIF(@quali_time, '');
SELECT * FROM races;

CREATE TABLE results(
	result_id INT,	
    race_id INT,
    driver_id INT,
    constructor_id INT,	
    grid_position INT,
    final_position INT,
    points INT,
    laps INT,
    fastest_lap INT,
    ranking INT,
    fastest_lap_time TIME,	
    fastest_lap_speed	DOUBLE,
    status_id INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/results.csv' INTO TABLE results
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\r\n"
IGNORE 1 LINES
(result_id, race_id, driver_id, constructor_id, grid_position, final_position, points, laps, @fastest_lap, @ranking, @fastest_lap_time, @fastest_lap_speed, @status_id)
SET fastest_lap = NULLIF(@fastest_lap, ''), 
	ranking = NULLIF(@ranking, ''),
    fastest_lap_time = NULLIF(@fastest_lap_time, ''),
    fastest_lap_speed = NULLIF(@fastest_lap_speed, ''),
    status_id = NULLIF(@status_id, '');    
SELECT * FROM results;

-- The full name of the oldest F1 driver
SELECT CONCAT(forename, ' ', surname) AS full_name,
	   date_of_birth
FROM drivers 
ORDER BY YEAR(date_of_birth) LIMIT 1;

-- The 5 youngest F1 drivers at the moment
SELECT CONCAT(forename, ' ', surname) AS full_name,
	   date_of_birth
FROM drivers 
ORDER BY YEAR(date_of_birth) DESC LIMIT 5;

-- Where are the most drivers coming from?
 SELECT nationality,
        COUNT(*) AS number_of_drivers
 FROM drivers 
 GROUP BY nationality 
 ORDER BY number_of_drivers DESC;
 
 -- Has there ever been a Romanian F1 driver?
 SELECT * FROM drivers WHERE nationality = 'romanian';
 
-- The year when F1 began
SELECT race_year, 
	   race_name
FROM races
ORDER BY race_year;

-- the driver with the fastest lap time
SELECT drivers.driver_id,
	   CONCAT(forename, ' ', surname) AS driver,
	   fastest_lap,
	   fastest_lap_time,
	   fastest_lap_speed
FROM drivers
JOIN results ON drivers.driver_id = results.driver_id
WHERE fastest_lap_time IS NOT NULL 
ORDER BY fastest_lap_time, fastest_lap_speed LIMIT 1;

-- The involvement of women in F1
SELECT  CONCAT(forename, ' ', surname) AS full_name,
		date_of_birth,
        race_date,
        YEAR(race_date) - YEAR(date_of_birth) AS age_at_that_moment,
        nationality,
        grid_position,
        final_position,
        points,
        race_name
FROM drivers
JOIN results ON drivers.driver_id = results.driver_id
JOIN races ON results.race_id = races.race_id
WHERE forename = 'Maria' ||  
	  forename = 'Lella' ||
      forename = 'Divina' ||
	  forename = 'Desire' ||
      forename = 'Giovanna'
ORDER BY points DESC, race_date;

-- Schumacher family
SELECT  CONCAT(forename, ' ', surname) AS full_name,
		date_of_birth,
        race_date,
        race_name
FROM drivers
JOIN results on drivers.driver_id = results.driver_id
JOIN races ON results.race_id = races.race_id 
WHERE surname = 'Schumacher'
ORDER BY race_date;

-- How long did Michael Schumacher drive F1?
SELECT  CONCAT(forename, ' ', surname) AS full_name,
        MAX(race_year) AS last_race,
        MIN(race_year) AS first_race,
        CONCAT(MAX(race_year) - MIN(race_year), ' ', 'years') AS career
FROM drivers
JOIN results on drivers.driver_id = results.driver_id
JOIN races ON results.race_id = races.race_id 
WHERE surname = 'Schumacher' &&
	  forename = 'Michael';

-- Jos Verstappen vs Max Verstappen (total points)
SELECT  CONCAT(forename, ' ', surname) AS full_name,
        SUM(points) as career_points
FROM drivers
JOIN results on drivers.driver_id = results.driver_id
WHERE surname LIKE '%Verst%'
GROUP BY full_name;

-- TOP 10 - who had won the most championship points?
SELECT  CONCAT(forename, ' ', surname) AS full_name,
        SUM(points) as career_points
FROM drivers
JOIN results on drivers.driver_id = results.driver_id
GROUP BY full_name
ORDER BY career_points DESC LIMIT 10;

-- Formula 1 drivers with the highest number of pole positions
SELECT  CONCAT(forename, ' ', surname) AS full_name,
        COUNT(final_position) AS pole_positions
FROM drivers 
JOIN results ON drivers.driver_id = results.driver_id
WHERE final_position = 1
GROUP BY full_name, drivers.driver_id 
ORDER BY pole_positions DESC;

-- points earned by every nationality 
SELECT nationality,
	   SUM(points) AS total_points
FROM results
JOIN drivers ON results.driver_id = drivers.driver_id
GROUP BY nationality
ORDER BY total_points DESC;

--  Creating a view to store data about 2023
CREATE VIEW f1_2023 AS
SELECT  CONCAT(forename, ' ', surname) AS full_name,
		nationality,
        date_of_birth,
		quali_date,
        quali_time,
        race_date,
		race_time,
        race_name,
        final_position,
        points,
        laps,
        fastest_lap,
        fastest_lap_time,
        fastest_lap_speed
FROM drivers
JOIN results on drivers.driver_id = results.driver_id
JOIN races ON results.race_id = races.race_id 
WHERE YEAR(race_date) = 2023;

SELECT * 
FROM f1_2023
ORDER BY race_name, 
	     final_position;
