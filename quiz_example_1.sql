/*
 * For each problem below,
 * write the output of the SELECT statement.
 * 
 * Each problem is worth 2^1 points instead of 2^0 points,
 * so the quiz will overall is worth 2^3 points.
 */


-- Problem 1
SELECT count(DISTINCT id) FROM basket_a WHERE id > NULL ;








-- Problem 2
SELECT fruit_a, count(*)
FROM basket_a
WHERE fruit_a ILIKE '%a%'
GROUP BY fruit_a
HAVING count(*) <= 2
ORDER BY fruit_a;









-- Problem 3
SELECT count(*)
FROM basket_a
JOIN basket_b USING (id)
WHERE id IS NOT NULL;









-- Problem 4
SELECT count(DISTINCT basket_a.id)
FROM basket_a
JOIN basket_b ON (basket_a.id > basket_b.id);
