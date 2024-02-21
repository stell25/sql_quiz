# Overview

This repo contains the material for the SQL quizzes in CMC's CSCI143: Big Data class.

Notes with example problems and explanations can be found in the `quiz_notes_?.sql` files.
For each SQL command in the notes,
you need to understand the output in both SQLite and Postgres.
In most cases, the output will be the same.
Differences are usually because sqlite3 is less standards compliant than postgres.

> **Terminology Note:**
> SQLite and Postgres are two different *database engines* or *RDBMS*es.
> SQL is the language used to interact with the database.

In the actual quiz, you will have 2^2 problems to complete and the quiz will be worth 2^3 points.
Each problem will be worth 2^1 points:
2^0 points for the correct sqlite3 output,
and 2^0 points for the correct postgres output.
If the command does not result in an error, you should provide the full table of the output.
If the command does result in an error, just write "error".
You do not need to provide the full error message.
If the output of both sqlite3 and postgres is the same,
you can just write "sqlite3 and postgres are the same" instead of redrawing the output.

Notice that I've switched to SQL math notation here instead of python.
One of the difficulties of using SQL is that the notation is different from most other programming languages.

## Running from SQLite

To create a SQLite database, run the command
```
$ sqlite3 quiz.db < create_tables.sql
```

You can run all practice problems at once with the command
```
$ cat quiz_example_?.sql | sqlite3 quiz.db
```

You might find the following incantation provides more useful output
```
$ (echo '.echo on' && echo '.mode markdown' && cat quiz_example_?.sql) | sqlite3 quiz.db
```

You can enter an interactive session with
```
$ sqlite3 quiz.db
```

## Running from Postgres

To create a postgres database, run the commands
```
$ docker-compose up --build -d
```
The `Dockerfile` runs the `create_tables.sql` files inside of postgres to populate the database with example values.

You can run all practice problems at once with the incantation
```
$ docker-compose < quiz_notes_?.sql exec -T pg psql -a
```

You can enter an interactive SQL session with the command
```
$ docker-compose exec pg psql
```
