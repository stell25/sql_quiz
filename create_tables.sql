CREATE TABLE basket_a (
    a INT PRIMARY KEY,
    fruit_a TEXT
);

CREATE TABLE basket_b (
    b INT PRIMARY KEY,
    fruit_b TEXT
);

INSERT INTO basket_a (a, fruit_a)
VALUES
    (1, 'Apple'),
    (2, 'Orange'),
    (3, 'Banana'),
    (4, 'Cucumber'),
    (5, NULL);

INSERT INTO basket_b (b, fruit_b)
VALUES
    (1, 'Orange'),
    (2, 'Apple'),
    (3, 'Watermelon'),
    (4, 'Pear'),
    (5, NULL);
    (6, NULL);
