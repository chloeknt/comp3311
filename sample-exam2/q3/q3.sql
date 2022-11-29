-- COMP3311 20T3 Final Exam
-- Q3:  performer(s) who play many instruments

-- ... helper views (if any) go here ...
create or replace view instrumentTypes(performer, name, instrument)
as
select distinct Playson.performer, Performers.name,
case when instrument ilike '%guitar%' then 'guitar'
else instrument
end
from Playson join Performers on Playson.performer = Performers.id
where instrument <> 'vocals'
;

create or replace view numInstruments(ninstruments)
as
select count(distinct instrumentTypes.instrument) as ninstruments from 
instrumentTypes
;

create or replace view idAndNumInstruments(performer,ninstruments)
as
select instrumentTypes.performer, count(*) from instrumentTypes group by 
instrumentTypes.performer having count(*) > ((select ninstruments from numInstruments) / 2)
;

create or replace view q3(performer, ninstruments)
as
select Performers.name, idAndNumInstruments.ninstruments from Performers
join idAndNumInstruments on Performers.id = idAndNumInstruments.performer
;

