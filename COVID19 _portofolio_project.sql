CREATE DATABASE covid;
USE covid;

CREATE TABLE covid_deaths (
    iso_code VARCHAR(20),
    continent VARCHAR(100),
    location VARCHAR(100),
    date VARCHAR(10),
    population BIGINT,
    total_cases INT,
    new_cases INT,
    new_cases_smoothed DOUBLE,
    total_deaths INT,
    new_deaths INT,
    new_deaths_smoothed DOUBLE,
    total_cases_per_million DOUBLE,
    new_cases_per_million DOUBLE,
    new_cases_smoothed_per_million DOUBLE,
    total_deaths_per_million DOUBLE,
    new_deaths_per_million DOUBLE,
    new_deaths_smoothed_per_million DOUBLE,
    reproduction_rate DOUBLE,
    icu_patients INT,
    icu_patients_per_million DOUBLE,
    hosp_patients INT,
    hosp_patients_per_million DOUBLE,
    weekly_icu_admissions INT,
    weekly_icu_admissions_per_million DOUBLE,
    weekly_hosp_admissions INT,
    weekly_hosp_admissions_per_million DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/covid_deaths.csv' INTO TABLE covid_deaths
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\r\n"
IGNORE 1 LINES
(iso_code, @continent, location, date, population, @total_cases, @new_cases, @new_cases_smoothed, @total_deaths, @new_deaths, @new_deaths_smoothed, @total_cases_per_million, @new_cases_per_million, @new_cases_smoothed_per_million, @total_deaths_per_million, @new_deaths_per_million, @new_deaths_smoothed_per_million, @reproduction_rate, @icu_patients, @icu_patients_per_million, @hosp_patients, @hosp_patients_per_million, @weekly_icu_admissions, @weekly_icu_admissions_per_million, @weekly_hosp_admissions, @weekly_hosp_admissions_per_million)
SET continent = NULLIF(@continent, 'NULL'),
    total_cases = NULLIF(@total_cases, 'NULL'),
    new_cases = NULLIF(@new_cases, 'NULL'),
    new_cases_smoothed = NULLIF(@new_cases_smoothed, 'NULL'), 
    total_deaths = NULLIF(@total_deaths, 'NULL'),
    new_deaths = NULLIF(@new_deaths, 'NULL'), 
    new_deaths_smoothed = NULLIF(@new_deaths_smoothed, 'NULL'),
    total_cases_per_million = NULLIF(@total_cases_per_million, 'NULL'),
    new_cases_per_million = NULLIF(@new_cases_per_million, 'NULL'),
    new_cases_smoothed_per_million = NULLIF(@new_cases_smoothed_per_million, 'NULL'), 
    total_deaths_per_million = NULLIF(@total_deaths_per_million, 'NULL'),
    new_deaths_per_million = NULLIF(@new_deaths_per_million, 'NULL'),
    new_deaths_smoothed_per_million = NULLIF(@new_deaths_smoothed_per_million, 'NULL'), 
    reproduction_rate = NULLIF(@reproduction_rate, 'NULL'),
    icu_patients = NULLIF(@icu_patients, 'NULL'),
    icu_patients_per_million = NULLIF(@icu_patients_per_million, 'NULL'), 
    hosp_patients = NULLIF(@hosp_patients, 'NULL'),
    hosp_patients_per_million = NULLIF(@hosp_patients_per_million, 'NULL'), 
    weekly_icu_admissions = NULLIF(@weekly_icu_admissions, 'NULL'),
    weekly_icu_admissions_per_million = NULLIF(@weekly_icu_admissions_per_million, 'NULL'),
    weekly_hosp_admissions = NULLIF(@weekly_hosp_admissions, 'NULL'),
    weekly_hosp_admissions_per_million = NULLIF(@weekly_hosp_admissions_per_million, 'NULL')
;

CREATE TABLE covid_vaccinations (
    iso_code VARCHAR(20),
    continent VARCHAR(100),
    location VARCHAR(100),
    date VARCHAR(10),
    new_tests INT,
    total_tests BIGINT,
    total_tests_per_thousand DOUBLE,
    new_tests_per_thousand DOUBLE,
    new_tests_smoothed INT,
    new_tests_smoothed_per_thousand DOUBLE,
    positive_rate DOUBLE,
    tests_per_case DOUBLE,
    tests_units VARCHAR(50),
    total_vaccinations BIGINT,
    people_vaccinated BIGINT,
    people_fully_vaccinated BIGINT,
    total_boosters BIGINT,
    new_vaccinations BIGINT,
    new_vaccinations_smoothed BIGINT,
    total_vaccinations_per_hundred DOUBLE,
    people_vaccinated_per_hundred DOUBLE,
    people_fully_vaccinated_per_hundred DOUBLE,
    total_boosters_per_hundred DOUBLE,
    new_vaccinations_smoothed_per_million INT,
    new_people_vaccinated_smoothed BIGINT,
    new_people_vaccinated_smoothed_per_hundred DOUBLE,
    stringency_index DOUBLE,
    population_density DOUBLE,
    median_age DOUBLE,
    aged_65_older DOUBLE,
    aged_70_older DOUBLE,
    gdp_per_capita DOUBLE,
    extreme_poverty DOUBLE,
    cardiovasc_death_rate DOUBLE,
    diabetes_prevalence DOUBLE,
    female_smokers DOUBLE,
    male_smokers DOUBLE,
    handwashing_facilities DOUBLE,
    hospital_beds_per_thousand DOUBLE,
    life_expectancy DOUBLE,
    human_development_index DOUBLE,
    excess_mortality_cumulative_absolute DOUBLE,
    excess_mortality_cumulative DOUBLE,
    excess_mortality DOUBLE,
    excess_mortality_cumulative_per_million DOUBLE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/covid_vaccinations.csv' INTO TABLE covid_vaccinations
FIELDS TERMINATED BY ","
LINES TERMINATED BY "\r\n"
IGNORE 1 LINES
(iso_code, @continent, location, date, @new_tests, @total_tests, @total_tests_per_thousand, @new_tests_per_thousand, @new_tests_smoothed, @new_tests_smoothed_per_thousand, @positive_rate, @tests_per_case, @tests_units, @total_vaccinations, @people_vaccinated, @people_fully_vaccinated, @total_boosters, @new_vaccinations, @new_vaccinations_smoothed, @total_vaccinations_per_hundred, @people_vaccinated_per_hundred, @people_fully_vaccinated_per_hundred, @total_boosters_per_hundred, @new_vaccinations_smoothed_per_million, @new_people_vaccinated_smoothed, @new_people_vaccinated_smoothed_per_hundred, @stringency_index, @population_density, @median_age, @aged_65_older, @aged_70_older, @gdp_per_capita, @extreme_poverty, @cardiovasc_death_rate, @diabetes_prevalence, @female_smokers, @male_smokers, @handwashing_facilities, @hospital_beds_per_thousand, @life_expectancy, @human_development_index, @excess_mortality_cumulative_absolute, @excess_mortality_cumulative, @excess_mortality, @excess_mortality_cumulative_per_million)
SET	continent = NULLIF(@continent, 'NULL'),	
	new_tests = NULLIF(@new_tests, 'NULL'),	
        total_tests = NULLIF(@total_tests, 'NULL'),	
	total_tests_per_thousand = NULLIF(@total_tests_per_thousand, 'NULL'),	
	new_tests_per_thousand = NULLIF(@new_tests_per_thousand, 'NULL'),		
	new_tests_smoothed = NULLIF(@new_tests_smoothed, 'NULL'),		
	new_tests_smoothed_per_thousand = NULLIF(@new_tests_smoothed_per_thousand, 'NULL'),	
	positive_rate = NULLIF(@positive_rate, 'NULL'),	
	tests_per_case = NULLIF(@tests_per_case, 'NULL'),	
	tests_units = NULLIF(@tests_units, 'NULL'),	
	total_vaccinations = NULLIF(@total_vaccinations, 'NULL'),	
	people_vaccinated = NULLIF(@people_vaccinated, 'NULL'),	
	people_fully_vaccinated = NULLIF(@people_fully_vaccinated, 'NULL'),	
	total_boosters = NULLIF(@total_boosters, 'NULL'),	
	new_vaccinations = NULLIF(@new_vaccinations, 'NULL'),	
	new_vaccinations_smoothed = NULLIF(@new_vaccinations_smoothed, 'NULL'),	
	total_vaccinations_per_hundred = NULLIF(@total_vaccinations_per_hundred, 'NULL'),	
	people_vaccinated_per_hundred = NULLIF(@people_vaccinated_per_hundred, 'NULL'),	
	people_fully_vaccinated_per_hundred = NULLIF(@people_fully_vaccinated_per_hundred, 'NULL'),	
	total_boosters_per_hundred = NULLIF(@total_boosters_per_hundred, 'NULL'),	
	new_vaccinations_smoothed_per_million = NULLIF(@new_vaccinations_smoothed_per_million, 'NULL'),		
	new_people_vaccinated_smoothed = NULLIF(@new_people_vaccinated_smoothed, 'NULL'),	
	new_people_vaccinated_smoothed_per_hundred = NULLIF(@new_people_vaccinated_smoothed_per_hundred, 'NULL'),		
	stringency_index = NULLIF(@stringency_index, 'NULL'),	
	population_density = NULLIF(@population_density, 'NULL'),	
	median_age = NULLIF(@median_age, 'NULL'),	
	aged_65_older = NULLIF(@aged_65_older, 'NULL'),	
	aged_70_older = NULLIF(@aged_70_older, 'NULL'),	
	gdp_per_capita = NULLIF(@gdp_per_capita, 'NULL'),	
	extreme_poverty = NULLIF(@extreme_poverty, 'NULL'),	
	cardiovasc_death_rate = NULLIF(@cardiovasc_death_rate, 'NULL'),	
	diabetes_prevalence = NULLIF(@diabetes_prevalence, 'NULL'),	
	female_smokers = NULLIF(@female_smokers, 'NULL'),	
	male_smokers = NULLIF(@male_smokers, 'NULL'),	
	handwashing_facilities = NULLIF(@handwashing_facilities, 'NULL'),	
	hospital_beds_per_thousand = NULLIF(@hospital_beds_per_thousand, 'NULL'),	
	life_expectancy = NULLIF(@life_expectancy, 'NULL'),	
	human_development_index = NULLIF(@human_development_index, 'NULL'),	
	excess_mortality_cumulative_absolute = NULLIF(@excess_mortality_cumulative_absolute, 'NULL'),		
	excess_mortality_cumulative = NULLIF(@excess_mortality_cumulative, 'NULL'),	
        excess_mortality = NULLIF(@excess_mortality, 'NULL'),	
	excess_mortality_cumulative_per_million = NULLIF(@excess_mortality_cumulative_per_million, 'NULL');

-- STANDARDIZE DATE FORMAT
SET @date = DATE_FORMAT(STR_TO_DATE(@date, '%d/%m/%Y'), '%Y-%m-%d');
SELECT 
    date, STR_TO_DATE(date, '%d/%m/%Y') AS date
FROM
    covid_deaths;

SET SQL_SAFE_UPDATES=0;

UPDATE covid_deaths 
SET 
    date = STR_TO_DATE(date, '%d/%m/%Y');

SET @date = DATE_FORMAT(STR_TO_DATE(@date, '%d/%m/%Y'), '%Y-%m-%d');
SELECT 
    date, STR_TO_DATE(date, '%d/%m/%Y') AS date
FROM
    covid_vaccinations;

UPDATE covid_vaccinations 
SET 
    date = STR_TO_DATE(date, '%d/%m/%Y');

SET SQL_SAFE_UPDATES=1;

-- EXPLORING THE DATA
SELECT 
    *
FROM
    covid_deaths
ORDER BY 3 , 4;

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_deaths
ORDER BY 1 , 2;

-- TOTAL CASES vs TOTAL DEATHS 
-- Shows likelihood of dying if you get covid in your country
SELECT 
    location,
    continent,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS death_percentage
FROM
    covid_deaths
WHERE
    total_cases IS NOT NULL
        AND continent IS NOT NULL
ORDER BY 1 , 2;

-- TOTAL CASES vs POPULATION
-- Shows the percentage of population infected with covid
SELECT 
    location,
    continent,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS infected_population_percentage
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2 , 3;

-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT 
    location,
    continent,
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX((total_cases / population)) * 100 AS population__infected_percentage
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY 1 , 2 , 3
ORDER BY 5 DESC;

-- COUNTRIES WITH HIGHEST DEATH COUNT COMPARED TO POPULATION
SELECT 
    location, continent, MAX(total_deaths) AS total_death_count
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY 1 , 2
ORDER BY 3 DESC;

-- EXPLORING THE DATA BY CONTINENT
-- Continents with the highest death count per population
SELECT 
    location, MAX(total_deaths) AS total_death_count
FROM
    covid_deaths
WHERE
    continent IS NULL
        AND location NOT LIKE '%income%'
        AND location NOT LIKE '%union%'
        AND location NOT LIKE '%world%'
GROUP BY 1
ORDER BY 2 DESC;

-- GLOBAL NUMBERS
SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM
    covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY date
ORDER BY 1 , 2;

-- TOTAL GLOBAL NUMBERS
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_percentage
FROM
    covid_deaths
WHERE
    continent IS NOT NULL;

-- TOTAL POPULATION vs VACCINATIONS
-- Shows percentage of population that has recieved at least one Covid Vaccine
SELECT deaths.location,
       deaths.continent,
       deaths.date,
       deaths.population,
       vaccinations.new_vaccinations,
       SUM(vaccinations.new_vaccinations) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM covid_deaths AS deaths
JOIN covid_vaccinations AS vaccinations 
	ON deaths.location = vaccinations.location
        AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL 
ORDER BY 1, 3;

-- Using CTE to perform Calculation on Partition By in previous query
--  COVID-19 Vaccination Rate
WITH population_vs_vaccinations (location, continent, date, population, new_vaccinations, rolling_people_vaccinated) 
AS( 
SELECT deaths.location,
       deaths.continent,
       deaths.date,
       deaths.population,
       vaccinations.new_vaccinations,
       SUM(vaccinations.new_vaccinations) OVER(PARTITION BY deaths.location 
					       ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM covid_deaths AS deaths
JOIN covid_vaccinations AS vaccinations 
	ON deaths.location = vaccinations.location
        AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL 
)
SELECT *,
       (rolling_people_vaccinated / population) * 100 AS vaccination_rate
FROM population_vs_vaccinations;

-- Using Temp Table to perform Calculation on Partition By in previous query
CREATE TEMPORARY TABLE vaccinated_population_percentage 
(
continent varchar(100),
location varchar(100),
date DATE,
population BIGINT,
new_vaccinations BIGINT,
rolling_people_vaccinated BIGINT
);
INSERT INTO vaccinated_population_percentage 
(SELECT deaths.location,
	deaths.continent,
	deaths.date,
	deaths.population,
        vaccinations.new_vaccinations,
        SUM(vaccinations.new_vaccinations) OVER(PARTITION BY deaths.location 
						ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM covid_deaths AS deaths
JOIN covid_vaccinations AS vaccinations 
	ON deaths.location = vaccinations.location
        AND deaths.date = vaccinations.date);
    
SELECT 
    *,
    (rolling_people_vaccinated / population) * 100 AS vaccination_rate
FROM
    vaccinated_population_percentage;

-- Creating a View to store data for later visualizations
CREATE VIEW vaccinated_population_percentage AS
(SELECT deaths.location,
	deaths.continent,
	deaths.date,
	deaths.population,
        vaccinations.new_vaccinations,
        SUM(vaccinations.new_vaccinations) OVER(PARTITION BY deaths.location 
						ORDER BY deaths.location, deaths.date) AS rolling_people_vaccinated
FROM covid_deaths AS deaths
JOIN covid_vaccinations AS vaccinations 
	ON deaths.location = vaccinations.location
        AND deaths.date = vaccinations.date
WHERE deaths.continent IS NOT NULL);

SELECT 
    *
FROM
    vaccinated_population_percentage;
   
    
-- EXPLORING THE DATA FROM EUROPE
-- Overview: COVID-19 in Europe
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    (SUM(new_deaths) / SUM(new_cases)) AS death_percentage
FROM
    covid_deaths
WHERE
    continent = 'Europe';

-- Highest amount of confirmed cases in Europe -TOP 5 
SELECT 
    location, 
    population, 
    SUM(new_cases) AS total_cases
FROM
    covid_deaths
WHERE
    continent = 'Europe'
GROUP BY 1 , 2
ORDER BY total_cases DESC
LIMIT 5;

-- Last month Death Percentage
SELECT 
    location,
    date,
    new_cases,
    new_deaths,
    (new_deaths / new_cases) * 100 AS death_percentage
FROM
    covid_deaths
WHERE
    new_deaths IS NOT NULL
    AND continent = 'Europe'
    AND date BETWEEN '2023-09-01' AND '2023-10-01'
ORDER BY 1 , 2 , 5;

-- CREATING A VIEW TO STORE DATA ABOUT EUROPE FOR LATER ANALYSIS 
CREATE VIEW Europe AS
    (SELECT 
        deaths.location,
        deaths.date,
        deaths.population,
        deaths.new_cases,
        deaths.new_deaths,
        deaths.hosp_patients,
        deaths.icu_patients,
        vaccinations.new_tests,
        vaccinations.new_vaccinations,
        vaccinations.median_age,
        vaccinations.extreme_poverty,
        vaccinations.handwashing_facilities,
        vaccinations.diabetes_prevalence,
        vaccinations.female_smokers,
        vaccinations.male_smokers
    FROM covid_deaths AS deaths
    JOIN covid_vaccinations AS vaccinations 
	ON deaths.location = vaccinations.location
        AND deaths.date = vaccinations.date
    WHERE
        deaths.continent = 'Europe'
    ORDER BY 1 , 2);


-- HOSPITAL vs INTENSITVE CARE UNIT PATIENTS
-- Shows the percentage of intensive care units patients from the total hospitalized patients
SELECT 
    SUM(hosp_patients) AS total_hosp_patients,
    SUM(icu_patients) AS total_icu_patients,
    (SUM(icu_patients) / SUM(hosp_patients)) * 100 AS hospitalized_in_icu_percentage
FROM
    europe;

-- TOTAL POPULATION vs TESTS
-- Shows what percentage of population got tested at least once
SELECT 
    location,
    population,
    SUM(new_tests) AS number_of_tests,
    (SUM(new_tests) / population) AS tested_people_percentage
FROM
    europe
GROUP BY 1 , 2
ORDER BY 4 DESC;

-- TOTAL CASES vs POVERTY
-- Exploring the number of COVID- 19 cases in top 20 poorest countries
SELECT 
    location,
    population,
    SUM(new_cases) AS total_cases,
    extreme_poverty
FROM
    europe
GROUP BY 1 , 2 , 4
ORDER BY 4 DESC
LIMIT 20;

-- TOTAL POPULATION vs TOTAL DEATHS
-- Shows the percentage of people who died, compared to the entire population
SELECT location, 
       date,
       population,
       new_deaths,
       SUM(new_deaths) OVER(PARTITION BY location 
			    ORDER BY location, date) AS death_count
FROM europe
ORDER BY 1, 2, 5;

-- Rolling Death Count vs Total Deaths per country
WITH death_rate (location, date, population, new_cases, cases_count, new_deaths, death_count, total_deaths) 
AS(
SELECT location, 
       date,
       population,
       new_cases,
	   SUM(new_cases) OVER(PARTITION BY location 
				ORDER BY location, date) AS cases_count,
       new_deaths,
       SUM(new_deaths) OVER(PARTITION BY location 
				ORDER BY location, date) AS death_count,
       SUM(new_deaths) OVER(PARTITION BY location 
				ORDER BY location) AS total_deaths
FROM europe
)
SELECT location, 
       date,
       population,
       new_cases,
       cases_count,
       new_deaths, 
       death_count,
       (new_deaths / new_cases) * 100 AS fatality_rate,
       (death_count / population) * 100 AS death_percentage,
       total_deaths
FROM death_rate;

-- The fatality rate among European countries with heavy smokers
SELECT 
    location,
    population,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    (SUM(new_deaths) / SUM(new_cases) * 100) AS fatality_rate,
    ROUND((female_smokers + male_smokers), 1) AS smokers,
    female_smokers,
    male_smokers
FROM
    europe
GROUP BY 1 , 2 , 7 , 8
ORDER BY 6 DESC;

-- COVID-19 vaccination in Europe
SELECT location,
       population,
       date,
       (new_vaccinations / population) * 100 AS vaccination_rate,
       new_vaccinations,
       SUM(new_vaccinations) OVER(PARTITION BY location 
				   ORDER BY location, date) AS rolling_vaccinations,
       SUM(new_vaccinations) OVER(PARTITION BY location 
				   ORDER BY location) AS total_vaccinations
FROM europe;

-- COVID vaccination in 2023
SELECT 
    location,
    population,
    date,
    new_vaccinations,
    (new_vaccinations / population) * 100 AS vaccination_rate
FROM
    europe
WHERE
    date LIKE '%2023%'
ORDER BY vaccination_rate DESC;
