Select *
From covidProject..covidDeaths$
order by 3,4

--Select *
--From covidProject..covidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From covidProject..covidDeaths$
order by 1,2

-- Total Cases vs Total Deaths (in the United States)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From covidProject..covidDeaths$
Where Location like '%states%'
order by 1,2

-- Total Cases vs Population (in the United States)
Select Location, date, total_cases, population, (total_cases/population)*100 as covid_percentage
From covidProject..covidDeaths$
Where Location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate vs Population
Select Location, population, MAX(total_cases) as highest_infection, MAX((total_cases/population))*100 as infection_percentage
From covidProject..covidDeaths$
Group by location, population
order by infection_percentage desc

-- Continent
Select continent, MAX(cast(Total_deaths as int)) as total_death_count
From covidProject..covidDeaths$
Where continent is not null
Group by continent
order by total_death_count desc

-- Global
Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_percentage
From covidProject..covidDeaths$
Where continent is not null
Group by date
order by 1,2

-- CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From covidProject..covidDeaths$ dea
Join covidProject..covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From covidProject..covidDeaths$ dea
Join covidProject..covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Views
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From covidProject..covidDeaths$ dea
Join covidProject..covidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select * 
From PercentPopulationVaccinated
