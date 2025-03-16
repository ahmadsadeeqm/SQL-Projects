SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject.dbo.CovidVaccination
--ORDER BY 3,4

-- Select the data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total cases vs Total deaths
-- shows likelihood of of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%states%'
AND WHERE continent is not null
ORDER BY 1,2

-- Total cases vs Populatioon 
-- shows what population got covid 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
where location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Countries showing the highest death count by population
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC



-- LET'S BREAK THINGS BY CONTINENT

-- showing continents with the highest death counts per population 
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GL0BAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population Vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentagePopulationVaccinated

CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccianation numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date=vac.date
--WHERE dea.continent is not null
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentagePopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccination vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3


SELECT * 
FROM PercentagePopulationVaccinated