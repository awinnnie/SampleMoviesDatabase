CREATE DATABASE IF NOT EXISTS `Movies`;
USE `Movies`;
drop table if exists tv_show_stars;
drop table if exists movie_cast;
drop table if exists movie_crew;
drop table if exists episode_cast;
drop table if exists episode_crew;
drop table if exists movie_languages;
drop table if exists tv_languages;
drop table if exists movie_genre;
drop table if exists tv_genre;
drop table if exists movie_country;
drop table if exists tv_country;
drop table if exists movie_production;
drop table if exists tv_production;
drop table if exists movie_awards;
drop table if exists movie_nominations;
drop table if exists tv_awards;
drop table if exists tv_nominations;
drop table if exists country_awards;
drop table if exists country_nominations;
drop table if exists episode_awards;
drop table if exists episode_nominations;
drop table if exists people_awards;
drop table if exists people_nominations;

drop table if exists awards;
drop table if exists award_types;
drop table if exists movies;
drop table if exists person;
drop table if exists jobs;
drop table if exists episodes;
drop table if exists seasons;
drop table if exists tv_show;
drop table if exists languages;
drop table if exists genres;
drop table if exists countries;
drop table if exists companies;

CREATE TABLE languages (
	code CHAR(2),
	name VARCHAR(50) NOT NULL,
    PRIMARY KEY (code)
    );

CREATE TABLE movies (
	movie_ID INT AUTO_INCREMENT,
	title VARCHAR(70) NOT NULL,
	release_date DATE NOT NULL,
	budget BIGINT CHECK (budget >= 0),
    box_office BIGINT CHECK (box_office >= 0),
    runtime INT CHECK (runtime > 0),
    tagline VARCHAR(200),
    description TEXT,
    rating VARCHAR(15) NOT NULL,
    status VARCHAR(20),
    primary_language CHAR(2) NOT NULL,
    PRIMARY KEY (movie_id),
    FOREIGN KEY (primary_language) REFERENCES languages(code),
    CHECK (status IN ('Released', 'Post-Production', 'Upcoming'))
  );
  
CREATE TABLE person (
	ID INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    gender ENUM('Female', 'Male', 'Non-Binary', 'Other'),
    PRIMARY KEY (ID)
    );
    
CREATE TABLE jobs (
	job_ID INT AUTO_INCREMENT,
    job_title VARCHAR(50) NOT NULL,
    dept_name VARCHAR(50),
    PRIMARY KEY(job_ID)
    );
    
CREATE TABLE tv_show (
	tv_show_ID INT AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20),
	primary_language CHAR(2) NOT NULL,
    PRIMARY KEY (tv_show_ID),
    FOREIGN KEY (primary_language) REFERENCES languages(code),
    CHECK (status IN ('Ended', 'Returning Series', 'Canceled'))
    );

CREATE TABLE seasons (
	season_ID INT AUTO_INCREMENT,
    season_number TINYINT UNSIGNED CHECK (season_number > 0),
    release_date DATE NOT NULL,
    status VARCHAR(20),
    tv_show_ID INT,
    PRIMARY KEY (season_ID),
    FOREIGN KEY (tv_show_ID) REFERENCES tv_show(tv_show_ID) ON DELETE CASCADE,
    CHECK (status IN ('Released', 'Post-Production', 'Upcoming'))
    );
    
CREATE TABLE episodes (
	episode_ID INT AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    runtime INT CHECK (runtime > 0),
    release_date DATE NOT NULL,
    budget BIGINT CHECK (budget >= 0),
    description TEXT,
    season_id INT,
    PRIMARY KEY (episode_ID),
    FOREIGN KEY (season_ID) REFERENCES seasons(season_ID) ON DELETE CASCADE
    );
    
CREATE TABLE genres (
	genre_ID INT AUTO_INCREMENT,
	name VARCHAR(70) NOT NULL,
    PRIMARY KEY (genre_ID)
    );
    
CREATE TABLE countries (
	code CHAR(2),
	name VARCHAR(200) NOT NULL,
    PRIMARY KEY (code)
    );
    
CREATE TABLE companies (
	company_ID INT AUTO_INCREMENT,
	name VARCHAR(200) NOT NULL,
    PRIMARY KEY (company_ID)
    );

CREATE TABLE award_types (
	award_type_ID INT AUTO_INCREMENT,
    award_type VARCHAR(200) UNIQUE NOT NULL,
    PRIMARY KEY (award_type_ID)
    );

