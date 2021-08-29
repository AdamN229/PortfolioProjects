Select *
From PortfolioDatabase..CovidDeathsData$
Where continent is not null
order by 3,4


--Select *
--From PortfolioDatabase..CovidVaccinationsData$
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioDatabase..CovidDeathsData$
Where continent is not null
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- This shows the chances of dying if you contract Covi-19
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioDatabase..CovidDeathsData$
Where location like '%states%' and continent is not null
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows the population that has had covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioDatabase..CovidDeathsData$
Where location like '%states%'
order by 1,2

-- What countries have the highest infection rates compared to population?

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioDatabase..CovidDeathsData$
Group by Location, population
order by PercentPopulationInfected desc

--  Shows countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioDatabase..CovidDeathsData$
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Showing continents with highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioDatabase..CovidDeathsData$
Where continent is null
Group by location
order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioDatabase..CovidDeathsData$
Where continent is not null
--Group by date
order by 1,2

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioDatabase..CovidDeathsData$
Where continent is not null
Group by date
order by 1,2


-- Looking at total population vs vacciantions

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioDatabase..CovidDeathsData$ dea
Join PortfolioDatabase..CovidVaccinationsData$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Second look

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioDatabase..CovidDeathsData$ dea
Join PortfolioDatabase..CovidVaccinationsData$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, 
Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioDatabase..CovidDeathsData$ dea
Join PortfolioDatabase..CovidVaccinationsData$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioDatabase..CovidDeathsData$ dea
Join PortfolioDatabase..CovidVaccinationsData$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


-- Creating View to store data visuals

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations
, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioDatabase..CovidDeathsData$ dea
Join PortfolioDatabase..CovidVaccinationsData$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

-- View 
Select * 
From PercentPopulationVaccinated