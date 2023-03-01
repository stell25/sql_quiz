/*
 * For each problem below,
 * write the output of the SELECT statement.
 * 
 * Each problem is worth 2^1 points instead of 2^0 points,
 * so the quiz will overall is worth 2^3 points.
 */


-- Problem 1
SELECT count(*) FROM (SELECT 'Apple' EXCEPT ALL SELECT 'APPLE')t;






-- Problem 2
SELECT count(DISTINCT fruit_a)
FROM basket_a
WHERE id NOT IN (
    SELECT id
    FROM basket_b
    WHERE fruit_b ILIKE 'a%'
);





-- Problem 3
SELECT count(*)
FROM basket_a
LEFT JOIN basket_b ON (basket_a.id IS NULL AND basket_b.id IS NULL);






-- Problem 4
SELECT count(*)
FROM basket_a
NATURAL RIGHT JOIN basket_b;
