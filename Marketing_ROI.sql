USE Projects_Datasets;

Select count(*) from marketing ---- Count original table

DROP TABLE IF EXISTS #Marketing_Clean;
SELECT * INTO #Marketing_Clean FROM marketing; ----Insert the original data into a temp table


/*---------------------------------------------------------------------------------------
Remove Duplicates (Actually Delete Them) Keep the most complete record (highest revenue)
---------------------------------------------------------------------------------------*/
SELECT count(*) as [Count Before Removing Duplicates] from #Marketing_Clean;  ---- Count before Cleaning
WITH dedup AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY campaign_id,campaign_name, campaign_date 
    ORDER BY revenue_generated DESC, ad_spend DESC) AS rn
    ---- Row number to identify campaings with the same ID, name and date. order by their revenue and ad_spend
    FROM #Marketing_Clean
)
DELETE FROM dedup
WHERE rn > 1; 
---- For this data none of the rows meet the condition so the count of rows stays the same

SELECT count(*) as [Count After Removing Duplicates] from #Marketing_Clean  
Select * from #Marketing_Clean


/*---------------------------------------------------------------------------------------
Standardize Text Fields (All Columns)
---------------------------------------------------------------------------------------*/

UPDATE #Marketing_Clean
SET 
    campaign_name = UPPER(TRIM(campaign_name)),
    channel       = UPPER(TRIM(channel)),
    campaign_date = Cast(campaign_date as Date),
    region        = UPPER(TRIM(region));


/*---------------------------------------------------------------------------------------
Fix Inconsistent Channel Names
---------------------------------------------------------------------------------------*/

UPDATE #Marketing_Clean
SET channel =
    CASE
        WHEN channel LIKE '%AFFILIATE%' THEN 'AFFILIATE'
        WHEN channel LIKE '%EMAIL%' THEN 'EMAIL'
        WHEN channel LIKE '%FACEBOOK%' THEN 'FACEBOOK'
        WHEN channel LIKE '%GOOGLE%' THEN 'GOOGLE'
        WHEN channel LIKE '%INSTAGRAM%' THEN 'INSTAGRAM'
        WHEN channel LIKE '%LINKEDIN%' THEN 'LINKEDIN'
        WHEN channel LIKE '%TIKTOK%' THEN 'TIKTOK'
        WHEN channel LIKE '%YOUTUBE%' THEN 'YOUTUBE'             
        ELSE 'OTHER'
    END;

/*---------------------------------------------------------------------------------------
Handling NULLs, Remove incomplete rows
---------------------------------------------------------------------------------------*/

DELETE FROM #Marketing_Clean
WHERE ad_spend IS NULL
   OR revenue_generated IS NULL;


/*---------------------------------------------------------------------------------------
Final Clean Dataset Check
---------------------------------------------------------------------------------------*/
SELECT COUNT(*) AS total_rows FROM #Marketing_Clean;
Select *,(revenue_generated - ad_spend) as Profit from #Marketing_Clean order by campaign_date


/*---------------------------------------------------------------------------------------
Lifetime ROI
---------------------------------------------------------------------------------------*/
SELECT
    SUM(revenue_generated) AS total_revenue,
    SUM(ad_spend) AS total_spend,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI
FROM #Marketing_Clean;


/*---------------------------------------------------------------------------------------
Lifetime ROI by Campaign 
---------------------------------------------------------------------------------------*/
SELECT
    campaign_name,
    SUM(ad_spend) AS spend,
    SUM(revenue_generated) AS revenue,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI

FROM #Marketing_Clean
GROUP BY campaign_name
ORDER BY ROI DESC;

/*---------------------------------------------------------------------------------------
Lifetime ROI by region 
---------------------------------------------------------------------------------------*/
SELECT
    region,
    SUM(ad_spend) AS spend,
    SUM(revenue_generated) AS revenue,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI

FROM #Marketing_Clean
GROUP BY region
ORDER BY ROI DESC;

/*---------------------------------------------------------------------------------------
Lifetime ROI by channel 
---------------------------------------------------------------------------------------*/
SELECT
    channel,
    SUM(ad_spend) AS spend,
    SUM(revenue_generated) AS revenue,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI

FROM #Marketing_Clean
GROUP BY channel
ORDER BY ROI DESC;

/*---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
Monthly
---------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------------
Monthly ROI
---------------------------------------------------------------------------------------*/
SELECT
    cast(datetrunc(month, campaign_date) as date) campaign_date,
    SUM(revenue_generated) AS total_revenue,
    SUM(ad_spend) AS total_spend,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI
