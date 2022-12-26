use Portfolio;
select * from CovidDeath
where continent is not null
order by 3,4;

select * from CovidVaccination
order by 3,4;


-- select data that we are going to be using --

select location, date, total_cases,new_cases, total_deaths,population
from CovidDeath
order by 1,2;

-- Looking at total cases and total deaths--
-- shows likelihood of dying if you contract covid in your country--
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeath
where location= 'India'
order by 1,2;


-- Look at total cases vs population 
-- What percentage of population are got covid 
select location, date, total_cases, Population ,(total_cases/population)*100 as PercenatgePopulationinfected
from CovidDeath
-- where location= 'India'
order by 1,2;

-- Looking at country at highest infection rate --
select location,population,max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as PercenatgePopulationinfected
from CovidDeath
--where location= 'India'
group by location,population
order by PercenatgePopulationinfected desc;

-- showing the countrries with highest death count per population 
select location,max(CAST(total_deaths as int)) as TotalDeathCount 
from CovidDeath
--where location= 'India'
where continent is not null
group by location
order by  TotalDeathCount desc;

-- lets break things down by continent
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath 
where continent is not  null 
group by continent
order by TotalDeathcount desc;


--select location ,max(cast(total_deaths as int)) as TotalDeathCount
--from CovidDeath
--where location like '%states%' 
--group by location ;


-- showing the contient with the highest death count 
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath 
where continent is not  null 
group by continent
order by TotalDeathcount desc;

-- Global Numbers 
select date ,sum(new_cases) as Totalcases,sum(cast(new_deaths as int )) as TotalDeath,sum(cast(new_deaths as int ))/sum(new_cases) *100 as DeathPercentage
from CovidDeath
--where  loacation like '%states%'
where continent is not null 
group by date 
order by 1,2;

-- Total Global Numbers 
select sum(new_cases) as Totalcases,sum(cast(new_deaths as int )) as TotalDeath ,sum(cast(new_deaths as int ))/sum(new_cases) *100 as DeathPercentage
from CovidDeath
--where  loacation like '%%'
where continent is not null 
--group by date 
order by 1,2;


-- Covid Vaccination 
select * from CovidVaccination ;


-- joining two table 

select * from CovidVaccination as vac
join CovidDeath as dea
on vac.location=dea.location
and vac.date=dea.date
order by 3;

-- Looking at Total Population Vs Vaccination 
select dea.continent ,dea.location ,dea.date,dea.population, vac.new_vaccinations 
from  CovidDeath as dea
join 
CovidVaccination as vac 
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
order by 2,3;

-- Rolling count over new vaccination on the basis of location and new way of converting the value into int 
select dea.continent ,dea.location ,dea.date,dea.population, vac.new_vaccinations 
from  CovidDeath as dea
join 
CovidVaccination as vac 
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
order by 2,3;

-- Rolling count over new vaccination on the basis of location and new way of converting the value into int 
select dea.continent ,dea.location ,dea.date,dea.population, vac.new_vaccinations ,
sum(convert(bigint,vac.new_vaccinations )) over(Partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
from  CovidDeath  dea
join 
CovidVaccination  vac 
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
order by 2,3;




-- use CTE 
With PopvsVac(Continent,Location,Date,Population,new_vaccination ,RollingPeoplevaccinated)
as
(
select dea.continent ,dea.location ,dea.date,dea.population, vac.new_vaccinations ,
sum(convert(bigint,vac.new_vaccinations )) over(Partition by dea.location order by dea.location,dea.date ) as RollingPeoplevaccinated
from  CovidDeath  dea
join 
CovidVaccination  vac 
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeoplevaccinated/Population)*100 from PopvsVac;


-- Temp Table 

Create table #PercentPopulationvaccinated
(
Continent nchar(255),
Location nchar(255),
Date datetime,
Population numeric ,
New_Vaccination bigint ,
RollingPeoplevaccinated numeric 
);
Insert into #PercentPopulationvaccinated
select dea.continent ,dea.location ,dea.date,dea.population, vac.new_vaccinations ,
sum(convert(bigint,vac.new_vaccinations )) over(Partition by dea.location order by dea.location,dea.date ) as RollingPeoplevaccinated
from  CovidDeath  dea
join 
CovidVaccination  vac 
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
--order by 2,3

select *,(RollingPeoplevaccinated/Population)*100
From #PercentPopulationvaccinated



-- creating view to store data for later visulizations

create view PercentPopulationvaccinated as 
select dea.continent ,dea.location ,dea.date,dea.population, vac.new_vaccinations ,
sum(convert(bigint,vac.new_vaccinations )) over(Partition by dea.location order by dea.location,dea.date ) as RollingPeoplevaccinated
from  CovidDeath  dea
join 
CovidVaccination  vac 
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
--order by 2,3


select * from PercentPopulationvaccinated