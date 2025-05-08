USE Movies;

DROP TRIGGER IF EXISTS trg_check_budget_boxoffice;
DROP TRIGGER IF EXISTS trg_default_tagline;
DROP TRIGGER IF EXISTS trg_uppercase_language_name;
DROP TRIGGER IF EXISTS trg_prevent_future_births;
DROP TRIGGER IF EXISTS trg_sync_primary_language_movie;
DROP TRIGGER IF EXISTS trg_sync_primary_language_tv;
DROP TRIGGER IF EXISTS trg_check_duplicate_cast;
DROP TRIGGER IF EXISTS trg_normalize_person_name;
DROP TRIGGER IF EXISTS trg_clean_company_name;

-- 1. Set box_office to 0 if it’s NULL when a new movie is inserted.
DELIMITER //

CREATE TRIGGER trg_check_budget_boxoffice
BEFORE INSERT ON movies
FOR EACH ROW
BEGIN
  IF NEW.box_office IS NULL THEN
    SET NEW.box_office = 0;
  END IF;
END //

DELIMITER ;

-- 2. Assign a default tagline to a movie if it's not provided during insertion.
DELIMITER //

CREATE TRIGGER trg_default_tagline
BEFORE INSERT ON movies
FOR EACH ROW
BEGIN
  IF NEW.tagline IS NULL THEN
    SET NEW.tagline = CONCAT('Experience ', NEW.title, '!');
  END IF;
END //

DELIMITER ;

-- 3. Ensure all language names are stored in uppercase.
DELIMITER //

CREATE TRIGGER trg_uppercase_language_name
BEFORE INSERT ON languages
FOR EACH ROW
BEGIN
  SET NEW.name = UPPER(NEW.name);
END //

DELIMITER ;

-- 4. Prevent insertion of people with birthdates in the future.
DELIMITER //

CREATE TRIGGER trg_prevent_future_births
BEFORE INSERT ON person
FOR EACH ROW
BEGIN
  IF NEW.date_of_birth > CURDATE() THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Date of birth cannot be in the future.';
  END IF;
END //

DELIMITER ;

-- 5. When a movie or TV show is inserted, add its primary language to the language table, if not already present.
DELIMITER //

CREATE TRIGGER trg_sync_primary_language_movie
AFTER INSERT ON movies
FOR EACH ROW
BEGIN
  INSERT IGNORE INTO languages (code, name)
  VALUES (NEW.primary_language, NEW.primary_language);
END //

CREATE TRIGGER trg_sync_primary_language_tv
AFTER INSERT ON tv_show
FOR EACH ROW
BEGIN
  INSERT IGNORE INTO languages (code, name)
  VALUES (NEW.primary_language, NEW.primary_language);
END//

DELIMITER ;

-- 6. Prevent an actor from being added to the same movie more than once.
DELIMITER //

CREATE TRIGGER trg_check_duplicate_cast
BEFORE INSERT ON movie_cast
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 FROM movie_cast
    WHERE movie_ID = NEW.movie_ID AND person_ID = NEW.person_ID
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'This actor is already cast in the movie.';
  END IF;
END //

DELIMITER ;

-- 7. Capitalize the first letter of names and lowercase the rest.
DELIMITER //

CREATE TRIGGER trg_normalize_person_name
BEFORE INSERT ON person
FOR EACH ROW
BEGIN
  SET NEW.first_name = CONCAT(UPPER(LEFT(NEW.first_name, 1)), LOWER(SUBSTRING(NEW.first_name, 2)));
  SET NEW.last_name = CONCAT(UPPER(LEFT(NEW.last_name, 1)), LOWER(SUBSTRING(NEW.last_name, 2)));
END //

DELIMITER ;

-- 8. Trim whitespace and capitalize company names when inserting.
DELIMITER //

CREATE TRIGGER trg_clean_company_name
BEFORE INSERT ON companies
FOR EACH ROW
BEGIN
  SET NEW.name = CONCAT(UPPER(LEFT(TRIM(NEW.name), 1)), LOWER(SUBSTRING(TRIM(NEW.name), 2)));
END //

DELIMITER ;

-- 1
INSERT INTO movies (movie_ID, title, release_date, budget, box_office, runtime, rating, status, primary_language) VALUES (1001, 'Test Movie 1', '2020-01-01', 1000000, NULL, 120, 'PG-13', 'Released', 'EN');
SELECT movie_ID, title, box_office FROM movies WHERE movie_ID = 1001;

-- 2
INSERT INTO movies (movie_ID, title, release_date, budget, box_office, runtime, rating, status, primary_language, tagline) VALUES (1002, 'Tagline Test', '2021-01-01', 500000, 100000, 90, 'PG', 'Released', 'EN', NULL);
SELECT movie_ID, title, tagline FROM movies WHERE movie_ID = 1002;

-- 3
INSERT INTO languages (code, name) VALUES ('fr', 'french');
SELECT code, name FROM languages WHERE code = 'fr';

-- 4
INSERT INTO person (ID, first_name, last_name, date_of_birth, gender) VALUES (9001, 'Future', 'Person', CURDATE() + INTERVAL 1 DAY, 'M');

-- 5
INSERT INTO movies (movie_ID, title, release_date, budget, box_office, runtime, rating, status, primary_language) VALUES (1003, 'Japanese Movie', '2022-01-01', 800000, 500000, 100, 'R', 'Released', 'jp');
SELECT * FROM languages WHERE code = 'jp';
INSERT INTO tv_show (tv_show_ID, title, description, status, primary_language) VALUES (2001, 'Anime Series', 'Animated TV series', 'Ongoing', 'jp');
SELECT * FROM languages WHERE code = 'jp';

-- 6
INSERT INTO movie_cast (movie_ID, person_ID, character_name) VALUES (1001, 3001, 'Hero');
INSERT INTO movie_cast (movie_ID, person_ID, character_name) VALUES (1001, 3001, 'Hero Again');

-- 7
INSERT INTO person (ID, first_name, last_name, date_of_birth, gender) VALUES (9002, 'aLEx', 'JOHNsON', '1990-05-05', 'M');
SELECT ID, first_name, last_name FROM person WHERE ID = 9002;

-- 8
INSERT INTO companies (company_ID, name) VALUES (5001, '   netFLIX   ');
SELECT company_ID, name FROM companies WHERE company_ID = 5001;
