use Movies;
drop view if exists view_movie_details;
drop view if exists view_actor_profile;
drop view if exists view_movie_financials_by_genre;
drop view if exists view_awards_per_person;
drop view if exists view_top_awarded_actors;
drop view if exists view_movie_award_summary;
drop view if exists view_full_cast_and_crew;
drop view if exists view_tv_show_details;

-- 1. List all movies along with their title, release date, budget, box office, rating, and the name of their primary language.
CREATE VIEW view_movie_details AS
    SELECT 
        m.movie_ID,
        m.title,
        m.release_date,
        m.budget,
        m.box_office,
        m.rating,
        l.name AS primary_language
    FROM
        movies m
            JOIN
        languages l ON m.primary_language = l.code;

-- 2. List all actors and the number of movies and episodes they have appeared in.
CREATE VIEW view_actor_profile AS
    SELECT 
        p.ID AS person_ID,
        CONCAT(p.first_name, ' ', p.last_name) AS full_name,
        COALESCE(m.num_movies, 0) AS movies_acted,
        COALESCE(e.num_episodes, 0) AS episodes_acted
    FROM
        person p
            LEFT JOIN
        (SELECT 
            person_ID, COUNT(*) AS num_movies
        FROM
            movie_cast
        GROUP BY person_ID) m ON p.ID = m.person_ID
            LEFT JOIN
        (SELECT 
            person_ID, COUNT(*) AS num_episodes
        FROM
            episode_cast
        GROUP BY person_ID) e ON p.ID = e.person_ID;
        
-- 3. Show the average budget and box office grouped by movie genre.
CREATE VIEW view_movie_financials_by_genre AS
    SELECT 
        g.name,
        ROUND(AVG(m.budget)) AS avg_budget,
        ROUND(AVG(m.box_office)) AS avg_box_office
    FROM
        movies m
            JOIN
        movie_genre mg ON m.movie_ID = mg.movie_ID
            JOIN
        genres g ON mg.genre_ID = g.genre_ID
    GROUP BY g.name;

-- 4. Summarize how many awards each person has received, grouped by award type.

CREATE VIEW view_awards_per_person AS
    SELECT 
        p.ID AS person_ID,
        CONCAT(p.first_name, ' ', p.last_name) AS full_name,
        at.award_type,
        COUNT(*) AS award_count
    FROM
        people_awards pa
            JOIN
        person p ON pa.person_ID = p.ID
            JOIN
        awards a ON pa.award_ID = a.award_ID
            JOIN
        award_types at ON a.award_type = at.award_type_ID
    GROUP BY p.ID , at.award_type;

-- 5. Actors with the most awards (using view_awards_per_person)
CREATE VIEW view_top_awarded_actors AS
SELECT 
    person_ID,
    full_name,
    SUM(award_count) AS total_awards
FROM 
    view_awards_per_person
GROUP BY 
    person_ID, full_name
ORDER BY 
    total_awards DESC
LIMIT 10;

-- 6. Total nominations and wins per movie
CREATE VIEW view_movie_award_summary AS
SELECT 
    m.movie_ID,
    m.title,
    COALESCE(n.num_nominations, 0) AS nominations,
    COALESCE(a.num_awards, 0) AS wins
FROM 
    movies m
LEFT JOIN (
    SELECT 
        movie_ID,
        COUNT(*) AS num_nominations
    FROM 
        movie_nominations
    GROUP BY 
        movie_ID
) n ON m.movie_ID = n.movie_ID
LEFT JOIN (
    SELECT 
        movie_ID,
        COUNT(*) AS num_awards
    FROM 
        movie_awards
    GROUP BY 
        movie_ID
) a ON m.movie_ID = a.movie_ID;

-- 7. Full cast and crew of movies and episodes
CREATE VIEW view_full_cast_and_crew AS
SELECT 
    m.title AS movie_title,
    CONCAT(p.first_name, ' ', p.last_name) AS person_name,
    mc.character_name AS role_or_job
FROM movie_cast mc
JOIN movies m ON mc.movie_ID = m.movie_ID
JOIN person p ON mc.person_ID = p.ID

UNION

SELECT 
    m.title,
    CONCAT(p.first_name, ' ', p.last_name),
    j.job_title
FROM movie_crew mc
JOIN movies m ON mc.movie_ID = m.movie_ID
JOIN person p ON mc.person_ID = p.ID
JOIN jobs j ON mc.job_ID = j.job_ID;

-- 8. Tv show details
CREATE VIEW view_tv_show_details AS
SELECT 
    t.tv_show_ID,
    t.title,
    t.status,
    l.name AS primary_language,
    COUNT(distinct s.season_ID) AS total_seasons,
    COUNT(distinct e.episode_ID) AS total_episodes
FROM tv_show t
JOIN languages l ON t.primary_language = l.code
LEFT JOIN seasons s ON t.tv_show_ID = s.tv_show_ID
LEFT JOIN episodes e ON s.season_ID = e.season_ID
GROUP BY t.tv_show_ID, t.title, t.status, l.name;


select * from view_movie_details;
select * from view_actor_profile;
select * from view_movie_financials_by_genre;
select * from view_awards_per_person;
select * from view_top_awarded_actors;
select * from view_movie_award_summary;
select * from view_full_cast_and_crew;
select * from view_tv_show_details;

