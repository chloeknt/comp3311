-- COMP3311 20T3 Final Exam
-- Q1: longest album(s)

-- ... helper views (if any) go here ...
create or replace view albumLength(album, total_length)
as
select Songs.on_album, sum(Songs.length) from Songs group by Songs.on_album 
order by sum(Songs.length) desc 
;

create or replace view q1("group",album,year)
as
select Groups.name, Albums.title, Albums.year from Groups join Albums on Groups.id
= Albums.made_by where Albums.id = (select albumLength.album from albumLength
where albumLength.total_length = (select max(albumLength.total_length) from
albumLength))
;

