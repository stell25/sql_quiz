/* quiz_3.sql
 *
 * You are allowed to use a computer in order to:
 * - connect to a running database and run arbitrary commands
 * - reference arbitrary documentation on the internet
 *
 * For each CREATE TABLE statement:
 * reorder the columns to use the least amount of disk space.
 *
 * For each INSERT statement:
 * state the total number of bytes required to store the inserted row.
 */


CREATE TABLE category (
    category_id integer NOT NULL,
    name text NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE foo (
    a BIGSERIAL,
    b TEXT,
    c BOOLEAN,
    d SMALLINT NOT NULL,
    e timestamp NOT NULL,
    f date
);

INSERT INTO foo (d,e) VALUES (2, '2016-01-25 10:10:10.555555-05:00');

INSERT INTO foo VALUES
    ( 1
    , NULL
    , NULL
    , 0
    , '2016-01-25 10:10:10.555555-05:00'
    , '2016-01-25'
    );
