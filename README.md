# IPL_-Sports_Magazine
Challenge #10: Analyse historical IPL data and provide insights on IPL 2024 for a Sports Magazine (Codebasics)
## Table of Contents:
1. [Problem Statement](https://github.com/pb319/IPL_Sports_Magazine/edit/main/README.md#problem-statement)
2. [Data Modeling](https://github.com/pb319/IPL_Sports_Magazine?tab=readme-ov-file#data-loading)
3. [Primary Data Analysis](https://github.com/pb319/IPL_Sports_Magazine/blob/main/README.md#primary-data-analysis)
## Problem Statement
**"Sports Basics"** is a sports blog company that entered space recently. They
wanted to get more traffic to their website by releasing a special edition magazine
on IPL 2024. This magazine aims to provide interesting insights and facts for
fans, analysts and teams based on the last 3 years' data.
The chief editor Tony Sharma oversees this publication, and he believes in data
analytics. He reached out to Peter Pandey, a journalist in his team who is a data-savvy cricket enthusiast.

## Data Loading
1. MySQL
- First I created a database called "ipl" using the following command

  ```CREATE DATABASE IF NOT EXISTS "ipl";```

- I used Mysql Workbench Table Data Import Wizard to import 
   - [fact_bowling_summary.csv](https://github.com/pb319/IPL_Sports_Magazine/files/14800053/fact_bowling_summary.csv)
   - [dim_match_summary.csv](https://github.com/pb319/IPL_Sports_Magazine/files/14800054/dim_match_summary.csv)
   - [dim_players.csv](https://github.com/pb319/IPL_Sports_Magazine/files/14800055/dim_players.csv)
   - [fact_bating_summary.csv](https://github.com/pb319/IPL_Sports_Magazine/files/14800056/fact_bating_summary.csv)

![01](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/2f5c505a-73e5-471b-8489-94c8c45a0b34)

Similarly, I added all other dimensions and fact tables into the Mysql Workbench:

  ![02](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/b3cd8eaf-1955-4840-88a6-707ba121d2f9)

The table names have been changed slightly using Mysql Workbench using the following bunch of code:
```
USE ipl;

ALTER TABLE dim_match_summary
RENAME TO  dim_match;

ALTER TABLE fact_bating_summary
RENAME TO  fact_bating;

ALTER TABLE fact_bowling_summary
RENAME TO  fact_bowling;
```
Connecting Mysql Database with **Power BI**:

  ![04](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/6b2ba598-1206-431c-b311-87f6a198571e)

## Data Exploration

1. Mysql

```
-- Data Exploration

	-- dim_match
		SELECT * FROM dim_match LIMIT 5; 
        DESC dim_match; 
		SELECT COUNT(match_id) as No_of_Matches,  
		COUNT(DISTINCT(team1)) as No_of_Teams, 
		COUNT(DISTINCT(RIGHT(matchDate,4))) as `Year` 
		FROM dim_match; 
        -- Therefore 10 teams participated in 206 matches

	-- dim_players
		SELECT * FROM dim_players LIMIT 5; 
        SELECT COUNT(DISTINCT(name)) as Player_Name, 
		COUNT(DISTINCT(team)) as No_of_Teams 
		FROM dim_players; 
        -- Data validation: Total Teams = 10, Total Number of Players 292

	-- fact_bating
		SELECT * FROM fact_bating LIMIT 5; 
        SELECT COUNT(DISTINCT(match_id)) as No_of_Matches, 
		COUNT(DISTINCT(batsmanName)) as Batsman_Count 
		FROM fact_bating;
        -- Data Consistency: Total Matches played  = 206, Total Number of Batsman is 262
		
	-- fact_bowling
		SELECT * FROM fact_bowling LIMIT 5; -- 5 Rows of `fact_bowling` table
		
        SELECT COUNT(DISTINCT(match_id)) as No_of_Matches, 
		COUNT(DISTINCT(bowlerName)) as Bowler_Count 
		FROM fact_bowling; 
        -- AGAIN Corraboration of Total Matches played  = 206
        -- Total Number of Bowlers 202 

```
For more detailed documentation [Click Here](https://github.com/pb319/IPL_Sports_Magazine/blob/main/Data_Exploration.sql)

## Data Cleaning
1. Mysql
  - There were some issues with "May 28-29, 2023" entry in the matchYear field while changing the datatype of matchDate column. Hence the following SQL command has been employed to manupulate the data a bit:
    ```
      set sql_safe_updates =0;
      UPDATE dim_match
      SET matchDate = 'May 29, 2023'
      WHERE matchDate = 'May 28-29, 2023';
      set sql_safe_updates =1;
    ```
1. Power BI

- "matchDate" datatype has been changed from text into Date:
   ```
    = Table.TransformColumnTypes(ipl_dim_match,{{"matchDate", type date}})
   ```
- "matchYear" column added:
   ```
   = Table.AddColumn(#"Changed Type", "matchYear", each Date.Year([matchDate]), Int64.Type)
   ```

## Primary Data Analysis:
1. Mysql
  - Top 10 batsmen based on past 3 years total runs scored
```
	-- Primary Analysis
	-- ** Caution  Edit-> Preferences-> SQL Editor -> read-timeout interval to be at least 60 seconds **

	USE ipl;  -- (ASSIGNING DEFAULT TABLE) MUST RUN CODE ELSE REST WILL NOT WORK
	SELECT  DENSE_RANK() OVER(ORDER BY SUM(runs) DESC) as Player_Rank, 
    	batsmanName as Player_Name, SUM(runs)as Total_Run 
	FROM fact_bating
	GROUP BY batsmanName 
	ORDER BY Total_Run DESC 
	LIMIT 10;     

```
- Top 10 batsmen based on past 3 years batting average. (min 60 balls faced in each season)
```
	-- [Bating Average is the total number of runs they have scored divided by the number of times they have been out]
	SELECT DENSE_RANK() OVER(ORDER BY ROUND(SUM(runs)/SUM(CASE WHEN `out/not_out` = "out" THEN 1 ELSE 0 END),2) DESC) AS Player_Rank, 
	batsmanName AS Player_Name,
	ROUND(SUM(runs)/COUNT(CASE WHEN `out/not_out` = "out" THEN 1 ELSE NULL END),2) AS Bating_Average
	FROM fact_bating F 
	INNER JOIN dim_match D  
	ON F.match_id = D.match_id 
    	WHERE batsmanName IN( 
			SELECT batsmanName
			FROM fact_bating f
			INNER JOIN dim_match d
            		ON f.match_id = d.match_id
			GROUP BY batsmanName , RIGHT(matchDate,4)
			HAVING SUM(balls)>60)
	GROUP BY batsmanName 
	ORDER BY Bating_Average DESC 
	LIMIT 10;

```

- Top 10 batsmen based on past 3 years strike rate (min 60 balls faced in each season)
```
	SELECT DENSE_RANK() OVER(ORDER BY AVG(SR) DESC)as Player_Rank, batsmanName as Player_Name,
	 ROUND(avg(SR),2) as Avg_SR 
	FROM fact_bating F 
	INNER JOIN dim_match D
	ON F.match_id = D.match_id 
    	WHERE batsmanName IN( 
			SELECT batsmanName
			FROM fact_bating f
			INNER JOIN dim_match d
           		 ON f.match_id = d.match_id
			GROUP BY batsmanName , RIGHT(matchDate,4)
            		HAVING SUM(balls)>60)
	GROUP BY batsmanName
	ORDER BY Avg_SR DESC 
	LIMIT 10;
```
- Top 10 bowlers based on past 3 years total wickets taken
```
	SELECT DENSE_RANK() OVER(ORDER BY SUM(wickets) DESC) AS Player_Rank,
    	bowlerName AS Name, 
	SUM(wickets) AS Total_Wickets 
	FROM fact_bowling F  
	INNER JOIN dim_match D
	ON F.match_id = D.match_id
	GROUP BY `Name` 
	ORDER BY Total_Wickets DESC 
	LIMIT 10;
	--  Note: 'KagisoRabada', and 'ArshdeepSingh' have the same Total_Wickets ranked at the same level
	

```
- Top 10 bowlers based on past 3 years bowling average. (min 60 balls bowled in each season)
```
	SELECT DENSE_RANK() OVER(ORDER BY (SUM(runs)/SUM(wickets)) ASC) as Player_Rank, 
	bowlerName as Player_Name,
	ROUND((SUM(runs)/SUM(wickets)),2) as Bowling_Avg 
    	FROM fact_bowling F
	INNER JOIN dim_match D
	ON F.match_id = D.match_id
    	WHERE bowlerName IN(
		SELECT bowlerName
		FROM fact_bowling F
		INNER JOIN dim_match D
		ON F.match_id = D.match_id
		GROUP BY bowlerName,RIGHT(matchDate,4)
		HAVING  SUM(overs*6) > 60 )
	GROUP BY bowlerName 
	ORDER BY Bowling_Avg ASC  
    	LIMIT 10; 	

```
- Top 10 bowlers based on past 3 years economy rate. (min 60 balls bowled in each season)
```
	SELECT  RANK() OVER(ORDER BY (ROUND(avg(economy),2)) ASC ) AS Player_Rank,
	bowlerName, ROUND(avg(economy),2) AS Avg_Economy 
	FROM fact_bowling f
	INNER JOIN dim_match d
	ON f.match_id =  d.match_id 
    	WHERE bowlerName IN (
		SELECT bowlerName
		FROM fact_bowling F
		INNER JOIN dim_match D
		ON F.match_id = D.match_id
		GROUP BY bowlerName, RIGHT(matchDate,4)
		HAVING  SUM(overs*6) > 60 )
	GROUP BY bowlerName
	ORDER BY Avg_Economy ASC
	LIMIT 10;

```
- Top 5 batsmen based on past 3 years boundary % (fours and sixes)
```
	-- Boundary %  is the percentage of total run that comes from 4s and 6s

    	SELECT batsmanName AS Player_Name,
	ROUND((100*(4*SUM(`4s`)+6*SUM(`6s`))/SUM(runs)),2) as 'Boundary%'
	FROM fact_bating AS f
	GROUP BY batsmanName 
	ORDER BY `Boundary%` DESC
	LIMIT 5;	

```
- Top 5 bowlers based on past 3 years dot ball %
```
	-- dot ball % i.e. percentage of dot balls to total ball
	
    	SELECT bowlerName AS Player_Name,
	ROUND(100*((SUM(`0s`))/(SUM(overs)*6)),2) as 'Dotball%' 
	FROM fact_bowling AS f
	GROUP BY bowlerName 
	ORDER BY `Dotball%` DESC 
	LIMIT 5;	

```
- Top 4 teams based on past 3 years winning %
```
	-- (the fraction of games or matches a team or individual has won)
    
	WITH task AS(SELECT DISTINCT(winner)AS team,
	(COUNT(*) OVER(PARTITION BY winner)/COUNT(match_id) OVER())*100 AS Win_Perc
	FROM dim_match)

	SELECT 
	(DENSE_RANK() OVER(ORDER BY Win_perc DESC) )AS Team_Rank,
	Team_Name,
	Win_Perc 
	FROM (SELECT DISTINCT(winner) AS Team_Name
	FROM dim_match) d 
	INNER JOIN task t
	ON d.Team_Name = team
	ORDER BY Win_Perc DESC
	LIMIT 4;	

```
- Top 2 teams with the highest number of wins achieved by chasing targets over the past 3 years
```
	WITH temp AS(SELECT winner,
	ROUND(AVG(CAST(SUBSTRING(margin,1,LOCATE(" ",margin)-1)AS SIGNED)),2) AS Avg_Lead
     	FROM dim_match
     	WHERE SUBSTRING(margin,LOCATE(" ",margin)+1,length(margin)) = "wickets" 
     	GROUP BY winner , SUBSTRING(margin,LOCATE(" ",margin)+1,length(margin)) 
	 ) 

	SELECT DENSE_RANK() OVER(ORDER BY Avg_Lead DESC) AS Team_Rank,
	winner, Avg_Lead -- Average lead
	FROM temp
	ORDER BY Avg_Lead DESC
	LIMIT 2;
    
    -- Sunrisers Hyderabad and Royal Challengers Bangalore are the outputs

```


