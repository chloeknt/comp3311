-- COMP3311 20T3 Final Exam
-- Q1: view of teams and #matches

-- ... helper views (if any) go here ...

create or replace view Q1(team,nmatches)
as
select country, count(*) from Teams join Involves on Teams.id=Involves.team group by Teams.country order by Teams.country
;

