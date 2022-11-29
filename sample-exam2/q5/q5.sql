-- COMP3311 20T3 Final Exam
-- Q5: find genres that groups worked in

-- ... helper views and/or functions go here ...
create or replace view groupAndGenres("group", genre)
as
select distinct Groups.name, Albums.genre from Groups full outer join Albums on 
Groups.id = Albums.made_by
;

drop function if exists q5();
drop type if exists GroupGenres;

create type GroupGenres as ("group" text, genres text);

create or replace function
    q5() returns setof GroupGenres
as $$
declare
	res GroupGenres;
	info record;
begin
	for info in
		select "group", string_agg(genre, ',' order by genre) as genres
		from groupAndGenres group by "group"
	loop
		res."group" := info."group";
		res.genres := info.genres;
		return next res;
	end loop;
end;
$$ language plpgsql
;

