SELECT *
FROM [Portafolio CoronaVirus]..CovidDeaths
WHERE continent IS NOT NULL

--SELECT *
--FROM [Portafolio CoronaVirus]..CovidVaccinations
--WHERE continent IS NOT NULL


--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM [Portafolio CoronaVirus]..CovidDeaths
--WHERE continent IS NOT NULL



-- Looking at total cases vs total death in Ecuador 

SELECT location, date, total_cases, total_deaths, (total_cases/total_deaths) * 100 AS death_percetage
FROM [Portafolio CoronaVirus]..CovidDeaths
WHERE location like  'Ecuador'
AND continent IS NOT NULL

-- Looking at total cases vs population in Ecuador 

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS populationGotCovid_percetage
FROM [Portafolio CoronaVirus]..CovidDeaths
WHERE location like  'Ecuador'
AND continent IS NOT NULL

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection_count, (MAX(total_cases)/population) * 100 AS percentage_populationInfected
FROM [Portafolio CoronaVirus]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentage_populationInfected DESC


-- Showing at countries with highest death count per population

SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM [Portafolio CoronaVirus]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Global numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 AS DeathPercentage 
FROM [Portafolio CoronaVirus]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 


--- Working with the 2 tables 

SELECT *
FROM [Portafolio CoronaVirus]..CovidDeaths as dea21
JOIN [Portafolio CoronaVirus]..CovidVaccinations as vacc21
ON dea21.location = vacc21.location
AND dea21.date = vacc21.date


--Looking at total population vs vaccinations

SELECT dea21.continent, dea21.location, dea21.date, dea21.population, vacc21.new_vaccinations
FROM [Portafolio CoronaVirus]..CovidDeaths as dea21
JOIN [Portafolio CoronaVirus]..CovidVaccinations as vacc21
ON dea21.location = vacc21.location
AND dea21.date = vacc21.date
WHERE dea21.continent IS NOT NULL 
ORDER BY 1,2,3

-- Now if i want to see the total vaccinations

SELECT dea21.continent, dea21.location, dea21.date, dea21.population, vacc21.new_vaccinations, SUM(CAST(vacc21.new_vaccinations AS INT)) OVER (PARTITION BY dea21.location ORDER BY dea21.location, dea21.date) AS RollingPeopleVaccionated
FROM [Portafolio CoronaVirus]..CovidDeaths as dea21
JOIN [Portafolio CoronaVirus]..CovidVaccinations as vacc21
ON dea21.location = vacc21.location
AND dea21.date = vacc21.date
WHERE dea21.continent IS NOT NULL 
ORDER BY 2,3


--USE CTE


WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccionated) AS (
    SELECT dea21.continent, dea21.location, dea21.date, dea21.population, vacc21.new_vaccinations, SUM(CAST(vacc21.new_vaccinations AS INT)) OVER (PARTITION BY dea21.location ORDER BY dea21.location, dea21.date) AS RollingPeopleVaccionated
    FROM [Portafolio CoronaVirus]..CovidDeaths AS dea21
    JOIN [Portafolio CoronaVirus]..CovidVaccinations AS vacc21 ON dea21.location = vacc21.location AND dea21.date = vacc21.date
    WHERE dea21.continent IS NOT NULL 
)

SELECT *, (RollingPeopleVaccionated/population)*100
FROM PopvsVac;



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea21.continent, dea21.location, dea21.date, dea21.population, vacc21.new_vaccinations, 
       SUM(CAST(vacc21.new_vaccinations AS INT)) OVER (PARTITION BY dea21.location ORDER BY dea21.location, dea21.date) AS RollingPeopleVaccinated
FROM [Portafolio CoronaVirus]..CovidDeaths AS dea21
JOIN [Portafolio CoronaVirus]..CovidVaccinations AS vacc21 ON dea21.location = vacc21.location AND dea21.date = vacc21.date
WHERE dea21.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentVaccinated
FROM #PercentPopulationVaccinated;



--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea21.continent, dea21.location, dea21.date, dea21.population, vacc21.new_vaccinations, 
       SUM(CAST(vacc21.new_vaccinations AS INT)) OVER (PARTITION BY dea21.location ORDER BY dea21.location, dea21.date) AS RollingPeopleVaccinated
FROM [Portafolio CoronaVirus]..CovidDeaths AS dea21
JOIN [Portafolio CoronaVirus]..CovidVaccinations AS vacc21 
ON dea21.location = vacc21.location AND dea21.date = vacc21.date
WHERE dea21.continent IS NOT NULL;