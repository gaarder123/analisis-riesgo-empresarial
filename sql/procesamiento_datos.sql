/* =========================================
   1. ELIMINAR TABLA SI EXISTE
========================================= */
DROP TABLE IF EXISTS financiamiento_2024_rev_rest;
GO


/* =========================================
   2. CREAR TABLA
========================================= */
CREATE TABLE financiamiento_2024_rev_rest (
    id_anonimo_emp NVARCHAR(100),
    tamano NVARCHAR(50),
    ciiu NVARCHAR(10),
    desc_ciiu NVARCHAR(MAX),
    sector NVARCHAR(100),
    ubigeo NVARCHAR(10),
    departamento NVARCHAR(100),
    provincia NVARCHAR(150),
    distrito NVARCHAR(150),
    contribuyente NVARCHAR(MAX),
    nrotrab INT,
    saldo_miles_soles DECIMAL(18,2),
    exporta NVARCHAR(10),
    ventas_prom DECIMAL(18,2),
    Año NVARCHAR(10),
    fec_creacion NVARCHAR(20)
);
GO


/* =========================================
   3. CARGA DE DATOS
========================================= */
BULK INSERT financiamiento_2024_rev_rest
FROM ''
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);
GO


/* =========================================
   4. VALIDACIÓN INICIAL
========================================= */
SELECT COUNT(*) AS total_registros FROM financiamiento_2024_rev_rest;
SELECT TOP 10 * FROM financiamiento_2024_rev_rest;
GO


/* =========================================
   5. LIMPIEZA DE DATOS

========================================= */

-- 🔹 Limpiar fecha
UPDATE financiamiento_2024_rev_rest
SET fec_creacion = LTRIM(RTRIM(REPLACE(fec_creacion, ';', '')));

-- 🔹 Crear y convertir fecha
ALTER TABLE financiamiento_2024_rev_rest
ADD fecha_creacion_date DATE;

UPDATE financiamiento_2024_rev_rest
SET fecha_creacion_date = TRY_CONVERT(DATE, fec_creacion, 112);

-- 🔹 Eliminar columna original
ALTER TABLE financiamiento_2024_rev_rest
DROP COLUMN fec_creacion;

-- 🔹 Limpiar columna año
UPDATE financiamiento_2024_rev_rest
SET Año = LTRIM(RTRIM(Año));


/* =========================================
   6. ESTANDARIZACIÓN DE DATOS
========================================= */

UPDATE financiamiento_2024_rev_rest
SET 
    tamano = UPPER(LTRIM(RTRIM(tamano))),
    sector = UPPER(LTRIM(RTRIM(sector))),
    departamento = UPPER(LTRIM(RTRIM(departamento))),
    provincia = UPPER(LTRIM(RTRIM(provincia))),
    distrito = UPPER(LTRIM(RTRIM(distrito))),
    contribuyente = UPPER(LTRIM(RTRIM(contribuyente)));


/* =========================================
   7. VALIDACIONES
========================================= */

-- Duplicados
SELECT id_anonimo_emp, COUNT(*) AS veces
FROM financiamiento_2024_rev_rest
GROUP BY id_anonimo_emp
HAVING COUNT(*) > 1;

-- IDs inválidos
SELECT *
FROM financiamiento_2024_rev_rest
WHERE id_anonimo_emp IS NULL OR id_anonimo_emp = '';

-- Valores negativos
SELECT *
FROM financiamiento_2024_rev_rest
WHERE ventas_prom < 0 OR saldo_miles_soles < 0;

-- Nulos críticos
SELECT *
FROM financiamiento_2024_rev_rest
WHERE ventas_prom IS NULL OR saldo_miles_soles IS NULL;

-- Nulos en segmentación
SELECT *
FROM financiamiento_2024_rev_rest
WHERE sector IS NULL OR sector = '';

SELECT *
FROM financiamiento_2024_rev_rest
WHERE departamento IS NULL OR departamento = '';


/* =========================================
   8. ELIMINACIÓN DE DATOS PROBLEMÁTICOS
========================================= */

-- Eliminar registros sin ID, sector o departamento
DELETE FROM financiamiento_2024_rev_rest
WHERE id_anonimo_emp IS NULL OR id_anonimo_emp = ''
   OR sector IS NULL OR sector = ''
   OR departamento IS NULL OR departamento = '';

-- Eliminar nulos en variables clave
DELETE FROM financiamiento_2024_rev_rest
WHERE ventas_prom IS NULL OR saldo_miles_soles IS NULL;

-- Eliminar valores negativos
DELETE FROM financiamiento_2024_rev_rest
WHERE ventas_prom < 0 OR saldo_miles_soles < 0;


/* =========================================
   9. VALIDACIÓN FINAL
========================================= */

SELECT COUNT(*) AS total_limpio
FROM financiamiento_2024_rev_rest;

SELECT TOP 10 *
FROM financiamiento_2024_rev_rest;


/* =========================================
   10. EDA – ANÁLISIS EXPLORATORIO
========================================= */

-- 🔹 10.1 Distribución por tamaño de empresa
SELECT  
    tamano,
    COUNT(*) AS total_empresas,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS porcentaje
FROM financiamiento_2024_rev_rest
GROUP BY tamano
ORDER BY total_empresas DESC;


-- 🔹 10.2 Top sectores por número de empresas y deuda
SELECT TOP 5 
    sector,
    COUNT(*) AS total_empresas,
    SUM(saldo_miles_soles * 1000.0) AS deuda_total,
    AVG(saldo_miles_soles * 1000.0) AS deuda_promedio
FROM financiamiento_2024_rev_rest
GROUP BY sector
ORDER BY total_empresas DESC;


-- 🔹 10.3 Ratio deuda / ventas por tamaño (agregado)
SELECT 
    tamano,
    SUM(saldo_miles_soles * 1000.0) / NULLIF(SUM(ventas_prom), 0) AS ratio_deuda
FROM financiamiento_2024_rev_rest
GROUP BY tamano
ORDER BY ratio_deuda DESC;


-- 🔹 10.4 Análisis geográfico (por departamento)
SELECT 
    departamento,
    COUNT(*) AS total_empresas,
    AVG(saldo_miles_soles) AS deuda_promedio
FROM financiamiento_2024_rev_rest
GROUP BY departamento
ORDER BY deuda_promedio DESC;


-- 🔹 10.5 Clasificación de riesgo (semáforo)
SELECT *,
    CASE
        WHEN ventas_prom IS NULL OR ventas_prom = 0 THEN 'SIN INFORMACION'
        WHEN (saldo_miles_soles * 1000.0) / ventas_prom > 1 THEN 'ALTO RIESGO'
        WHEN (saldo_miles_soles * 1000.0) / ventas_prom BETWEEN 0.5 AND 1 THEN 'RIESGO MODERADO'
        ELSE 'BAJO RIESGO'
    END AS semaforo_riesgo
FROM financiamiento_2024_rev_rest;
