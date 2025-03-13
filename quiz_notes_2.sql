/*
SELECT * FROM basket_a;
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

SELECT * FROM basket_b;
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
*/

-- A "subquery" is a SELECT statement that is inside another SELECT statement;
-- Subqueries can be placed anywhere a tablename can be placed;
-- Subqueries used in this way must be given a name

SELECT count(*) FROM (
    SELECT id FROM basket_a
) AS t; -- the AS is optional
/*
 count
-------
     7
(1 row)
*/

/*
The above query is equivalent to

SELECT count(*) FROM basket_a;
*/

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

/*
  fruit_a
------------
 Apple
 Apple
 Orange
 Banana
 Cucumber


 Apple
 Apple
 Orange
 Orange
 Watermelon
 Pear


(15 rows)

*/

-- NOTE:
-- sqlite3 is "weakly typed", and postgres is "strongly typed";
-- the types from a UNION need not match in sqlite3,
-- but they must match in postgres;
-- see: <https://www.sqlite.org/quirks.html>

/*
The following query is not allowed in postgres, but is allowed in sqlite3

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    UNION ALL
    SELcECT id FROM basket_b
) t;
*/

-- UNION removes duplicates, so changing the columns can change the number of rows
-- UNION ALL: changing the columns will never change the number of rows

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    UNION
    SELECT fruit_b FROM basket_b
) t;
/*  7
 */

SELECT count(*) FROM (
    SELECT id, fruit_a FROM basket_a
    UNION
    SELECT id, fruit_b FROM basket_b
) t;
/* 12
 */

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    WHERE id < 3
    UNION ALL
    SELECT fruit_b FROM basket_b
    WHERE id > 3 AND fruit_b ILIKE '%a%'
) t;
/* count: 5
  fruit_a
------------
 Apple
 Apple
 Orange
 Orange
 Watermelon
(5 rows)
 */

SELECT count(id) FROM (
    SELECT DISTINCT id FROM basket_a
    UNION ALL
    SELECT id FROM basket_b
) t;
/* count:10, doesnt count null values
 id
----

  3
  4
  2
  1
  1
  2
  3
  4
  5

  6

(13 rows)
 */

SELECT count(id) FROM (
    SELECT DISTINCT id FROM basket_a
    UNION ALL
    SELECT DISTINCT id FROM basket_b
) t;
/* count: 10
 */

SELECT count(id) FROM (
    SELECT id FROM basket_a
    UNION ALL
    SELECT id FROM basket_b
) t;
/* count: 11
 id
----
  1
  1
  2
  3

  4

  1
  2
  3
  4
  5

  6

(15 rows)
 */

SELECT count(DISTINCT id) FROM (
    SELECT id FROM basket_a
    UNION ALL
    SELECT id FROM basket_b
) t;
/* count:6
 *  id
----

  3
  5
  4
  6
  2
  1
(7 rows)
 */

SELECT count(DISTINCT id) FROM (
    SELECT id FROM basket_a
    WHERE
        fruit_a LIKE '%a%'
    UNION ALL
    SELECT id FROM basket_b
    WHERE
        fruit_b LIKE '%A%'
) t;
/* count: 3
 id
----
  3
  2
  1
(3 rows)
 */

SELECT 'Apple' UNION SELECT 'Orange';
/*
 ?column?
----------
 Apple
 Orange
(2 rows)
 */

-- INTERSECT ALL returns all rows that are in both queries
-- INTERSECT also removes duplicates

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    INTERSECT
    SELECT fruit_b FROM basket_b
) t;
/* count: 3
 fruit_a
---------

 Orange
 Apple
(3 rows)
 */

SELECT count(*) FROM (
    SELECT id, fruit_a FROM basket_a
    INTERSECT
    SELECT id, fruit_b FROM basket_b
) t;
/*
 id | fruit_a
----+---------
    |
  1 | Apple
(2 rows)
 */

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    INTERSECT ALL
    SELECT fruit_b FROM basket_b
) t;
/*
 fruit_a
---------


 Orange
 Apple
 Apple
(5 rows)
 */

SELECT count(*) FROM (
    SELECT fruit_a FROM basket_a
    INTERSECT
    SELECT fruit_a FROM basket_a
    WHERE id < 5
) t;
/*
 fruit_a
---------

 Banana
 Orange
 Apple
(4 rows)
 */

