# SampleMoviesDatabase
This SQL Database stores movies, actors and crew members, TV shows, and awards. Some data is inserted, and queries, views, and functions are written based on it. The data is generated using Python, with Faker, and some Kaggle datasets. The project was developed collaboratively by [Anna Khurshudyan](https://github.com/awinnnie) and [Nane Khachatryan](https://github.com/nane-khachatryan21).

## Project Files

| File                   | Description |
|------------------------|-------------|
| `create.sql`           | SQL script to create the full schema. Run this first. |
| `insert.sql`           | All `INSERT INTO` statements; some manually added and some generated with Python. |
| `indexing.sql`         | Indexing for optimizing queries. |
| `triggers.sql`         | Triggers for automation and validation. |
| `functions.sql`        | Stored SQL functions. |
| `views.sql`            | Defined views for reporting and simplified queries. |
| `queries.sql`         | Collection of sample SQL queries. |
| `data_generation.ipynb` | Python scripts showing how we generated the data for insertion using libraries such as SQLAlchemy and Faker, as well as real-world datasets from Kaggle. |
| `ERD.pdf`              | ERD created using diagrams.net. |
| `Normalization.pdf`    | 3NF, BCNF, and 4NF decompositions. |
| `workbench_diagram.pdf`| Relational schema diagram reverse-engineered from MySQL Workbench. |
