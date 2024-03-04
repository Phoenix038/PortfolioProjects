
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Looking at toal cases vs total deaths
--Shows likelyhood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%States%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid
select Location, date, total_cases, population, (total_cases/population)*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%States%'
order by 1,2

--Looking at Countries with the highest infection rate compare to Population
select Location, max(total_cases) as Highestinfectioncount, population, max((total_cases/population))*100 as Percentpopulationinfected
from PortfolioProject..CovidDeaths
group by location, population
order by Percentpopulationinfected DESC

--Showing county with highest death count per population
select Location, max(cast(total_deaths as int)) as Totaldeathcount, population, max((total_cases/population))*100 as Percentpopulationdeath
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by Totaldeathcount DESC

--Let's breaking things down by continent
select continent, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Totaldeathcount DESC

-- Showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Totaldeathcount DESC

-- Global numbers
select date, sum(new_cases), sum(cast(new_deaths as int))
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccinations
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
, (Rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3
--or sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
-- Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (Rollingpeoplevaccinated/population)*100
from PopvsVac

-- Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
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
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
select *
from PercentPopulationVaccinated