CREATE TABLE awards (
	award_ID INT AUTO_INCREMENT,
    award_category VARCHAR(200) NOT NULL,
    award_type INT NOT NULL,
    PRIMARY KEY (award_ID),
    FOREIGN KEY (award_type) REFERENCES award_types(award_type_ID)
    );
    
-- Many-to-many tables

CREATE TABLE tv_show_stars (
	tv_show_ID INT,
    person_ID INT,
    character_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (tv_show_ID, person_ID),
    FOREIGN KEY (tv_show_ID) REFERENCES tv_show(tv_show_ID) ON DELETE CASCADE,
    FOREIGN KEY (person_ID) REFERENCES person(ID) ON DELETE CASCADE
    );
    
CREATE TABLE movie_cast (
	movie_ID INT,
    person_ID INT,
    character_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (movie_ID, person_ID),
    FOREIGN KEY (movie_ID) REFERENCES movies(movie_ID) ON DELETE CASCADE,
    FOREIGN KEY (person_ID) REFERENCES person(ID) ON DELETE CASCADE
    );
    
CREATE TABLE movie_crew (
	movie_ID INT,
    person_ID INT,
    job_ID INT,
    PRIMARY KEY (movie_ID, person_ID, job_ID),
    FOREIGN KEY (movie_ID) REFERENCES movies(movie_ID) ON DELETE CASCADE,
    FOREIGN KEY (person_ID) REFERENCES person(ID) ON DELETE CASCADE,
    FOREIGN KEY (job_ID) REFERENCES jobs(job_ID) ON DELETE CASCADE
    );
    
CREATE TABLE episode_cast (
	episode_ID INT,
    person_ID INT,
    character_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (episode_ID, person_ID),
    FOREIGN KEY (episode_ID) REFERENCES episodes(episode_ID) ON DELETE CASCADE,
    FOREIGN KEY (person_ID) REFERENCES person(ID) ON DELETE CASCADE
    );
    
CREATE TABLE episode_crew (
	episode_ID INT,
    person_ID INT,
    job_ID INT,
    PRIMARY KEY (episode_ID, person_ID, job_ID),
    FOREIGN KEY (episode_ID) REFERENCES episodes(episode_ID) ON DELETE CASCADE,
    FOREIGN KEY (person_ID) REFERENCES person(ID) ON DELETE CASCADE,
    FOREIGN KEY (job_ID) REFERENCES jobs(job_ID) ON DELETE CASCADE
    );
    
CREATE TABLE movie_languages (
	movie_ID INT,
    lang_code CHAR(2),
    PRIMARY KEY (movie_ID, lang_code),
    FOREIGN KEY (movie_ID) REFERENCES movies(movie_ID) ON DELETE CASCADE,
    FOREIGN KEY (lang_code) REFERENCES languages(code)
    );

CREATE TABLE tv_languages (
	tv_ID INT,
    lang_code CHAR(2),
    PRIMARY KEY (tv_ID, lang_code),
    FOREIGN KEY (tv_ID) REFERENCES tv_show(tv_show_ID) ON DELETE CASCADE,
    FOREIGN KEY (lang_code) REFERENCES languages(code)
    );
    
CREATE TABLE movie_genre (
	movie_ID INT,
    genre_ID INT,
    PRIMARY KEY (movie_ID, genre_ID),
    FOREIGN KEY (movie_ID) REFERENCES movies(movie_ID) ON DELETE CASCADE,
    FOREIGN KEY (genre_ID) REFERENCES genres(genre_ID)
    );

CREATE TABLE tv_genre (
	tv_ID INT,
    genre_ID INT,
    PRIMARY KEY (tv_ID, genre_ID),
    FOREIGN KEY (tv_ID) REFERENCES tv_show(tv_show_ID) ON DELETE CASCADE,
    FOREIGN KEY (genre_ID) REFERENCES genres(genre_ID)
    );

CREATE TABLE movie_country (
	movie_ID INT, 
    country_code CHAR(2),
    PRIMARY KEY (movie_ID, country_code),
    FOREIGN KEY (movie_ID) REFERENCES movies(movie_ID) ON DELETE CASCADE,
    FOREIGN KEY (country_code) REFERENCES countries(code)
    );
    
CREATE TABLE tv_country (
	tv_ID INT,
    country_code CHAR(2),
    PRIMARY KEY (tv_ID, country_code),
    FOREIGN KEY (tv_ID) REFERENCES tv_show(tv_show_ID) ON DELETE CASCADE,
    FOREIGN KEY (country_code) REFERENCES countries(code)
    );
    
