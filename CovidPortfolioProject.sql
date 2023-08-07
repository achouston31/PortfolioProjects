/***********************************************************************************************

Object Name:

Object Type: SQL Script

Description: Analysis of Covid Death and Vaccination data from January 01, 2020 to April 30, 2021.

Author: Andrew Houston

Create Date: 08.04.2023

Change History

------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------

Follow-up notes:

------------------------------------------------------------------------------------------------

************************************************************************************************/

/*** Previewing the data to add notes ***/
SELECT *
FROM CovidDeaths
WHERE continent is not null

SELECT MAX(date)
FROM CovidDeaths
WHERE continent is not null

SELECT MIN(date)
FROM CovidDeaths
WHERE continent is not null



SELECT *
FROM CovidVaccinations

/*** Selecting the needed data ***/

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2


/*** Pulling up US data concerning Covid Deaths ***/

-- This table will show the percentage of deaths for those that contracted Covid
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location like '%states%'
ORDER BY 1, 2

--This table adds a column showing the total percent of the US population infected

SELECT Location, Date, total_cases, Population, (total_cases/Population)*100 AS Percent_Infected
FROM CovidDeaths
WHERE Location like '%states%'
ORDER BY 1, 2 

/*** Global Numbers ***/

--This query shows total death percentage worldwide

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


--This table shows each countries infection highest percentage of population infected at any point in the given time line working from highest to lowest. 

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS Percent_Infected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY 4 DESC

-- This table shows the country with the highest total death count working form largest to smallest. 

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC



/*** Breaking numbers down by continent ***/

--This table shows total deaths by continent.

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--This table shows continents with infection percentage working from highest to lowest. 

SELECT continent, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS Percent_Infected
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 3 DESC


/*** Joing CovidDeaths and CovidVaccinations tables. ***/

--Joing the tables for inspection
SELECT *
FROM CovidDeaths cds
JOIN CovidVaccinations cvs
	ON cds.location = cvs.location AND cds.date = cvs.date

--

SELECT cds.continent, cds.location, cds.date, cds.population, cvs.new_vaccinations, SUM(CAST(cvs.new_vaccinations AS INT)) OVER (PARTITION BY cds.Location) AS RollingPeopleVaccinated
FROM CovidDeaths cds
JOIN CovidVaccinations cvs
	ON cds.location = cvs.location AND cds.date = cvs.date
WHERE cds.continent is not null
ORDER BY 2, 3



-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccination, RollingPeopleVaccinated)
AS 
(
SELECT cds.continent, cds.location, cds.date, cds.population, cvs.new_vaccinations, 
SUM(CONVERT(INT,cvs.new_vaccinations)) OVER (PARTITION BY cds.Location ORDER BY cds.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths cds
JOIN CovidVaccinations cvs
	ON cds.location = cvs.location 
	AND cds.date = cvs.date
WHERE cds.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac
ORDER BY 2



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255), 
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cds.continent, cds.location, cds.date, cds.population, cvs.new_vaccinations, 
SUM(CONVERT(INT,cvs.new_vaccinations)) OVER (PARTITION BY cds.Location ORDER BY cds.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths cds
JOIN CovidVaccinations cvs
	ON cds.location = cvs.location 
	AND cds.date = cvs.date
WHERE cds.continent is not null
--ORDER BY 2, 3




SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated
ORDER BY Location, Date




/*** Creating View for visualizations ***/

--This creates a view of rolling total of each countries population that is vaccianated.

DROP VIEW IF EXISTS RollingPopulationVaccinated 
GO
--Adding "GO" allows the "DROP VIEW IF EXISTS" to function in SSMS
CREATE VIEW RollingPopulationVaccinated AS
SELECT cds.continent, cds.location, cds.date, cds.population, cvs.new_vaccinations, 
SUM(CONVERT(INT,cvs.new_vaccinations)) OVER (PARTITION BY cds.Location ORDER BY cds.date) AS RollingPeopleVaccinated
FROM CovidDeaths cds
JOIN CovidVaccinations cvs
	ON cds.location = cvs.location 
	AND cds.date = cvs.date
WHERE cds.continent is not null


SELECT *
FROM RollingPopulationVaccinated
ORDER BY location



--This table shows total deaths by country from highest to lowest. 

DROP VIEW IF EXISTS TotalDeathsByCountry 
GO
CREATE VIEW TotalDeathsByCountry AS
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null AND total_deaths is not null
GROUP BY Location


SELECT *
FROM TotalDeathsByCountry
ORDER BY 2 DESC
