
## About
The Max to Min extension has been created as part of an Interview assignment. The project is designed to find an aggregate of the Maximum and Minimum numbers in a column. 

The original scope is defined as follows: 

```
Write an aggregate that returns a text formatted like:
max -> min
for an integer column, where min and max are minimum and maximum values of
that column.
For example:
SELECT max_to_min(val)
FROM (VALUES(5),(3),(6),(7),(9),(10),(7)) t(val);
max_to_min
-----------
10 -> 3
You can use any approach or language you like.
```

>Make the aggregate work for wider range of datatypes 


Just for Fun I have made the aggregate work with Integers, Numeric and text based types (Yes text based to form an aggregate alphabetically - Potentially pretty pointless :) ) 

 
> Make the output format configurable in any way 

The extension defaults to the "->" separator defined in the scope although a custom separator can be added as follows: 
```
SELECT max_to_min(max_min_agg(val), ' <Custom_Separator> ') AS result
FROM (VALUES (5), (3), (6), (7), (9), (10), (7)) AS t(val);
```   
The possibilities here are endless although using ', ' to output a CSL/CSV seems most appropriate if this needs to be used programmatically.  
>Package the aggregate into a PostgreSQL extension

Its packaged as a postgres extension although ideally it should also be packaged as a DEB or RPM package via a CI process.  
>  Add automated testing of new aggregate function to test its correct

I have created unit tests using PGTap and pg_prove. They cover all of the examples below and can be ran using `make test`. 



>  ● Add README or documentation of Which will explain how to install the function or
> the extension and how to use it


Here it is! 



## Sensible Approach
Another approach to this would be to simply use max and concat functions built into postgres but this approach is unique and more performant in some cases.
```
SELECT CONCAT(MAX(number)::text),'->',MIN(number)::text FROM test_numbers;
postgres=# SELECT CONCAT(MAX(number)::text),'->',MIN(number)::text FROM test_numbers;
 concat  | ?column? | min 
---------+----------+-----
 1000000 | ->       | 1
(1 row)

```
## How this Works

#### State Transition Functions (minmax_state_*):
These functions (minmax_state_int, minmax_state_numeric, minmax_state_text) are designed to maintain the state of the maximum and minimum values as the aggregation progresses over each row in the table. They are called for each row being processed by the aggregate function and update the current maximum and minimum values.

#### Aggregate Functions (max_min_agg):
The max_min_agg aggregate functions use the state transition functions to compute the maximum and minimum values for the specified data type (integer, numeric, text). These aggregates accumulate the state (min and max values) for all rows in a table or a specified subset of rows.

#### Formatting Function (max_to_min):
Once the max_min_agg function has processed all rows and produced the final state (an array with max and min values), the max_to_min function formats these values into a readable string format with a customizable separator. This function takes the array output from max_min_agg and converts it into a formatted text string, such as "max -> min".

## Installation 
The max_to_min extension has only been tested on Postgres 15 on Debian 11. The extension itself should run on most recent versions of Postgres however the build scripts and tests would potentially need to be updated. 

 - Git clone this repo
 - run `make install`
 - connect to postgres `sudo -u postgres psql`
 - Create the extension ``CREATE EXTENSION max_to_min;``
```
postgres=# CREATE EXTENSION max_to_min;
CREATE EXTENSION
```
### Usage Examples for `max_to_min` Function

#### Example 1: Integer Values Using Default Separator

```sql
SELECT max_to_min(max_min_agg(val)) AS result
FROM (VALUES (5), (3), (6), (7), (9), (10), (7)) AS t(val);
```

**Expected Output:**
```
 result  
---------
 10 -> 3
```

#### Example 2: Integer Values Using Custom Separator

```sql
SELECT max_to_min(max_min_agg(val), ' to ') AS result
FROM (VALUES (5), (3), (6), (7), (9), (10), (7)) AS t(val);
```

**Expected Output:**
```
 result  
---------
 10 to 3
```

#### Example 3: Numeric Values Using Default Separator

```sql
SELECT max_to_min(max_min_agg(val::numeric)) AS result
FROM (VALUES (5.5), (3.2), (6.6), (7.1), (9.9), (10.0), (7.7)) AS t(val);
```

**Expected Output:**
```
   result   
------------
 10.0 -> 3.2
```

#### Example 4: Numeric Values Using Custom Separator

```sql
SELECT max_to_min(max_min_agg(val::numeric), ' to ') AS result
FROM (VALUES (5.5), (3.2), (6.6), (7.1), (9.9), (10.0), (7.7)) AS t(val);
```

**Expected Output:**
```
   result   
------------
 10.0 to 3.2
```

#### Example 5: Text Values Using Default Separator

```sql
SELECT max_to_min(max_min_agg(val)) AS result
FROM (VALUES ('apple'), ('banana'), ('cherry'), ('date')) AS t(val);
```

**Expected Output:**
```
   result   
------------
 date -> apple
```

#### Example 6: Text Values Using Custom Separator

```sql
SELECT max_to_min(max_min_agg(val), ', ') AS result
FROM (VALUES ('apple'), ('banana'), ('cherry'), ('date')) AS t(val);
```

**Expected Output:**
```
   result   
------------
 date, apple
```

These examples show how to use the `max_to_min` function with different data types and separators directly in SQL queries.


### Testing The Extension ###
The Extension comes with unit tests for each of the examples above. Tests can be found in the tests directory and are using pgTap and ran using pg_prune. 

To tun the tests you must have the following dependencies installed: 

* postgresql-15
* postgresql-15-pgtap

To run the tests, from the extension directory run `make tests`  the output should be as follows: 
```
/var/lib/postgresql/max_to_min_tests.sql .. ok   
All tests successful.
Files=1, Tests=6,  0 wallclock secs ( 0.02 usr  0.00 sys +  0.02 cusr  0.00 csys =  0.04 CPU)
Result: PASS
Cleaning up test scripts...
sudo rm -f /var/lib/postgresql/max_to_min_tests.sql

```
Ideally this would be done as a CI pipeline on commit although I do not have this functionality on my personal gitlab. 

### Performance Testing
Whilst I have not written any performance tests for this it is important to understand how this extension will perform on larger datasets. Within the tests directory you can find directory called dummy data containing a CSV with 1 Million rows. 

I inserted this into a test table: 
```
CREATE TABLE test_numbers (
    id SERIAL PRIMARY KEY,
    number INTEGER
);

\copy test_numbers(number)
FROM '/var/lib/postgresql/dummy_data.csv'
DELIMITER ','
CSV;
```
Using this table I ran the max_to_min function on all 1 million rows on the number column: 
```
postgres=# SELECT max_to_min(max_min_agg(number)) AS result
FROM test_numbers;
 1000000 -> 1

Time: 742.001 ms
```

This completed subsecond on an average spec'd laptop although I expect some performance improvements could be had through optimization of the extension and/or by indexing the table correctly. 

### Considerations and Improvements
#### Additional Functionality
The extension does not allow any sort of filtering, this could be easily added to allow getting aggregates for specific ranges of data. e.g.: 

```
postgres=# SELECT max_to_min(max_min_agg(number)) AS result
FROM test_numbers WHERE date > "2024-01-10 00:00:00"
```
I did not add this as it was not part of the spec. 

#### Packaging
Ideally the extension should be packaged. Depending on the distribution I'd recommend a DEB package or an RPM. This could be setup to ensure any dependencies are installed and the package should be built as part of a CI pipeline. 

#### CI/CD
A CI Pipeline could easily be created to allow the extension to be tested, packaged and released.
