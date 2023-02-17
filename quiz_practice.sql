/*
 * All the problems below are being run from a psql session
 * that was launched from the following terminal session:
 * ```
 * $ cd; rm -rf quiz; mkdir quiz; cd quiz
 * $ git clone https://github.com/mikeizbicki/sql_quiz
 * $ cd sql_quiz
 * $ docker-compose build
 * $ docker-compose up -d
 * $ docker-compose exec pg psql
 * ```
 * 
 * You can run all practice problems at once with the command
 * ```
 * $ docker-compose < quiz_practice.sql exec -T pg psql -a
 * ```
 *
 * In the actual quiz, you will have only 2^2 problems to complete.
 * Each problem will be worth 2^1 points instead of 2^0 points,
 * so the quiz will overall be worth 2^3 points.
 * (Notice that I've switched to SQL math notation here instead of python.)
 */


-- aggregate functions will ignore null values only if included in the function list

SELECT count(*) FROM basket_a;
SELECT count(1) FROM basket_a;
SELECT count(fruit_a) FROM basket_a;
SELECT count(id) FROM basket_a;
SELECT count(id || fruit_a) FROM basket_a;

SELECT sum(1) FROM basket_a;
SELECT sum(id) FROM basket_a;

-- the DISTINCT operator removes duplicates before passing to the aggregate function

SELECT count(DISTINCT fruit_a) FROM basket_a;
SELECT count(DISTINCT id) FROM basket_a;
SELECT count(DISTINCT 1) FROM basket_a;
SELECT sum(DISTINCT id) FROM basket_a;

-- operators on NULL values always return NULL
-- A NULL condition in a WHERE clause causes the row to not be selected

SELECT count(*) FROM basket_a WHERE fruit_a = NULL;
SELECT count(*) FROM basket_a WHERE fruit_a IS NULL;
SELECT count(*) FROM basket_a WHERE fruit_a != NULL;
SELECT count(*) FROM basket_a WHERE fruit_a IS NOT NULL;

SELECT count(*) FROM basket_a WHERE id < 3;
SELECT count(*) FROM basket_a WHERE id < 3 OR id IS NULL;
SELECT count(id) FROM basket_a WHERE id < 3;
SELECT count(DISTINCT id) FROM basket_a WHERE id < 3;

SELECT count(*) FROM basket_a WHERE (fruit_a = NULL) IS NULL;
SELECT count(*) FROM basket_a WHERE NOT (fruit_a = NULL) IS NULL;

SELECT sum(id) FROM basket_a WHERE fruit_a IS NULL;
SELECT sum(id) FROM basket_a WHERE id IS NOT NULL;

-- the LIKE operator is case sensitive
-- ILIKE is case insensitive
-- % is like the POSIX glob
-- (this is the behavior defined by the ANSI SQL standard;
-- other databases behave differently)

SELECT count(*) FROM basket_a WHERE fruit_a LIKE '%a%';
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE '%a%';
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE 'a%';
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE 'a';
SELECT count(DISTINCT fruit_a) FROM basket_a WHERE fruit_a ILIKE '%a%';

-- GROUP BY considers NULL values to be their own group
-- NULL values are by default ordered last

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
ORDER BY fruit_a DESC;

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
ORDER BY fruit_a ASC;

-- the WHERE clause happens before the GROUP BY, the HAVING clause happens after the GROUP BY
-- the WHERE clause cannot contain aggregate functions, but the HAVING clause can
-- the HAVING clause cannot contain columns that are not included in the SELECT statement's column list, but the WHERE clause can

SELECT fruit_a, count(*)
FROM basket_a
WHERE id IS NULL
GROUP BY fruit_a
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
WHERE id = NULL
GROUP BY fruit_a
ORDER BY fruit_a;

SELECT fruit_a, count(fruit_a)
FROM basket_a
WHERE id < 5 AND id >= 3
GROUP BY fruit_a
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
WHERE id < 5 AND id >= 3
GROUP BY fruit_a
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
HAVING count(*) > 1
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
HAVING count(*) > 1
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
GROUP BY fruit_a
HAVING count(fruit_a) = 1
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a
WHERE fruit_a LIKE '%a%'
GROUP BY fruit_a
HAVING fruit_a LIKE '%a%'
ORDER BY fruit_a;

-- JOINs construct a new table by combining two separate tables.
-- All JOINs are constructed internally from a CROSS JOIN,
-- but CROSS JOINs are rarely directly used in practice.
-- The CROSS JOIN joins every row from the first table with every other row from the second table.

SELECT count(*)
FROM basket_a, basket_b;

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;

SELECT count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id OR (basket_a.id IS NULL AND basket_b.id IS NULL);

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id;


SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b;

SELECT count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b;

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b;

SELECT fruit_a, count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b
GROUP BY fruit_a
ORDER BY fruit_a DESC;

SELECT fruit_a, count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b
GROUP BY fruit_a
HAVING count(basket_a.id) > 3
ORDER BY fruit_a;

SELECT fruit_a, count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id
GROUP BY fruit_a
ORDER BY fruit_a;

-- The CROSS JOIN with an equality condition is equivalent to an INNER JOIN;
-- This is the most common type of join, and so can be written as just JOIN

SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b ON basket_a.id = basket_b.id;

-- If the joined column names are the same in both tables,
-- then the USING clause can be used

SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b USING (id);
