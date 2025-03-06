/*
SQL has lots of weird syntax compared to other languages.
This is because: 
1. SQL was designed in the 70s before current conventions were standardized, and
1. these conventions have not been changed for backwards compatibility reasons.
*/

-- commands case insensitive, but text case sensative
-- when you dont have a FROM, you get a table with a single row output
sElEcT 'hello world';
SELECT 'Hello' = 'hello';
postgres=# sElEcT 'hello world';
  ?column?
-------------
 hello world
(1 row)

postgres=# SELECT 'Hello' = 'hello';
 ?column?
----------
 f
(1 row)

sqlite> SELECT 'hello world';
hello world
sqlite> SELECT 'Hello' = 'hello';
0

-- string concatenation uses || not +
-- + used only for "real" math
SELECT 'hello' || 'world';
SELECT 1 + 2;

postgres=# SELECT 'hello' || 'world';
  ?column?
------------
 helloworld
(1 row)

postgres=# SELECT 1 + 2;
 ?column?
----------
        3
(1 row)

sqlite> SELECT 'hello' || 'world';
helloworld
sqlite> SELECT 1 + 2;
3

-- escape quotations by doubling the quote marked
SELECT 'isn''t SQL great?';
-- SELECT 'isn\'t SQL great?';          /* syntax error */
postgres=returns column that says the below
-- sqlite3 > isn't SQL great?

-- ONLY psql supports the "dollar quoted string literal" syntax
SELECT $$isn't SQL great?$$;
SELECT $blah$isn't SQL great?$blah$;

-- DOUBLE QUOTES FOR COLUMN/RELATION NAMES
-- SINGLE QUOTES FOR STRING
-- they are optional if no special characters are used in the name
SELECT 'hello world';
SELECT 'hello world' AS greeting;
SELECT 'hello world' AS "the greeting";

postgres=# SELECT 'hello world' AS greeting;
  greeting
-------------
 hello world
(1 row)

postgres=# SELECT 'hello world' AS "the greeting";
 the greeting
--------------
 hello world
(1 row)

sqlite> SELECT 'hello world' AS greeting;
hello world
sqlite> SELECT 'hello world' AS "the greeting";
hello world

/*
All the notes below concern the *semantics* of SQL instead of the *syntax*.
*/
Basket_a
 id | fruit_a
----+----------
  1 | Apple
  1 | Apple
  2 | Orange
  3 | Banana
    | Cucumber
  4 |
    |
(7 rows)

Basket_b
 id |  fruit_b
----+------------
  1 | Apple
  2 | Apple
  3 | Orange
  4 | Orange
  5 | Watermelon
    | Pear
  6 |
    |
(8 rows)

-- aggregate functions will ignore null values only if included in the function list (i.e. sum, count, avg, min, max)

--for the following, sqlite3 just returns a number, postgres returns a table as such: count
-------
     4
(1 row)

SELECT count(*) FROM basket_a;
SELECT count(1) FROM basket_a;
--count(*) counts the number of rows, so it counts NULL rows
SELECT count(fruit_a) FROM basket_a;
SELECT count(id) FROM basket_a;
--count(column) ignores NULL values
SELECT count(id || fruit_a) FROM basket_a;
--returns 4
SELECT sum(1) FROM basket_a;
--7, returns a count
SELECT sum(id) FROM basket_a;
--11

--count(1) or sum(1) returns the number of rows

-- the DISTINCT operator removes duplicates before passing to the aggregate function

SELECT count(DISTINCT fruit_a) FROM basket_a; --4
SELECT count(DISTINCT id) FROM basket_a; --4
SELECT count(DISTINCT 1) FROM basket_a; --1
--DISTINCT 1- boolean that returns whether or not there are rows in the table
SELECT sum(DISTINCT id) FROM basket_a; --10

-- operators on NULL values always return NULL
-- A NULL condition in a WHERE clause causes the row to not be selected

SELECT count(*) FROM basket_a WHERE fruit_a = NULL; --0
SELECT count(*) FROM basket_a WHERE fruit_a IS NULL; --2
SELECT count(*) FROM basket_a WHERE fruit_a != NULL; --0
SELECT count(*) FROM basket_a WHERE fruit_a IS NOT NULL; --5

SELECT count(*) FROM basket_a WHERE id < 3; --3
SELECT count(*) FROM basket_a WHERE id < 3 OR id IS NULL; --5
SELECT count(id) FROM basket_a WHERE id < 3; --3
SELECT count(DISTINCT id) FROM basket_a WHERE id < 3;--2

SELECT count(*) FROM basket_a WHERE (fruit_a = NULL) IS NULL;--7
SELECT count(*) FROM basket_a WHERE NOT (fruit_a = NULL) IS NULL;--0

SELECT sum(id) FROM basket_a WHERE fruit_a IS NULL;--4
SELECT sum(id) FROM basket_a WHERE id IS NOT NULL;--11

