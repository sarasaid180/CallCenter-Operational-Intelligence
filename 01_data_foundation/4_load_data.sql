/*
=============================================================
Load Data: Agents, Calls, and Surveys
=============================================================
Script Purpose:
    This script truncates existing data and reloads it from CSV files.
    It follows the correct dependency order to avoid FK errors.
*/

USE CallCenterDB;
GO

-- =============================================================
-- 1. CLEAN EXISTING DATA (Bottom-to-Top Order)
-- =============================================================
PRINT '>> Cleaning existing data...';
TRUNCATE TABLE dbo.Surveys;
TRUNCATE TABLE dbo.Calls;
DELETE FROM dbo.Agents; -- Using DELETE because TRUNCATE is blocked by FK
GO

-- =============================================================
-- 2. INSERT AGENTS DATA 
-- =============================================================
PRINT '>> Inserting Data Into: dbo.Agents';
BULK INSERT dbo.Agents
FROM 'D:\Programs\pycharm\PythonProject\agents_data.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);
GO

-- =============================================================
-- 3. INSERT CALLS DATA
-- =============================================================
PRINT '>> Inserting Data Into: dbo.Calls';
BULK INSERT dbo.Calls
FROM 'D:\Programs\pycharm\PythonProject\calls_data.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);
GO

-- =============================================================
-- 4. INSERT SURVEYS DATA
-- =============================================================
PRINT '>> Inserting Data Into: dbo.Surveys';
BULK INSERT dbo.Surveys
FROM 'D:\Programs\pycharm\PythonProject\surveys_data.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);
GO

PRINT '>> Data Load Complete!';

