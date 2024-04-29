select*
from [portfolio project]..CovidDeaths
where continent is not null
order by 3,4

--select*
--from [portfolio project]..CovidVaccinations
--order by 3,4

--select data that we are going to be using

select Location,date,total_cases,new_cases,total_deaths,population
from [portfolio project]..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths

--Shows likelihood of dying if you contract in United states
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project]..CovidDeaths
where continent is not null
and location like'%states%'
order by 1,2

--Shows likelihood of dying if you contract in India
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project]..CovidDeaths
WHERE location='india' and continent is not null
order by 1,2

--looking at total cases vs population

-- shows us what percentage of population has got covid

select Location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from [portfolio project]..CovidDeaths
WHERE location='india'and continent is not null
order by 1,2


--looking at countries with highes infection rate compared to population

select Location,population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from [portfolio project]..CovidDeaths
where continent is not null
Group by Location,population
order by  PercentPopulationInfected desc

--showing countries with highest death count per population


select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
from [portfolio project]..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

--break things down by continentt

--showing continet with highest death count per populatiuon

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from [portfolio project]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(New_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [portfolio project]..CovidDeaths
--WHERE location='india' 
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
order by 2,3

--use cte
with PopvsVac(continent,locaton,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from PopvsVac



--temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALISATION

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
    on dea.location=vac.location
	and dea.date=vac.date
	where dea.continent is not null
--order by 2,3