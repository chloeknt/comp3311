-- COMP3311 20T3 Final Exam
-- Q2: group(s) with no albums

-- ... helper views (if any) go here ...
create or replace view groupsWithAlbums("group")
as
select Albums.made_by from Albums group by Albums.made_by
;

create or replace view q2("group")
as
select Groups.name from Groups where Groups.id not in (select 
groupsWithAlbums."group" from groupsWithAlbums)
;

