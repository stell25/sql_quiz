
-- A "subquery" is a SELECT statement that is inside another SELECT statement;
-- Subqueries can also be placed anywhere a tablename can be placed;
-- Subqueries used in this way must be given a name

SELECT count(*) FROM (
    SELECT id FROM basket_a
) t; -- the AS is optional

--SELECT count(*) FROM basket_a;

-- JOINs combine tables "horizontally" whereas set operations combine tables "vertically"
-- column types must match between the two select statements,
-- but the final column names will be the column names of the first query

-- UNION ALL concatenates the results of two queries
-- UNION also removes duplicates

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    UNION ALL
    SELECT fruit_b FROM basket_b
) t;

-- UNION removes duplicates, so changing the columns can change the number of rows
-- UNION ALL: changing the columns will never change the number of rows

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    UNION
    SELECT fruit_b FROM basket_b
) t;

SELECT count(*) FROM (
    SELECT id, fruit_a FROM basket_a
    UNION
    SELECT id, fruit_b FROM basket_b
) t;

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    WHERE id < 3
    UNION ALL
    SELECT fruit_b FROM basket_b
    WHERE id > 3 AND fruit_b ILIKE '%a%'
) t;

SELECT count(id) FROM (
    SELECT DISTINCT id FROM basket_a
    UNION ALL
    SELECT id FROM basket_b
) t;

SELECT count(id) FROM (
    SELECT DISTINCT id FROM basket_a
    UNION ALL
    SELECT DISTINCT id FROM basket_b
) t;

SELECT count(id) FROM (
    SELECT id FROM basket_a
    UNION ALL
    SELECT id FROM basket_b
) t;

SELECT count(DISTINCT id) FROM (
    SELECT id FROM basket_a
    UNION ALL
    SELECT id FROM basket_b
) t;

SELECT count(DISTINCT id) FROM (
    SELECT id FROM basket_a
    WHERE
        fruit_a LIKE '%a%'
    UNION ALL
    SELECT id FROM basket_b
    WHERE
        fruit_b LIKE '%A%'
) t;

SELECT 'Apple' UNION SELECT 'Orange';

-- INTERSECT ALL returns all rows that are in both queries
-- INTERSECT also removes duplicates

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    INTERSECT
    SELECT fruit_b FROM basket_b
) t;

SELECT count(*) FROM (
    SELECT id, fruit_a FROM basket_a
    INTERSECT
    SELECT id, fruit_b FROM basket_b
) t;

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    INTERSECT ALL
    SELECT fruit_b FROM basket_b
) t;

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    INTERSECT
    SELECT fruit_a FROM basket_a
    WHERE id < 5
) t;

-- EXCEPT ALL returns all rows that are in the first query but not the second
-- EXCEPT also removes duplicates

SELECT count(*)
FROM (
    SELECT fruit_a FROM basket_a
    EXCEPT ALL
    SELECT fruit_b FROM basket_b
) t;

SELECT count(DISTINCT fruit_a)
FROM (
    SELECT fruit_a FROM basket_a
    EXCEPT
    SELECT fruit_b FROM basket_b
    WHERE fruit_b IS NOT NULL
) t;

SELECT count(*)
FROM (
    SELECT fruit_b FROM basket_b
    EXCEPT
    SELECT fruit_a FROM basket_a
    WHERE fruit_a IS NOT NULL
) t;

SELECT count(*) FROM (
    SELECT fruit_b FROM basket_b
    EXCEPT
    SELECT NULL
) t;

-- The IN operator lets you compare to a "list"
-- See: <https://www.postgresql.org/docs/15/functions-comparisons.html#FUNCTIONS-COMPARISONS-IN-SCALAR>
/*
A IN (a, b, c)
is syntactic sugar for
A = a OR A = b OR A = c
*/

SELECT count(*) FROM basket_a WHERE id      IN (3, 4);
SELECT count(*) FROM basket_a WHERE fruit_a IN ('Apple', 'Orange');
SELECT count(*) FROM basket_a WHERE fruit_a IN (NULL);

SELECT count(*) FROM basket_a WHERE id      NOT IN (3, 4);
SELECT count(*) FROM basket_a WHERE fruit_a NOT IN ('Apple', 'Orange');
SELECT count(*) FROM basket_a WHERE fruit_a NOT IN (NULL);

SELECT count(*) FROM basket_a WHERE NOT id      IN (3, 4);
SELECT count(*) FROM basket_a WHERE NOT fruit_a IN ('Apple', 'Orange');
SELECT count(*) FROM basket_a WHERE NOT fruit_a IN (NULL);

