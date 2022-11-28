-- COMP3311 20T3 Final Exam
-- Q4: function that takes two team names and
--     returns #matches they've played against each other

create or replace function
	Q4(_team1 text, _team2 text) returns integer
as $$
declare
	t_id1 integer;
	t_id2 integer;
	info1 record;
	info2 record;
	n_matches integer := 0;
begin
	perform * from Teams where country = _team1;
	if (not found) then
		return null;
	end if;
	perform * from Teams where country = _team2;
	if (not found) then
		return null;
	end if;
	for info1 in
		select match from Involves where team = (select id from Teams where country = _team1)
	loop
		for info2 in 
			select match from Involves where match = info1.match and
			team = (select id from Teams where country = _team2)
		loop
			n_matches := n_matches + 1;
		end loop;
	end loop;
	return n_matches;
end;
$$ language plpgsql
;
