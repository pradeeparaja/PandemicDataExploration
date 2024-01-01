--What is the total number of covid-19 cases and deaths globally?

Select sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths
from `Covid_data_analysis.Global_data`;

--How has the pandemic evolved over time?
SELECT EXTRACT(year from date_reported) as Year ,SUM(new_cases) AS total_cases,SUM(new_deaths) AS total_deaths
FROM `Covid_data_analysis.Global_data`
GROUP BY Year
ORDER BY Year;


--Which countries have experienced the highest and lowest total covid-19 cases and deaths?
WITH CountryTotals AS (
  SELECT Country, SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths
  FROM `Covid_data_analysis.Global_data`
  GROUP BY Country
)
SELECT Country, Total_Cases, Total_Deaths
FROM (
  SELECT Country, Total_cases, Total_deaths,
  ROW_NUMBER() OVER (ORDER BY Total_cases DESC) AS RowAsc,
  ROW_NUMBER() OVER (ORDER BY Total_cases ASC) AS RowDesc
  FROM CountryTotals
) AS RANkDATA
WHERE RowDesc <=5 OR RowAsc <= 5;

--What are the daily trends in new cases and deaths?

WITH dailyTrends As(
  Select Date_reported, SUM(new_cases) AS Daily_Total_cases, SUM(new_deaths) AS Daily_Total_deaths
  from `Covid_data_analysis.Global_data`
  group by Date_reported
)
select Date_reported, Daily_Total_cases, Daily_Total_deaths
from dailyTrends;

--How does the (Case Fatality Rate) CFR vary between countries?
with CFR as(
  Select Country, sum(new_cases) as Total_cases, sum(new_deaths) as Total_Deaths
  from `Covid_data_analysis.Global_data`
  group by Country
)
Select Country, round((Total_deaths/nullif(Total_cases,0)),2)*100 as Fatality_Rate
from CFR
order by Fatality_Rate DESC;

--What is the death ratio and total covid - 19 cases based on the population?
With DeathRation as (
  Select distinct GD.country, WP.Population2023, sum(GD.New_deaths) as Total_deaths
  from `Covid_data_analysis.Global_data` as GD
  join
  `Covid_data_analysis.World_population` as WP
  using(Country)
  where country is not null
  group by GD.country, WP.population2023
)
Select country,Total_deaths/nullif(population2023,0)*100 as DeathRation 
from DeathRation
order by DeathRation Desc;

--How has the administration of first doses evolved over time globally?
Select DATE_UPDATED, Sum(PERSONS_VACCINATED_1PLUS_DOSE) as number_of_1st_dose from `Covid_data_analysis.Vaccination_Data`
group by DATE_UPDATED;

--Is there a correlation between the rollout of second doses and the decline in new COVID-19 case
Select v.DATE_UPDATED, sum(g.New_cases) as Total_cases , sum(v.PERSONS_LAST_DOSE) as number_of_2st_dose  from `Covid_data_analysis.Vaccination_Data`as v
left join `Covid_data_analysis.Global_data` as g
on v.DATE_UPDATED = g.Date_reported
where v.date_updated is not null and g.New_cases is not null
group by v.DATE_UPDATED 
order by DATE_UPDATED;



--Which countries have achieved the highest vaccination coverage for the first dose?
with Vaccination_Coverage as (
Select COUNTRY, sum(PERSONS_VACCINATED_1PLUS_DOSE) as Number_of_1st_dose
from 
`Covid_data_analysis.Vaccination_Data`
Group by COUNTRY
)
Select * ,
Rank() over(Order by Number_of_1st_dose DESC) as Country_Rank
from Vaccination_Coverage
order by Country_Rank;

--Are there disparities in the distribution of booster doses among different countries?
WITH Booster_Dose_Coverage AS (
SELECT COUNTRY,
Sum(PERSONS_BOOSTER_ADD_DOSE) as Number_of_Booster_doses   
FROM `Covid_data_analysis.Vaccination_Data`
GROUP BY COUNTRY
)
SELECT*,
    RANK() OVER (ORDER BY Number_of_Booster_doses DESC) AS Country_Booster_Rank
FROM Booster_Dose_Coverage
order by Country_Booster_Rank;

--Which companies are the major contributors to the production of COVID-19 vaccines?
Select COMPANY_NAME,  count(VACCINE_NAME) as Total_vaccines
from `Covid_data_analysis.Vaccine_Type`
where COMPANY_NAME is not null
group by COMPANY_NAME
order by Total_vaccines Desc;


--How many different vaccine products does each company manufacture?

Select count(Distinct PRODUCT_NAME) as Unique_Products
from `Covid_data_analysis.Vaccine_Type`



