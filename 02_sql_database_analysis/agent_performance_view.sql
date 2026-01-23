/* =============================================================================
VIEW: v_Agent_Performance_Report
DESCRIPTION: 
    This view generates a comprehensive agent performance leaderboard. 
    It calculates key call center KPIs including AHT, FCR, RCR, and CSAT.
    
LOGIC:
    - Normalizes AHT from seconds to minutes.
    - Uses a 40/40/20 weighted Efficiency Score:
        * 40% First Call Resolution (FCR)
        * 40% Normalized CSAT Score 
        * 20% Speed Factor (Agent AHT compared to the Category Average)
    - Caps the final Efficiency Score at 100.00.
    - Groups data by Agent and Call Reason for granular analysis.
=============================================================================
*/

IF OBJECT_ID('v_Agent_Performance_Report', 'V') IS NOT NULL
    DROP VIEW v_Agent_Performance_Report;
GO

CREATE VIEW v_Agent_Performance_Report AS

WITH Raw_Metrics AS (
    -- STEP 1: Aggregate raw call data into foundational metrics per Agent/Reason
    -- This eliminates repetition by calculating the sums and averages once.
    SELECT 
        a.AgentID,
        a.Name,
        a.Queue,
        c.CallReason,
        a.Tenure_Months,
        a.HourlyRate,
        COUNT(c.CallID) AS Total_Calls,
        
        -- Calculate FCR as a float to prevent integer division issues
        AVG(CAST(c.IsResolved AS FLOAT)) * 100 AS FCR_Raw,
        
        -- Average CSAT (ignoring NULLs where no survey exists)
        AVG(CAST(s.CSAT_Score AS FLOAT)) AS CSAT_Raw,
        
        -- Weighted AHT Calculation: (Total Talk + Total Hold) / Volume of calls / 60 seconds
        (SUM(CAST(c.TalkTime AS FLOAT) + CAST(c.HoldTime AS FLOAT)) / NULLIF(COUNT(c.CallID), 0)) / 60.0 AS AHT_Mins_Raw

    FROM [CallCenterDB].[dbo].[Agents] a
    JOIN [CallCenterDB].[dbo].[Calls] c ON a.AgentID = c.AgentID
    LEFT JOIN [CallCenterDB].[dbo].[Surveys] s ON c.CallID = s.CallID
    GROUP BY a.AgentID, a.Name, a.Queue, c.CallReason, a.Tenure_Months, a.HourlyRate
),

Benchmark_Layer AS (
    -- STEP 2: Calculate the Global Benchmark for Speed Factor
    -- Using a Window Function to find the Average AHT by the call reason category
    SELECT 
        *,
        AVG(AHT_Mins_Raw) OVER(PARTITION BY CallReason) AS Category_Avg_AHT
    FROM Raw_Metrics
)

-- STEP 3: Final Calculation, Binning, and Capping logic
-- Using the CTEs above to keep the Efficiency Score formula readable.
SELECT 
    AgentID,
    Name,
    Queue,
    CallReason,
    Total_Calls,
    
    -- Experience Binning Logic
    CASE
        WHEN Tenure_Months <= 3 THEN 'Nesting'
        WHEN Tenure_Months <= 12 THEN 'Developing'
        WHEN Tenure_Months <= 24 THEN 'Proficient'
        ELSE 'Veteran' 
    END AS Experience_Level,

    -- Pay Tier Logic
    CASE 
        WHEN HourlyRate BETWEEN 18 AND 21 THEN 'Tier 1'
        WHEN HourlyRate BETWEEN 22 AND 25 THEN 'Tier 2'
        WHEN HourlyRate BETWEEN 26 AND 28 THEN 'Tier 3'
        ELSE 'Tier 4'
    END AS Pay_Tier,

    -- Final Metric Formatting
    CAST(AHT_Mins_Raw AS DECIMAL(10,2)) AS Agent_AHT,
    CAST(FCR_Raw AS DECIMAL(10,2)) AS Agent_FCR,
    CAST(100 - FCR_Raw AS DECIMAL(10,2)) AS Agent_RCR, -- Repeat Call Rate (inverse of FCR)
    CAST(CSAT_Raw AS DECIMAL(10,2)) AS Agent_Avg_CSAT,

    -- STEP 4: The Weighted Efficiency Score
    -- Logic: (FCR * 0.4) + (Normalized CSAT * 0.4) + (Speed Factor * 0.2)
    CAST(
        CASE 
            WHEN (FCR_Raw * 0.4) + ((CSAT_Raw / 5.0) * 40.0) + ((Category_Avg_AHT / NULLIF(AHT_Mins_Raw, 0)) * 20.0) > 100 
            THEN 100 
            ELSE (FCR_Raw * 0.4) + ((CSAT_Raw / 5.0) * 40.0) + ((Category_Avg_AHT / NULLIF(AHT_Mins_Raw, 0)) * 20.0)
        END 
    AS DECIMAL(10,2)) AS Final_Efficiency_Score

FROM Benchmark_Layer;
GO
