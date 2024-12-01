# IPL_-Sports_Magazine
- Challenge #10: Analyse historical IPL data and provide insights on IPL 2024 for a Sports Magazine (Codebasics)
- Project Presentation PDF: [Linkedin Post](https://www.linkedin.com/posts/pranaybiswas_ipl-sports-magazine-activity-7190769304886280192-8a2H?utm_source=share&utm_medium=member_desktop).
***
![1](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/b4656d19-7319-4425-ba7f-d857bae6261c)

***
## Table of Contents:
0. [Project Link](https://codebasics.io/challenge/codebasics-resume-project-challenge)
1. [Problem Statement](https://github.com/pb319/IPL_Sports_Magazine#problem-statement)
2. [Data Modeling](https://github.com/pb319/IPL_Sports_Magazine?tab=readme-ov-file#data-loading)
3. [Primary Data Analysis](https://github.com/pb319/IPL_Sports_Magazine/blob/main/README.md#primary-data-analysis)
4. [Orange Cap and Purple Cap Prediction](https://github.com/pb319/IPL_Sports_Magazine/blob/main/README.md#the-orange-and-purple-cap-prediction)
5. [My Team 11](https://github.com/pb319/IPL_Sports_Magazine/blob/main/README.md#my-team-11)
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
	
	-- Let's have a look into the margin column
			select DISTINCT(
			CASE 
				WHEN margin LIKE "%run%" THEN RIGHT(margin,4)
				WHEN margin LIKE "%wicket%" THEN (RIGHT(margin,7)) END) AS Margin
			FROM dim_match;
            -- that is We have 4 different in the form of singular and plural

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
1. Mysql (Validated by Power BI Dashboar in the background)
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
![Untitled design (18)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/81f700be-e98a-41e5-9829-46b5044d8cb7)


- Top 10 batsmen based on past 3 years batting average. (min 60 balls faced in each season)
```
	-- [Bating Average is the total number of runs they have scored divided by the number of times they have been out]
    
    	WITH CTE1 AS(SELECT batsmanName, RIGHT(matchDate,4) AS Season 
	FROM fact_bating f
	INNER JOIN dim_match d
	ON f.match_id = d.match_id
	GROUP BY 1, 2
	HAVING SUM(balls)>60)

            
	SELECT DENSE_RANK() OVER(ORDER BY ROUND(SUM(runs)/SUM(CASE WHEN `out/not_out` = "out" THEN 1 ELSE 0 END),2) DESC) as Player_Rank, 
	batsmanName as Player_Name,
     	ROUND(SUM(runs)/COUNT(CASE WHEN `out/not_out` = "out" THEN 1 ELSE NULL END),2) AS Bating_Average
	FROM fact_bating F 
	INNER JOIN dim_match D   -- `dim_match` and `fact_bating` has been Inner Joined using `match_id`
	ON F.match_id = D.match_id 
	WHERE batsmanName IN( 
			SELECT batsmanName
			FROM CTE1
			GROUP BY 1
            		HAVING count(Season) = 3)  
	GROUP BY batsmanName 
	HAVING COUNT(DISTINCT(RIGHT(matchDate,4)))=3 
	ORDER BY Bating_Average DESC -- ordered in decsending order
	LIMIT 10;


```
![Untitled design (19)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/56270fd7-d62d-4563-bcaf-22b37155f8b2)


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
![Untitled design (20)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/85ac9207-5a68-43b2-a9d6-359c75058a73)

- Top 5 batsmen based on past 3 years boundary % (min 60 balls faced in each season)
```
-- Boundary %  is the percentage of total run that comes from 4s and 6s (min 60 balls faced in each season)
    
    	WITH CTE1 AS(SELECT batsmanName, RIGHT(matchDate,4) AS Season 
	FROM fact_bating f
	INNER JOIN dim_match d
	ON f.match_id = d.match_id
	GROUP BY 1, 2
	HAVING SUM(balls)>60)
    
    
	SELECT batsmanName AS Player_Name,
	ROUND((100*(4*SUM(`4s`)+6*SUM(`6s`))/SUM(runs)),2) as 'Boundary%'
	FROM fact_bating AS f
    	WHERE batsmanName IN( 
			SELECT batsmanName
			FROM CTE1
			GROUP BY 1
            		HAVING count(Season) = 3 ) 
	GROUP BY batsmanName 
	ORDER BY `Boundary%` DESC
	LIMIT 5;
    
```
![Untitled design (28)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/33d6144e-25c7-4c45-9873-29f60349fb31)


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
	
	
```
![Untitled design (22)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/7accafcb-ed15-4b04-b06b-df12c3ddec4a)


- Top 10 bowlers based on past 3 years bowling average. (min 60 balls bowled in each season)
```
	    
	WITH CTE2 AS(SELECT bowlerName, RIGHT(matchDate,4) AS Season -- CTE Filtered by Atleast 60 balls delivered
	FROM fact_bowling f
	INNER JOIN dim_match d
	ON f.match_id = d.match_id
	GROUP BY 1, 2
	HAVING SUM(overs)*6 > 60)
    
    	SELECT DENSE_RANK() OVER(ORDER BY (SUM(runs)/SUM(wickets)) ASC) as Player_Rank, -- Ranking
	bowlerName as Player_Name,
    	ROUND((SUM(runs)/SUM(wickets)),2) as Bowling_Avg 
    	FROM fact_bowling F
	INNER JOIN dim_match D
	ON F.match_id = D.match_id
    	WHERE bowlerName IN( 
			SELECT bowlerName
			FROM CTE2
			GROUP BY 1
			HAVING count(Season) = 3 )
	GROUP BY bowlerName 
    	HAVING Bowling_Avg IS NOT NULL
	ORDER BY Bowling_Avg ASC 
    	LIMIT 10; 


```
![Untitled design (25)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/1a057ba6-d5ba-4f66-bd3d-e76c8b114772)

- Top 10 bowlers based on past 3 years economy rate. (min 60 balls bowled in each season)
```
	
    	WITH CTE2 AS(SELECT bowlerName, RIGHT(matchDate,4) AS Season -- CTE Filtered by Atleast 60 balls delivered
	FROM fact_bowling f
	INNER JOIN dim_match d
	ON f.match_id = d.match_id
	GROUP BY 1, 2
	HAVING SUM(overs)*6 > 60)
	
    	SELECT  RANK() OVER(ORDER BY (ROUND(avg(economy),2)) ASC ) as Player_Rank,
	bowlerName, ROUND(avg(economy),3) as Avg_Economy -- Rounded upto 2 decimal place
	FROM fact_bowling f
	INNER JOIN dim_match d
	ON f.match_id =  d.match_id -- `fact_bowling` and `dim_match` has been  Inner Joined on `match_id`
    	WHERE bowlerName IN ( 
			SELECT bowlerName
			FROM CTE2
			GROUP BY 1
            		HAVING count(Season) = 3 )  -- All of the Three Seasons Bowled 
	GROUP BY bowlerName
	ORDER BY Avg_Economy ASC
	LIMIT 10;

```
![Untitled design (26)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/ffa9926d-e452-48bc-8c53-594ea9b857bd)

- Top 10 bowlers based on past 3 years dot ball % (min 60 balls bowled in each season)
```
    -- dot ball % i.e. percentage of dot balls to total ball
    
    	WITH CTE2 AS(SELECT bowlerName, RIGHT(matchDate,4) AS Season 
	FROM fact_bowling f
	INNER JOIN dim_match d
	ON f.match_id = d.match_id
	GROUP BY 1, 2
	HAVING SUM(overs)*6 > 60)
	
    	SELECT bowlerName AS Player_Name,
	ROUND(100*((SUM(`0s`))/(SUM(overs)*6)),2) as 'Dotball%' 
	FROM fact_bowling AS f
    	WHERE bowlerName IN ( 
			SELECT bowlerName
			FROM CTE2
			GROUP BY 1
            		HAVING count(Season) = 3 ) 
	GROUP BY bowlerName 
	ORDER BY `Dotball%` DESC 
	LIMIT 5;

```
![Untitled design (27)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/1ea459bf-3851-4ab0-8b4d-f68774641f1a)

- Top 4 teams based on past 3 years winning %
```
-- (the fraction of games or matches a team or individual has won)
-- I employed Common Table Expression to execute the query
    
    	WITH CTE3 AS(SELECT team1 AS team,
	COUNT(match_id) as First_bat
	FROM dim_match
	GROUP BY 1
	),
    
    
    	CTE4 AS(SELECT team2 AS team,
    	COUNT(match_id) as First_ball
	FROM dim_match
    	GROUP BY 1
	),
    
    
	task AS(SELECT winner AS team,
    	COUNT(*) AS `#Win`
    	FROM dim_match
    	GROUP BY 1
	)
	
    	SELECT team AS Team,
    	(`First_ball`+`First_bat`) AS Total_play,
	ROUND((100*`#Win`/(`First_ball`+`First_bat`)),2) AS Win_Prc
	FROM CTE3
	JOIN CTE4 USING (team)
	JOIN task USING (team)
	ORDER BY 3
	LIMIT 4;
    

```
![Untitled design (29)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/87ed1292-ce15-489a-bcfb-c7254886bc49)

- Top 2 teams with the highest number of wins achieved by chasing targets over the past 3 years
```

   

	WITH temp AS(SELECT winner,
	ROUND(COUNT(CAST(SUBSTRING(margin,1,LOCATE(" ",margin)-1)AS SIGNED)),2) AS Avg_Lead -- Substring `Lead_Number` absolute value of field like `26 wickets` '26' is Lead_Number and 'wickets' is filed 
	FROM dim_match
     	WHERE SUBSTRING(margin,LOCATE(" ",margin)+1,length(margin)) = "wickets" -- Those who chases run and wins must be won by wickets
     	GROUP BY winner , SUBSTRING(margin,LOCATE(" ",margin)+1,length(margin)) -- substring() gives ou "wickets"/'runs'
	 ) 

	SELECT DENSE_RANK() OVER(ORDER BY Avg_Lead DESC) AS Team_Rank,
	winner, Avg_Lead -- Average lead
	FROM temp
	
	ORDER BY Avg_Lead DESC
	LIMIT 2;


```
![Untitled design (31)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/043348ec-5e6e-4866-a592-69379769c622)


In our first social update, we noticed anomalies in some SQL query outputs that require rectification. You may refer to [Old Primary SQL Analysis Docstring](https://github.com/pb319/IPL_Sports_Magazine/blob/main/Primary_Analysis.sql) or [Linked Post](https://www.linkedin.com/posts/pranaybiswas_mysql-query-drills-activity-7183933808914706432-f9d4?utm_source=share&utm_medium=member_desktop).

The Rectified SQL Queries are as follows:
You may refer to the docstring - ([Updated SQL Query](https://github.com/pb319/IPL_Sports_Magazine/blob/main/Primary_Analysis%20(Rectified).sql))
***
1. Power BI (Cleaning and Basic Analysis)
  - Power Query (M Language)
  - DAX Measures
    	
   > Both can be found in ([Final_Dashboard.pbix](https://github.com/pb319/IPL_Sports_Magazine/raw/main/Final_Dashboard.pbix))

## The Orange and Purple Cap Prediction
Here in this section, we will deal with various machine learning models and Statistical analysis to optimize those models mostly deployed through R and Python as a part of our "Predictive Analytics".
![2](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/0df16955-407e-4d4b-886c-ba5ca7b84c09)

## Orange Cap:
#### __Objective__: 
- To predict the player having maximum total run in the IPL season 2024.

#### __Methodologies__: 
- Assumptions like _**Independence of errors, Normality of errors**_, etc. have been checked using various plots and measures.
- Primary model has been made through _**Stepwise Regression method**_.
- _**Multicollinearity**_ of independent variable has been identified by _**Variance Inflation Factor**_
- _**Multicollinearity**_ of the independent variable has been addressed by _**Principal Component Analysis**_
- _**Test of Significance**_ has been considered while model building
- Reliability has been reconfirmed by _**R-Squared and Adjusted R-Squared**_
  
  ![image](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/cdf20152-6806-4161-9b14-e4a618cbe705)

## Purple Cap:
#### __Objective__: 

- To predict the player with the most wickets in the IPL season 2024.

#### __Methodologies__: 

- The approach mentioned earlier for "Orange Cap Prediction" has been imitated.

#### Resources
- Explanation: _[Linked Post](https://bit.ly/3io5qqX)_
- Resources: Datasets are available [Here](https://github.com/pb319/IPL_Sports_Magazine/tree/main/Predictive%20Analytics)


  ![image](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/d75224af-3572-477c-81bc-222c4b5bf7d5)
***
- The Ultimate Result:

![IPL_Sports_Magazine](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/61e79abe-3c81-4e95-be8a-626552e3715c)

  


## My Team 11

1. Power BI
- Data Analysis
	- I Classified the pool of players into various homogeneous groups (like Opener, Middle Order, Lower Order, etc.)
	- To classify some criteria are needed. I got it from Analysis using Power BI.
   	- Illustration: Say we want to make criteria for openers then:
   	  	1. Filter the pool using position 1,2. We can't allow middle-order players to play the role of opener.
   	  	2. Then Line Charts would depict 90 percentile points which may help us to put a cap for further filtering like Strike Rate, Average Ball Faced, etc.
   	  	3. Ordering players based on Standard Deviation of runs/Strike Rate/anything else may help choose the right ones. 
- Actionable Insights
- ** [Explanation Video](https://lnkd.in/gj4eiFfv)
- The Ultimate Result:

![IPL_Sports_Magazine (1)](https://github.com/pb319/IPL_Sports_Magazine/assets/66114329/3d866908-afa9-483e-b7d2-5224ff35c5c7)


Thank You So Much!! See You Soon, Until then Goodbye 👋👋

***


