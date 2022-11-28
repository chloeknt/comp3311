-- COMP3311 20T3 Final Exam Q6
-- Put any helper views or PLpgSQL functions here
-- Helper to compile match information 
-- You can leave it empty, but you must submit it
drop function if exists IsPlayerOfTeam(integer, integer);
create or replace function
	IsPlayerOfTeam(_player integer, _team integer) returns boolean
as $$
declare
begin
	perform * from Players where id = _player and memberof = _team;
	if (not found) then
		return False;
	end if;
	return True;
end;
$$ language plpgsql
;