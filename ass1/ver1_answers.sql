-- COMP3311 21T3 Assignment 1
--
-- Fill in the gaps ("...") below with your code
-- You can add any auxiliary views/function that you like
-- The code in this file MUST load into a database in one pass
-- It will be tested as follows:
-- createdb test; psql test -f ass1.dump; psql test -f ass1.sql
-- Make sure it can load without errorunder these conditions


-- Q1: oldest brewery

create or replace view Q1(brewery)
as
select name 
from Breweries 
where founded = (select MIN(founded) from Breweries)
;

-- Q2: collaboration beers

create or replace view Q2(beer)
as
select distinct Beers.name                             
from Beers 
inner join Brewed_by 
on Beers.id=Brewed_by.beer
where Beers.id 
in (select beer from Brewed_by group by beer having count(brewery) > 1)
;

-- Q3: worst beer

create or replace view Q3(worst)
as
select name 
from Beers 
where rating = (select min(rating) from Beers)
;

-- Q4: too strong beer

create or replace view Q4(beer,abv,style,max_abv)
as
select Beers.name, Beers.abv, Styles.name, Styles.max_abv
from Beers 
join Styles 
on Beers.style=Styles.id
where Styles.max_abv < Beers.abv
;

-- Q5: most common style

create or replace view Q5(style)
as
select distinct Styles.name 
from Styles 
join Beers 
on Styles.id=Beers.style
where Styles.id = (select Beers.style from Beers group by Beers.style order by count(style) desc limit 1)
;

-- Q6: duplicated style names

create or replace view Q6(style1,style2)
as
select style1.name, style2.name
from Styles style1, Styles style2
where style1.name ilike style2.name and style1.name != style2.name and style1.name < style2.name
;

-- Q7: breweries that make no beers

create or replace view Q7(brewery)
as
select brewery.name 
from Breweries brewery 
where not exists (
    select * 
    from Brewed_by 
    where Brewed_by.brewery = brewery.id
)
;

-- Q8: city with the most breweries

create or replace view Q8(city,country)
as
select Locations.metro, Locations.country 
from Locations 
where Locations.id = (
    select Breweries.located_in 
    from Breweries 
    group by Breweries.located_in 
    order by count(*) desc 
    limit 1
)
;

-- Q9: breweries that make more than 5 styles

create or replace view Q9(brewery,nstyles)
as
select Breweries.name, count(*)
from Breweries
(select Breweries.name from Breweries join Brewed_by 
on Breweries.id=Brewed_by.brewery where Brewed_by.beer = 
(select distinct Beers.style from Beers)
)
where 
;


-- templates for PLpgSQL functions coming soon
