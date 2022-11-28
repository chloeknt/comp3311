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
select Breweries.name as brewery
from Breweries 
where Breweries.founded = (
    select min(founded) 
    from Breweries
)
;

-- Q2: collaboration beers

create or replace view Q2(beer)
as
select distinct Beers.name as beer                        
from Beers 
join Brewed_by 
on Beers.id=Brewed_by.beer
where Beers.id in (
    select beer 
    from Brewed_by 
    group by beer 
    having count(brewery) > 1
)
;

-- Q3: worst beer

create or replace view Q3(worst)
as
select Beers.name as worst
from Beers 
where rating = (
    select min(rating) 
    from Beers
)
;

-- Q4: too strong beer

create or replace view Q4(beer,abv,style,max_abv)
as
select Beers.name as beer, Beers.abv, Styles.name as style, Styles.max_abv
from Beers 
join Styles 
on Beers.style=Styles.id
where Styles.max_abv < Beers.abv
;

-- Q5: most common style

create or replace view Q5(style)
as
select distinct Styles.name as style
from Styles 
join Beers 
on Styles.id=Beers.style
where Styles.id = (
    select Beers.style 
    from Beers 
    group by Beers.style 
    order by count(style) desc limit 1
)
;

-- Q6: duplicated style names

create or replace view Q6(style1,style2)
as
select style1.name as style1, style2.name as style2
from Styles style1, Styles style2
where style1.name ilike style2.name and style1.name < style2.name
;

-- Q7: breweries that make no beers

create or replace view Q7(brewery)
as
select brewery.name as brewery
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
select Locations.metro as city, Locations.country as country
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
-- select the breweries one by one
-- select the beers each brewery makes
-- check and count up the number of styles each beer is 
select brewery.name as brewery, count(distinct brewery.style) as nstyles 
from (
    select Breweries.name, Beers.style 
    from Breweries
    join Brewed_by
    on Breweries.id = Brewed_by.brewery
    join Beers
    on Beers.id = Brewed_by.beer
) as brewery
group by brewery.name 
having count(distinct brewery.style) > 5
;


-- Q10: beers of a certain style
create or replace function
	q10(_style text) returns setof BeerInfo
as $$
declare 
    info BeerInfo; 
begin
    for info in 
        select Beers.name as beer, string_agg(Breweries.name, ' + ' order by Breweries.name) brewery, Styles.name as style, Beers.brewed as _year, Beers.abv as abv          
        from Beers
        join Styles
        on Beers.style = Styles.id
        join Brewed_by 
        on Beers.id=Brewed_by.beer
        join Breweries
        on Breweries.id = Brewed_by.brewery
        where Styles.name = _style
        group by Beers.name, Beers.id, Styles.name, Beers.brewed, Beers.abv
    loop
        return next info;
    end loop;
end;
$$
language plpgsql;


-- Q11: beers with names matching a pattern

create or replace function
	Q11(partial_name text) returns setof text
as $$
declare
    pattern text := '%' || partial_name || '%';
    info record;
    result text;
begin
    for info in 
        select Beers.name as beer, string_agg(Breweries.name, ' + ' order by Breweries.name) brewery, Styles.name as style, Beers.abv as abv 
        from Beers
        join Styles
        on Beers.style = Styles.id
        join Brewed_by
        on Beers.id = Brewed_by.beer
        join Breweries
        on Breweries.id = Brewed_by.brewery
        where Beers.name ilike pattern
        group by Beers.name, Beers.id, Styles.name, Beers.abv
    loop
        result := '"' || info.beer || '", ' || info.brewery || ', ' || info.style || ', ' || info.abv || '% ABV';
        return next result;
    end loop;
end;
$$
language plpgsql;

-- Q12: breweries and the beers they make
create or replace function
	Q12(partial_name text) returns setof text
as $$
declare
    pattern text := '%' || partial_name || '%';
    info record;
    beer_info record;
    beer_result text;
    found int;
begin
    found := 0;
    for info in 
        select Breweries.name as brewery, Breweries.founded as founded
        from Breweries 
        where Breweries.name ilike pattern
        order by Breweries.name
    loop
        return next brewery_info(info.brewery);
        return next location_info(info.brewery);
        for beer_info in 
            select Beers.name as beer, Styles.name as style, Beers.brewed as _year, Beers.abv as abv
            from Beers
            join Styles
            on Beers.style = Styles.id 
            join Brewed_by
            on Beers.id = Brewed_by.beer
            join Breweries
            on Breweries.id = Brewed_by.brewery
            where Breweries.name = info.brewery
            order by Beers.brewed, Beers.name
        loop
            found := 1;
            beer_result := '  "' || beer_info.beer || '", ' || beer_info.style || ', ' || beer_info._year || ', ' || beer_info.abv || '% ABV';
            return next beer_result;
        end loop;
        if found = 0 then 
            beer_result := '  No known beers';
            return next beer_result;
        end if;
        found := 0;
    end loop;
end;
$$
language plpgsql;

-- This function will return a set of Brewery information matching the pattern
create or replace function 
    brewery_info(_brewery text) returns text
as $$
declare
    result text;
    info record;
begin
    for info in 
        select Breweries.name as brewery, Breweries.founded as founded
        from Breweries 
        where Breweries.name = _brewery
        order by Breweries.name
    loop
        result := info.brewery || ', founded ' || info.founded;
    end loop;
    return result;
end;
$$
language plpgsql;


-- This function will return a set of location information for a particular brewery
create or replace function
    location_info(_brewery text) returns setof text
as $$
declare
    result text;
    _data record;
    region text;
    city text;
    town text;
    country text;
begin
    for _data in   
        select Locations.country as l_country, Locations.metro as l_city, Locations.region as l_region, Locations.town as l_town
        from Locations 
        join Breweries
        on Locations.id = Breweries.located_in
        where Breweries.name = _brewery
    loop
        region := _data.l_region;
        city := _data.l_city;
        town := _data.l_town;
        country := _data.l_country;
    result := (case    
        when region is not null and city is null and town is null then 'located in ' || region || ', ' || country
        when region is not null and town is null and city is not null then 'located in ' || city || ', ' || region || ', ' || country
        when region is not null and town is not null and city is null then 'located in ' || town || ', ' || region || ', ' || country
        when region is not null and town is not null and city is not null then 'located in ' || town || ', ' || region || ', ' || country
        when region is null and city is null and town is null then 'located in ' || country
        when region is null and town is null and city is not null then 'located in ' || city || ', ' || country
        else 'located in ' || town || ', ' || country
    end);
    end loop;
    return next result;
end;
$$
language plpgsql;

-- This function will return a set of beer information for a particular brewery
create or replace function 
    beer_info(_beer text) returns text 
as $$
declare
    info record;
    result text;
    complete text;
begin
    -- Beer info
    for info in 
        select Beers.name as beer, Styles.name as style, Beers.brewed as _year, Beers.abv as abv
        from Beers
        join Styles
        on Beers.style = Styles.id 
        join Brewed_by
        on Beers.id = Brewed_by.beer
        join Breweries
        on Breweries.id = Brewed_by.brewery
        where Breweries.name = _brewery
        order by Beers.brewed, Beers.name
    loop
        result := '  "' || info.beer || '", ' || info.style || ', ' || info._year || ', ' || info.abv || '% ABV';
        return result;
    end loop;
end;
$$
language plpgsql;
