-- COMP3311 20T3 Final Exam
-- Q5: show "cards" awarded against a given team

-- Returns whether a certain player is a member of a certain team
create or replace function
	IsPlayerOfTeam(_player integer, _team text) returns boolean
as $$
declare
begin
	perform * from Players where id = _player and memberof = (select id from Teams where country = _team);
	if (not found) then
		return False;
	end if;
	return True;
end;
$$ language plpgsql
;

drop function if exists q5(text);
drop type if exists RedYellow;

create type RedYellow as (nreds integer, nyellows integer);

create or replace function
	Q5(_team text) returns RedYellow
as $$
declare
	reds integer := 0;
	yellows integer := 0;
	res RedYellow;
	info record;
begin
	perform * from Teams where country = _team;
	if (not found) then
		res.nreds := null;
		res.nyellows := null;
		return res;
	end if;
	for info in
		select givento, cardtype from Cards 
	loop
		if IsPlayerOfTeam(info.givento, _team) then
			if info.cardtype = 'yellow' then
				yellows := yellows + 1;
			else 
				reds := reds + 1;
			end if;
		end if;
	end loop;
	res.nreds := reds;
	res.nyellows := yellows;
	return res;
end;
$$ language plpgsql
;
