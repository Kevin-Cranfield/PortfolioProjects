SELECT *
FROM dbo.CovidDeaths
where continent is not null
order by 3,4;

SELECT *
FROM dbo.CovidVaccinations
where continent is not null
order by 3,4;

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2;

-- Looking at total cases vs Total Deaths
-- How likely you are of dying if you contracted covid in United Kingdom

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%kingdom%'
AND continent is not null
ORDER BY 1,2;

-- Looking at the total cases vs the population
-- Shows what percentage of poulation got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPoultionInfected
FROM PortfolioProject..CovidDeaths
where location like '%kingdom%'
AND continent is not null
ORDER BY 1,2;

-- Looking at countries with hightest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPoultionInfected
FROM PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
GROUP BY location, population
ORDER BY PercentPoultionInfected DESC;

-- LETS BREAK THINGS DOWN BY CONTINENT 



-- Showing Countrys with highest death count per poulation

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC;


-- Showing continenbts with highest death count per poulation

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global numbers

SELECT  date, SUM(new_cases) as newCases, SUM(cast(new_deaths as int)) as newDeaths,SUM(cast(New_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
GROUP BY date
ORDER BY 1,2;

-- Total population vs vaccinations

-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3
) 
select *, (RollingPeopleVaccinated/Population)* 100 as PercentagePeopleVac
FROM PopvsVac

-- TEMP Table



Create Table #PercentPopulationVaccinated1
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated1
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated1


--Ceating veiw to store later for visulations
USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

USE PortfolioProject
GO
CREATE VIEW HowLikleyDyingUK as

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%kingdom%'
AND continent is not null
--ORDER BY 1,2;

CREATE VIEW PercentagePopulationHadCovidUK as

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPoultionInfected
FROM PortfolioProject..CovidDeaths
where location like '%kingdom%'
AND continent is not null
--ORDER BY 1,2;

CREATE VIEW PercentagePopulationHadCovidWorldwide as

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPoultionInfected
FROM PortfolioProject..CovidDeaths
--where location like '%kingdom%'
Where continent is not null
--ORDER BY 1,2;

CREATE VIEW countrieHightestInfectionRateComparedPopulation  as

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPoultionInfected
FROM PortfolioProject..CovidDeaths
--where location like '%kingdom%'
where continent is not null
GROUP BY location, population
--ORDER BY PercentPoultionInfected DESC;

CREATE VIEW TotalPopulationVsVaccinations as 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3
) 
select *, (RollingPeopleVaccinated/Population)* 100 as PercentagePeopleVac
FROM PopvsVac

