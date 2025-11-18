-- Create a trigger to prevent NULL values in farm_identification_id
CREATE TRIGGER IF NOT EXISTS prevent_null_farm_id
BEFORE INSERT ON sensitization
BEGIN
    SELECT CASE
        WHEN NEW.farm_identification_id IS NULL THEN
            RAISE(ABORT, 'farm_identification_id cannot be NULL')
    END;
END;

-- Create a similar trigger for updates
CREATE TRIGGER IF NOT EXISTS prevent_null_farm_id_update
BEFORE UPDATE OF farm_identification_id ON sensitization
BEGIN
    SELECT CASE
        WHEN NEW.farm_identification_id IS NULL THEN
            RAISE(ABORT, 'farm_identification_id cannot be NULL')
    END;
END;
