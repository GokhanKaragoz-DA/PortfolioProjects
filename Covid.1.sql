-- Review the entire dataset
SELECT * 
FROM CovidDeaths
ORDER BY 3, 4


-- Select Columns to be used
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2


-- Total Deaths/Total Cases (DeathRatio) If Infected - World Wide
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRatio
FROM CovidDeaths
ORDER BY 1,2


-- Total Deaths/Total Cases (DeathRatio) If Infected for - specific countries
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRatio
FROM CovidDeaths
WHERE location = 'Turkey'
ORDER BY 1,2 


-- MAXIMUM Total Deaths/Total Cases (DeathRatio) If Infected for - specific countries
SELECT location, MAX(total_deaths/total_cases)*100 AS DeathRatio
FROM CovidDeaths
WHERE location = 'Turkey'
GROUP BY location
ORDER BY 1,2


-- Total Cases vs. Population(InfectionRate) for specific countries
SELECT location,date,population,total_cases,(total_cases/population)*100 AS InfectionRate
FROM CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2


-- InfectionRate Comparision among Countries
SELECT location,MAX(total_cases/population)*100 AS InfectionRate
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY 2 DESC


-- Number of Deaths per Continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY 2 DESC


-- Number of Deaths per country
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY 2 DESC


-- Death Ratio (total_deaths/population) per continent
SELECT location, MAX(total_deaths/population)*100 AS DeathRatio_by_Population
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY 2 DESC


-- GLobal Numbers (10TH NOVEMBER 2023)
SELECT
	SUM(new_cases) AS TotalCases,
	SUM(new_deaths) AS TotalDeaths, 
	SUM(new_deaths) * 100.0 / SUM(new_cases) as DeathRatio_Nov2023
FROM CovidDeaths
WHERE continent IS NOT NULL


-- GLobal Numbers Daily (till 10TH NOVEMBER 2023)
SELECT date, 
	SUM(new_cases) AS TotalDailyNewCases,
	SUM(new_deaths) AS TotalDailyNewDeaths, 
		CASE 
			WHEN SUM(new_cases) = 0 THEN NULL
			ELSE SUM(new_deaths) * 100.0 / SUM(new_cases)
		END AS DeathRatio
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1


-- TOTAL VACCINATION vs POPULATION
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
	   SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS ROLLINGVACCINATEDPOPULATION
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC ON DEA.location=VAC.location AND DEA.date=VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE
WITH POPvsVAC (Continent,location, date, population, new_vaccinations, ROLLINGVACCINATEDPOPULATION)
	AS
	(
		SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
			   SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS ROLLINGVACCINATEDPOPULATION
		FROM CovidDeaths DEA
		JOIN CovidVaccinations VAC ON DEA.location=VAC.location AND DEA.date=VAC.date
		WHERE DEA.continent IS NOT NULL
	)
SELECT *, (ROLLINGVACCINATEDPOPULATION/population)*100 AS VACvsPOPULATION
FROM POPvsVAC


-- TEMP TABLE
DROP TABLE IF EXISTS #VaccinatedPopulationPercentage
CREATE TABLE #VaccinatedPopulationPercentage

(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinatedPeople numeric
)

INSERT INTO #VaccinatedPopulationPercentage

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
			   SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS ROLLINGVACCINATEDPOPULATION
		FROM CovidDeaths DEA
		JOIN CovidVaccinations VAC ON DEA.location=VAC.location AND DEA.date=VAC.date
		WHERE DEA.continent IS NOT NULL

SELECT *, (RollingVaccinatedPeople/population)*100 AS VACvsPOPULATION
FROM #VaccinatedPopulationPercentage


-- CREATING VIEW for VISUALIZATIONS
CREATE VIEW VaccinatedPopulationPercentage AS

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
	   SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS ROLLINGVACCINATEDPOPULATION
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC ON DEA.location=VAC.location AND DEA.date=VAC.date
WHERE DEA.continent IS NOT NULL

