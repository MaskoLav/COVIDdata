Select *
From COVID_project.dbo.CovidDeaths$
where continent is not null
order by 3,4


--Select *
--From COVID_project.dbo.CovidVaccinations$
--order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From COVID_project.dbo.CovidDeaths$
where continent is not null
order by 1,2


-- Death percentage of people who had covid in a country (eg. Croatia)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From COVID_project.dbo.CovidDeaths$
where continent is not null 
and location like '%croatia%'
order by 1,2


-- Percentage of people who have had covid in a country
Select location, date, total_cases, population, (total_cases/population)*100 as PopulationInfPerc
From COVID_project.dbo.CovidDeaths$
where continent is not null 
and location like '%croatia%'
order by 1,2


-- Max amount of people infected in a country as a percentage
Select location, population, MAX(total_cases) as MAXTotalCases, MAX((total_cases/population))*100 as MaxInfectedAmount
From COVID_project.dbo.CovidDeaths$
where continent is not null 
--and location like '%croatia%'
order by MaxInfectedAmount desc


-- Maximum deaths in a country
Select location, MAX(cast(total_deaths as int)) as MAXTotalDeathsCountry
From COVID_project.dbo.CovidDeaths$
where continent is not null 
--and location like '%croatia%'
Group by location
order by MAXTotalDeathsCountry desc


-- Maximum deaths in a continent
Select location, MAX(cast(total_deaths as int)) as MAXTotalDeathsContinent
From COVID_project.dbo.CovidDeaths$
where continent is null 
--and location like '%croatia%'
Group by location
order by MAXTotalDeathsContinent desc

--Percentage of people that died against the total population
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From COVID_project.dbo.CovidDeaths$
where continent is not null 
Group By date
order by DeathPercentage desc

-- Joining two excel files
Select * 
From COVID_project.dbo.CovidDeaths$ dea
Join COVID_project.dbo.CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations))OVER(partition by dea.location order by dea.location,dea.date) as TotalVaccinatedUpToTheDate
From COVID_project.dbo.CovidDeaths$ dea
Join COVID_project.dbo.CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--and dea.location like 'croatia'
order by 2,3


--CTE

with PopVsVac (Continent,Location,Date,Population,new_vaccinations,TotalVaccinatedUpToTheDate)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations))OVER(partition by dea.location order by dea.location,dea.date) as TotalVaccinatedUpToTheDate
	From COVID_project.dbo.CovidDeaths$ dea
	Join COVID_project.dbo.CovidVaccinations$ vac
		on dea.location=vac.location
		and dea.date=vac.date
	where dea.continent is not null
)
Select *, (TotalVaccinatedUpToTheDate/Population)*100
From PopVsVac
order by 2,3


--TEMP TABLE

DROP Table if exists #PercPopVaccinated
Create Table #PercPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
TotalVaccinatedUpToTheDate numeric
)

Insert into #PercPopVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations))OVER(partition by dea.location order by dea.location,dea.date) as TotalVaccinatedUpToTheDate
	From COVID_project.dbo.CovidDeaths$ dea
	Join COVID_project.dbo.CovidVaccinations$ vac
		on dea.location=vac.location
		and dea.date=vac.date
	where dea.continent is not null

Select *, (TotalVaccinatedUpToTheDate/Population)*100 as ProportionOfVacc
From #PercPopVaccinated
order by 2,3


--Creating View for later vis

Create View PercPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int,vac.new_vaccinations))OVER(partition by dea.location order by dea.location,dea.date) as TotalVaccinatedUpToTheDate
	From COVID_project.dbo.CovidDeaths$ dea
	Join COVID_project.dbo.CovidVaccinations$ vac
		on dea.location=vac.location
		and dea.date=vac.date
	where dea.continent is not null

Select *
From PercPopVaccinated

