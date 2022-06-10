/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4



-- Select data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' 
and continent is not null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population was infected with Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%states%'
order by 1,2


--Countries with Highest Infection Rate Compared to Population

Select location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc




-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows percentage of population that has received at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform calcuation on partition by in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from popvsvac

-- Using Temp Table to perform calculation on partition by in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View To Store Data For Later Visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) 
OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



--Tableau Visualization 1
Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
--group by date
order by 1,2


--Tableau Visualization 2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


--Tableau Visualization 3
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--Tableau Visualization 4
Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From portfolioproject..coviddeaths
--Where location like '%states%'
Group by location, population, date
order by PercentPopulationInfected desc