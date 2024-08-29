
-- the max and min for integer type
CREATE OR REPLACE FUNCTION minmax_state_int(state integer[], value integer)
RETURNS integer[] AS $$
BEGIN
    -- Initialize state if it's the first call
    IF state IS NULL OR array_length(state, 1) IS NULL THEN
        RETURN ARRAY[value, value]; -- Initialize with max = value, min = value
    END IF;

    -- Update max
    IF value IS DISTINCT FROM NULL AND value > state[1] THEN
        state[1] := value; -- Update max
    END IF;

    -- Update min
    IF value IS DISTINCT FROM NULL AND value < state[2] THEN
        state[2] := value; -- Update min
    END IF;

    RETURN state;
END;
$$ LANGUAGE plpgsql;

-- the max and min for numeric type
CREATE OR REPLACE FUNCTION minmax_state_numeric(state numeric[], value numeric)
RETURNS numeric[] AS $$
BEGIN
    -- Initialize state
    IF state IS NULL OR array_length(state, 1) IS NULL THEN
        RETURN ARRAY[value, value]; 
    END IF;

    -- Update max
    IF value IS DISTINCT FROM NULL AND value > state[1] THEN
        state[1] := value; 
    END IF;

    -- Update min
    IF value IS DISTINCT FROM NULL AND value < state[2] THEN
        state[2] := value; -- Update min
    END IF;

    RETURN state;
END;
$$ LANGUAGE plpgsql;

-- text type max/min
CREATE OR REPLACE FUNCTION minmax_state_text(state text[], value text)
RETURNS text[] AS $$
BEGIN
    IF state IS NULL OR array_length(state, 1) IS NULL THEN
        RETURN ARRAY[value, value]; -- Initialize with max = value, min = value
    END IF;

    -- Update max (alphabetical order)
    IF value IS DISTINCT FROM NULL AND value > state[1] THEN
        state[1] := value; -- Update max
    END IF;

    -- Update min (alphabetical order)
    IF value IS DISTINCT FROM NULL AND value < state[2] THEN
        state[2] := value; -- Update min
    END IF;

    RETURN state;
END;
$$ LANGUAGE plpgsql;

--  integer type without formatting
CREATE AGGREGATE max_min_agg(integer) (
    SFUNC = minmax_state_int,
    STYPE = integer[],
    INITCOND = '{}'
);

--  numeric type without formatting
CREATE AGGREGATE max_min_agg(numeric) (
    SFUNC = minmax_state_numeric,
    STYPE = numeric[],
    INITCOND = '{}'
);

--  text type without formatting
CREATE AGGREGATE max_min_agg(text) (
    SFUNC = minmax_state_text,
    STYPE = text[],
    INITCOND = '{}'
);

-- format max and min values with a customizable separator
CREATE OR REPLACE FUNCTION max_to_min(val_array anyarray, separator text DEFAULT ' -> ')
RETURNS text AS $$
DECLARE
    max_val text;
    min_val text;
BEGIN
    -- Check if array is NULL or empty
    IF val_array IS NULL OR array_length(val_array, 1) IS NULL THEN
        RETURN NULL;
    END IF;

    -- Extract max and min values
    max_val := val_array[1]::text;
    min_val := val_array[2]::text;

    -- Format the result with the specified separator
    RETURN max_val || separator || min_val;
END;
$$ LANGUAGE plpgsql;

-- We already know what this is - Adding for best practices 
COMMENT ON EXTENSION max_to_min IS 'Extension to calculate and format max and min values for various data types.';
