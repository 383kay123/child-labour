-- Ensure the sensitization table has the correct schema
CREATE TABLE IF NOT EXISTS sensitization_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cover_page_id INTEGER NOT NULL,
  farm_identification_id INTEGER NOT NULL,
  is_acknowledged INTEGER DEFAULT 0,
  acknowledged_at TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  is_synced INTEGER DEFAULT 0,
  sync_status INTEGER DEFAULT 0,
  FOREIGN KEY (cover_page_id) REFERENCES cover_page (id) ON DELETE CASCADE,
  FOREIGN KEY (farm_identification_id) REFERENCES combined_farmer_identification (id) ON DELETE CASCADE
);

-- Copy data from old table if it exists
INSERT OR IGNORE INTO sensitization_new
SELECT * FROM sensitization;

-- Drop old table
DROP TABLE IF EXISTS sensitization;

-- Rename new table
ALTER TABLE sensitization_new RENAME TO sensitization;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_sensitization_farm_id 
ON sensitization (farm_identification_id);
