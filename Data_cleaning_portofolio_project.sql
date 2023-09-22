CREATE DATABASE Nashville;
USE Nashville;

CREATE TABLE housing(
	unique_id INT, 	
    parcel_id VARCHAR(50),
    land_use VARCHAR(50),
    property_address VARCHAR(100),
    sale_date VARCHAR(50),
    sale_price INT,
    legal_reference VARCHAR(100),
    sold_as_vacant VARCHAR(5),
    owner_name VARCHAR(110),
    owner_address VARCHAR(110),	
    acreage	DECIMAL(5,3),
    tax_district VARCHAR(50),
    land_value INT,
    building_value INT,
    total_value INT,
    year_built YEAR,
    bedrooms INT,
    full_bath INT,
    half_bath INT
);
SELECT * FROM housing;


SELECT sale_date FROM housing;

-- STANDARDIZE DATE FORMAT
SET @sale_date = DATE_FORMAT(STR_TO_DATE(@sale_date, '%M %d,%Y'), '%Y-%m-%d');
SELECT sale_date,
	   STR_TO_DATE(sale_date, '%M %d,%Y') AS sale_date
FROM housing;

SET SQL_SAFE_UPDATES=0;
UPDATE housing
SET sale_date = STR_TO_DATE(sale_date, '%M %d,%Y');

-- POPULATE PROPERTY ADDRESS
SELECT a.parcel_id, 
	   a.property_address, 
       b.parcel_id, 
       b.property_address,
       IF(ISNULL(a.property_address) = 1, b.property_address, a.property_address)
FROM nashville.housing a
JOIN nashville.housing b
	ON a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
WHERE a.property_address IS NULL;

UPDATE nashville.housing a
JOIN nashville.housing b
	ON a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
SET a.property_address = IF(ISNULL(a.property_address) = 1, b.property_address, a.property_address)
WHERE a.property_address IS NULL;

SELECT * FROM housing;

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS

-- PROPERTY ADDRESS
SELECT property_address FROM housing;
SELECT 
	SUBSTRING(property_address, 1, LOCATE(',', property_address) -1) AS address,
    SUBSTRING(property_address, LOCATE(',', property_address) +1, LENGTH(property_address)) AS address
FROM housing;

ALTER TABLE housing
ADD property_split_address Nvarchar(255);
UPDATE housing
SET property_split_address = SUBSTRING(property_address, 1, LOCATE(',', property_address) -1);

ALTER TABLE housing
ADD property_split_city Nvarchar(255);
UPDATE housing
SET property_split_city = SUBSTRING(property_address, LOCATE(',', property_address) +1, LENGTH(property_address));

SELECT * FROM housing;

-- OWNER ADDRESS
SELECT owner_address FROM housing;
SELECT 
	SUBSTRING_INDEX((SUBSTRING_INDEX(owner_address,',',1)),',',-1) AS address,
	SUBSTRING_INDEX((SUBSTRING_INDEX(owner_address,',',2)),',',-1) AS address,
	SUBSTRING_INDEX((SUBSTRING_INDEX(owner_address,',',3)),',',-1) AS address
FROM housing;

ALTER TABLE housing
ADD owner_split_address NVARCHAR(255);
UPDATE housing
SET owner_split_address = SUBSTRING_INDEX((SUBSTRING_INDEX(owner_address,',',1)),',',-1);

ALTER TABLE housing
ADD owner_split_city NVARCHAR(255);
UPDATE housing
SET owner_split_city = SUBSTRING_INDEX((SUBSTRING_INDEX(owner_address,',',2)),',',-1);

ALTER TABLE housing
ADD owner_split_state NVARCHAR(255);
UPDATE housing
SET owner_split_state = SUBSTRING_INDEX((SUBSTRING_INDEX(owner_address,',',3)),',',-1);

SELECT * FROM housing;

-- CHANGE Y AND N TO YES AND NO IN 'sold_as_vacant' field
SELECT DISTINCT sold_as_vacant,
				COUNT(sold_as_vacant) 
FROM housing
GROUP BY sold_as_vacant ORDER BY 2;

SELECT sold_as_vacant,
	   CASE
			WHEN sold_as_vacant = 'Y' THEN 'Yes'
			WHEN sold_as_vacant = 'N' THEN 'No'
		    ELSE sold_as_vacant 
       END AS sold_as_vacant2
FROM housing;

UPDATE housing
SET sold_as_vacant = CASE
						WHEN sold_as_vacant = 'Y' THEN 'Yes'
						WHEN sold_as_vacant = 'N' THEN 'No'
						ELSE sold_as_vacant 
					 END;

-- REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT * ,
	   ROW_NUMBER() OVER(PARTITION BY parcel_id,
									  property_address,
                                      sale_price,
                                      sale_date,
                                      legal_reference
                                      ORDER BY unique_id) AS row_num
FROM housing
-- ORDER BY parcel_id
)
DELETE
FROM housing USING housing JOIN RowNumCTE ON housing.unique_id = RowNumCTE.unique_id
WHERE RowNumCTE.row_num > 1;
-- SELECT * FROM RowNumCTE 
-- WHERE RowNumCTE.row_num > 1
-- ORDER BY property_address;

-- DELETE UNUSED COLUMNS
SELECT * 
FROM housing;

ALTER TABLE housing
DROP COLUMN owner_address,  
DROP COLUMN property_address,
DROP COLUMN tax_district;