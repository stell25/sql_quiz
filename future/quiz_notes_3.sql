/* quiz_practice_3.sql
 *
 * This quiz will test your understanding of how much disk space a row uses.
 * You will be allowed to use a computer in order to:
 * - connect to a running database
 * - reference arbitrary documentation on the internet
 *
 * For each CREATE TABLE statement:
 * reorder the columns to use the least amount of disk space.
 *
 * For each INSERT statement:
 * state the total number of bytes required to store the inserted row.
 *
 * For the actual quiz, expect 2 CREATE TABLE commands and 2 INSERT commands.
 * At least one of the tables will be taken from the pagila database.
 */

CREATE TABLE example (
    id INT8,
    a CHAR,
    b INT4,
    c INT2,
    d LINE,
    e JSONB
);


INSERT INTO example VALUES (0, 'a', 0, 0, '{1, 2, 3}', NULL);


INSERT INTO example VALUES (NULL, NULL, NULL, NULL, NULL, NULL);


INSERT INTO example VALUES (0, NULL, 0, NULL, '{1, 2, 3}', NULL);


INSERT INTO example VALUES (0, 'a', 0, NULL, '{1, 2, 3}', NULL);


INSERT INTO example VALUES (0, NULL, 0, 0, '{1, 2, 3}', NULL);


INSERT INTO example VALUES (NULL, NULL, 0, 0, '{1, 2, 3}', NULL);


INSERT INTO example VALUES (NULL, NULL, 0, 0, NULL, NULL);









CREATE TABLE network_connection (
    id BIGSERIAL PRIMARY KEY,
    source MACADDR NOT NULL,
    dest MACADDR NOT NULL,
    bytes_sent SMALLINT NOT NULL,
    starttime TIMESTAMP WITH TIME ZONE NOT NULL
);



INSERT INTO network_connection (source, dest, starttime, bytes_sent) VALUES 
    ('13:37:DE:AD:BE:EF', 'FF:FF:FF:FF:FF:FF', '2016-01-25 10:10:10.555555-05:00', 10);









CREATE TABLE event (
    id BIGSERIAL,
    name TEXT,
    public BOOLEAN,
    max_guests SMALLINT,
    location_id INTEGER NOT NULL,
    starttime timestamp with time zone NOT NULL,
    endtime timestamp with time zone,
    a INT,
    b INT,
    c INT,
    d INT,
    e INT,
    f INT,
    g INT,
    h INT
);
 

INSERT INTO event (location_id, starttime) VALUES (0, '2016-01-25 10:10:10.555555-05:00');


INSERT INTO event (location_id, starttime, max_guests) VALUES (0, '2016-01-25 10:10:10.555555-05:00', 10);


INSERT INTO event (location_id, starttime, h) VALUES (0, '2016-01-25 10:10:10.555555-05:00', 1);