CREATE TABLE movie_production (
	movie_ID INT,
    prod_ID INT,
    PRIMARY KEY (movie_ID, prod_ID),
    FOREIGN KEY (movie_ID) REFERENCES movies(movie_ID) ON DELETE CASCADE,
    FOREIGN KEY (prod_ID) REFERENCES companies(company_ID)
    );
    
CREATE TABLE tv_production (
	tv_ID INT,
    prod_ID INT,
    PRIMARY KEY (tv_ID, prod_ID),
    FOREIGN KEY (tv_ID) REFERENCES tv_show(tv_show_ID) ON DELETE CASCADE,
    FOREIGN KEY (prod_ID) REFERENCES companies(company_ID)
    );

CREATE TABLE movie_awards (
	movie_ID INT,
    award_ID INT,
    award_date DATE NOT NULL,
    PRIMARY KEY (movie_ID, award_ID, award_date),
    FOREIGN KEY (movie_ID) REFERENCES movies(movie_ID) ON DELETE CASCADE,
    FOREIGN KEY (award_ID) REFERENCES awards(award_ID)
    );
    
CREATE TABLE movie_nominations (
	movie_ID INT,
    award_ID INT,
    nomination_date DATE NOT NULL,
    PRIMARY KEY (movie_ID, award_ID, nomination_date),
    FOREIGN KEY (movie_ID) REFERENCES movies(movie_ID) ON DELETE CASCADE,
    FOREIGN KEY (award_ID) REFERENCES awards(award_ID)
    );
CREATE TABLE tv_awards (
	tv_ID INT,
    award_ID INT,
    award_date DATE NOT NULL,
    PRIMARY KEY (tv_ID, award_ID, award_date),
    FOREIGN KEY (tv_ID) REFERENCES tv_show(tv_show_ID) ON DELETE CASCADE,
    FOREIGN KEY (award_ID) REFERENCES awards(award_ID)
    );
    
CREATE TABLE tv_nominations (
	tv_ID INT,
    award_ID INT,
    nomination_date DATE NOT NULL,
    PRIMARY KEY (tv_ID, award_ID, nomination_date),
    FOREIGN KEY (tv_ID) REFERENCES tv_show(tv_show_ID) ON DELETE CASCADE,
    FOREIGN KEY (award_ID) REFERENCES awards(award_ID)
    );
    
CREATE TABLE country_awards (
	country_code CHAR(2),
    award_ID INT,
    award_date DATE NOT NULL,
    PRIMARY KEY (country_code, award_ID, award_date),
    FOREIGN KEY (country_code) REFERENCES countries(code),
    FOREIGN KEY (award_ID) REFERENCES awards(award_ID)
    );
    
CREATE TABLE country_nominations (
	country_code CHAR(2),
    award_ID INT,
    nomination_date DATE NOT NULL,
    PRIMARY KEY (country_code, award_ID, nomination_date),
    FOREIGN KEY (country_code) REFERENCES countries(code),
    FOREIGN KEY (award_ID) REFERENCES awards(award_ID)
    );
    
CREATE TABLE episode_awards (
	episode_ID INT,
    award_ID INT,
    award_date DATE NOT NULL,
    PRIMARY KEY (episode_ID, award_ID, award_date),
    FOREIGN KEY (episode_ID) REFERENCES episodes(episode_ID) ON DELETE CASCADE,
    FOREIGN KEY (award_ID) REFERENCES awards(award_ID)
    );
    
CREATE TABLE episode_nominations (
	episode_ID INT,
    award_ID INT,
    nomination_date DATE NOT NULL,
    PRIMARY KEY (episode_ID, award_ID, nomination_date),
    FOREIGN KEY (episode_ID) REFERENCES episodes(episode_ID) ON DELETE CASCADE,
    FOREIGN KEY (award_ID) REFERENCES awards(award_ID)
    );
    
CREATE TABLE people_awards (
	person_ID INT,
    award_ID INT,
    award_date DATE NOT NULL,
    PRIMARY KEY (person_ID, award_ID, award_date),
    FOREIGN KEY (person_ID) REFERENCES person(ID) ON DELETE CASCADE,
    FOREIGN KEY (award_ID) REFERENCES awards(award_ID)
    );
    
CREATE TABLE people_nominations (
	person_ID INT,
    award_ID INT,
    nomination_date DATE NOT NULL,
    PRIMARY KEY (person_ID, award_ID, nomination_date),
    FOREIGN KEY (person_ID) REFERENCES person(ID) ON DELETE CASCADE,
    FOREIGN KEY (award_ID) REFERENCES awards(award_ID)
    );