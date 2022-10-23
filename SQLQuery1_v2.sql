select *
from PortofolioProject..CovidVaccinations
order by 3,4

select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select from Greece data we will use

select location, date,  total_deaths , total_cases,new_cases,population,
 cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where location = 'Greece'
order by date

-- Compare cases vs deaths in Greece
select location,  total_deaths , total_cases,
 cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where location like '%Greece%'
order by date asc

--Compare total cases vs population
-- Show us the percntage of people that got Covid

select location, date,  population , total_cases,
 cast(total_cases as float)/cast(population as float)*100 as CasesPercentage
from PortofolioProject..CovidDeaths
where location like '%Greece%'
order by date asc

--Looking for countries with Highest infection rate vs compared to population
select location, population, max(total_cases) as HighestInfectionCount, 
 max(cast(total_cases as float)/cast(population as float)*100 ) as MaxInfectedPopPercentage
from PortofolioProject..CovidDeaths
group by location, population
order by MaxInfectedPopPercentage desc

-- Only for Greece
select location, population, max(total_cases) as HighestInfectionCount, 
 max(cast(total_cases as float)/cast(population as float)*100 ) as MaxInfectedPopPercentage
from PortofolioProject..CovidDeaths
where location='Greece'
group by location, population
order by MaxInfectedPopPercentage desc


-- Showing Countries with Highest Death Count per Population
select location , max(cast(total_deaths as float)) as TotalDeathsCount
from PortofolioProject..CovidDeaths
where continent is  null
group by location 
order by TotalDeathsCount desc

--Let's examine by continent
select continent , max(cast(total_deaths as float)) as TotalDeathsCount
from PortofolioProject..CovidDeaths
where continent is not null
group by continent 
order by TotalDeathsCount desc

---Showing the continents with the highest death count

select continent , max(cast(total_deaths as float)) as TotalDeathsCount
from PortofolioProject..CovidDeaths
where continent is not null
group by continent 
order by TotalDeathsCount desc

--Global numbers & seperate date and time in date column

select cast(date as date) as date, sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths,
   sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
-- total_deaths , total_cases,
 --cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
--where location like '%Greece%'
where continent is not null
group by date
order by 1,2

--Get total cases

select  sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths,
   sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
-- total_deaths , total_cases,
 --cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
--where location like '%Greece%'
where continent is not null
order by 1,2

--Looking at total Population vs Vaccinations using partition by function

select dea.continent, dea.location , cast(dea.date as date) as date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
  on dea.location = vac.location
   and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE 

with PopvsVac (Continent,Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location , cast(dea.date as date) as date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
  on dea.location = vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp table
drop table if exists #PercentPopulationVaccinated
create table  #PercentPopulationVaccinated
(
Contintent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location , cast(dea.date as date) as date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
  on dea.location = vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Create View to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location , cast(dea.date as date) as date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
  on dea.location = vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3 

select *
from PercentPopulationVaccinated