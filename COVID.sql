SELECT *
FROM PortafolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortafolioProject..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

SELECT location, date, total_cases,  new_cases, total_deaths, population
FROM PortafolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in Chile

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortafolioProject..CovidDeaths
WHERE location LIKE 'Chile'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of populatio have Covid 

SELECT location, date,  population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortafolioProject..CovidDeaths
--WHERE location LIKE 'Chile'
ORDER BY 1,2

--Looking at Countries with highest infection rate to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortafolioProject..CovidDeaths
--WHERE location LIKE 'Chile'
GROUP BY population, location
ORDER BY 4 DESC

--Showing Countries with highest death count per population

SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Let's break things down by Continent

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) AS total_cases, sum(cast(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortafolioProject..CovidDeaths
--WHERE location LIKE 'Chile'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortafolioProject..CovidDeaths dea
JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortafolioProject..CovidDeaths dea
JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
 

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortafolioProject..CovidDeaths dea
JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


Select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for laater visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortafolioProject..CovidDeaths dea
JOIN PortafolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3





