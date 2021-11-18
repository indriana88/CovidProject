
Select * From Portofolio..CovidDeath
Where continent is not null
Order by 3,4

--Select * From Portofolio..CovidVaksin
--Order by 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From Portofolio..CovidDeath
Order by 1,2

-- Looking for total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your contry
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPrecentages
From Portofolio..CovidDeath
Where location like '%indonesia%'
And continent is not null
Order by 1,2

--Looking for total cases vs population
-- Shows what percent of population got govid
Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From Portofolio..CovidDeath
Where location like '%states%'
Order by 1,2

--Looking at countriest with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfection, MAX((total_cases/population))*100 AS PercentPopulationInfected
From Portofolio..CovidDeath
Where continent is not null
Group by location, population
Order by PercentPopulationInfected DESC

--Showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From Portofolio..CovidDeath
Where continent is not null
Group by location
Order by TotalDeathCount DESC

-- LETS BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From Portofolio..CovidDeath
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--Global Numbers

--The day that the world has the most death people by covid vs new cases covid
Select date, SUM(new_cases) AS NewCases, SUM(cast(new_deaths as int)) AS NewDeath, 
SUM(Cast(New_Deaths as int))/SUM(New_Cases)*100 
AS DeathPercentage
From Portofolio..CovidDeath
Where continent is not null
Group by date
Order by DeathPercentage DESC

--JOINTABLE

--Looking at Total Population VS Vacctinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Portofolio..CovidDeath dea
Join Portofolio..CovidVaksin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--Looking for.. pertambahan JUMLAH yang udah di vaksin per harinya/RollingPeaopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) AS TotalVaccinatedPerDay
--, (TotalVaccinatedPerDay/Population)*100
From Portofolio..CovidDeath dea
Join Portofolio..CovidVaksin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalVaccinatedPerDay)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) AS TotalVaccinatedPerDay
--, (TotalVaccinatedPerDay/Population)*100
From Portofolio..CovidDeath dea
Join Portofolio..CovidVaksin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select*, (TotalVaccinatedPerDay/Population)*100
From PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccinatedPerDay numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) AS TotalVaccinatedPerDay
--, (TotalVaccinatedPerDay/Population)*100
From Portofolio..CovidDeath dea
Join Portofolio..CovidVaksin vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select*, (TotalVaccinatedPerDay/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) AS TotalVaccinatedPerDay
--, (TotalVaccinatedPerDay/Population)*100
From Portofolio..CovidDeath dea
Join Portofolio..CovidVaksin vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select * From PercentPopulationVaccinated
