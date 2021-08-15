SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent is not null 
ORDER BY 1,2

-- Looking at Total Cases vs Population 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percent_of_population_infected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent is not null 
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location,  population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_of_population_infected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY location, population
ORDER BY 4 DESC	

-- Let's break things down by continent 
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global numbers by date
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2

-- Total global cases and deaths
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingpPeopleVaccinated, 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

-- USE CTE 

With PopvsVac (Continent, Locaion, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingpPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null 
-- ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population) * 100 AS PercentVaccinated
FROM PopvsVac

-- TEMP Table 

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255), 
  Date datetime,
  Population numeric, 
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingpPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/population) * 100 AS PercentVaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualtizations
CREATE View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS RollingpPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null 

SELECT * 
FROM PercentPopulationVaccinated