-- In the ANSI SQL standard:
-- (1) the LIKE operator is case sensitive
-- (2) % behaves in the same way as the POSIX glob
--
-- Case sensitive operations are usually more efficient to implement;
-- case in-sensitive operations, are usually more useful.
--
-- In postgres:
-- (1) LIKE is case sensitive
-- (2) ILIKE is case insensitive
--
-- In sqlite3:
-- (1) LIKE is case insensitive
-- (2) ILIKE does not exist and results in an error

SELECT count(*) FROM basket_a WHERE fruit_a LIKE '%a%';--psql: 2, sql3: 4
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE '%a%';--psql: 4, sql3: error
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE 'a%';--psql: 2
SELECT count(*) FROM basket_a WHERE fruit_a ILIKE 'a';--psql: 0
SELECT count(DISTINCT fruit_a) FROM basket_a WHERE fruit_a ILIKE '%a%';--psql: 3

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

postgres=#
 fruit_a  | count
----------+-------
 Cucumber |     1
          |     1
(2 rows)

sqlite> 
|1
Cucumber|1

SELECT fruit_a, count(*)
FROM basket_a
WHERE id = NULL
GROUP BY fruit_a
ORDER BY fruit_a;--returns nothing

SELECT fruit_a, count(fruit_a)
FROM basket_a
WHERE id < 5 AND id >= 3
GROUP BY fruit_a
ORDER BY fruit_a;

postgres=#
fruit_a | count
---------+-------
 Banana  |     1
         |     0
(2 rows)

sqlite>
|0
Banana|1

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
--returns 56, multiply number of rows in basket_a by basket_b 
postgres=#
 count
-------
    56
(1 row)

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;
--5

SELECT count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;
--5

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;
--4

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id OR (basket_a.id IS NULL AND basket_b.id IS NULL);
--9
--postgres=#
 id | fruit_a  | id | fruit_b
----+----------+----+---------
  1 | Apple    |  1 | Apple
  1 | Apple    |  1 | Apple
  2 | Orange   |  2 | Apple
  3 | Banana   |  3 | Orange
    | Cucumber |    | Pear
    | Cucumber |    |
  4 |          |  4 | Orange
    |          |    | Pear
    |          |    |
(9 rows)

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id;
--6
 id | fruit_a | id | fruit_b
----+---------+----+---------
  2 | Orange  |  1 | Apple
  3 | Banana  |  1 | Apple
  3 | Banana  |  2 | Apple
  4 |         |  1 | Apple
  4 |         |  2 | Apple
  4 |         |  3 | Orange
(6 rows)

SELECT count(*)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b;
--6
--postgres=#
-- id | fruit_a | id | fruit_b
----+---------+----+---------
  1 | Apple   |  2 | Apple
  1 | Apple   |  1 | Apple
  1 | Apple   |  2 | Apple
  1 | Apple   |  1 | Apple
  2 | Orange  |  4 | Orange
  2 | Orange  |  3 | Orange
(6 rows)

SELECT count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b;
--6

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b;
--2

SELECT fruit_a, count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b
GROUP BY fruit_a
ORDER BY fruit_a DESC;
--postgres=#
 fruit_a | count
---------+-------
 Orange  |     2
 Apple   |     4
(2 rows)

--sqlite>
Orange|2
Apple|4

