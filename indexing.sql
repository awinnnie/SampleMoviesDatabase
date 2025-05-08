USE Movies;

CREATE INDEX idx_movies_primary_language ON movies(primary_language);
CREATE INDEX idx_movies_release_date ON movies(release_date);
CREATE INDEX idx_movies_rating ON movies(rating);
CREATE INDEX idx_tv_show_status ON tv_show(status);
CREATE INDEX idx_episodes_release_date ON episodes(release_date);
CREATE INDEX idx_person_last_name ON person(last_name);
CREATE INDEX idx_jobs_job_title ON jobs(job_title);
CREATE INDEX idx_movie_crew_movie_ID ON movie_crew(movie_ID);
CREATE INDEX idx_movie_crew_job_ID ON movie_crew(job_ID);
CREATE INDEX idx_movie_cast_person_ID ON movie_cast(person_ID);
CREATE INDEX idx_episode_cast_person_ID ON episode_cast(person_ID);
CREATE INDEX idx_movie_genre_genre_ID ON movie_genre(genre_ID);
CREATE INDEX idx_tv_genre_genre_ID ON tv_genre(genre_ID);
CREATE INDEX idx_movie_country_country_code ON movie_country(country_code);
CREATE INDEX idx_people_awards_person_ID ON people_awards(person_ID);
CREATE INDEX idx_people_awards_award_ID ON people_awards(award_ID);