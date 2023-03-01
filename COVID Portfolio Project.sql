select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--select data thath we are going to be using
SELECT  location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2

--looking at total cases vs total deaths
--show likelihood of dying if you contract covid in your country
SELECT  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location = 'Indonesia'
ORDER BY 1,2

--Looking at total cases vs population
--show what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where location = 'indonesia'
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortofolioProject..CovidDeaths
group by location, population
order by PercentagePopulationInfected desc

-- Showing countries with Highest Death Count per population
select Location, max(cast(total_deaths as bigint)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null AND continent != ''
group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null AND continent != ''
group by continent
order by TotalDeathCount desc 

--showing continent with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null AND continent != ''
group by continent
order by TotalDeathCount desc 

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null AND continent != ''
--group by date
order by 1,2


--LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccination vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null AND dea.continent != ''
order by 2,3

--USE CTE
WITH PopvcVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccination vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null AND dea.continent != ''
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
from PopvcVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float,
RollingPeopleVaccinated float
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccination vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null AND dea.continent != ''
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccination vac
	ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null AND dea.continent != ''
--order by 2,3


select*
from PercentPopulationVaccinated 