SELECT fruit_a, count(basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.fruit_a = basket_b.fruit_b
GROUP BY fruit_a
HAVING count(basket_a.id) > 3
ORDER BY fruit_a;
--postgres=#
 fruit_a | count
---------+-------
 Apple   |     4
(1 row)

--sqlite>
Apple|4

SELECT fruit_a, count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id
GROUP BY fruit_a
ORDER BY fruit_a;
--postgres=#
 fruit_a | count
---------+-------
 Banana  |     2
 Orange  |     1
         |     3
(3 rows)

--sqlite>
|3
Banana|2
Orange|1

-- The INNER JOIN is syntactic sugar for a CROSS JOIN plus a WHERE clause

SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b ON basket_a.id = basket_b.id;
--5
--postgres=#
 id | fruit_a | id | fruit_b
----+---------+----+---------
  1 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  2 | Orange  |  2 | Apple
  3 | Banana  |  3 | Orange
  4 |         |  4 | Orange
(5 rows)
--sqlite>
1|Apple|1|Apple
1|Apple|1|Apple
2|Orange|2|Apple
3|Banana|3|Orange
4||4|Orange


/*
the above query is equivalent to 

SELECT count(DISTINCT basket_a.id)
FROM basket_a, basket_b
WHERE basket_a.id = basket_b.id;
*/

SELECT fruit_a, count(*)
FROM basket_a
JOIN basket_b ON basket_a.id > basket_b.id
GROUP BY fruit_a
ORDER BY fruit_a;

/*
the above query is equivalent to 

SELECT fruit_a, count(*)
FROM basket_a, basket_b
WHERE basket_a.id > basket_b.id
GROUP BY fruit_a
ORDER BY fruit_a;
*/

-- The USING clause is syntactic sugar for an INNER JOIN that:
-- (1) uses an equality condition
-- (2) has identical column names in both tables
--
-- WARNING:
-- Ensure that you understand the behavior of NULL values.

SELECT count(DISTINCT id)
FROM basket_a
JOIN basket_b USING (id);
--4
--postgres=#
 id | fruit_a | fruit_b
----+---------+---------
  1 | Apple   | Apple
  1 | Apple   | Apple
  2 | Orange  | Apple
  3 | Banana  | Orange
  4 |         | Orange
(5 rows)

/*
the above query is equivalent to

SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b ON basket_a.id = basket_b.id

Note that in the column list for JOINs with the ON clause,
we must use "fully qualified names" to refer to columns.
When we use the USING clause,
we do not need to specify the table of the "id" column.
*/

SELECT count(*)
FROM basket_a
JOIN basket_b USING (id)
WHERE id IS NOT NULL;
--postgres=#
 id | fruit_a | fruit_b
----+---------+---------
  1 | Apple   | Apple
  1 | Apple   | Apple
  2 | Orange  | Apple
  3 | Banana  | Orange
  4 |         | Orange
(5 rows)

-- The NATURAL JOIN is syntactic sugar for a USING clause.
-- It joins the tables on all columns with shared names.

SELECT count(DISTINCT id)
FROM basket_a
NATURAL JOIN basket_b;
--4
--SAME AS ABOCE

-- A "self join" is a join of a table with itself.
-- Self joins are not their own special join type;
-- any type of join (e.g. CROSS, INNER, NATURAL) can be called a self join.
-- To be syntactically valid, a self join must specify a "table alias".
-- (Table aliases are always allowed, but required for self joins.)
-- Aliases disambiguate which column of the table we are referring to.

SELECT count(*)
FROM basket_a AS a1
   , basket_a AS a2
WHERE a1.id > a2.id;
--9
--postgres=#
 id | fruit_a | id | fruit_a
----+---------+----+---------
  2 | Orange  |  1 | Apple
  2 | Orange  |  1 | Apple
  3 | Banana  |  1 | Apple
  3 | Banana  |  1 | Apple
  3 | Banana  |  2 | Orange
  4 |         |  1 | Apple
  4 |         |  1 | Apple
  4 |         |  2 | Orange
  4 |         |  3 | Banana
(9 rows)

SELECT count(*)
FROM basket_a AS a1
   , basket_a AS a2
WHERE a1.id = a2.id;
 id | fruit_a | id | fruit_a
----+---------+----+---------
  1 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  2 | Orange  |  2 | Orange
  3 | Banana  |  3 | Banana
  4 |         |  4 |
(7 rows)

SELECT count(*)
FROM basket_a a1 -- the AS keyword is optional
   , basket_a a2
WHERE a1.id = a2.id;
--7, same as above

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (id);

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (id, fruit_a);
--postgres=#
 id | fruit_a
----+---------
  1 | Apple
  1 | Apple
  1 | Apple
  1 | Apple
  2 | Orange
  3 | Banana
(6 rows)

SELECT count(*)
FROM basket_a a1
NATURAL JOIN basket_a a2;
--6, same as above

-- All joins are "binary operations" and involve exactly two tables.
-- But multiple joins can be combined together.
-- CROSS JOINS, INNER JOINS, and NATURAL JOINS are associative and commutative (up to the ordering of column results).

SELECT count(*)
FROM basket_a a1, basket_a a2, basket_b
WHERE a1.id = a2.id
  AND a1.fruit_a = basket_b.fruit_b;
--postgres=#
 id | fruit_a | id | fruit_a | id | fruit_b
----+---------+----+---------+----+---------
  1 | Apple   |  1 | Apple   |  2 | Apple
  1 | Apple   |  1 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple   |  2 | Apple
  1 | Apple   |  1 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple   |  2 | Apple
  1 | Apple   |  1 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple   |  2 | Apple
  1 | Apple   |  1 | Apple   |  1 | Apple
  2 | Orange  |  2 | Orange  |  4 | Orange
  2 | Orange  |  2 | Orange  |  3 | Orange
(10 rows)

/*
the above query is the same as

SELECT count(*)
FROM basket_a a1, basket_b, basket_a a2
WHERE a1.id = a2.id
  AND a1.fruit_a = basket_b.fruit_b;

SELECT count(*)
FROM basket_b, basket_a a2, basket_a a1 
WHERE a1.id = a2.id
  AND a1.fruit_a = basket_b.fruit_b;
*/

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 ON a1.id = a2.id
JOIN basket_b ON a1.fruit_a = basket_b.fruit_b;
--10, same as above

/*
the above query is equivalent to

SELECT count(*)
FROM basket_a a1
JOIN basket_b ON a1.fruit_a = basket_b.fruit_b
JOIN basket_a a2 ON a1.id = a2.id;

SELECT count(*)
FROM basket_b 
JOIN basket_a a1 ON a1.fruit_a = basket_b.fruit_b
JOIN basket_a a2 ON a1.id = a2.id;
*/

-- NOTE:
-- SQL is based mathematically on "relational algebra".
-- If this were a database theory course,
-- we would cover relational algebra in detail and prove the associative and commutative properties above.