-- EXCEPT ALL returns all rows that are in the first query but not the second
-- EXCEPT also removes duplicates

SELECT count(*)
FROM (
    SELECT fruit_a FROM basket_a
    EXCEPT ALL
    SELECT fruit_b FROM basket_b
) t;
/*
 fruit_a
----------
 Banana
 Cucumber
(2 rows)
 */

SELECT count(DISTINCT fruit_a)
FROM (
    SELECT fruit_a FROM basket_a
    EXCEPT
    SELECT fruit_b FROM basket_b
    WHERE fruit_b IS NOT NULL
) t;
/*
 fruit_a
----------

 Banana
 Cucumber
(3 rows)
 */

SELECT count(*)
FROM (
    SELECT fruit_b FROM basket_b
    EXCEPT
    SELECT fruit_a FROM basket_a
    WHERE fruit_a IS NOT NULL
) t;

/*
  fruit_b
------------

 Watermelon
 Pear
(3 rows)
 */

SELECT count(*) FROM (
    SELECT fruit_b FROM basket_b
    EXCEPT
    SELECT NULL
) t;
/*
  fruit_b
------------
 Orange
 Watermelon
 Pear
 Apple
(4 rows)
 */

-- The IN operator lets you compare to a "list"
-- See: <https://www.postgresql.org/docs/15/functions-comparisons.html#FUNCTIONS-COMPARISONS-IN-SCALAR>
/*
A IN (a, b, c)
is syntactic sugar for
A = a OR A = b OR A = c
Putting NULL doesn't affect the count(*) since A = NULL willalways result in NULL
*/

SELECT count(*) FROM basket_a WHERE id      IN (3, 4); --2
SELECT count(*) FROM basket_a WHERE id IN (3, 4, NULL); --2
SELECT count(*) FROM basket_a WHERE fruit_a IN ('Apple', 'Orange');--3
SELECT count(*) FROM basket_a WHERE fruit_a IN (NULL);--0

SELECT count(*) FROM basket_a WHERE id      NOT IN (3, 4);--4
SELECT count(*) FROM basket_a WHERE fruit_a NOT IN ('Apple', 'Orange');--3
SELECT count(*) FROM basket_a WHERE fruit_a NOT IN (NULL);--0

SELECT count(*) FROM basket_a WHERE NOT id      IN (3, 4);--3
SELECT count(*) FROM basket_a WHERE NOT fruit_a IN ('Apple', 'Orange'); --2
SELECT count(*) FROM basket_a WHERE NOT fruit_a IN (NULL); --0

-- A common use-case for subqueries is to populate the "list" to the right of the IN operator
-- These subqueries can only have a single column and do not require a name

SELECT count(*) FROM basket_a WHERE id      IN (SELECT  3      UNION SELECT 4       ); --same as IN(3, 4) = 2
SELECT count(*) FROM basket_a WHERE fruit_a IN (SELECT 'Apple' UNION SELECT 'Orange'); --3

SELECT count(*)                 FROM basket_a WHERE fruit_a IN (SELECT fruit_b  FROM basket_b); -- 3
SELECT count(*)                 FROM basket_a WHERE fruit_a IN (SELECT DISTINCT fruit_b  FROM basket_b); --3

-- adding the DISTINCT keyword into the subquery to the right of an IN clause will never change the results

SELECT count(*)                 FROM basket_a WHERE id      IN (SELECT id       FROM basket_b);--5
SELECT count(fruit_a)           FROM basket_a WHERE id      IN (SELECT id       FROM basket_b);--4
SELECT count(DISTINCT fruit_a)  FROM basket_a WHERE id      IN (SELECT id       FROM basket_b);--3

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
-- when `condition` is an equality of the form `a.c1=b.c2` and there are no NULL values, then the following is also equivalent:
--
--     SELECT * FROM a JOIN b ON (a.c1 = b.c2)
--     UNION ALL
--     SELECT * FROM a WHERE a.c1 NOT IN (SELECT b.c2 FROM b);

--A LEFT JOIN returns all the rows from the left table (the first table) and the matched rows from the right table (the second table). If there’s no match, the result will contain NULL for columns from the right table.

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b USING (id);
/* count: 7
 id | fruit_a  | fruit_b
----+----------+---------
  1 | Apple    | Apple
  1 | Apple    | Apple
  2 | Orange   | Apple
  3 | Banana   | Orange
    | Cucumber |
  4 |          | Orange
    |          |
(7 rows)
 */

