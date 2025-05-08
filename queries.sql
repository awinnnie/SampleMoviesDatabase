use Movies;

-- 1. Find the average runtime of movies per language where runtime 60min or longer (feature length movies).
SELECT 
    l.name language, l.code, AVG(runtime) AS avg_runtime
FROM
    movies m
        JOIN
    languages l ON m.primary_language = l.code
GROUP BY primary_language
HAVING avg_runtime >= 60;

-- 2. List the number of movies and tv shows produced per company.
SELECT 
    c.name company_name,
    COUNT(DISTINCT m.movie_ID) AS num_movies,
    COUNT(DISTINCT tv.tv_ID) AS num_tv_shows
FROM
    companies c
        LEFT JOIN
    movie_production m ON c.company_ID = m.prod_ID
        LEFT JOIN
    tv_production tv ON c.company_ID = tv.prod_ID
GROUP BY c.company_ID , c.name
ORDER BY company_name;

-- 3. Count how many awards and nominations each person has.
SELECT 
    p.ID,
    p.first_name,
    p.last_name,
    COUNT(DISTINCT a.award_ID) AS num_awards,
    COUNT(DISTINCT n.award_ID) AS num_nominations
FROM
    person p
        LEFT JOIN
    people_awards a ON p.ID = a.person_ID
        LEFT JOIN
    people_nominations n ON p.ID = n.person_ID
GROUP BY p.ID
ORDER BY num_awards DESC, num_nominations DESC;

-- 4. List all movies that have grossed more than $10,000,000 with their director's name.
SELECT 
    m.title movie_title,
    CONCAT(p.first_name, ' ', p.last_name) AS director,
    m.box_office
FROM
    movies m
        JOIN
    movie_crew mc ON m.movie_ID = mc.movie_ID
        JOIN
    person p ON mc.person_ID = p.ID
        JOIN
    jobs j ON mc.job_ID = j.job_ID
WHERE
    j.job_title = 'Director'
        AND m.box_office > 10000000;
        
-- 5. List TV episodes that cost more than the average budget of their season.
SELECT 
    ts.title tv_show_title,
    s.season_number,
    e.title episode_title,
    e.budget episode_budget,
    season_avg_budget.avg_budget season_avg_budget
FROM
    episodes e
        JOIN
    seasons s ON e.season_ID = s.season_ID
        JOIN
    tv_show ts ON s.tv_show_ID = ts.tv_show_ID
        JOIN
    (SELECT 
        season_id, ROUND(AVG(budget), 2) AS avg_budget
    FROM
        episodes
    GROUP BY season_id) AS season_avg_budget ON e.season_id = season_avg_budget.season_id
WHERE
    e.budget > season_avg_budget.avg_budget
ORDER BY episode_budget DESC;

-- 6. List all the movies released by a country that has won an award.
SELECT 
    m.title AS movie_title, c.name AS country
FROM
    movies m
        JOIN
    movie_country mc ON m.movie_ID = mc.movie_ID
        JOIN
    countries c ON mc.country_code = c.code
WHERE
    mc.country_code IN (
		SELECT DISTINCT
            country_code
        FROM
            country_awards);
            
-- 7. Get people who have received more awards than the average per person.
SELECT 
    p.ID,
    CONCAT(p.first_name, ' ', p.last_name) AS name,
    COUNT(pa.award_ID) AS total_awards
FROM
    person p
        JOIN
    people_awards pa ON p.ID = pa.person_ID
GROUP BY p.ID
HAVING total_awards > (SELECT 
        ROUND(AVG(award_count))
    FROM
        (SELECT 
            COUNT(award_ID) AS award_count
        FROM
            people_awards
        GROUP BY person_ID) AS person_award_count)
ORDER BY total_awards DESC;

-- 8. List the most frequent collaborators (actor pairs) who worked on more than 5 projects together (movie or TV episode).
SELECT 
    CONCAT(p1.first_name, ' ', p1.last_name) AS actor_1,
    CONCAT(p2.first_name, ' ', p2.last_name) AS actor_2,
    shared.shared_appearances
