USE [PORTFOLIO PROJECT]

SELECT * FROM [PORTFOLIO PROJECT] ..[Covid Vaccinations]
ORDER BY 3,4

SELECT * FROM [PORTFOLIO PROJECT] ..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


SELECT CovidDeaths.location,CovidDeaths.date,CovidDeaths.total_cases,CovidDeaths.new_cases,CovidDeaths.total_deaths,CovidDeaths.population
FROM CovidDeaths
ORDER BY 1,2;

-- THE TOTAL CASES VS TOTAL DEATHS  
SELECT CovidDeaths.location,CovidDeaths.date,CovidDeaths.total_cases,CovidDeaths.total_deaths, (total_deaths/total_cases)*100 AS 'DEATH RATE'
FROM CovidDeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2;

-- TOTAL CASES VS POPULATION
SELECT CovidDeaths.location,CovidDeaths.date,CovidDeaths.total_cases,population, (total_cases/population)*100 AS 'INFECTED %'
FROM CovidDeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2;

--COUNTRIES WITH HIGHEST INFECTION  RATE

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as 'PercentPopulationInfected'
From CovidDeaths
--Where location like '%INDIA%'
Group by Location, Population
order by PercentPopulationInfected desc;



--CONTINENTS WITH HIGHEST DEATH COUNT

Select continent, MAX(CAST(total_deaths AS INT)) as  'TotalDeathCount'
From CovidDeaths
WHERE continent IS NOT  NULL
Group by continent
order by TotalDeathCount desc;



---- GLOBAL  NUMBERS---
SELECT SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS 'total_new_deaths', SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS 'DeathPercentage'
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2;


--TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT (INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN [Covid Vaccinations] vac
	ON dea.location =vac.location
	AND  dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3;


--USE CTE
WITH POPvsVAC (continent,Location,Date,Population,New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT (INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN [Covid Vaccinations] vac
	ON dea.location =vac.location
	AND  dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated/Population)*100 AS '%POP VACCINATED'
FROM POPvsVAC


--Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE #PercentPopulationVaccinated

CREATE TABLE  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT (INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN [Covid Vaccinations] vac
	ON dea.location =vac.location
	AND  dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/Population)*100 AS '%POP VACCINATED'
FROM #PercentPopulationVaccinated



-- CREATING VIEW--

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN [Covid Vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 


