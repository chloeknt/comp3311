-- COMP3311 21T3 Exam Q4
-- Return address for a property, given its ID
-- Format: [UnitNum/]StreetNum StreetName StreetType, Suburb Postode
-- If property ID is not in the database, return 'No such property'
create or replace view apartmentInfo(id, address)
as
select Properties.id, concat(Properties.unit_no, '/', Properties.street_no, ' ',
Streets.name, ' ', Streets.stype, ', ',
Suburbs.name, ' ', Suburbs.postcode)
from Properties join Streets on Properties.street = Streets.id 
join Suburbs on Streets.suburb = Suburbs.id 
;

create or replace view houseInfo(id, address)
as
select Properties.id, concat(Properties.street_no, ' ', Streets.name, ' ', 
Streets.stype, ', ', Suburbs.name, ' ', Suburbs.postcode)
from Properties join Streets on Properties.street = Streets.id 
join Suburbs on Streets.suburb = Suburbs.id 
;
;

create or replace function address(propID integer) returns text
as
$$
declare
	info record;
	address_string text;
	type text;
begin
	perform * from Properties where id = propID;
	if (not found) then
		return 'No such property';
	end if;
	select ptype into type from Properties where id = propID;
	if type = 'Apartment' then
		select address into address_string from apartmentInfo where id = propID;
	else
		select address into address_string from houseInfo where id = propID;
	end if;
	return address_string;
end;
$$ language plpgsql;
