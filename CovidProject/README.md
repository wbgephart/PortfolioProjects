This project gives an idea of what data exploration can look like within SQL. There are several skills displayed here
and it allows for the user to be able to evaluate these data sets across multiple countries. Some of what is used here
includes joins, CTE's, temp tables, windows functions, aggregate functions, creating view, and converting data types.

The steps taken to analyze this data went as follows:

1. I looked at the Total Cases vs Total Deaths (which show the likelihood of dying if you contract covid in your country)
2. Total Cases vs. Popluation (which can give you an idea of what percentage of the population are infected with Covid by country)
3. Countries with highest infection rate compared to population
4. Countries with highest death count per population
5. Sowing continents with highest death count per population
6. Total Population vs Vaccinations (which shows the percentage of the population that has received 1 or more vacciations for COVID)
7. Using CTE's to perorm calculations by partitions in the total population vs. vaccinations query
8. Using temp tables to perform calcuations on partition by in the previous query
9. And finally, creating views to store data for later visualizations.

What I really like about the queries in this data is that you are able to tailor it to your specific country.
For example, if someone from Canada was wanting to look at their data, they would simply have to change the quereis so that they
said "like '%canada%'" instead of "like '%states%'". The queries in this data set also allowed me to create visualizations
using Tableau later on. The visualization for this dataset can be found at https://public.tableau.com/app/profile/william.gephart/viz/CovidProject_16548318031930/Dashboard1?publish=yes
