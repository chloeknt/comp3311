-- COMP3311 20T3 Final Exam Q7
-- Put any helper views or PLpgSQL functions here
-- You can leave it empty, but you must submit it

create or replace view goalsOrderedByDate
as
select Goals.scoredin, Goals.scoredby, Matches.playedon, count(*) from Goals join Matches on Goals.scoredin = Matches.id group by Goals.scoredin, Goals.scoredby, Matches.playedon order by Matches.playedon
;