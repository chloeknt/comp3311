-- COMP3311 20T3 Final Exam
-- Q2: view of amazing goal scorers

-- ... helpers go here ...

create or replace view Q2(player,ngoals)
as
select Players.name, count(*) from Players join Goals on Players.id = Goals.scoredby where 
Goals.rating = 'amazing' group by Players.name having count(*) > 1 order by Players.name
;

