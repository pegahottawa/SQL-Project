select 
  location,
  continent,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population 
from PUBLIC.coviddeaths
where location like '%States%' 
order by 1,3

--looking at Total Cases vs Total Deaths
--likelihood of dying

ALTER TABLE PUBLIC.coviddeaths
 ALTER COLUMN "total_deaths" TYPE integer USING(total_deaths::INTEGER)
 --or you can use cast( column name as int)
 select 
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases::decimal)*100 as DeathPercentage
from PUBLIC.coviddeaths
where location like '%States%'
order by 1,2

--looking at Total Cases vs Population
--shows what percentage of population got Covid

select 
  location,
  date,
  total_cases,
  population,
  (total_cases/population::decimal)*100 as PercentPopulationInfected 
from PUBLIC.coviddeaths
where location like '%States%'
order by 1,2

select
  location,
  population,
  Max(total_cases) as HighestInfectionCount,
  Max((total_cases/population::decimal))*100 as PercentPopulationInfected 
from PUBLIC.coviddeaths
group by 1,2
order by 4 desc

--showing Countries with Highest Death Count

select
  location,
  Max(total_deaths) as TotalDeathCount
from PUBLIC.coviddeaths
where continent is not null --since we want this by country not continent 
group by 1
order by TotalDeathCount desc

--showing Continent with Highest Death Count

select
  continent ,
  Max(total_deaths) as TotalDeathCount
from PUBLIC.coviddeaths
where continent is not null
group by 1
order by TotalDeathCount desc


--Global Numbers 

select 
 date,
 SUM(cast(new_cases as int)) as total_cases,
 SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int))/
 SUM(cast(new_cases as int))::decimal)*100 as DeathPercentageWorld
from  PUBLIC.coviddeaths
where continent is not null
group by date
order by 1,2

select 
 SUM(cast(new_cases as int)) as total_cases,
 SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int))/
 SUM(cast(new_cases as int))::decimal)*100 as DeathPercentageWorld
from  PUBLIC.coviddeaths
where continent is not null
order by 1

select *
from  PUBLIC.coviddeaths as d
join PUBLIC.covidvaccinations as v
on d.location = v.location and d.date = v.date 


--looking at Total Population vs Vaccination

with PopvsVac as (
select 
 d.date,
 d.continent,
 d.location,
 d.population,
 v.new_vaccinations,
 SUM(cast(v.new_vaccinations as int))over
 (partition by d.location order by d.date) as RollingPeopleVaccinated
from  PUBLIC.coviddeaths as d
join PUBLIC.covidvaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null 
order by 2,3,1
)
select *,
 (RollingPeopleVaccinated/population::decimal)*100 as PercPopvaVac
from PopvsVac
where new_vaccinations is not null


--Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists PercentPopulationVaccinated

drop view PercentPopulationVaccinated

create table PercentPopulationVaccinated
(
date date,
location varchar(255),
continent varchar(255),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
);

INSERT INTO PercentPopulationVaccinated
select 
 d.date,
 d.location,
 d.continent,
 d.population ,
 cast(v.new_vaccinations as int) as new_vaccinations,
 SUM(cast(v.new_vaccinations as int))over(partition by d.location order by d.date ) as RollingPeopleVaccinated
from PUBLIC.coviddeaths as d
join PUBLIC.covidvaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null 
order by 2,3,1

select *,
 (RollingPeopleVaccinated/population::decimal)*100 as PercPopvaVac
from PercentPopulationVaccinated
where new_vaccinations is not null 


--creating view to store data for later visulizations 

create view PercentPopulationVaccinated as
select 
 d.date,
 d.location,
 d.continent,
 d.population ,
 cast(v.new_vaccinations as int) as new_vaccinations,
 SUM(cast(v.new_vaccinations as int))over(partition by d.location order by d.date ) as RollingPeopleVaccinated
from PUBLIC.coviddeaths as d
join PUBLIC.covidvaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null 
--order by 2,3,1


























