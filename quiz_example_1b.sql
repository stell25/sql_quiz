/*
 * For each problem below,
 * write the output of the SELECT statement in both sqlite3 and postgres.
 * If the command does not result in an error, you should provide the full table of the output.
 * (The names of columns are unimportant.)
 * If the command does result in an error, just write "error".
 * (You do not need to provide the full error message.)
 * If the output of both sqlite3 and postgres is the same,
 * you can just write "sqlite3 and postgres are the same" instead of redrawing the output.
 */


-- Problem 1
SELECT count(fruit_a) FROM basket_a;








-- Problem 2
SELECT fruit_b, count(*)
FROM basket_b
WHERE fruit_b LIKE '%a%'
GROUP BY fruit_b
HAVING count(*) >= 2
ORDER BY fruit_b;









-- Problem 3
SELECT count(*)
FROM basket_a a1
JOIN basket_b b1 ON a1.fruit_a = b1.fruit_b
JOIN basket_a a2 ON a1.id > a2.id
WHERE a1.id = NULL;









-- Problem 4
SELECT count(DISTINCT basket_b.id)
FROM basket_a
JOIN basket_b ON (basket_a.id >= basket_b.id);
