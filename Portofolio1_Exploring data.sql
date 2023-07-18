--Select * 
--FROM CovidVaccinations
--ORDER BY 3,4

Select * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Mengambil data yang dibutuhkan
Select location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases VS Total Death
-- Looking Possiblity Die if you contract country in your countries
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%indonesia%' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases Vs Population
-- SHOW WHAT PERCENTAGE OF POPULATION GOT COVID
Select location, date, population, total_cases, (total_deaths/population)*100 AS CasePercentage
FROM CovidDeaths
WHERE location like '%indonesia%' AND  continent IS NOT NULL
ORDER BY 1,2


-- Looking at Countries with Higest Infection Rate Compared to Population
Select location, population, MAX(total_cases) AS HigestInfectionCount,
Max((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Looking at Countries with Higest Death Rate Compared to Population
Select location, MAX(cast(total_deaths as int)) AS Total_Death
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death desc


-- LETS BREAK THINGS DOWN BY CONTINENT
Select continent, MAX(cast(total_deaths as int)) AS Total_Death
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death desc


-- SHOWING CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION
Select continent, MAX(cast(total_deaths as int)) AS Total_Death
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death desc


-- Global Number
Select  SUM(new_cases) AS new_cases_date, SUM(cast(new_deaths as int)) AS new_deaths_date, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Percetage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date


-- Look Population vs Vaccinations
SELECT dead.continent, dead.location, dead.date, dead.population, vaccin.new_vaccinations, SUM(CAST (vaccin.new_vaccinations AS INT)) 
	OVER (PARTITION BY dead.location order by dead.location, dead.date) AS RollingPeopleVaccin,
	(RollingPeopleVaccin/population)* 100 AS percete
FROM CovidDeaths AS dead
JOIN CovidVaccinations AS vaccin
	ON dead.location = vaccin.location
	AND dead.date = vaccin.date
WHERE dead.continent IS NOT NULL
ORDER BY 2,3

-- USING CTE
with PopulationVsVaccin (continent, location, date, population, new_vaccinations, RollingPeopleVaccin)
AS
(SELECT dead.continent, dead.location, dead.date, dead.population, vaccin.new_vaccinations, SUM(CAST (vaccin.new_vaccinations AS INT)) 
	OVER (PARTITION BY dead.location order by dead.location, dead.date) AS RollingPeopleVaccin
	--(RollingPeopleVaccin/population)* 100 AS percete
FROM CovidDeaths AS dead
JOIN CovidVaccinations AS vaccin
	ON dead.location = vaccin.location
	AND dead.date = vaccin.date
WHERE dead.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccin/population)*100 AS percentageVaccin
FROM PopulationVsVaccin
ORDER BY 2,3


-- Temp Table
DROP TABLE IF EXISTS #PercentePopulationVaccinated
CREATE TABLE #PercentePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vacctions numeric,
RollingPeopleVaccin numeric)

INSERT INTO #PercentePopulationVaccinated
SELECT dead.continent, dead.location, dead.date, dead.population, vaccin.new_vaccinations, SUM(CAST (vaccin.new_vaccinations AS INT)) 
	OVER (PARTITION BY dead.location order by dead.location, dead.date) AS RollingPeopleVaccin
	--(RollingPeopleVaccin/population)* 100 AS percete
FROM CovidDeaths AS dead
JOIN CovidVaccinations AS vaccin
	ON dead.location = vaccin.location
	AND dead.date = vaccin.date

SELECT *, (RollingPeopleVaccin/population)*100 AS percentageVaccin
FROM #PercentePopulationVaccinated
ORDER BY 2,3


-- CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentePopulationVaccinated AS
SELECT dead.continent, dead.location, dead.date, dead.population, vaccin.new_vaccinations, SUM(CAST (vaccin.new_vaccinations AS INT)) 
	OVER (PARTITION BY dead.location order by dead.location, dead.date) AS RollingPeopleVaccin
	--(RollingPeopleVaccin/population)* 100 AS percete
FROM CovidDeaths AS dead
JOIN CovidVaccinations AS vaccin
	ON dead.location = vaccin.location
	AND dead.date = vaccin.date
WHERE dead.continent IS NOT NULL

select * 
from PercentePopulationVaccinated