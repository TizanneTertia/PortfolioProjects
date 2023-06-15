
SELECT *
FROM PortFolioProject1.dbo.CovidDeaths


SELECT *
FROM PortFolioProject1.dbo.CovidVaccinations
ORDER BY 1,2,3

--Select the life location,continent expectancy, aged 65 older, 70 older

SELECT continent,location,life_expectancy ,aged_65_older,aged_70_older
FROM PortFolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL

--Select list off people that have diabetes, female smokers,male smokers

SELECT continent,location,diabetes_prevalence,female_smokers,male_smokers
FROM PortFolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL

--Select list off handwashing facilities, extreme poverty
SELECT continent,location,population,handwashing_facilities,extreme_poverty
FROM PortFolioProject1.dbo.CovidDeaths

-- Select weekly icu admissions, weekly hosp admissions
SELECT continent,location,population,weekly_hosp_admissions,weekly_icu_admissions
FROM PortFolioProject1.dbo.CovidDeaths

--The total number off deaths
SELECT location,MAX (total_deaths) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
order by TotalDeathsCount desc

--date that cases and deaths were on 
SELECT date,SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date

--JOIN the tables together 
SELECT *
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location 
AND Dea.date = Vac.date

--Amount of People Vaccinated
SELECT Dea.continent,Dea.location,Dea.date, Dea.population,Vac.new_vaccinations,
SUM (CONVERT(INT,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location , Dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location 
AND Dea.date = Vac.date
	WHERE Dea.continent IS NOT NULL
	ORDER BY 2,3

--Creating a CTE

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
Population INT,
new_vaccinations INT,
RollingPeopleVaccinated INT
)
--Insert into the table
INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent,Dea.location,Dea.date, Dea.population,Vac.new_vaccinations,
SUM (CONVERT(INT,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location , Dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location 
AND Dea.date = Vac.date

SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--CREATE VIEWS
CREATE VIEW PercentPopulationVaccinated AS 
SELECT Dea.continent,Dea.location,Dea.date, Dea.population,Vac.new_vaccinations,
SUM (CONVERT(INT,Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location , Dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
ON Dea.location = Vac.location 
AND Dea.date = Vac.date

CREATE VIEW PeopleWithDibetesAndSmokers AS
SELECT continent,location,diabetes_prevalence,female_smokers,male_smokers
FROM PortFolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL

CREATE VIEW TotalDeathsNewCasesOnTheSameDate AS
SELECT date,SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date