FROM (
    SELECT 
        LEAST(c1.person_ID, c2.person_ID) AS person1_id,
        GREATEST(c1.person_ID, c2.person_ID) AS person2_id,
        COUNT(*) AS shared_appearances
    FROM (
        SELECT movie_ID AS project_id, person_ID
        FROM movie_cast
        UNION ALL
        SELECT episode_ID AS project_id, person_ID
        FROM episode_cast
    ) AS c1
    JOIN (
        SELECT movie_ID AS project_id, person_ID
        FROM movie_cast
        UNION ALL
        SELECT episode_ID AS project_id, person_ID
        FROM episode_cast
    ) AS c2
    ON c1.project_id = c2.project_id AND c1.person_ID < c2.person_ID
    GROUP BY person1_id, person2_id
    HAVING COUNT(*) > 5
) AS shared
JOIN person p1 ON shared.person1_id = p1.ID
JOIN person p2 ON shared.person2_id = p2.ID
ORDER BY shared.shared_appearances DESC;

-- 9. Find the average budget, box office and most frequent rating (age restriction) of movies per genre.
SELECT 
    g.name genre_name,
    ROUND(AVG(budget)) AS avg_budget,
    ROUND(AVG(box_office)) AS avg_box_office,
    (SELECT 
            m2.rating
        FROM
            movies m2
                JOIN
            movie_genre mg2 ON m2.movie_ID = mg2.movie_ID
        WHERE
            mg2.genre_ID = g.genre_ID
        GROUP BY m2.rating
        ORDER BY COUNT(rating) DESC
        LIMIT 1) AS most_frequent_rating
FROM
    movies m
        JOIN
    movie_genre mg ON m.movie_ID = mg.movie_ID
        JOIN
    genres g ON mg.genre_ID = g.genre_ID
GROUP BY g.genre_ID , g.name
ORDER BY avg_box_office DESC;

-- 10. List all people who have acted in at least one movie and have also won an award.
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS name
FROM
    person p
WHERE
    EXISTS( SELECT 
            *
        FROM
            movie_cast mc
        WHERE
            mc.person_ID = p.ID)
        AND EXISTS( SELECT 
            *
        FROM
            people_awards pa
        WHERE
            pa.person_ID = p.ID);