SELECT count(fruit_b)
FROM basket_a
LEFT JOIN basket_b USING (id); --5

SELECT count(DISTINCT fruit_b)
FROM basket_a
LEFT JOIN basket_b USING (id); --2

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b USING (id)
WHERE
    fruit_b LIKE '%a%';
/*
 * count: 2
 id | fruit_a | fruit_b
----+---------+---------
  3 | Banana  | Orange
  4 |         | Orange
(2 rows)
 */

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b USING (id)
WHERE
    id > 1;
/*
Count: 3
 id | fruit_a | fruit_b
----+---------+---------
  2 | Orange  | Apple
  3 | Banana  | Orange
  4 |         | Orange
(3 rows)
 */

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (fruit_a = fruit_b);
/*
Count: 10
 id | fruit_a  | id | fruit_b
----+----------+----+---------
  1 | Apple    |  2 | Apple
  1 | Apple    |  1 | Apple
  1 | Apple    |  2 | Apple
  1 | Apple    |  1 | Apple
  2 | Orange   |  4 | Orange
  2 | Orange   |  3 | Orange
  3 | Banana   |    |
    | Cucumber |    |
  4 |          |    |
    |          |    |
(10 rows)
 */

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (fruit_a = fruit_b AND basket_a.id = basket_b.id);
/*
Count: 7
 id | fruit_a  | id | fruit_b
----+----------+----+---------
  1 | Apple    |  1 | Apple
  1 | Apple    |  1 | Apple
  2 | Orange   |    |
  3 | Banana   |    |
    | Cucumber |    |
  4 |          |    |
    |          |    |
(7 rows)
 */

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (fruit_a = fruit_b OR basket_a.id = basket_b.id);
/*
Count: 11
 id | fruit_a  | id | fruit_b
----+----------+----+---------
  1 | Apple    |  1 | Apple
  1 | Apple    |  2 | Apple
  1 | Apple    |  1 | Apple
  1 | Apple    |  2 | Apple
  2 | Orange   |  2 | Apple
  2 | Orange   |  3 | Orange
  2 | Orange   |  4 | Orange
  3 | Banana   |  3 | Orange
    | Cucumber |    |
  4 |          |  4 | Orange
    |          |    |
(11 rows)
 */

SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (basket_a.id < basket_b.id);
/*
Count = 21
 id | fruit_a  | id |  fruit_b
----+----------+----+------------
  1 | Apple    |  2 | Apple
  1 | Apple    |  3 | Orange
  1 | Apple    |  4 | Orange
  1 | Apple    |  5 | Watermelon
  1 | Apple    |  6 |
  1 | Apple    |  2 | Apple
  1 | Apple    |  3 | Orange
  1 | Apple    |  4 | Orange
  1 | Apple    |  5 | Watermelon
  1 | Apple    |  6 |
  2 | Orange   |  3 | Orange
  2 | Orange   |  4 | Orange
  2 | Orange   |  5 | Watermelon
  2 | Orange   |  6 |
  3 | Banana   |  4 | Orange
  3 | Banana   |  5 | Watermelon
  3 | Banana   |  6 |
    | Cucumber |    |
  4 |          |  5 | Watermelon
  4 |          |  6 |
    |          |    |
(21 rows)
 */

-- A RIGHT JOIN B is equivalent to B LEFT JOIN A
-- A RIGHT JOIN returns all the rows from the right table (the second table) and the matched rows from the left table (the first table). If there’s no match, the result will contain NULL for columns from the left table.

SELECT count(*)
FROM basket_a
RIGHT JOIN basket_b USING (id);
/*
Count: 9
 id | fruit_a |  fruit_b
----+---------+------------
  1 | Apple   | Apple
  1 | Apple   | Apple
  2 | Orange  | Apple
  3 | Banana  | Orange
  4 |         | Orange
  5 |         | Watermelon
    |         | Pear
  6 |         |
    |         |
(9 rows)
 */

-- A FULL JOIN is like a "right join plus a left join"
-- A FULL OUTER JOIN combines the effects of both LEFT JOIN and RIGHT JOIN. It returns all rows when there is a match in either the left table or the right table. If there is no match, the result will contain NULL for the non-matching side.--number of rows is both # of rows added together

