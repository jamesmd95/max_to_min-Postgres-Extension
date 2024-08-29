\copy test_numbers(number)
FROM '/var/lib/postgresql/dummy_data.csv'
DELIMITER ','
CSV;
