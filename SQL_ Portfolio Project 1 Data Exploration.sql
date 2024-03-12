select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

select  Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Total cases VS Total deaths
-- shows likelihood of dying after contracting covid (by country)
select  Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%watini%'
and continent is not null
order by 1,2



-- what percentage of population got covid
select  Location, date, population, total_cases,  (total_cases/ population) * 100 as InfectedPopulationPercent
from PortfolioProject..CovidDeaths
where location like '%watini%'
order by 1,2


-- Looking at countries with highest infection rate compared to their population
select  Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/ population)) * 100 as InfectedPopulationPercent
from PortfolioProject..CovidDeaths
---where location like '%watini%'
group by Location, population
order by InfectedPopulationPercent desc

--Showing countries with the Highest Death count per population


select  Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
---where location like '%watini%'
where continent is not null
group by Location
order by TotalDeathCount desc




-- Breaking things down by CONTINENT


--showing continents with the Higest death counts

select  continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
---where location like '%watini%'
where continent is not null
group by continent
order by TotalDeathCount desc



--GLOBAL NUMBERS

select date, SUM (new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths ,SUM(cast(new_deaths as int))  / SUM(new_cases)*100   as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%watini%'
where continent is not null
group by date
order by 1,2

-- TOTAL DEATH PERCENTAGE 

select SUM (new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths ,SUM(cast(new_deaths as int))  / SUM(new_cases)*100   as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%watini%'
where continent is not null
order by 1,2



-- Total Population VS Vaccinations

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert (int,vac.new_vaccinations )) OVER (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
        and dea.date = vac.date
 where dea.continent is not null
 order by 2,3





 -- USE CTE


 with PopvsVac (Continent, Location , Date, Population, new_vaccinations, RollingPeopleVaccinated)
 as
(
 select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert (int,vac.new_vaccinations )) OVER (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
        and dea.date = vac.date
 where dea.continent is not null
-- order by 2,3
 )
 select*, (RollingPeopleVaccinated/Population)*100
 from PopvsVac




 --TEMP TABLE

 Create Table #PercentPopulationVaccinated (
 
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 insert into #PercentPopulationVaccinated
 select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert (int,vac.new_vaccinations )) OVER (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
        and dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3
 select*, (RollingPeopleVaccinated/Population)*100
 from #PercentPopulationVaccinated



 -- creating view to store data for visualizations

 Create view PercentagePopulationVaccinated as
  select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert (int,vac.new_vaccinations )) OVER (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
        and dea.date = vac.date
 where dea.continent is not null
-- order by 2,3

select *
from PercentagePopulationVaccinated