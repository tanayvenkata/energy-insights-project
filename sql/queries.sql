-- One
/* Energy Independence Metric
 * Tables: total_energy_production, energy_balance (temp)
 */

WITH energy_balance AS (
    SELECT 
        p.country,
        p.year,
        p.value AS production,
        c.value AS consumption,
        (p.value - c.value) AS net_energy,
        (p.value / NULLIF(c.value, 0)) AS independence_ratio
    FROM 
        total_energy_production p
    JOIN 
        total_energy_consumption c 
        ON p.country = c.country AND p.year = c.year
)
SELECT 
    country,
    year,
    net_energy,
    independence_ratio,
    CASE
        WHEN independence_ratio >= 1.2 THEN 'Major Exporter'
        WHEN independence_ratio BETWEEN 1.0 AND 1.2 THEN 'Self-Sufficient'
        WHEN independence_ratio BETWEEN 0.8 AND 1.0 THEN 'Minor Importer'
        ELSE 'Dependent Importer'
    END AS energy_status
FROM 
    energy_balance
WHERE 
    year BETWEEN 2010 AND 2023
ORDER BY 
    country, year;

-- Two
/* Energy Transition Speed by Country (Fossils --> Renewables)
 * Tables: electricity_gen_renewables, electricity_gen_fossil, yearly_ratio (temp)
 */

WITH yearly_ratio AS (
    SELECT
        r.country,
        r.year,
        r.value AS renewable_gen,
        f.value AS fossil_gen,
        r.value / NULLIF((r.value + f.value), 0) AS renewable_ratio
    FROM
        electricity_gen_renewables r
    JOIN
        electricity_gen_fossil f ON r.country = f.country AND r.year = f.year
)
SELECT
    yr1.country,
    yr1.year AS start_year,
    yr2.year AS end_year,
    yr1.renewable_ratio AS start_ratio,
    yr2.renewable_ratio AS end_ratio,
    (yr2.renewable_ratio - yr1.renewable_ratio) AS ratio_change,
    (yr2.renewable_ratio - yr1.renewable_ratio) / (yr2.year - yr1.year) AS yearly_transition_rate
FROM
    yearly_ratio yr1
JOIN
    yearly_ratio yr2 ON yr1.country = yr2.country AND yr1.year < yr2.year
WHERE
    yr1.year = 2010 AND yr2.year = 2023
ORDER BY
    yearly_transition_rate DESC;

-- Three
/* Emissions Efficiency of Energy Production
 * Tables: world_emissions, total_energy_production, emissions_vs_production (temp)
 */

WITH emissions_vs_production AS (
    SELECT
        e.country,
        e.year, 
        e.value AS emissions, 
        p.value AS total_energy_production, 
        e.value / NULLIF(p.value, 0) AS emissions_per_unit_energy
    FROM
        world_emissions e
    JOIN
    	total_energy_production p ON e.country = p.country AND e.year = p.year
    WHERE
        e.year BETWEEN 2010 AND 2023
)
SELECT 
	country,
    year, 
    emissions_per_unit_energy,
        RANK () OVER (PARTITION BY year ORDER BY emissions_per_unit_energy) rank_in_year
    FROM
        emissions_vs_production
    WHERE
        total_energy_production > 0
        AND emissions > 0
    ORDER BY
    	year, emissions_per_unit_energy DESC
    	
    	
-- Four
/* Energy Mix Diversity Index
 * Tables: electricity_gen_fossil, electricity_gen_renewables, electricity_gen_nuclear, energy_sources (temp)
 */

WITH energy_sources AS (
    SELECT
        f.country,
        f.year,
        f.value AS fossil,
        r.value AS renewable,
        n.value AS nuclear
    FROM
        electricity_gen_fossil f
    JOIN
        electricity_gen_renewables r ON f.country = r.country AND f.year = r.year
    LEFT JOIN
        electricity_gen_nuclear n ON f.country = n.country AND f.year = r.year
)
SELECT
    country,
    year,
    fossil,
    renewable,
    COALESCE(nuclear, 0) AS nuclear,
    (fossil + renewable + COALESCE(nuclear, 0)) AS total,
    fossil / (fossil + renewable + COALESCE(nuclear, 0)) AS fossil_share,
    renewable / (fossil + renewable + COALESCE(nuclear, 0)) AS renewable_share,
    COALESCE(nuclear, 0) / (fossil + renewable + COALESCE(nuclear, 0)) AS nuclear_share,
    -- Shannon diversity index calculation
    -1 * (
        (fossil / (fossil + renewable + COALESCE(nuclear, 0))) * LN(fossil / (fossil + renewable + COALESCE(nuclear, 0))) +
        (renewable / (fossil + renewable + COALESCE(nuclear, 0))) * LN(renewable / (fossil + renewable + COALESCE(nuclear, 0))) +
        CASE 
            WHEN nuclear > 0 THEN (nuclear / (fossil + renewable + nuclear)) * LN(nuclear / (fossil + renewable + nuclear))
            ELSE 0
        END
    ) AS diversity_index
FROM
    energy_sources
WHERE
    year IN (2010, 2015, 2020, 2023)
ORDER BY
    year, diversity_index DESC;