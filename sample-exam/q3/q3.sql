-- COMP3311 20T3 Final Exam
-- Q3: team(s) with most players who have never scored a goal

-- Make a table for player, country, number of goals this player has scored
-- Left outer join to also get players with zero goals 
create or replace view PlayersAndGoals(player,team,ngoals)
as
select Players.id, Teams.country, count(Goals.id) from Players join Teams on Teams.id = Players.memberof 
left outer join Goals on Goals.scoredby=Players.id group by Players.id, Teams.country
;

create or replace view TeamsAndGoaless(team,nplayers)
as
select team, count(*) from PlayersAndGoals 
where ngoals = 0 group by team
;

create or replace view Q3(team,nplayers)
as
select team, nplayers from TeamsAndGoaless
where nplayers = (select max(nplayers) from TeamsAndGoaless)
;

