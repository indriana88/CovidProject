--Query table tableau number1
Select SUM(New_Cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPrecentage
From Portofolio..CovidDeath
Where continent is not null

--Query tableau table 2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portofolio..CovidDeath
Where continent is null 
and location not in ('World', 'European Union', 'International','Upper middle income','High income','Lower middle income','low income')
Group by location
order by TotalDeathCount desc

--3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portofolio..CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portofolio..CovidDeath
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc