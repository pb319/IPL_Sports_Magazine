-- Primary Analysis
-- ** Caution  Edit-> Preferences-> SQL Editor -> read-timeout interval to be atleast 60 seconds **

	USE ipl;  -- (ASSIGNING DEFAULT TABLE) MUST RUN CODE ELSE REST WILL NOT WORK

	SELECT * FROM fact_bating
    WHERE batsmanName = 'FafduPlessis' 
    LIMIT 5; -- Have a look on the `fact_bating` column 

	-- [Top 10 batsmen based on past 3 years total runs scored]
	
    SELECT  DENSE_RANK() OVER(ORDER BY SUM(runs) DESC) as Player_Rank, -- Window Function throgh DENSE_RANK is used to show Player ranking
    batsmanName as Player_Name, SUM(runs)as Total_Run  -- `Total_Run` stands for Total Run by each batsman
	FROM fact_bating
	GROUP BY batsmanName 
	ORDER BY Total_Run DESC -- decreasing order has been used to order the batsman having highest total_Run to lowest
	LIMIT 10; -- Limiting top 10 batsman 
    

	-- [Top 10 batsmen based on past 3 years batting average. (min 60 balls faced in each season)]
	-- [Bating Average is the total number of runs they have scored divided by the number of times they have been out]
    
    WITH CTE1 AS(SELECT batsmanName, RIGHT(matchDate,4) AS Season -- CTE Filtered by Atleast 60 balls played
	FROM fact_bating f
	INNER JOIN dim_match d
	ON f.match_id = d.match_id
	GROUP BY 1, 2
	HAVING SUM(balls)>60)

            
	SELECT DENSE_RANK() OVER(ORDER BY ROUND(SUM(runs)/SUM(CASE WHEN `out/not_out` = "out" THEN 1 ELSE 0 END),2) DESC) as Player_Rank, -- Ranking based on decreasing bating average of the the players
	 batsmanName as Player_Name,
     ROUND(SUM(runs)/COUNT(CASE WHEN `out/not_out` = "out" THEN 1 ELSE NULL END),2) AS Bating_Average-- Rounding up to 2 decimal places
     -- RIGHT(matchDate,4) as Match_Year, -- the substring having 4 character (year) has been fetched from `matchDate`
	 -- SUM(balls) as Total_Balls_Faced -- `Total_Balls_Faced` which stands for total ball faced by each batsman grouped by `batsman` and `Match_Year` 
	FROM fact_bating F 
	INNER JOIN dim_match D   -- `dim_match` and `fact_bating` has been Inner Joined using `match_id`
	ON F.match_id = D.match_id 
    -- Since Filtering and Ordering have been done on two different layers, subquery is used to filter batsman who faced min 60 balls in each season
	WHERE batsmanName IN( 
			SELECT batsmanName
			FROM CTE1
			GROUP BY 1
            HAVING count(Season) = 3)  -- All of the Three Seasons Played
	GROUP BY batsmanName 
	HAVING COUNT(DISTINCT(RIGHT(matchDate,4)))=3 -- Batsman faced atleast 60 balls(**)
	ORDER BY Bating_Average DESC -- ordered in decsending order
	LIMIT 10;


	-- [Top 10 batsmen based on past 3 years strike rate (min 60 balls faced in each season)]
    
	WITH CTE1 AS(SELECT batsmanName, RIGHT(matchDate,4) AS Season -- CTE Filtered by Atleast 60 balls played
	FROM fact_bating f
	INNER JOIN dim_match d
	ON f.match_id = d.match_id
	GROUP BY 1, 2
	HAVING SUM(balls)>60)
    
    
    SELECT DENSE_RANK() OVER(ORDER BY AVG(SR) DESC)as Player_Rank, batsmanName as Player_Name, -- Ranking 
	 ROUND(avg(SR),2) as Avg_SR -- `Avg_SR` stands for Average Strike Rate by aggregating strike rates of each batsman
	FROM fact_bating F 
	INNER JOIN dim_match D
	ON F.match_id = D.match_id -- `dim_match` and `fact_bating` has been Inner Joined using `match_id`
    -- Similar to the above case season wise filter
    WHERE batsmanName IN( 
			SELECT batsmanName
			FROM CTE1
			GROUP BY 1
            HAVING count(Season) = 3 ) -- All of the Three Seasons Played
            GROUP BY batsmanName
    -- HAVING COUNT(DISTINCT(RIGHT(matchDate,4)))=3 -- Batsman faced atleast 60 balls(**)
	ORDER BY Avg_SR DESC -- Decsending Order
	LIMIT 10;
    
    
    -- [Top 5 batsmen based on past 3 years boundary %]
    -- Boundary %  is the percentage of total run that comes from 4s and 6s (min 60 balls faced in each season)
    
    WITH CTE1 AS(SELECT batsmanName, RIGHT(matchDate,4) AS Season -- CTE Filtered by Atleast 60 balls played
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
            HAVING count(Season) = 3 ) -- All of the Three Seasons Played
	GROUP BY batsmanName 
	ORDER BY `Boundary%` DESC
	LIMIT 5;

	-- Top 10 bowlers based on past 3 years total wickets taken.
	
    SELECT DENSE_RANK() OVER(ORDER BY SUM(wickets) DESC) as Player_Rank, bowlerName as Name, 
	SUM(wickets) as Total_Wickets -- `Total_Wicket` stands for the total wicket taken by each bowler
	FROM fact_bowling F  
	INNER JOIN dim_match D
	ON F.match_id = D.match_id
	GROUP BY `Name` -- Grouped BY each bowler 
	ORDER BY Total_Wickets DESC -- Decsending orderof Total_wickets
	LIMIT 10;
    --  Note: 'KagisoRabada', 'ArshdeepSingh' having same Total_Wickets ranked at the same level


	-- Top 10 bowlers based on past 3 years bowling average. (min 60 balls bowled in each season)
    
    WITH CTE2 AS(SELECT bowlerName, RIGHT(matchDate,4) AS Season -- CTE Filtered by Atleast 60 balls delivered
	FROM fact_bowling f
	INNER JOIN dim_match d
	ON f.match_id = d.match_id
	GROUP BY 1, 2
	HAVING SUM(overs)*6 > 60)
    
    SELECT DENSE_RANK() OVER(ORDER BY (SUM(runs)/SUM(wickets)) ASC) as Player_Rank, -- Ranking
	bowlerName as Player_Name,
    ROUND((SUM(runs)/SUM(wickets)),2) as Bowling_Avg --  number of runs they have conceded per wicket taken is `Bowling_Avg`
    FROM fact_bowling F
	INNER JOIN dim_match D
	ON F.match_id = D.match_id
    WHERE bowlerName IN( 
			SELECT bowlerName
			FROM CTE2
			GROUP BY 1
            HAVING count(Season) = 3 )-- All of the Three Seasons Bowled 
	GROUP BY bowlerName 
    HAVING Bowling_Avg IS NOT NULL
	ORDER BY Bowling_Avg ASC -- Lesser the Bowling_Avg better the bowler 
    LIMIT 10; 

	-- Top 10 bowlers based on past 3 years economy rate. (min 60 balls bowled in each season)
    
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
    
    -- Top 5 bowlers based on past 3 years dot ball % (min 60 balls bowled in each season)
    -- dot ball % i.e. percentage of dot balls to total ball
    
    WITH CTE2 AS(SELECT bowlerName, RIGHT(matchDate,4) AS Season -- CTE Filtered by Atleast 60 balls delivered
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
            HAVING count(Season) = 3 )  -- All of the Three Seasons Bowled 
	GROUP BY bowlerName 
	ORDER BY `Dotball%` DESC 
	LIMIT 5;

	-- Top 5 batsmen based on past 3 years boundary % (fours and sixes)
	-- Boundary %  is the percentage of total run that comes from 4s and 6s
    
    
    SELECT batsmanName AS Player_Name,
	ROUND((100*(4*SUM(`4s`)+6*SUM(`6s`))/SUM(runs)),2) as 'Boundary%'
	FROM fact_bating AS f
	GROUP BY batsmanName 
	ORDER BY `Boundary%` DESC
	LIMIT 5;

	-- [Top 5 bowlers based on past 3 years dot ball %]
    -- dot ball % i.e. percentage of dot balls to total ball
	
    SELECT bowlerName AS Player_Name,
	ROUND(100*((SUM(`0s`))/(SUM(overs)*6)),2) as 'Dotball%' 
	FROM fact_bowling AS f
	GROUP BY bowlerName 
	ORDER BY `Dotball%` DESC 
	LIMIT 5;

	-- [Top 4 teams based on past 3 years winning %] 
    -- (the fraction of games or matches a team or individual has won)
    -- I employed Common Table Expression to excute the query
    
    WITH CTE3 AS(SELECT team1 AS team,
    COUNT(match_id) as First_bat
    -- Similar to GROUP BY winner and the selecting aggregated column COUNT(*)
	-- (COUNT(*) OVER(PARTITION BY winner)/COUNT(match_id) OVER())*100 AS Win_Perc -- `Win_Perc` stands for Winning Percentage
	FROM dim_match
    GROUP BY 1
	),
    
    
    CTE4 AS(SELECT team2 AS team,
    COUNT(match_id) as First_ball
    -- Similar to GROUP BY winner and the selecting aggregated column COUNT(*)
	-- (COUNT(*) OVER(PARTITION BY winner)/COUNT(match_id) OVER())*100 AS Win_Perc -- `Win_Perc` stands for Winning Percentage
	FROM dim_match
    GROUP BY 1
	),
    
    
	task AS(SELECT winner AS team,
    COUNT(*) AS `#Win`
    -- Similar to GROUP BY winner and the selecting aggregated column COUNT(*)
	-- (COUNT(*) OVER(PARTITION BY winner)/COUNT(match_id) OVER())*100 AS Win_Perc -- `Win_Perc` stands for Winning Percentage
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
    
    
    
	-- [Top 2 teams with the highest number of wins achieved by chasing targets over the past 3 years]
   

	WITH temp AS(SELECT winner,
	 ROUND(COUNT(CAST(SUBSTRING(margin,1,LOCATE(" ",margin)-1)AS SIGNED)),2) AS Avg_Lead -- Substring `Lead_Number` absolute value of field like `26 wickets` '26' is Lead_Number and 'wickets' is filed 
	 -- `Field` stands for 'Wicket'/'Run'
     FROM dim_match
     WHERE SUBSTRING(margin,LOCATE(" ",margin)+1,length(margin)) = "wickets" -- Those who chases run and wins must be won by wickets
     GROUP BY winner , SUBSTRING(margin,LOCATE(" ",margin)+1,length(margin)) -- substring() gives ou "wickets"/'runs'
	 ) 

	SELECT DENSE_RANK() OVER(ORDER BY Avg_Lead DESC) AS Team_Rank,
	winner, Avg_Lead -- Average lead
	FROM temp
	
	ORDER BY Avg_Lead DESC
	LIMIT 2;
    
    -- Sunrisers Hyderabad and Royal Challengers Bangalore are the outputs





