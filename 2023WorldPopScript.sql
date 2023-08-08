/***********************************************************************************************

Object Name: 2023 Global Population Data 

Object Type: SQL Script

Description: Using 2023 global population data to create Tableau Dashboard

Author: Andrew Houston

Create Date: 08.06.2023

Change History

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

Follow-up notes:

------------------------------------------------------------------------------------------------

************************************************************************************************/

SELECT *
FROM WorldPopulation2023$


--Population and number of people per Square Kilometer. Only the Holy See is excluded due to calculation 

SELECT Country, Population2023 AS TotalPop, [Land Area(KmÂ²)], [Density(P/KmÂ²)] AS PopulationPerSqKM
FROM WorldPopulation2023$
ORDER BY Country




--Urban population Numbers. Some data points are null values, so excluding those from results. 

SELECT Country, Population2023, MedianAge, ROUND(Population2023*[UrbanPop%],0) AS UrabanPop, [UrbanPop%] * 100 AS UrbanPopPercent
FROM WorldPopulation2023$
WHERE [UrbanPop%] IS NOT NULL
ORDER BY 1

--Median Age

SELECT Country, MedianAge
FROM WorldPopulation2023$

--Net Population Change and Urban Population

SELECT Country, NetChange, [UrbanPop%] * 100 AS UrbanPopPercent
FROM WorldPopulation2023$
WHERE [UrbanPop%] IS NOT NULL






