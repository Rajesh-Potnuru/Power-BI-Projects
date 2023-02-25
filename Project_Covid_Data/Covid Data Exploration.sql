--Checking both tables have same number of rows
select COUNT(*) as Records from CovidData..[covid-deaths];
select COUNT(*) as Records from CovidData..[covid-vaccinations];


-- Viewing the data from both tables
select * 
from CovidData..[covid-deaths]
order by 3,4;

select *
from CovidData..[covid-vaccinations]
order by 3,4;

--Viewing continents and location details to check null/ empty data
select continent,location
from CovidData..[covid-deaths]
--where continent is not null
group by continent, location;



--Querying the location, date, population, total cases, new cases, total deaths and new deaths
select continent,location,date, population, total_cases, new_cases, total_deaths, new_deaths
from CovidData..[covid-deaths]
where continent is not null
order by 2,3;

--Total death percentage by population and daily death percentage by daily death percentage
select continent,location,date, population, total_cases, new_cases, total_deaths, new_deaths
from CovidData..[covid-deaths]
where continent is not null
order by 2,3;

--Total cases percentage by population and date
select continent,location,date, population, total_cases, (total_cases/population)*100 as total_cases_percentage_in_population
from CovidData..[covid-deaths]
where continent is not null
order by 2,3;

--New infesction cases by day percentage by total cases
select continent,location,date, population, total_cases,new_cases, (new_cases/total_cases)*100 as new_cases_percentage_in_total_cases
from CovidData..[covid-deaths]
where continent is not null
order by 2,3;

----Total deaths percentage by population and date
select continent,location,date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as total_deaths_percentage_in_total_cases
from CovidData..[covid-deaths]
where continent is not null
order by 2,3;

--New daily deaths percentage
select continent,location,date, population, total_cases, total_deaths,new_deaths, (cast(new_deaths as float)/total_deaths)*100 as new_deaths_percentage_in_total_deaths
from CovidData..[covid-deaths]
where continent is not null
order by 2,3;

--Total cases and total deaths by continent and location
select continent, location,population, MAX(total_cases) as total_cases,(MAX(total_cases/population)*100) as total_cases_percentage, MAX(cast(total_deaths as int)) as total_deaths, (MAX(total_deaths/total_cases)*100) as total_death_percentage
from CovidData..[covid-deaths]
where continent is not null 
group by continent, location, population
order by total_deaths desc;

--Total cases, total cases percentage, new cases, new cases percentage, total deaths, total death percentage,new deaths, new death percentage
select continent,location,date, population, total_cases, (total_cases/population)*100 as total_cases_percentage_in_population,
		new_cases, (new_cases/total_cases)*100 as new_cases_percentage_in_total_cases, 
		total_deaths, (total_deaths/total_cases)*100 as total_deaths_percentage_in_total_cases,
		new_deaths, (cast(new_deaths as float)/total_deaths)*100 as new_deaths_percentage_in_total_deaths
from CovidData..[covid-deaths]
where continent is not null
order by 2,3;


-- Viewing the data from vaccinations table
select *
from CovidData..[covid-vaccinations]
order by 3,4;

--Total people fully vaccinated by date
select continent,location, date,people_fully_vaccinated
from CovidData..[covid-vaccinations]
where continent is not null
order by location, date;

--Total people fully vaccinated by continent and location
select continent,location,MAX(CAST(people_fully_vaccinated as int)) as total_vaccinations
from CovidData..[covid-vaccinations]
where continent is not null
group by continent,location
order by total_vaccinations desc;


--Temp table creation
drop table if exists #TempCovidData;
create table #TempCovidData(
	continent nvarchar(255),
	location nvarchar(255),
	population numeric,
	date Date,
	total_cases numeric,
	total_cases_percentage_in_population float,
	new_cases numeric,
	new_cases_percentage_in_total_cases float,
	total_deaths numeric,
	total_deaths_percentage_in_total_cases float,
	new_deaths numeric,
	new_deaths_percentage_in_total_deaths float,
	new_vaccinations numeric,
	fully_vaccinated_people numeric,
	fully_vaccinated_percentage float
);

insert into #TempCovidData
select cd.continent, cd.location, cd.population, cd.date,  cd.total_cases, (cd.total_cases/cd.population)*100 as total_cases_percentage_in_population,
		cd.new_cases, (cd.new_cases/cd.total_cases)*100 as new_cases_percentage_in_total_cases, 
		cd.total_deaths, (cd.total_deaths/cd.total_cases)*100 as total_deaths_percentage_in_total_cases,
		cd.new_deaths, (cast(cd.new_deaths as float)/cd.total_deaths)*100 as new_deaths_percentage_in_total_deaths,
		cv.new_vaccinations,
		CAST(cv.people_fully_vaccinated as int) as fully_vaccinated_people, (CAST(cv.people_fully_vaccinated as int)/cd.population)*100 as fully_vaccinated_percentage
from CovidData..[covid-deaths] as cd
join CovidData..[covid-vaccinations] as cv
on cd.date = cv.date and
	cd.location=cv.location
where cd.continent is not null and cv.continent is not null



--All the required data after joining
drop view if exists CovidDataView; --run separately
create view CovidDataView as
select cd.continent, cd.location, cd.population, cd.date,  cd.total_cases, (cd.total_cases/cd.population)*100 as total_cases_percentage_in_population,
		cd.new_cases, (cd.new_cases/cd.total_cases)*100 as new_cases_percentage_in_total_cases, 
		cd.total_deaths, (cd.total_deaths/cd.total_cases)*100 as total_deaths_percentage_in_total_cases,
		cd.new_deaths, (cast(cd.new_deaths as float)/cd.total_deaths)*100 as new_deaths_percentage_in_total_deaths,
		cv.new_vaccinations,
		CAST(cv.people_fully_vaccinated as int) as fully_vaccinated_people, (CAST(cv.people_fully_vaccinated as int)/cd.population)*100 as fully_vaccinated_percentage
from CovidData..[covid-deaths] as cd
join CovidData..[covid-vaccinations] as cv
on cd.date = cv.date and
	cd.location=cv.location
where cd.continent is not null and cv.continent is not null ;
--order by cd.location,cd.date

--View 
select * from CovidData..CovidDataView