SELECT count(*)
FROM basket_a
FULL JOIN basket_b USING (id);

/*
Count: 11
 id | fruit_a  |  fruit_b
----+----------+------------
  1 | Apple    | Apple
  1 | Apple    | Apple
  2 | Orange   | Apple
  3 | Banana   | Orange
    | Cucumber |
  4 |          | Orange
    |          |
    |          |
    |          | Pear
  5 |          | Watermelon
  6 |          |
(11 rows)
 */

-- The LEFT, RIGHT, and FULL JOINs are all examples of OUTER JOINs.
-- The OUTER keyword can be added without changing the meaning.

SELECT count(*)
FROM basket_a
FULL OUTER JOIN basket_b USING (id); --11

SELECT count(*)
FROM basket_a
LEFT OUTER JOIN basket_b USING (id); --7

SELECT count(*)
FROM basket_a
RIGHT OUTER JOIN basket_b USING (id); --9

--A NATURAL JOIN in SQL is a type of join that automatically matches columns between two tables with the same name and data type. Unlike other joins where you explicitly specify the columns to join on, a NATURAL JOIN finds and uses all columns with the same name in both tables to perform the join.
-- The "natural" join is syntactic sugar over the USING clause:
-- it is equivalent to using the USING clause over all columns with the same name;
-- The natural join is not a separate type of join, and can be combined with INNER/LEFT/RIGHT joins

SELECT count(*) FROM basket_a NATURAL JOIN basket_b; --5
/*
 id | fruit_a | fruit_b
----+---------+---------
  1 | Apple   | Apple
  1 | Apple   | Apple
  2 | Orange  | Apple
  3 | Banana  | Orange
  4 |         | Orange
(5 rows)
 */
SELECT count(*) FROM basket_a NATURAL LEFT JOIN basket_b;
SELECT count(*) FROM basket_a NATURAL LEFT OUTER JOIN basket_b; --7
/*
 id | fruit_a  | fruit_b
----+----------+---------
  1 | Apple    | Apple
  1 | Apple    | Apple
  2 | Orange   | Apple
  3 | Banana   | Orange
    | Cucumber |
  4 |          | Orange
    |          |
(7 rows)
 */
SELECT count(*) FROM basket_a NATURAL RIGHT JOIN basket_b;
SELECT count(*) FROM basket_a NATURAL RIGHT OUTER JOIN basket_b;
/*
Count: 9
 id | fruit_a |  fruit_b
----+---------+------------
  1 | Apple   | Apple
  1 | Apple   | Apple
  2 | Orange  | Apple
  3 | Banana  | Orange
  4 |         | Orange
  5 |         | Watermelon
    |         | Pear
  6 |         |
    |         |
(9 rows)
 */

SELECT count(*) FROM basket_a NATURAL FULL JOIN basket_b;
SELECT count(*) FROM basket_a NATURAL FULL OUTER JOIN basket_b;--11
/*
 id | fruit_a  |  fruit_b
----+----------+------------
  1 | Apple    | Apple
  1 | Apple    | Apple
  2 | Orange   | Apple
  3 | Banana   | Orange
    | Cucumber |
  4 |          | Orange
    |          |
    |          |
    |          | Pear
  5 |          | Watermelon
  6 |          |
(11 rows)
 */

SELECT sum(DISTINCT id) FROM basket_a NATURAL RIGHT JOIN basket_b;
/*
 sum
-----
  21
(1 row)

 id
----

  3
  5
  4
  6
  2
  1
(7 rows)
 */

-- outer joins can be chained together,
-- and the same table can be used multiple times

SELECT count(*)
FROM basket_a a1
LEFT JOIN basket_a a2 USING (id)
LEFT JOIN basket_a a3 USING (id);
/*
Count: 13
 id | fruit_a  | fruit_a | fruit_a
----+----------+---------+---------
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  2 | Orange   | Orange  | Orange
  3 | Banana   | Banana  | Banana
    | Cucumber |         |
  4 |          |         |
    |          |         |
(13 rows)
 */

SELECT count(*)
FROM basket_b b1
LEFT JOIN basket_b b2 USING (id)
LEFT JOIN basket_b b3 USING (id);
/*
Count: 8
 id |  fruit_b   |  fruit_b   |  fruit_b
----+------------+------------+------------
  1 | Apple      | Apple      | Apple
  2 | Apple      | Apple      | Apple
  3 | Orange     | Orange     | Orange
  4 | Orange     | Orange     | Orange
  5 | Watermelon | Watermelon | Watermelon
    | Pear       |            |
  6 |            |            |
    |            |            |
(8 rows)
 */

