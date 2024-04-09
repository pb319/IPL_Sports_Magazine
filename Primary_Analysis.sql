-- Primary Analysis
-- ** Caution  Edit-> Preferences-> SQL Editor -> read-timeout interval to be at least 60 seconds **

	USE ipl;  -- (ASSIGNING DEFAULT TABLE) MUST RUN CODE ELSE REST WILL NOT WORK

	SELECT * FROM fact_bating
    	WHERE batsmanName = 'FafduPlessis' 
    	LIMIT 5; -- Have a look on the `fact_bating` column 

	-- Top 10 batsmen based on past 3 years total runs scored.
	
    	SELECT  DENSE_RANK() OVER(ORDER BY SUM(runs) DESC) as Player_Rank, -- Window Function through DENSE_RANK is used to show Player ranking
    	batsmanName as Player_Name, SUM(runs)as Total_Run  -- `Total_Run` stands for Total Run by each batsman
	FROM fact_bating
	GROUP BY batsmanName 
	ORDER BY Total_Run DESC -- decreasing order has been used to order the batsman having the highest total_Run to the lowest
	LIMIT 10; -- Limiting top 10 batsman 
    

	-- Top 10 batsmen based on past 3 years batting average. (min 60 balls faced in each season)
    
	-- [Bating Average is the total number of runs they have scored divided by the number of times they have been out]
        
    	SELECT DENSE_RANK() OVER(ORDER BY ROUND(SUM(runs)/SUM(CASE WHEN `out/not_out` = "out" THEN 1 ELSE 0 END),2) DESC) as Player_Rank, -- Ranking based on decreasing batting average of the players
	batsmanName as Player_Name,
     	ROUND(SUM(runs)/COUNT(CASE WHEN `out/not_out` = "out" THEN 1 ELSE NULL END),2) AS Bating_Average-- Rounding up to 2 decimal places
     	-- RIGHT(matchDate,4) as Match_Year, -- the substring having 4 characters (year) has been fetched from `matchDate`
	 -- SUM(balls) as Total_Balls_Faced -- `Total_Balls_Faced` which stands for total ball faced by each batsman grouped by `batsman` and `Match_Year` 
	FROM fact_bating F 
	INNER JOIN dim_match D   -- `dim_match` and `fact_bating` has been Inner Joined using `match_id`
	ON F.match_id = D.match_id 
    	-- Since Filtering and Ordering have been done on two different layers, subquery is used to filter batsmen who faced min 60 balls in each season
	WHERE batsmanName IN( 
			SELECT batsmanName
			FROM fact_bating f
			INNER JOIN dim_match d
            		ON f.match_id = d.match_id
			GROUP BY batsmanName , RIGHT(matchDate,4)
        HAVING SUM(balls)>60) -- total balls faced grouped by Bastman and Year
	GROUP BY batsmanName
	-- HAVING Total_Balls_Faced >= 60 -- Batsman faced at least 60 balls
	ORDER BY Bating_Average DESC -- ordered in descending order
	LIMIT 10; 



	-- Top 10 batsmen based on past 3 years strike rate (min 60 balls faced in each season)
	
    	SELECT DENSE_RANK() OVER(ORDER BY AVG(SR) DESC)as Player_Rank, batsmanName as Player_Name, -- Ranking 
	ROUND(avg(SR),2) as Avg_SR -- `Avg_SR` stands for Average Strike Rate by aggregating strike rates of each batsman
	FROM fact_bating F 
	INNER JOIN dim_match D
	ON F.match_id = D.match_id -- `dim_match` and `fact_bating` has been Inner Joined using `match_id`
    	-- Similar to the above case season wise filter
    	WHERE batsmanName IN( 
			SELECT batsmanName
			FROM fact_bating f
			INNER JOIN dim_match d
           		ON f.match_id = d.match_id
			GROUP BY batsmanName , RIGHT(matchDate,4)
            		HAVING SUM(balls)>60)
	GROUP BY batsmanName
	ORDER BY Avg_SR DESC -- Descending Order
	LIMIT 10;


	-- Top 10 bowlers based on past 3 years' total wickets taken.
	
    	SELECT DENSE_RANK() OVER(ORDER BY SUM(wickets) DESC) as Player_Rank, bowlerName as Name, 
	SUM(wickets) as Total_Wickets -- `Total_Wicket` stands for the total wicket taken by each bowler
	FROM fact_bowling F  
	INNER JOIN dim_match D
	ON F.match_id = D.match_id
	GROUP BY `Name` -- Grouped BY each bowler 
	ORDER BY Total_Wickets DESC -- Descending order of Total_wickets
	LIMIT 10;
    --  Note: 'KagisoRabada', and 'ArshdeepSingh' have the same Total_Wickets ranked at the same level


	-- Top 10 bowlers based on past 3 years bowling average. (min 60 balls bowled in each season)
    
    	SELECT DENSE_RANK() OVER(ORDER BY (SUM(runs)/SUM(wickets)) ASC) as Player_Rank, -- Ranking
	bowlerName as Player_Name,
    	ROUND((SUM(runs)/SUM(wickets)),2) as Bowling_Avg --  the number of runs they have conceded per wicket taken is `Bowling_Avg`
    	FROM fact_bowling F
	INNER JOIN dim_match D
	ON F.match_id = D.match_id
    	WHERE bowlerName IN(
	    	SELECT bowlerName
	    	FROM fact_bowling F
		INNER JOIN dim_match D
		ON F.match_id = D.match_id
	    	GROUP BY bowlerName,RIGHT(matchDate,4)
	    	HAVING  SUM(overs*6) > 60) -- Total balls bowled by each bowler in each season having more than 60 balls
	GROUP BY bowlerName 
	ORDER BY Bowling_Avg ASC -- The Lesser the Bowling_Avg, better the bowler 
    	LIMIT 10; 

	-- Top 10 bowlers based on past 3 years economy rate. (min 60 balls bowled in each season)
	
    	SELECT  RANK() OVER(ORDER BY (ROUND(avg(economy),2)) ASC ) as Player_Rank,
	bowlerName, ROUND(avg(economy),2) as Avg_Economy -- Rounded upto 2 decimal place
	FROM fact_bowling f
	INNER JOIN dim_match d
	ON f.match_id =  d.match_id -- `fact_bowling` and `dim_match` has been  Inner Joined on `match_id`
    	WHERE bowlerName IN (
    	SELECT bowlerName
    	FROM fact_bowling F
	INNER JOIN dim_match D
	ON F.match_id = D.match_id
    	GROUP BY bowlerName,RIGHT(matchDate,4)
    	HAVING  SUM(overs*6) > 60) -- Total balls bowled by each bowler in each season having more than 60 balls
    	GROUP BY bowlerName
	ORDER BY Avg_Economy ASC
	LIMIT 10;

	-- Top 5 batsmen based on past 3 years boundary % (fours and sixes)
	-- Boundary %  is the percentage of total run that comes from 4s and 6s
    
    
    SELECT batsmanName AS Player_Name,
	ROUND((100*(4*SUM(`4s`)+6*SUM(`6s`))/SUM(runs)),2) as 'Boundary%'
	FROM fact_bating AS f
	GROUP BY batsmanName 
	ORDER BY `Boundary%` DESC
	LIMIT 5;

	-- Top 5 bowlers based on past 3 years dot ball %
    -- dot ball % i.e. percentage of dot balls to total ball
	
    	SELECT bowlerName AS Player_Name,
	ROUND(100*((SUM(`0s`))/(SUM(overs)*6)),2) as 'Dotball%' 
	FROM fact_bowling AS f
	GROUP BY bowlerName 
	ORDER BY `Dotball%` DESC 
	LIMIT 5;

	-- Top 4 teams based on past 3 years winning %. 
    -- (the fraction of games or matches a team or individual has won)
    -- I employed a Common Table Expression to execute the query
    
	WITH task AS(SELECT DISTINCT(winner)AS team,
    -- Similar to GROUP BY winner and the selecting aggregated column COUNT(*)
	(COUNT(*) OVER(PARTITION BY winner)/COUNT(match_id) OVER())*100 AS Win_Perc -- `Win_Perc` stands for Winning Percentage
	FROM dim_match
	)

	SELECT 
	(DENSE_RANK() OVER(ORDER BY Win_perc DESC) )AS Team_Rank,
	Team_Name,
	Win_Perc 
	FROM (SELECT DISTINCT(winner) AS Team_Name
	FROM dim_match) d -- Using subquery task table has been referenced to tap the `Win_Perc` column
	INNER JOIN task t
	ON d.Team_Name = team
	ORDER BY Win_Perc DESC
    	LIMIT 4;

	-- Top 2 teams with the highest number of wins achieved by chasing targets over the past 3 years.

	WITH temp AS(SELECT winner,
	ROUND(AVG(CAST(SUBSTRING(margin,1,LOCATE(" ",margin)-1)AS SIGNED)),2) AS Avg_Lead -- Substring `Lead_Number` absolute value of field like `26 wickets` '26' is Lead_Number and 'wickets' is filed 
	 -- `Field` stands for 'Wicket'/'Run'
     	FROM dim_match
     	WHERE SUBSTRING(margin,LOCATE(" ",margin)+1,length(margin)) = "wickets" -- Those who chase run and win must be won by wickets
     	GROUP BY winner , SUBSTRING(margin,LOCATE(" ",margin)+1,length(margin)) -- substring() gives ou "wickets"/'runs'
	 ) 

	SELECT DENSE_RANK() OVER(ORDER BY Avg_Lead DESC) AS Team_Rank,
	winner, Avg_Lead -- Average lead
	FROM temp
	
	ORDER BY Avg_Lead DESC
	LIMIT 2;
    
    -- Sunrisers Hyderabad and Royal Challengers Bangalore are the outputs





