USE CovidProject

SELECT *
FROM CovidDeaths
ORDER BY 3,4

ALTER TABLE CovidDeaths
ALTER COLUMN Total_Deaths FLOAT;

ALTER TABLE CovidDeaths
ALTER COLUMN Total_Cases FLOAT;

---SELECT *
---FROM CovidVaccinations
--ORDER BY 3,4

---SELECT DATA THAT I IM GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths,population_density
FROM CovidDeaths
ORDER BY 1,2

---PERCENTAGE OF DEATHS TOTAL DEATHS VS TOTAL CASES

SELECT location, YEAR(date) AS Year, SUM(total_deaths) AS TotalDeaths,SUM(total_cases) AS TotalCases, SUM(total_deaths)/SUM(total_cases)*100 AS DeathRateInfected
FROM CovidDeaths
GROUP BY LOCATION,YEAR(date)
ORDER BY 1,2

---PERCENTAGE OF DEATHS, DEATHS PER YEAR VS POPULATION

SELECT location, YEAR(DATE) AS Year, SUM(new_deaths) AS DeathsPerYear, population,(SUM(new_deaths)/population)*100 AS DeathRateTotalPopulation
FROM CovidDeaths
GROUP BY location,YEAR(date),population
ORDER BY 1,2


---PERCENTAGE OF DEATHS PER YEAR---
SELECT location, YEAR(date) AS Year, SUM(new_deaths) AS TotalNewDeaths,SUM(New_cases) AS TotalNewCases, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS DeathRate
FROM CovidDeaths
GROUP BY LOCATION,YEAR(date)
ORDER BY 1,2

---TOTAL DEATH RATE PER COUNTRY---
SELECT location, SUM(new_deaths) AS TotalNewDeaths,SUM(New_cases) AS TotalNewCases, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS DeathRate
FROM CovidDeaths
GROUP BY LOCATION
ORDER BY 1,2

SELECT location, SUM(new_deaths) AS TotalNewDeaths,SUM(New_cases) AS TotalNewCases, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS DeathRate
FROM CovidDeaths
WHERE LOCATION LIKE '%United%'
GROUP BY LOCATION
ORDER BY 1,2

--- COUNTRIES WIH THE HIGHETS INFECTION RATE COMPARED TO POPULATION

SELECT location, MAX(TOTAL_CASES) MaxInfectionCount,POPULATION, (MAX(total_cases)/POPULATION)*100 AS PercentageInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

---COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION---

SELECT location, MAX(TOTAL_DEATHS) AS TotalDeath
FROM CovidDeaths
GROUP BY location
ORDER BY 2 DESC

---SEE DATA BY CONTINENT---

SELECT continent, MAX(TOTAL_DEATHS) AS TotalDeath
FROM CovidDeaths
WHERE continent  IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

SELECT location, MAX(TOTAL_DEATHS) AS TotalDeath
FROM CovidDeaths
WHERE continent  IS  NULL
GROUP BY location
ORDER BY 2 DESC


---GLOBAL NUMBERS---
SELECT SUM(new_deaths) AS TotalNewDeaths,SUM(New_cases) AS TotalNewCases, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS DeathRate
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

---- TOTAL VACCINATION X LOCATION

ALTER TABLE covidvaccinations
ALTER COLUMN new_vaccinations FLOAT;

SELECT V.location,year(V.date),SUM(new_vaccinations) AS VaccinatedPerYear, population, (SUM(new_vaccinations)/population) * 100 AS VaccinatedRate
FROM CovidVaccinations V
JOIN CovidDeaths D
	ON V.location = D.location
	AND V.date = D.date
GROUP BY V.location,year(V.date), population
ORDER BY 5 DESC


SELECT V.continent,V.location,(V.date), population, V.new_vaccinations, 
SUM(New_vaccinations) OVER (PARTITION BY V.location ORDER BY V.location, (V.date)) AS RollingPeopleVaccinated
FROM CovidVaccinations V
JOIN CovidDeaths D
	ON V.location = D.location
	AND V.date = D.date
WHERE V.continent IS NOT NULL
ORDER BY V.location,V.date



SELECT V.location,year(V.date) AS Year,MAX(total_vaccinations) AS VaccinatedPerYear, population, (MAX(new_vaccinations)/population) * 100 AS VaccinatedRate
FROM CovidVaccinations V
JOIN CovidDeaths D
	ON V.location = D.location
	AND V.date = D.date
GROUP BY V.location,year(V.date), population
ORDER BY 5 DESC

---USING CTE TOTAL POPULATION VS VACCINATIONS---
SELECT V.continent,V.location,(V.date), population, V.new_vaccinations, 
SUM(New_vaccinations) OVER (PARTITION BY V.location ORDER BY V.location, (V.date)) AS RollingPeopleVaccinated
FROM CovidVaccinations V
JOIN CovidDeaths D
	ON V.location = D.location
	AND V.date = D.date
WHERE V.continent IS NOT NULL
ORDER BY V.location,V.date


WITH PopvsVac (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT V.continent,V.location,(V.date), population, V.new_vaccinations, 
SUM(New_vaccinations) OVER (PARTITION BY V.location ORDER BY V.location, (V.date)) AS RollingPeopleVaccinated
FROM CovidVaccinations V
JOIN CovidDeaths D
	ON V.location = D.location
	AND V.date = D.date
WHERE V.continent IS NOT NULL
---ORDER BY V.location,V.date
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac
ORDER BY 7 DESC

---USING TEMP.TABLE TOTAL POPULATION VS VACCINATIONS---

DROP TABLE IF EXISTS #PopvsVac

CREATE TABLE #PopvsVac
(
Continent VARCHAR(100),
Location VARCHAR (100),
Date DATETIME,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated  numeric
)

INSERT INTO #PopvsVac
SELECT V.continent,V.location,(V.date), population, V.new_vaccinations, 
SUM(New_vaccinations) OVER (PARTITION BY V.location ORDER BY V.location, (V.date)) AS RollingPeopleVaccinated
FROM CovidVaccinations V
JOIN CovidDeaths D
	ON V.location = D.location
	AND V.date = D.date
--WHERE V.continent IS NOT NULL
---ORDER BY V.location,V.date


SELECT *, (RollingPeopleVaccinated/population)*100 AS Rate
FROM #PopvsVac

---CREATING A VIEW TO STORE DATA FOR FOLLOW VISUALIZATOINS---

CREATE VIEW PopvsVac AS
SELECT V.continent,V.location,(V.date), population, V.new_vaccinations, 
SUM(New_vaccinations) OVER (PARTITION BY V.location ORDER BY V.location, (V.date)) AS RollingPeopleVaccinated
FROM CovidVaccinations V
JOIN CovidDeaths D
	ON V.location = D.location
	AND V.date = D.date
WHERE V.continent IS NOT NULL
