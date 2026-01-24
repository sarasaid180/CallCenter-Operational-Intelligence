
--===========================================================================
-- Quality Checks : Agents Table
--===========================================================================

-- 1. Checking for duplicate or null values in the AgentID coulmn
SELECT AgentID FROM CallCenterDB.dbo.Agents
GROUP BY AgentID 
HAVING COUNT(1) > 1 OR AgentID IS NULL

-- 2. Checking for unwanted spaces in the name and queue columns
SELECT Name, Queue 
FROM CallCenterDB.dbo.Agents
WHERE  Name != TRIM(Name) OR  Queue != TRIM(Queue)

-- 3. Checking the unique values in the queue column
SELECT DISTINCT Queue FROM CallCenterDB.dbo.Agents
  

--===========================================================================
-- Quality Checks : Calls Table
--===========================================================================

-- 1. Checking for duplicate or null values in the CallID column
SELECT CallID FROM CallCenterDB.dbo.Calls
GROUP BY CallID 
HAVING COUNT(1) > 1 OR CallID IS NULL;

-- 2. Checking for logical errors in TalkTime or HoldTime (should not be negative)
SELECT CallID, TalkTime, HoldTime
FROM CallCenterDB.dbo.Calls
WHERE TalkTime < 0 OR HoldTime < 0;

-- 3. Checking for unwanted spaces 
SELECT DISTINCT CallReason 
FROM CallCenterDB.dbo.Calls
WHERE CallReason != TRIM(CallReason);

-- 4. Checking for "Ghost" Agents (Calls assigned to an AgentID that doesn't exist in Agents table)
-- This is a Referential Integrity check.
SELECT DISTINCT c.AgentID
FROM CallCenterDB.dbo.Calls c
LEFT JOIN CallCenterDB.dbo.Agents a ON c.AgentID = a.AgentID
WHERE a.AgentID IS NULL;

-- 5. Checking IsResolved values (Should only be 0 or 1)
SELECT DISTINCT IsResolved 
FROM CallCenterDB.dbo.Calls;

--===========================================================================
-- Quality Checks : Surveys Table
--===========================================================================

-- 1. Checking for duplicate CallIDs (One call should not have two survey results)
SELECT CallID FROM CallCenterDB.dbo.Surveys
GROUP BY CallID 
HAVING COUNT(1) > 1;

-- 2. Validating the CSAT_Score range (Should be 1 to 5)
-- If a 0 or a 6, is found it will mess up the 40/40/20 weighted score.
SELECT DISTINCT CSAT_Score 
FROM CallCenterDB.dbo.Surveys
WHERE CSAT_Score < 1 OR CSAT_Score > 5;

-- 3. Checking for Surveys without a matching CallID in the Calls table
SELECT s.CallID
FROM CallCenterDB.dbo.Surveys s
LEFT JOIN CallCenterDB.dbo.Calls c ON s.CallID = c.CallID
WHERE c.CallID IS NULL;

