-- COMP3311 21T3 Exam Q2
-- Number of unsold properties of each type in each suburb
-- Ordered by type, then suburb
create or replace view propLocation(property, suburb, ptype)
as
select Properties.id, Suburbs.id, Properties.ptype from Properties join Streets on
Properties.street = Streets.id join Suburbs on Streets.suburb = Suburbs.id where
Properties.sold_date is null
;


create or replace view q2(suburb, ptype, nprops)
as
select Suburbs.name, propLocation.ptype, count(*) from Suburbs join
propLocation on Suburbs.id = propLocation.suburb group by Suburbs.name, 
propLocation.ptype order by propLocation.ptype, Suburbs.name
;
