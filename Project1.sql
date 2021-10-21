Use [PortfolioProjects]

--Viewing Covid Vaccination Data 
Select * 
from [dbo].[CovidVaccinations$]

--Viewing Covid Deaths Data
Select *
from [dbo].['owid-covid-data$']
order by 3,4


--Working with Necessay Data
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..['owid-covid-data$']
order by 1,2

--Total Cases vs Total Deaths (Death_Percentage gives probability of Dying from covid)
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProjects..['owid-covid-data$']
--where location like '%States%'
order by 1,2

--Total Cases vs Population (Percentage_Population gives insight to what % of population has contacted covid)
Select Location, date, total_cases, population, (total_cases/population)*100 as Percentage_Population
from PortfolioProjects..['owid-covid-data$']
where continent is not null
order by 1,2

--Countries with Highest Infection Rates Compared to Population
Select Location, population, max(total_cases) as HighestInfection_Count, Max((total_cases/population))*100 as Percentage_Population
from PortfolioProjects..['owid-covid-data$']
where continent is not null
group by Location, Population
order by Percentage_Population desc

--Countries with Highest Death Count per Population
Select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProjects..['owid-covid-data$']
where continent is not null
group by location
order by TotalDeathCount desc

--ANALYSIS BY CONTINENT

--Continents with Highest Death Counts
Select continent, max(cast(Total_deaths as int))as TotalDeathCount
from PortfolioProjects..['owid-covid-data$']
where continent is not null
Group by continent
order by TotalDeathCount Desc

--Continents with Highest Infection Rates
Select continent, population, max(total_cases) as HighestInfection_Count, Max((total_cases/population))*100 as Percentage_Population
from PortfolioProjects..['owid-covid-data$']
--where continent is not null
group by continent, Population
order by Percentage_Population desc



--GLOBAL CHECK
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
		sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjects..['owid-covid-data$']
where continent is not null
Group by date
order by 1,2


--Vaccinations vs Dates
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProjects..['owid-covid-data$'] Dea join PortfolioProjects..CovidVaccinations$ Vac
on Dea.location = vac.location and Dea.date=Vac.date
where dea.continent is not null
order by 2,3

--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(int,vac.new_vaccinations)) over (partition by Dea.location order by dea.location, dea.Date) as CumSumVaccinations
from PortfolioProjects..['owid-covid-data$'] Dea join PortfolioProjects..CovidVaccinations$ Vac
on Dea.location = vac.location and Dea.date=Vac.date
where dea.continent is not null
order by 2,3



--Working with CTE/TEMP TABLES
--CTE

With PopvsVac (continent, location, date, population, new_vaccinations, CumSumVaccinations)

as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(int,vac.new_vaccinations)) over (partition by Dea.location order by dea.location, dea.Date) as CumSumVaccinations
from PortfolioProjects..['owid-covid-data$'] Dea join PortfolioProjects..CovidVaccinations$ Vac
on Dea.location = vac.location and Dea.date=Vac.date
where dea.continent is not null
)
Select *, (CumSumVaccinations/Population) as PerVaccinatn
from PopvsVac


--	TEMP TABLE
Drop Table if exists #PopvsVacc
Create Table #PopvsVacc
(
Continent nvarchar(255), location nvarchar(255), Date datetime, 
	Population numeric, New_Vaccinations numeric, CumSumVaccinations numeric)

Insert into #PopvsVacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(int,vac.new_vaccinations)) over (partition by Dea.location order by dea.location, dea.Date) as CumSumVaccinations
from PortfolioProjects..['owid-covid-data$'] Dea join PortfolioProjects..CovidVaccinations$ Vac
on Dea.location = vac.location and Dea.date=Vac.date
where dea.continent is not null

Select *, (CumSumVaccinations/Population) as PerVaccinatn
from #PopvsVacc


-- CREATING VIEW FOR STORING DATA TO USE FOR VISUALIZATION

