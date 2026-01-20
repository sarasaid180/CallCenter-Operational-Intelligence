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
-- 2. INSERT AGENTS DATA 
-- =============================================================
TRUNCATE TABLE dbo.Agents;

PRINT '>> Inserting Data Into: dbo.Agents';
BULK INSERT dbo.Agents
FROM 'D:\My Projects\SQL Projects\call_centerDB\agents_data.csv'
With(
	 FIRSTROW = 2,
	 FIELDTERMINATOR = ',',
	 ROWTERMINATOR = '\n',
	 TABLOCK
);
GO



-- =============================================================
-- 3. INSERT CALLS DATA
-- =============================================================
TRUNCATE TABLE dbo.Calls;

PRINT '>> Inserting Data Into: dbo.Calls';
BULK INSERT dbo.Calls
FROM 'D:\My Projects\SQL Projects\call_centerDB\calls_data.csv'
With(
	 FIRSTROW = 2,
	 FIELDTERMINATOR = ',',
	 ROWTERMINATOR = '\n',
	 TABLOCK
);
GO

-- =============================================================
-- 4. INSERT SURVEYS DATA
-- =============================================================
TRUNCATE TABLE dbo.Surveys;

PRINT '>> Inserting Data Into: dbo.Surveys';
BULK INSERT dbo.Surveys
FROM 'D:\My Projects\SQL Projects\call_centerDB\surveys_data.csv'
With(
	 FIRSTROW = 2,
	 FIELDTERMINATOR = ',',
	 ROWTERMINATOR = '\n',
	 TABLOCK
);
GO

PRINT '>> Data Load Complete!';

--SELECT * FROM CallCenterDB.dbo.Surveys