-- 11. Genres whose movies tend to flop (budget > box office) more than 3% of the time.
SELECT 
    g.name AS genre,
    ROUND(SUM(CASE WHEN m.box_office < m.budget THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS flop_rate
FROM 
    genres g
    JOIN movie_genre mg ON g.genre_ID = mg.genre_ID
    JOIN movies m ON mg.movie_ID = m.movie_ID
GROUP BY g.genre_ID
HAVING flop_rate > 3;

-- 12. Longest-running TV shows (in days) between first and last season release.
SELECT 
    tv.title,
    DATEDIFF(MAX(s.release_date), MIN(s.release_date)) AS run_days
FROM 
    tv_show tv
    JOIN seasons s ON tv.tv_show_ID = s.tv_show_ID
GROUP BY tv.tv_show_ID
ORDER BY run_days DESC;

-- 13. Genres where more than 15% of movies are rated 'R'.
SELECT
	g.name, ROUND(SUM(CASE WHEN m.rating = 'R' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS r_rate
FROM 
	genres g
JOIN movie_genre mg ON g.genre_ID = mg.genre_ID
JOIN movies m ON mg.movie_ID = m.movie_ID
GROUP BY g.genre_ID
HAVING r_rate > 15;

-- 14. Movies that mention 'love' in their description but are not in the 'Romance' genre.
SELECT 
	DISTINCT m.title, g.name AS genre
FROM 
	movies m
JOIN 
	movie_genre mg ON m.movie_ID = mg.movie_ID
JOIN 
	genres g ON mg.genre_ID = g.genre_ID
WHERE 
	LOWER(m.description) LIKE '%love%'
AND 
	m.movie_ID NOT IN (
		SELECT movie_ID
		FROM movie_genre mg2
		JOIN genres g2 ON mg2.genre_ID = g2.genre_ID
		WHERE g2.name = 'Romance'
);

-- 15. Find average runtime of episodes per TV show (with titles).
WITH episode_runtimes AS (
    SELECT ts.title, e.runtime
    FROM tv_show ts
    JOIN seasons s ON ts.tv_show_ID = s.tv_show_ID
    JOIN episodes e ON s.season_ID = e.season_ID
)
SELECT 
	title, ROUND(AVG(runtime), 2) AS avg_runtime
FROM 
	episode_runtimes
GROUP BY 
	title
ORDER BY
	avg_runtime DESC;

-- 16. Awards and their most common gender and average age.
WITH age_gender_stats AS (
    SELECT
        a.award_ID,
        a.award_category,
        p.gender,
        TIMESTAMPDIFF(YEAR, p.date_of_birth, pa.award_date) AS age
    FROM
        people_awards pa
        JOIN person p ON pa.person_ID = p.ID
        JOIN awards a ON pa.award_ID = a.award_ID
)
SELECT 
    award_category,
    AVG(age) AS average_age,
    (
        SELECT gender
        FROM age_gender_stats ag2
        WHERE ag2.award_ID = ag.award_ID
        GROUP BY gender
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS most_common_gender
FROM 
    age_gender_stats ag
GROUP BY 
    award_ID, award_category;
    
-- 17. Average number of episodes per season for each TV show.
SELECT 
    ts.tv_show_ID,
    ts.title,
    COUNT(e.episode_ID) / COUNT(DISTINCT s.season_ID) AS avg_episodes_per_season
FROM 
    tv_show ts
    JOIN seasons s ON ts.tv_show_ID = s.tv_show_ID
    JOIN episodes e ON s.season_ID = e.season_ID
GROUP BY 
    ts.tv_show_ID, ts.title
ORDER BY 
    avg_episodes_per_season DESC;
 
-- 18. TV Shows where all main stars won at least 1 award.
SELECT 
    ts.title
FROM 
    tv_show ts
WHERE NOT EXISTS (
    SELECT 1
    FROM tv_show_stars tss
    WHERE tss.tv_show_ID = ts.tv_show_ID
    AND NOT EXISTS (
        SELECT 1
        FROM people_awards pa
        WHERE pa.person_ID = tss.person_ID
    )
);

-- 19. Movies about “revenge” or “betrayal” and a high budget.
SELECT 
    title,
    budget,
    description
FROM 
    movies
WHERE 
    budget > 100000000
    AND (
        description LIKE '%revenge%' OR
        description LIKE '%betrayal%'
    )
ORDER BY budget DESC;

-- 20. Actors that starred in both award-winning shows and award-winning movies.
SELECT DISTINCT 
    p.first_name,
    p.last_name,
    p.gender,
    p.date_of_birth
FROM person p
WHERE 
    EXISTS (
        SELECT 1
        FROM tv_show_stars tss
        JOIN tv_awards ta ON tss.tv_show_ID = ta.tv_ID
        WHERE tss.person_ID = p.ID
    )
    AND EXISTS (
        SELECT 1
        FROM movie_cast mc
        JOIN movie_awards ma ON mc.movie_ID = ma.movie_ID
        WHERE mc.person_ID = p.ID
    );

-- 21. Movies with biggest nomination-awards difference.
SELECT 
    m.title,
    COUNT(DISTINCT mn.nomination_date) AS total_nominations,
    COUNT(DISTINCT ma.award_date) AS total_awards,
    COUNT(DISTINCT mn.nomination_date) - COUNT(DISTINCT ma.award_date) AS nomination_award_diff
FROM 
    movies m
    LEFT JOIN movie_nominations mn ON m.movie_ID = mn.movie_ID
    LEFT JOIN movie_awards ma ON m.movie_ID = ma.movie_ID
GROUP BY 
    m.movie_ID
ORDER BY 
    nomination_award_diff DESC;