-- OUTER JOIN order is not commutative

SELECT count(*)
FROM basket_a a
LEFT JOIN basket_b b1 USING (id)
LEFT JOIN basket_b b2 USING (id);
/*
Count: 7
 id | fruit_a  | fruit_b | fruit_b
----+----------+---------+---------
  1 | Apple    | Apple   | Apple
  1 | Apple    | Apple   | Apple
  2 | Orange   | Apple   | Apple
  3 | Banana   | Orange  | Orange
    | Cucumber |         |
  4 |          | Orange  | Orange
    |          |         |
(7 rows)
 */

SELECT count(*)
FROM basket_b b1
LEFT JOIN basket_a a USING (id)
LEFT JOIN basket_b b2 USING (id);
/*
 id |  fruit_b   | fruit_a |  fruit_b
----+------------+---------+------------
  1 | Apple      | Apple   | Apple
  1 | Apple      | Apple   | Apple
  2 | Apple      | Orange  | Apple
  3 | Orange     | Banana  | Orange
  4 | Orange     |         | Orange
  5 | Watermelon |         | Watermelon
    | Pear       |         |
  6 |            |         |
    |            |         |
(9 rows)
 */

SELECT count(*)
FROM basket_b b1
LEFT JOIN basket_b b2 USING (id)
LEFT JOIN basket_a a USING (id);
/*
 id |  fruit_b   |  fruit_b   | fruit_a
----+------------+------------+---------
  1 | Apple      | Apple      | Apple
  1 | Apple      | Apple      | Apple
  2 | Apple      | Apple      | Orange
  3 | Orange     | Orange     | Banana
  4 | Orange     | Orange     |
  5 | Watermelon | Watermelon |
    | Pear       |            |
  6 |            |            |
    |            |            |
(9 rows)
 */

-- when an outer join is combined with any other type of join,
-- then the joins are no longer associative

SELECT count(*) FROM basket_b b1 LEFT JOIN basket_a a USING (id) JOIN basket_b b2 USING (id);--7
SELECT count(*) FROM (basket_b b1 LEFT JOIN basket_a a USING (id)) JOIN basket_b b2 USING (id);--7
/*
 id |  fruit_b   | fruit_a |  fruit_b
----+------------+---------+------------
  1 | Apple      | Apple   | Apple
  1 | Apple      | Apple   | Apple
  2 | Apple      | Orange  | Apple
  3 | Orange     | Banana  | Orange
  4 | Orange     |         | Orange
  5 | Watermelon |         | Watermelon
  6 |            |         |
(7 rows)
 */

SELECT count(*) FROM basket_b b1 LEFT JOIN (basket_a a JOIN basket_b b2 USING (id)) USING (id);
/*
 id |  fruit_b   | fruit_a | fruit_b
----+------------+---------+---------
  1 | Apple      | Apple   | Apple
  1 | Apple      | Apple   | Apple
  2 | Apple      | Orange  | Apple
  3 | Orange     | Banana  | Orange
  4 | Orange     |         | Orange
    |            |         |
    | Pear       |         |
  5 | Wa id |  fruit_b   | fruit_a | fruit_b
----+------------+---------+---------
  1 | Apple      | Apple   | Apple
  1 | Apple      | Apple   | Apple
  2 | Apple      | Orange  | Apple
  3 | Orange     | Banana  | Orange
  4 | Orange     |         | Orange
    |            |         |
    | Pear       |         |
  5 | Watermelon |         |
  6 |            |         |
(9 rows)termelon |         |
  6 |            |         |
(9 rows)
 */

-- As discussed above, every LEFT/RIGHT JOIN can be written in terms of a subquery;
-- subqueries are strictly more powerful, however;
-- if a subquery contains an aggregate function, then it cannot be re-written as a join

SELECT count(*) FROM (
    SELECT sum(id) FROM basket_a
    UNION
    SELECT sum(id) FROM basket_b
) t;
/*
 sum
-----
  11
  21
(2 rows)
 */

SELECT count(*) FROM (
    SELECT sum(DISTINCT id) FROM basket_a
    UNION
    SELECT sum(id) FROM basket_b WHERE id < 5
) t;
/*
 sum
-----
  10
(1 row)
 */

