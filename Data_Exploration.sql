-- Creating a Database for Importing CSV files
CREATE DATABASE IF NOT EXISTS ipl;

-- Altering Complex names into simple one
	USE ipl;  -- (ASSIGNING DEFAULT TABLE) MUST RUN CODE ELSE REST WILL NOT WORK
    
	ALTER TABLE dim_match_summary
	RENAME TO  dim_match; 	-- `dim_match_summary` has been changed to `dim_match`
	
    	ALTER TABLE fact_bating_summary					
	RENAME TO  fact_bating;	-- `dim_bating_summary` has been changed to `dim_match`
	
    	ALTER TABLE fact_bowling_summary
	RENAME TO  fact_bowling; -- `fact_bowling_summary` has been changed to `fact_bowling`

-- Data Exploration

	-- DIM_MATCH
		SELECT * FROM dim_match LIMIT 5; -- 5 Rows of `dim_match` table
        
		SELECT COUNT(match_id) as No_of_Matches, -- `No_of_Matches` stands for the total number of matches played in these three years 
		COUNT(DISTINCT(team1)) as No_of_Teams, -- `No_of_Teams` stands for the total Number of Teams that participated in these three years
		COUNT(DISTINCT(RIGHT(matchDate,4))) as `Year` -- SUbstring is extracted from `matchDate` to check whether the data is only given for three years or any cleaning is required
		FROM dim_match; 
        
		DESC dim_match; -- Describes each column

		-- Let's have a look into the margin column
			select DISTINCT(
			CASE 
				WHEN margin LIKE "%run%" THEN RIGHT(margin,4)
				WHEN margin LIKE "%wicket%" THEN (RIGHT(margin,7)) END) AS Margin
			FROM dim_match;
            -- that is We have 4 different in the form of singular and plural
		
		-- FROM here we come to know that 10 teams participated in 206 matches so far in these three years

		SELECT *
		FROM dim_match
		WHERE match_id = 'T208201'; -- this query has been used to understand a specific field with a different entry that has been changed as follows 
		
		set sql_safe_updates =0; -- safe mode revoked
		-- this field may cause some problems while splitting and changing data type hence changed to 'May 29, 2023' from `'May 28-29, 2023'`
		
        	UPDATE dim_match
		SET matchDate = 'May 29, 2023'
		WHERE matchDate = 'May 28-29, 2023'; 
		
        set sql_safe_updates =1; -- safe mode revived

	-- dim_players
		SELECT * FROM dim_players LIMIT 5; -- 5 Rows of `dim_players` table
		
       		SELECT COUNT(DISTINCT(name)) as Player_Name, -- `Player_Name` stands for Name of the player
		COUNT(DISTINCT(team)) as No_of_Teams -- As aforementioned
		FROM dim_players; 
        -- Data validation has been checked i.e. Total Teams = 10
        -- Total Number of Players 292
	 

	-- fact_bating
		SELECT * FROM fact_bating LIMIT 5; -- 5 Rows of `fact_bating` table
		
        	SELECT COUNT(DISTINCT(match_id)) as No_of_Matches, -- `No_of_Matches` stands for the total number of matches played in these three years
		COUNT(DISTINCT(batsmanName)) as Batsman_Count -- `Batsman_Count`stands for total number of batsman in the dataset
		FROM fact_bating;
        -- AGAIN Corraboration of Total Matches played  = 206
		-- Total Number of Batsman is 262
	-- fact_bowling
		SELECT * FROM fact_bowling LIMIT 5; -- 5 Rows of `fact_bowling` table
		
        SELECT COUNT(DISTINCT(match_id)) as No_of_Matches, -- `No_of_Matches` stands for the total number of matches played in these three years
		COUNT(DISTINCT(bowlerName)) as Bowler_Count -- `Batsman_Count`stands for total number of batsman in the dataset
		FROM fact_bowling; 
        -- AGAIN Corraboration of Total Matches played  = 206
        -- Total Number of Bowlers 202 

	


