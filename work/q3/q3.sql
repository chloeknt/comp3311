-- COMP3311 21T3 Exam Q3
-- Unsold house(s) with the lowest listed price
-- Ordered by property ID
create or replace view unsoldProps(property, price, street, suburb)
as
select Properties.id, Properties.list_price, concat(Properties.street_no, ' ', 
Streets.name, ' ', Streets.stype) as street, Suburbs.name
from Properties join Streets on Properties.street = Streets.id 
join Suburbs on Streets.suburb = Suburbs.id where
Properties.sold_date is null and Properties.ptype = 'House'
;


create or replace view q3(id,price,street,suburb)
as
select property, price, street, suburb from unsoldProps
where price = (select min(price) from unsoldProps) 
order by property
;
