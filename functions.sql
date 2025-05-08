USE Movies;

-- Drop functions if they exist
DROP FUNCTION IF EXISTS count_movies_by_language;
DROP FUNCTION IF EXISTS count_movies_by_genre_year;
DROP FUNCTION IF EXISTS count_episodes;
DROP FUNCTION IF EXISTS has_person_award;
DROP FUNCTION IF EXISTS avg_runtime_by_genre_name;
DROP FUNCTION IF EXISTS tv_people_count;
DROP FUNCTION IF EXISTS person_full_credits;
DROP FUNCTION IF EXISTS get_most_recent_movie_award;
DROP FUNCTION IF EXISTS cast_gender_balance;
DROP FUNCTION IF EXISTS tv_cast_gender_balance;
DROP FUNCTION IF EXISTS movie_profitability;
DROP FUNCTION IF EXISTS age;

-- 1. Count number of movies in a given language
DELIMITER //

CREATE FUNCTION count_movies_by_language(lang CHAR(2))
RETURNS INTEGER
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE movie_count INT;

    SELECT COUNT(*) 
    INTO movie_count
    FROM movies
    WHERE primary_language = lang;

    RETURN movie_count;
END //

-- 2. Count number of movies by genre and year
CREATE FUNCTION count_movies_by_genre_year(
    genre_name VARCHAR(100),
    year_input INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE movie_count INT;

    SELECT COUNT(*)
    INTO movie_count
    FROM movies m
    JOIN movie_genre mg ON m.movie_ID = mg.movie_ID
    JOIN genres g ON g.genre_ID = mg.genre_ID
    WHERE g.name = genre_name
      AND YEAR(m.release_date) = year_input;

    RETURN movie_count;
END //

DELIMITER ;

-- 3. Count episodes by season ID
DELIMITER //

CREATE FUNCTION count_episodes(seasonID INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE e_count INT;
    SELECT COUNT(*) INTO e_count
    FROM episodes
    WHERE season_ID = seasonID;
    RETURN e_count;
END //

DELIMITER ;

-- 4. Check if person has won any awards
DELIMITER //

CREATE FUNCTION has_person_award(pID INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result BOOLEAN;
    SELECT EXISTS (
        SELECT 1 FROM people_awards WHERE person_ID = pID
    ) INTO result;
    RETURN result;
END //

DELIMITER ;

-- 5. Average runtime of movies by genre
DELIMITER //

CREATE FUNCTION avg_runtime_by_genre_name(gname VARCHAR(100))
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avg_time DECIMAL(5,2);

    SELECT AVG(m.runtime) INTO avg_time
    FROM movies m
    JOIN movie_genre mg ON m.movie_ID = mg.movie_ID
    JOIN genres g ON g.genre_ID = mg.genre_ID
    WHERE g.name = gname;

    RETURN avg_time;
END //

DELIMITER ;

-- 6. Number of cast and crew in a tv show
DELIMITER //

CREATE FUNCTION tv_people_count(tvID INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total INT;

    SELECT (
        (SELECT COUNT(*) 
         FROM episode_cast ec
         JOIN episodes e ON ec.episode_ID = e.episode_ID
         JOIN seasons s ON e.season_id = s.season_ID
         WHERE s.tv_show_ID = tvID)
      +
        (SELECT COUNT(*) 
         FROM episode_crew ec
         JOIN episodes e ON ec.episode_ID = e.episode_ID
         JOIN seasons s ON e.season_id = s.season_ID
         WHERE s.tv_show_ID = tvID)
    ) INTO total;

    RETURN total;
END //

DELIMITER ;

-- 7. Person's total number of credits
DELIMITER //

CREATE FUNCTION person_full_credits(pid INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;
  SELECT 
    (SELECT COUNT(*) FROM movie_cast WHERE person_ID = pid) +
    (SELECT COUNT(*) FROM movie_crew WHERE person_ID = pid) +
    (SELECT COUNT(*) FROM episode_cast WHERE person_ID = pid) +
    (SELECT COUNT(*) FROM episode_crew WHERE person_ID = pid)
  INTO total;
  RETURN total;
END //

DELIMITER ;

-- 8. Most recent award date of a movie

DELIMITER //

CREATE FUNCTION get_most_recent_movie_award(mid INT)
RETURNS DATE
DETERMINISTIC
BEGIN
  DECLARE recent DATE;
  SELECT MAX(award_date) INTO recent
  FROM movie_awards
  WHERE movie_ID = mid;
  RETURN recent;
END //

DELIMITER ;

-- 9. The gender percentage of female cast members in a movie
DELIMITER //

CREATE FUNCTION cast_gender_balance(movieID INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE percent_female DECIMAL(5,2);
    DECLARE total_cast INT;

    SELECT COUNT(*) INTO total_cast
    FROM movie_cast
    WHERE movie_ID = movieID;

    IF total_cast = 0 THEN
        SET percent_female = NULL;
    ELSE
        SELECT 
            (COUNT(CASE p.gender WHEN 'Female' THEN 1 END) / total_cast) * 100
        INTO percent_female
        FROM movie_cast mc
        JOIN person p ON mc.person_ID = p.ID
        WHERE mc.movie_ID = movieID;
    END IF;
    RETURN percent_female;
END //

DELIMITER ;
 
-- 10. The gender percentage of female cast members in a tv show
DELIMITER //
CREATE FUNCTION tv_cast_gender_balance(tvID INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE percent_female DECIMAL(5,2);
    DECLARE total_cast INT;

    SELECT COUNT(*) INTO total_cast
    FROM tv_show_stars
    WHERE tv_show_ID = tvID;

    IF total_cast = 0 THEN
        SET percent_female = NULL;
    ELSE
        SELECT 
            (COUNT(CASE p.gender WHEN 'Female' THEN 1 END) / total_cast) * 100
        INTO percent_female
        FROM tv_show_stars tss
        JOIN person p ON tss.person_ID = p.ID
        WHERE tss.tv_show_ID = tvID;
    END IF;

    RETURN percent_female;
END //

DELIMITER ;

-- 11. Movie profit (box_office - budget)
DELIMITER //

CREATE FUNCTION movie_profitability(movieID INT)
RETURNS BIGINT
DETERMINISTIC
BEGIN
    DECLARE profit BIGINT;

    SELECT 
        CASE 
            WHEN budget = 0 THEN NULL
            ELSE (box_office - budget)
        END 
    INTO profit
    FROM movies
    WHERE movie_ID = movieID;

    RETURN profit;
END //

DELIMITER ;

-- 12. Calculate age of a person
DELIMITER //

CREATE FUNCTION age(person_input INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE dob DATE;
  DECLARE age INT;
  SELECT date_of_birth INTO dob
  FROM person
  WHERE ID = person_input;
  IF dob IS NULL THEN
    RETURN NULL;
  END IF;
  SET age = TIMESTAMPDIFF(YEAR, dob, CURDATE());
  RETURN age;
END//

DELIMITER ;

-- Example calls
-- 1
SELECT count_movies_by_language('EN') AS en_movies;

-- 2
SELECT count_movies_by_genre_year('Action', 2016) AS action_2016_movies;

-- 3
-- Tv shows with a season with more than 10 episodes
SELECT tv.title, s.season_number, count_episodes(s.season_ID) AS episode_count
FROM seasons s
JOIN tv_show tv ON s.tv_show_ID = tv.tv_show_ID
WHERE count_episodes(s.season_ID) > 10;

-- 4
-- Names of people who have won at least 1 award
SELECT p.ID, p.first_name, p.last_name
FROM person p
WHERE has_person_award(p.ID) = TRUE;

-- 5
SELECT avg_runtime_by_genre_name('Action') AS avg_runtime_action;

-- 6
SELECT ts.title, tv_people_count(ts.tv_show_ID) AS total_people
FROM tv_show ts
WHERE ts.title IN ('Breaking Bad', 'The Office', 'Stranger Things');

-- 7
SELECT ID, first_name, last_name, person_full_credits(ID) AS all_credits
FROM person
WHERE person_full_credits(ID) > 10
ORDER BY all_credits DESC;

-- 8 
SELECT movie_ID, title, get_most_recent_movie_award(movie_ID) AS last_award_date
FROM movies
WHERE get_most_recent_movie_award(movie_ID) IS NOT NULL;

-- 9
SELECT m.title, cast_gender_balance(m.movie_ID) AS female_cast_percentage
FROM movies m
WHERE cast_gender_balance(m.movie_ID) IS NOT NULL;

-- 10
SELECT title, tv_cast_gender_balance(tv_show_ID) AS female_cast_percentage
FROM tv_show
ORDER BY female_cast_percentage DESC;

-- 11. Find movies with negative profit
SELECT title, movie_profitability(movie_ID) AS profit_margin
FROM movies
WHERE movie_profitability(movie_ID) < 0
;

-- 12
SELECT ID, CONCAT(first_name, ' ', last_name) name, date_of_birth, age(ID) age
FROM person
ORDER BY age;
