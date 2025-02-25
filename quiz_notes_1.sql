/*
SQL has lots of weird syntax compared to other languages.
This is because: 
1. SQL was designed in the 70s before current conventions were standardized, and
1. these conventions have not been changed for backwards compatibility reasons.
*/

-- commands case insensitive, but text case sensative
sElEcT 'hello world';
SELECT 'Hello' = 'hello';

-- string concatenation uses || not +
-- + used only for "real" math
SELECT 'hello' || 'world';
SELECT 1 + 2;

-- escape quotations by doubling the quote marked
SELECT 'isn''t SQL great?';
-- SELECT 'isn\'t SQL great?';          /* syntax error */

-- sql supports the "dollar quoted string literal" syntax
SELECT $$isn't SQL great?$$;
SELECT $blah$isn't SQL great?$blah$;

-- double quotes for column/relation names
-- they are optional if no special characters are used in the name
SELECT 'hello world';
SELECT 'hello world' AS greeting;
SELECT 'hello world' AS "the greeting";

/*
All the notes below concern the *semantics* of SQL instead of the *syntax*.
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

-- The INNER JOIN is syntactic sugar for a CROSS JOIN plus a WHERE clause

SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b ON basket_a.id = basket_b.id;

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

-- The NATURAL JOIN is syntactic sugar for a USING clause.
-- It joins the tables on all columns with shared names.

SELECT count(DISTINCT id)
FROM basket_a
NATURAL JOIN basket_b;

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

SELECT count(*)
FROM basket_a AS a1
   , basket_a AS a2
WHERE a1.id = a2.id;

SELECT count(*)
FROM basket_a a1 -- the AS keyword is optional
   , basket_a a2
WHERE a1.id = a2.id;

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (id);

SELECT count(*)
FROM basket_a a1
JOIN basket_a a2 USING (id, fruit_a);

SELECT count(*)
FROM basket_a a1
NATURAL JOIN basket_a a2;

-- All joins are "binary operations" and involve exactly two tables.
-- But multiple joins can be combined together.
-- CROSS JOINS, INNER JOINS, and NATURAL JOINS are associative and commutative (up to the ordering of column results).

SELECT count(*)
FROM basket_a a1, basket_a a2, basket_b
WHERE a1.id = a2.id
  AND a1.fruit_a = basket_b.fruit_b;

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
