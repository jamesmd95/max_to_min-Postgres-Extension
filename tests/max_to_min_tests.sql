-- Load pgTAP extension
CREATE EXTENSION IF NOT EXISTS pgtap;
-- Load max to min extension; 
CREATE EXTENSION max_to_min;
-- We have 6 tests
SELECT plan(6);

-- Test 1: integer values using default separator
BEGIN;

DROP TABLE IF EXISTS test_result;
CREATE TEMPORARY TABLE test_result AS
SELECT max_to_min(max_min_agg(val)) AS result
FROM (VALUES (5), (3), (6), (7), (9), (10), (7)) AS t(val);
SELECT is((SELECT result FROM test_result), '10 -> 3', 'Test max_to_min with integer values using default separator');

COMMIT;

-- Test 2: integer values using custom separator
BEGIN;

DROP TABLE IF EXISTS test_result;
CREATE TEMPORARY TABLE test_result AS
SELECT max_to_min(max_min_agg(val), ' to ') AS result
FROM (VALUES (5), (3), (6), (7), (9), (10), (7)) AS t(val);
SELECT is((SELECT result FROM test_result), '10 to 3', 'Test max_to_min with integer values using custom separator');

COMMIT;

-- Test 3: numeric values using default separator
BEGIN;

DROP TABLE IF EXISTS test_result;
CREATE TEMPORARY TABLE test_result AS
SELECT max_to_min(max_min_agg(val::numeric)) AS result
FROM (VALUES (5.5), (3.2), (6.6), (7.1), (9.9), (10.0), (7.7)) AS t(val);
SELECT is((SELECT result FROM test_result), '10.0 -> 3.2', 'Test max_to_min with numeric values using default separator');

COMMIT;

-- Test 4: numeric values using custom separator
BEGIN;

DROP TABLE IF EXISTS test_result;
CREATE TEMPORARY TABLE test_result AS
SELECT max_to_min(max_min_agg(val::numeric), ' to ') AS result
FROM (VALUES (5.5), (3.2), (6.6), (7.1), (9.9), (10.0), (7.7)) AS t(val);
SELECT is((SELECT result FROM test_result), '10.0 to 3.2', 'Test max_to_min with numeric values using custom separator');

COMMIT;

-- Test 5: text values using default separator
BEGIN;

DROP TABLE IF EXISTS test_result;
CREATE TEMPORARY TABLE test_result AS
SELECT max_to_min(max_min_agg(val)) AS result
FROM (VALUES ('apple'), ('banana'), ('cherry'), ('date')) AS t(val);
SELECT is((SELECT result FROM test_result), 'date -> apple', 'Test max_to_min with text values using default separator');

COMMIT;

-- Test 6: text values using custom separator
BEGIN;

DROP TABLE IF EXISTS test_result;
CREATE TEMPORARY TABLE test_result AS
SELECT max_to_min(max_min_agg(val), ', ') AS result
FROM (VALUES ('apple'), ('banana'), ('cherry'), ('date')) AS t(val);
SELECT is((SELECT result FROM test_result), 'date, apple', 'Test max_to_min with text values using custom separator');

COMMIT;

-- We're done! 
SELECT * FROM finish();
