
--Covid-19 Data Exploration (GigQuery Version)



--Select Data that we are going to be starting with

SELECT
  location, date, total_cases, new_cases, total_deaths, population
FROM `nodal-time-361920.Portfolio_covid.CovidDeaths`
order by 1,2


-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

SELECT
  location, date, total_cases, total_deaths,
  (total_deaths / total_cases) * 100 AS DeathPercentage
FROM `nodal-time-361920.Portfolio_covid.CovidDeaths`
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got Covid

SELECT
  location, date, population, total_cases,
  (total_cases / population) * 100 AS Percent_Population_Infected
FROM `nodal-time-361920.Portfolio_covid.CovidDeaths`
WHERE location = 'United States'
order BY Percent_Population_Infected DESC


--  Looking at Countries with Highest Infection Rate compared to Population

SELECT
  location, population,
  MAX(total_cases) AS Highest_Infection_Count,
  MAX((total_cases / population)) * 100  AS Percent_Population_Infected
FROM `nodal-time-361920.Portfolio_covid.CovidDeaths`
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC



SELECT
  location,
  MAX(total_cases) AS Total_Death_Count,
FROM `nodal-time-361920.Portfolio_covid.CovidDeaths`
WHERE continent != 'Null'
GROUP BY location
ORDER BY Total_Death_Count DESC



-- Global numbers

SELECT
  date,
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  SUM(new_deaths) / SUM(new_cases) * 100 AS Death_Percentage
FROM `nodal-time-361920.Portfolio_covid.CovidDeaths`
WHERE continent != 'Null'
GROUP BY date
ORDER BY 1, 2



-- Total cases

SELECT
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  SUM(new_deaths) / SUM(new_cases) * 100 AS Death_Percentage
FROM `nodal-time-361920.Portfolio_covid.CovidDeaths`
WHERE continent != 'Null'
ORDER BY 1, 2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one dose of vaccine
SELECT
  Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
  SUM(Vaccinations.new_vaccinations) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS Rolling_People_Vaccinated
FROM `nodal-time-361920.Portfolio_covid.CovidDeaths` AS Deaths
JOIN `nodal-time-361920.Portfolio_covid.CovidVaccinations` AS Vaccinations
ON Deaths.location = Vaccinations.location
AND Deaths.date = Vaccinations.date
WHERE Deaths.continent != 'Null'
ORDER BY 2,3


-- Use CTE 

WITH Population_vs_Vaccinations
AS
(
  SELECT
    Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
    SUM(Vaccinations.new_vaccinations) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS Rolling_People_Vaccinated
  FROM `nodal-time-361920.Portfolio_covid.CovidDeaths` AS Deaths
  JOIN `nodal-time-361920.Portfolio_covid.CovidVaccinations` AS Vaccinations
  ON Deaths.location = Vaccinations.location
  AND Deaths.date = Vaccinations.date
  WHERE Deaths.continent != 'Null'

)

select *, (Rolling_People_Vaccinated / Population) * 100 AS Vaccinated_Percentage
from Population_vs_Vaccinations



-- Creating View to store data for later visualizations

Create View `nodal-time-361920.Portfolio_covid.Percent_People_Vaccinated` AS
SELECT
  Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vaccinations.new_vaccinations,
  SUM(Vaccinations.new_vaccinations) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS Rolling_People_Vaccinated
FROM `nodal-time-361920.Portfolio_covid.CovidDeaths` AS Deaths
JOIN `nodal-time-361920.Portfolio_covid.CovidVaccinations` AS Vaccinations
ON Deaths.location = Vaccinations.location
AND Deaths.date = Vaccinations.date
WHERE Deaths.continent != 'Null'

select *
from `nodal-time-361920.Portfolio_covid.Percent_People_Vaccinated`









