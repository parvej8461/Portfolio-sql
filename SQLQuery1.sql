SELECT * 
FROM CovidDeaths$_xlnm#_FilterDatabase
where continent is not null
order by 3,4

--SELECT * 
--FROM CovidVaccinations$_xlnm#_FilterDatabase
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$_xlnm#_FilterDatabase

order by 1,2

--looking total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your coiuntry
select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as death_percentage 
from CovidDeaths$_xlnm#_FilterDatabase
where location= 'India'
order by 1,2



--look at total cases vs population

select location, date, total_cases,population ,(total_cases/population)*100 as death_percentage 
from CovidDeaths$_xlnm#_FilterDatabase
--where location= 'India'
order by 1,2

-- looking at max cases vs population

select location,population, MAX(total_cases) as maximuminfectedcount ,MAX((total_cases/population))*100 as maxpercentinfected
from CovidDeaths$_xlnm#_FilterDatabase
group by population,location
order by maxpercentinfected DESC



-- countries showing highest death count per population
select location, MAX(cast(total_deaths as int)) as maximumdeathcount 
from CovidDeaths$_xlnm#_FilterDatabase
where continent is not null
group by location
order by maximumdeathcount DESC


-- lets break by continet

select location, MAX(cast(total_deaths as int)) as maximumdeathcount 
from CovidDeaths$_xlnm#_FilterDatabase
where continent is null
group by location
order by maximumdeathcount DESC


--continets with highest death counts
select location, MAX(cast(total_deaths as int)) as maximumdeathcount 
from CovidDeaths$_xlnm#_FilterDatabase
where continent is null
group by location
order by maximumdeathcount DESC




-- global number
select  date, SUM(new_cases),SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from CovidDeaths$_xlnm#_FilterDatabase
where continent is not null
group by date
order by 1,2


--lookinat total population vs covid vaccination

--- Use CTE
with posvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths$_xlnm#_FilterDatabase dea
JOIN CovidVaccinations$_xlnm#_FilterDatabase vac
    on dea.location =vac.location
	and dea.date= vac.date
	where dea.continent is not null
--order by 1,2,3
)
select continent, location, population, new_vaccinations, rollingpeoplevaccinated
from posvsvac
order by 1,2,3


--creating query for later visulaization

create view percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths$_xlnm#_FilterDatabase dea
JOIN CovidVaccinations$_xlnm#_FilterDatabase vac
    on dea.location =vac.location
	and dea.date= vac.date
	where dea.continent is not null

select * from percentpopulationvaccinated


