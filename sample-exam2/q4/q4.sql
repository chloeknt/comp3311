-- COMP3311 20T3 Final Exam
-- Q4: list of long and short songs by each group

-- ... helper views and/or functions (if any) go here ...
create or replace view shortSongs("group", title)
as
select Groups.name, Songs.title from Songs join Albums on Songs.on_album 
= Albums.id join Groups on Albums.made_by = Groups.id
where Songs.length < 180
;

create or replace view longSongs("group", title)
as 
select Groups.name, Songs.title from Songs join Albums on Songs.on_album 
= Albums.id join Groups on Albums.made_by = Groups.id
where Songs.length > 360
;

drop function if exists q4();
drop type if exists SongCounts;
create type SongCounts as ( "group" text, nshort integer, nlong integer );

create or replace function
	q4() returns setof SongCounts
as $$
declare
	res SongCounts;
	_group record;
begin
	for _group in 
		select Groups.name as name from Groups 
	loop
		res."group" := _group.name;
		select count(*) into res.nshort from shortSongs where shortSongs."group" = 
		_group.name group by shortSongs.group;
		if res.nshort is null then
			res.nshort := 0;
		end if;
		select count(*) into res.nlong from longSongs where longSongs."group" = 
		_group.name group by longSongs.group; 
		if res.nlong is null then
			res.nlong := 0;
		end if;
		return next res;
	end loop;
end
$$ language plpgsql
;
