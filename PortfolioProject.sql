SELECT *
FROM CovidVaccinations$
ORDER BY 1,4

--Selecting data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDer by 1,2


--looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDer by 1,2



--Looking at the totalcases vs population 
--shows what percentage of population that got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as Populationpercentage
FROM CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDer by 1,2


--looking at countries wth hihest infection rate compared to population

SELECT location, population, MAX(total_cases) as Highestinfectioncount, MAX(total_cases/population)*100 as InfectedPopulationpercentage
FROM CovidDeaths
--WHERE location LIKE '%Nigeria%'
GROUP BY location, population
ORDer by InfectedPopulationpercentage desc


--showing country with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as highestdeathcountpercountry
FROM CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
GROUP BY location
ORDer by highestdeathcountpercountry desc 


--Let's break things down by continent

--Showing continents with the highest death counts per population 

SELECT continent, MAX(cast(total_deaths as int)) as highestdeathcountpercountry
FROM CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDer by highestdeathcountpercountry desc 



--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentages 
FROM CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
--GROUP BY date
ORDER by 1,2





--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea. date) as Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea. date) as Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (Rollingpeoplevaccinated/population)*100
FROM PopvsVac


--use Temp table
DROP table if exists #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

INSERT INTO #Percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea. date) as Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (Rollingpeoplevaccinated/population)*100
FROM #Percentpopulationvaccinated




--Creating view to store data for later visualisation 


Create View Percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea. date) as Rollingpeoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM Percentpopulationvaccinated
