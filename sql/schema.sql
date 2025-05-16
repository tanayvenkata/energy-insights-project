CREATE TABLE IF NOT EXISTS annual_petrol_production (
    country TEXT,
    year INTEGER,
    value REAL
);

CREATE TABLE IF NOT EXISTS electricity_gen_fossil (
    country TEXT,
    year INTEGER,
    value REAL
);

CREATE TABLE IF NOT EXISTS electricity_gen_nuclear (
    country TEXT,
    year INTEGER,
    value REAL
);

CREATE TABLE IF NOT EXISTS electricity_gen_renewables (
    country TEXT,
    year INTEGER,
    value REAL
);

CREATE TABLE IF NOT EXISTS electricity_gen_total (
    country TEXT,
    year INTEGER,
    value REAL
);

CREATE TABLE IF NOT EXISTS natural_gas_exports (
    country TEXT,
    year INTEGER,
    value REAL
);

CREATE TABLE IF NOT EXISTS natural_gas_imports (
    country TEXT,
    year INTEGER,
    value REAL
);

CREATE TABLE IF NOT EXISTS net_imports_electricity (
    country TEXT,
    year INTEGER,
    value REAL
);

CREATE TABLE IF NOT EXISTS total_energy_consumption (
    country TEXT,
    year INTEGER,
    value REAL
);

CREATE TABLE IF NOT EXISTS total_energy_production (
    country TEXT,
    year INTEGER,
    value REAL
);

CREATE TABLE IF NOT EXISTS world_emissions (
    country TEXT,
    year INTEGER,
    value REAL
);