-- A common use-case for subqueries is to populate the "list" to the right of the IN operator
-- These subqueries can only have a single column and do not require a name

SELECT count(*) FROM basket_a WHERE id      IN (SELECT  3      UNION SELECT 4       );
SELECT count(*) FROM basket_a WHERE fruit_a IN (SELECT 'Apple' UNION SELECT 'Orange');

SELECT count(*)                 FROM basket_a WHERE fruit_a IN (SELECT fruit_b  FROM basket_b);
SELECT count(*)                 FROM basket_a WHERE fruit_a IN (SELECT DISTINCT fruit_b  FROM basket_b);
-- adding the DISTINCT keyword into the subquery to the right of an IN clause will never change the results

SELECT count(*)                 FROM basket_a WHERE id      IN (SELECT id       FROM basket_b);
SELECT count(fruit_a)           FROM basket_a WHERE id      IN (SELECT id       FROM basket_b);
SELECT count(DISTINCT fruit_a)  FROM basket_a WHERE id      IN (SELECT id       FROM basket_b);

-- We've already seen that the INNER JOIN is syntactic sugar over the cross join plus a condition;
-- that is, the following two statements are equivalent:
--
--     SELECT * FROM a JOIN b ON (condition);
--     SELECT * FROM a,b WHERE condition;
--
-- Outer joins are syntactic sugar for INNER JOIN plus a set operation;
-- The left outer join given by
--
--     SELECT * FROM a LEFT JOIN b ON (condition);
--
-- is equivalent to
--
--     SELECT * FROM a JOIN b ON (condition)
--     UNION ALL
--     (
--     SELECT a.*,NULL,NULL,NULL,... FROM a         -- there should be one NULL for each column in b
--     EXCEPT ALL
--     SELECT a.*,NULL,NULL,NULL,... FROM a JOIN b ON (condition)
--     );
--
-- when `condition` is an equality of the form `a.c1=b.c2`, then the following is also equivalent:
--
--     SELECT * FROM a JOIN b ON (a.c1 = b.c2)
--     UNION ALL
--     SELECT * FROM a WHERE a.c1 NOT IN (SELECT b.c2 FROM b);
--

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b USING (id);

SELECT count(fruit_b)
FROM basket_a
LEFT JOIN basket_b USING (id);

SELECT count(DISTINCT fruit_b)
FROM basket_a
LEFT JOIN basket_b USING (id);

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b USING (id)
WHERE
    fruit_b LIKE '%a%';

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b USING (id)
WHERE
    id > 1;

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (fruit_a = fruit_b);

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (fruit_a = fruit_b AND basket_a.id = basket_b.id);

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (fruit_a = fruit_b OR basket_a.id = basket_b.id);

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (basket_a.id < basket_b.id);

-- A RIGHT JOIN B is equivalent to B LEFT JOIN A

SELECT count(*)
FROM basket_a
RIGHT JOIN basket_b USING (id);

-- The "natural" join is syntactic sugar over the USING clause:
-- it is equivalent to using the USING clause over all columns with the same name;
-- The natural join is not a separate type of join, and can be combined with INNER/LEFT/RIGHT joins

SELECT count(*) FROM basket_a NATURAL JOIN basket_b;
SELECT count(*) FROM basket_a NATURAL LEFT JOIN basket_b;
SELECT count(*) FROM basket_a NATURAL RIGHT JOIN basket_b;

SELECT sum(DISTINCT id) FROM basket_a NATURAL RIGHT JOIN basket_b;

-- As discussed above, every LEFT/RIGHT JOIN can be written in terms of a subquery;
-- subqueries are strictly more powerful, however;
-- if a subquery contains an aggregate function, then it cannot be re-written as a join

SELECT count(*) FROM (
    SELECT sum(id) FROM basket_a
    UNION
    SELECT sum(id) FROM basket_b
) t;

SELECT count(*) FROM (
    SELECT sum(DISTINCT id) FROM basket_a
    UNION
    SELECT sum(id) FROM basket_b WHERE id < 5
) t;

SELECT count(*) FROM (
    SELECT count(id) FROM basket_a
    UNION
    SELECT id FROM basket_b
) t;

SELECT count(*)
FROM basket_a
WHERE id NOT IN (SELECT sum(id) FROM basket_b WHERE fruit_b ILIKE '%a%');

SELECT count(*)
FROM basket_b
WHERE id IN (SELECT count(id) FROM basket_b WHERE fruit_b ILIKE '%a%');

SELECT count(*)
FROM basket_b
WHERE id IN (SELECT count(id) FROM basket_a WHERE id < 5);