FROM #Marketing_Clean
group by cast(datetrunc(month, campaign_date) as date) 
order by cast(datetrunc(month, campaign_date) as date) asc
;


/*---------------------------------------------------------------------------------------
Monthly ROI by Campaign name
---------------------------------------------------------------------------------------*/
SELECT
    campaign_name,
    DATEADD(month, DATEDIFF(month, 0, campaign_date), 0) AS month_start_date,  -- Get the start of the month
    SUM(revenue_generated) AS total_revenue,
    SUM(ad_spend) AS total_spend,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI
FROM #Marketing_Clean
GROUP BY 
    campaign_name,
    DATEADD(month, DATEDIFF(month, 0, campaign_date), 0)  -- Group by start of the month
ORDER BY campaign_name,
    month_start_date ASC;

/*---------------------------------------------------------------------------------------
Monthly ROI by region 
---------------------------------------------------------------------------------------*/
SELECT
    region,
    DATEADD(month, DATEDIFF(month, 0, campaign_date), 0) AS month_start_date,  -- Get the start of the month
    SUM(revenue_generated) AS total_revenue,
    SUM(ad_spend) AS total_spend,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI
FROM #Marketing_Clean
GROUP BY 
    region,
    DATEADD(month, DATEDIFF(month, 0, campaign_date), 0)  -- Group by start of the month
ORDER BY region,
    month_start_date ASC;

/*---------------------------------------------------------------------------------------
Monthly ROI by channel 
---------------------------------------------------------------------------------------*/
SELECT
    channel,
    DATEADD(month, DATEDIFF(month, 0, campaign_date), 0) AS month_start_date,  -- Get the start of the month
    SUM(revenue_generated) AS total_revenue,
    SUM(ad_spend) AS total_spend,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI
FROM #Marketing_Clean
GROUP BY 
    channel,
    DATEADD(month, DATEDIFF(month, 0, campaign_date), 0)  -- Group by start of the month
ORDER BY channel,
    month_start_date ASC;




/*---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
QUARTERLY
---------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------------------
QUARTERLY Lifetime ROI
---------------------------------------------------------------------------------------*/
SELECT
    SUM(revenue_generated) AS total_revenue,
    SUM(ad_spend) AS total_spend,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI
FROM #Marketing_Clean;


/*---------------------------------------------------------------------------------------
QUARTERLY Lifetime ROI by Campaign 
---------------------------------------------------------------------------------------*/
SELECT
    campaign_name,
    DATEADD(quarter, DATEDIFF(quarter, 0, campaign_date), 0) AS quarter_start_date,  -- Get the start of the quarter
    SUM(revenue_generated) AS total_revenue,
    SUM(ad_spend) AS total_spend,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI
FROM #Marketing_Clean
GROUP BY 
    campaign_name,
    DATEADD(quarter, DATEDIFF(quarter, 0, campaign_date), 0)  -- Group by start of the quarter
ORDER BY campaign_name,
    quarter_start_date ASC;

/*---------------------------------------------------------------------------------------
QUARTERLY Lifetime ROI by region 
---------------------------------------------------------------------------------------*/
SELECT
    region,
    DATEADD(quarter, DATEDIFF(quarter, 0, campaign_date), 0) AS quarter_start_date,  -- Get the start of the quarter
    SUM(revenue_generated) AS total_revenue,
    SUM(ad_spend) AS total_spend,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI
FROM #Marketing_Clean
GROUP BY 
    region,
    DATEADD(quarter, DATEDIFF(quarter, 0, campaign_date), 0)  -- Group by start of the quarter
ORDER BY region,
    quarter_start_date ASC;

/*---------------------------------------------------------------------------------------
QUARTERLY Lifetime ROI by channel 
---------------------------------------------------------------------------------------*/
SELECT
    channel,
    DATEADD(quarter, DATEDIFF(quarter, 0, campaign_date), 0) AS quarter_start_date,  -- Get the start of the quarter
    SUM(revenue_generated) AS total_revenue,
    SUM(ad_spend) AS total_spend,
    SUM(revenue_generated) - SUM(ad_spend) AS profit,
    CASE 
        WHEN SUM(ad_spend) = 0 THEN NULL
        ELSE (SUM(revenue_generated) - SUM(ad_spend)) * 1.0 / SUM(ad_spend)
    END AS ROI
FROM #Marketing_Clean
GROUP BY 
    channel,
    DATEADD(quarter, DATEDIFF(quarter, 0, campaign_date), 0)  -- Group by start of the quarter
ORDER BY channel,
    quarter_start_date ASC;


