# Config
EXTENSION_NAME = max_to_min
DB_NAME = testdb
DB_USER = postgres
TEST_SCRIPT = max_to_min_tests.sql
SQL_DIR = /usr/share/postgresql/15/extension
EXTENSION_SQL = sql/$(EXTENSION_NAME)--1.0.sql
CONTROL_FILE = $(EXTENSION_NAME).control

.PHONY: all
all: install

# Install the extension
.PHONY: install
install:
	@echo "Installing the extension..."
	sudo mkdir -p $(SQL_DIR)
	sudo cp $(EXTENSION_SQL) $(SQL_DIR)
	sudo cp $(CONTROL_FILE) $(SQL_DIR)
	@echo "Extension installed successfully."

# Setup test database - Not used here but good practice
.PHONY: setup
setup:
	@echo "Setting up test database..."
	sudo -i -u $(DB_USER) psql -c "DROP DATABASE IF EXISTS $(DB_NAME);"
	sudo -i -u $(DB_USER) psql -c "CREATE DATABASE $(DB_NAME);"
	sudo -i -u $(DB_USER) psql -c "DROP EXTENSION $(EXTENSION_NAME);"
	sudo -i -u $(DB_USER) psql -c "CREATE EXTENSION IF NOT EXISTS $(EXTENSION_NAME);"

# Copy test script to PostgreSQL directory - This avoids permission issues locally. Really this entire process should be dockerized
.PHONY: copy_tests
copy_tests:
	@echo "Copying test scripts to PostgreSQL directory..."
	sudo cp tests/$(TEST_SCRIPT) /var/lib/postgresql/

# Run PostgreSQL tests - Using pgtap and pgprove for this, there are other methods that may be more suitable but this is what I am used to.
.PHONY: run_tests
run_tests:
	@echo "Running tests..."
	sudo -i -u $(DB_USER) pg_prove --dbname $(DB_NAME)  /var/lib/postgresql/$(TEST_SCRIPT)

# Cleanup - Removing the test script from the postgresql directory.
.PHONY: cleanup
cleanup:
	@echo "Cleaning up test scripts..."
	sudo rm -f /var/lib/postgresql/$(TEST_SCRIPT)

.PHONY: test
test: setup copy_tests run_tests cleanup
