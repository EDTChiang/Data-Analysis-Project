select * from zoom_usage_data;
set sql_safe_updates = 0;


-- data cleaning first --
-- comments tab is irrelevant --

alter table zoom_usage_data
drop column Comments;


-- check for duplicates --

with cte1 (userid, dates, dur, dev, loc, par, ct, ins, fr, ci, ag, st, dupes) as
(
select *, row_number() over (partition by 'Date', Duration, Device, Location, Participants, CallType, SubscriptionType, AgeGroup)
as dupes
from zoom_usage_data
)
select * from cte1
where dupes != 1;

create table zoom_usage_data1 like zoom_usage_data;

alter table zoom_usage_data1 add column copies int;

insert into zoom_usage_data1
select *, row_number() over (partition by 'Date', Duration, Device, Location, Participants, CallType, SubscriptionType, AgeGroup)
from zoom_usage_data;

select * from zoom_usage_data1
where copies != 1;

delete from zoom_usage_data1
where copies != 1;

-- no more duplicates, now use zoom_usage_data1 --

rename table zoom_usage_data1 to zoom_data;

alter table zoom_data
drop column copies;

select * from zoom_data
order by userid asc;

-- firstly you cannot have a negative duration --

alter table zoom_data
drop column duration_proper;

select duration from zoom_data
where duration < 0 ;

select abs(duration) from zoom_data;

update zoom_data
set Duration = abs(Duration);

select * from zoom_data
order by 2;

-- 