/*
=============================================================
CREATE TABLES: AGENTS, CALLS, AND SURVEYS
=============================================================
Purpose: 
    Initializes the database schema for Call Center Analytics.
    Drops existing tables to ensure a clean deployment.
Tables: 
    - Agents (Dimension)
    - Calls  (Fact)
    - Surveys (Dimension/Fact)
*/

USE CallCenterDB;
GO

-- =============================================================
-- 1. DROP EXISTING TABLES (Correct Dependency Order)
-- =============================================================
IF OBJECT_ID('dbo.Surveys', 'U') IS NOT NULL DROP TABLE dbo.Surveys;
IF OBJECT_ID('dbo.Calls',   'U') IS NOT NULL DROP TABLE dbo.Calls;
IF OBJECT_ID('dbo.Agents',  'U') IS NOT NULL DROP TABLE dbo.Agents;
GO

-- =============================================================
-- 2. CREATE AGENTS TABLE
-- =============================================================
CREATE TABLE Agents (
    AgentID        INT PRIMARY KEY,
    Name           VARCHAR(100),
    Queue          VARCHAR(50),
    Tenure_Months  INT,
    HourlyRate     INT
);
GO

-- =============================================================
-- 3. CREATE CALLS TABLE
-- =============================================================
CREATE TABLE Calls (
    CallID         INT PRIMARY KEY,
    AgentID        INT,
    Timestamp      DATETIME2,
    WaitTime       INT,
    TalkTime       INT,
    HoldTime       INT,
    IsResolved     INT, -- 0: No, 1: Yes
    CallReason     VARCHAR(100),
);
GO

-- =============================================================
-- 4. CREATE SURVEYS TABLE
-- =============================================================
CREATE TABLE Surveys (
    SurveyID       INT PRIMARY KEY,
    CallID         INT,
    CSAT_Score     INT,
    FeedbackText   VARCHAR(MAX),
);
GO
