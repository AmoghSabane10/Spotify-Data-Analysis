DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

select * from spotify
limit 10;

-- List all albums along with their respective artists.
select distinct album, artist from spotify
;

--Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) as total_comments from spotify where licensed = 'true';

-- Find all tracks that belong to the album type single.
select track from spotify
where album_type = 'single';

/* 

Count the total number of tracks by each artist.*/

select count(track) as no_of_tracks, artist from spotify
group by 2;


-- Calculate the average danceability of tracks in each album.
select album, avg(danceability) from spotify
group by 1;

-- Find the top 5 tracks with the highest energy values.

select track, max(energy) from spotify
group by 1
order by 2 desc limit 5;

-- List all tracks along with their views and likes where official_video = TRUE.

select track, sum(views) as total_views, sum(likes) as total_likes from spotify
where official_video = 'true'
group by 1
order by 2 desc;

-- For each album, calculate the total views of all associated tracks.

select album, track, sum(views) as total_views from spotify
group by 1,2
order by 3 desc;

/* 
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

select * from
(select  track,   
Coalesce(Sum(case when most_played_on = 'Youtube' then stream end),0) as stream_on_YT,
Coalesce(Sum(case when most_played_on = 'Spotify' then stream end),0) as stream_on_Spotify 

from spotify
group by 1) as t1  
where stream_on_Spotify>stream_on_YT and stream_on_YT <>0
;



--Find the top 3 most-viewed tracks for each artist using window functions.
select artist, track, views from 
(select artist,track, dense_rank() over (partition by artist order by sum(views) desc) as rn, sum(views) as views from spotify
group by 1,2) as t1
where rn<4
;

-- Write a query to find tracks where the liveness score is above the average.


select album, track, liveness from spotify
where liveness> (select avg(liveness) from spotify)
;

select album, track, avg(liveness) over (partition by album order by liveness) as avg_liv from spotify
group by 1,2;

-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

with cte as (select album, max(energy) as highest_energy, min(energy) as low_ener from spotify
group by 1)
select album, Round((highest_energy - low_ener)::numeric,2) as energy_diff  from cte
order by 2 desc;

-- Find tracks where the energy-to-liveness ratio is greater than 1.2.

select track, round((energy/liveness)::numeric,2) as EL_ratio from spotify
where round((energy/liveness)::numeric,2)>1.2 and liveness <>0;

/* 
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

select track, views, sum(views) over ( order by sum(views)) as cum_views 
from spotify
group by 1,2
;

-- query optimization

explain analyze

select artist, track, views from spotify
where artist = 'Gorillaz' and most_played_on = 'Youtube'
order by stream desc limit 25

create index artist_index on spotify(artist);