SELECT count(*) FROM (
    SELECT count(id) FROM basket_a
    UNION
    SELECT id FROM basket_b
) t;
/*
 count
-------

     5
     4
     6
     2
     1
     3
(7 rows)
 */

SELECT count(*)
FROM basket_a
WHERE id NOT IN (SELECT sum(id) FROM basket_b WHERE fruit_b ILIKE '%a%');
/*
 id | fruit_a
----+---------
  1 | Apple
  1 | Apple
  2 | Orange
  3 | Banana
  4 |
(5 rows)
 */

SELECT count(*)
FROM basket_b
WHERE id IN (SELECT count(id) FROM basket_b WHERE fruit_b ILIKE '%a%');

SELECT count(*)
FROM basket_b
WHERE id IN (SELECT count(id) FROM basket_a WHERE id < 5);
/*
id |  fruit_b
----+------------
  5 | Watermelon
(1 row)
*/

-- subqueries can be combined with JOINs

SELECT count(*)
FROM basket_a
WHERE id NOT IN (SELECT sum(id) FROM basket_b WHERE fruit_b ILIKE '%a%');SELECT count(*)
FROM basket_b
WHERE id IN (
    SELECT count(id)
    FROM basket_a
    JOIN basket_b USING (id)
    WHERE id < 5
);
/*
 id | fruit_a
----+---------
  1 | Apple
  1 | Apple
  2 | Orange
  3 | Banana
  4 |
(5 rows)

 count
-------
     1
(1 row)
 */

SELECT count(*)
FROM basket_b, basket_a
WHERE basket_b.id IN (
    SELECT count(id)
    FROM basket_a
    JOIN basket_b USING (id)
    WHERE id < 5
);
/*
 id |  fruit_b   | id | fruit_a
----+------------+----+----------
  5 | Watermelon |  1 | Apple
  5 | Watermelon |  1 | Apple
  5 | Watermelon |  2 | Orange
  5 | Watermelon |  3 | Banana
  5 | Watermelon |    | Cucumber
  5 | Watermelon |  4 |
  5 | Watermelon |    |
(7 rows)
 */

SELECT count(*)
FROM basket_b
LEFT JOIN basket_a USING (id)
WHERE basket_b.id IN (
    SELECT count(id)
    FROM basket_a
    JOIN basket_b USING (id)
    WHERE id < 5
);
/*
 id |  fruit_b   | fruit_a
----+------------+---------
  5 | Watermelon |
(1 row)
 */

SELECT count(*)
FROM basket_b
RIGHT JOIN basket_a USING (id)
WHERE basket_b.id IN (
    SELECT count(id)
    FROM basket_a
    JOIN basket_b USING (id)
    WHERE id < 5
);--0

SELECT count(*)
FROM basket_b
RIGHT JOIN basket_a USING (id)
WHERE basket_b.id IN (SELECT id FROM basket_a WHERE id < 5);
/*
 id | fruit_b | fruit_a
----+---------+---------
  1 | Apple   | Apple
  1 | Apple   | Apple
  2 | Apple   | Orange
  3 | Orange  | Banana
  4 | Orange  |
(5 rows)
 */

SELECT count(*)
FROM basket_b
RIGHT JOIN basket_a USING (id)
WHERE basket_b.id IN (
    SELECT count(id)
    FROM basket_a
    JOIN basket_b USING (id)
    WHERE id < 5
);--0

SELECT count(*)
FROM basket_b
LEFT JOIN basket_a ON (fruit_a = fruit_b)
WHERE basket_b.id IN (SELECT id FROM basket_a WHERE id < 5);
/*
 id | fruit_b | id | fruit_a
----+---------+----+---------
  2 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  2 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  4 | Orange  |  2 | Orange
  3 | Orange  |  2 | Orange
(6 rows)
 */

SELECT count(*)
FROM basket_b
RIGHT JOIN basket_a ON (fruit_a = fruit_b)
WHERE basket_b.id IN (SELECT id FROM basket_a WHERE id < 5);
/*
 id | fruit_b | id | fruit_a
----+---------+----+---------
  2 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  2 | Apple   |  1 | Apple
  1 | Apple   |  1 | Apple
  4 | Orange  |  2 | Orange
  3 | Orange  |  2 | Orange
(6 rows)
 */
