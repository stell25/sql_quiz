/*
This file shows the *truth tables* for boolean operations on NULL values.
For these operations, the intuition is that NULL represents an "unknown value".
(That is, the real underlying value might be TRUE or might be FALSE.)
*/
.mode markdown

CREATE TABLE bool (value BOOLEAN);
INSERT INTO bool VALUES (TRUE), (FALSE), (NULL);

-- In SQLite: TRUE=1 , FALSE=0

SELECT value, NOT value FROM bool;
/*
| value | NOT value |
|-------|-----------|
| 1     | 0         |
| 0     | 1         |
|       |           |
*/

SELECT value, TRUE AND value, FALSE AND value, NULL AND value FROM bool;
/*
| value | TRUE AND value | FALSE AND value | NULL AND value |
|-------|----------------|-----------------|----------------|
| 1     | 1              | 0               |                |
| 0     | 0              | 0               | 0              |
|       |                | 0               |                |
*/

SELECT value, TRUE OR value, FALSE OR value, NULL OR value FROM bool;
/*
| value | TRUE OR value | FALSE OR value | NULL OR value |
|-------|---------------|----------------|---------------|
| 1     | 1             | 1              | 1             |
| 0     | 1             | 0              |               |
|       | 1             |                |               |
*/
