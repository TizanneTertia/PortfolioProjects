
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null


--SELECT *
--FROM PortfolioProject..CovidVaccinations

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2


SELECT location,date,population,total_cases,(total_cases/population)*100 as Population_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%Africa%'


SELECT location,population,MAX (total_cases) AS HighestInfectionCount,Max((total_cases/population))*100 as Population_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Africa%'
WHERE continent is not null
GROUP BY location,population



SELECT location,MAX (total_deaths) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
order by TotalDeathsCount desc

SELECT location,MAX (total_deaths) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
order by TotalDeathsCount desc

SELECT date,SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date

SELECT *
FROM PortfolioProject..CovidVaccinations

ALTER TABLE PortfolioProject..CovidVaccinations
DROP COLUMN F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22,F23,F24

SELECT *
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location 
AND Dea.date = Vac.date



SELECT Dea.continent,Dea.location,Dea.date, Dea.population,Vac.new_vaccinations,
SUM (CONVERT(INT,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location , Dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location 
AND Dea.date = Vac.date
	WHERE Dea.continent IS NOT NULL
	ORDER BY 2,3



WITH PopVsVac (continent , location , date, population,new_vaccinations,RollingPeopleVaccinated) 
	as
	(
SELECT Dea.continent,Dea.location,Dea.date, Dea.population,Vac.new_vaccinations,
SUM (CONVERT(INT,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location , Dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location 
AND Dea.date = Vac.date
	WHERE Dea.continent IS NOT NULL
	)
	SELECT * , (RollingPeopleVaccinated/population)*100
	FROM PopVsVac

	DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent,Dea.location,Dea.date, Dea.population,Vac.new_vaccinations,
SUM (CONVERT(INT,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location , Dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location 
AND Dea.date = Vac.date
--WHERE Dea.continent IS NOT NULL

	SELECT * , (RollingPeopleVaccinated/population)*100
	FROM #PercentPopulationVaccinated

	CREATE VIEW PercentPopulationVaccinated AS 
	SELECT Dea.continent,Dea.location,Dea.date, Dea.population,Vac.new_vaccinations,
SUM (CONVERT(INT,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location , Dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location 
AND Dea.date = Vac.date
--WHERE Dea.continent IS NOT NULL

