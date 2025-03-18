/*


                                    DATA CLEANING


*/



--Check & Removing any null value in track_id, track_name, artists, popularity
SELECT TOP(1000)*
FROM PortfolioProjects..Tracks

DELETE
FROM [PortfolioProjects].[dbo].[Tracks]
  WHERE
		track_id is null OR
		track_name is null OR
		artists is null OR
		popularity is null

SELECT COUNT(*) FROM [PortfolioProjects].[dbo].[Tracks]
WHERE 
    track_id IS NULL OR
    track_name IS NULL OR
    artists IS NULL OR
    popularity IS NULL;

SELECT TOP(1000)*
FROM PortfolioProjects..Tracks

---------------------------------------------

-- Checking & Removing Duplicates in track_id
SELECT DISTINCT(track_id)
      ,(artists)
From PortfolioProjects..Tracks

--------------------------------------

-- Normalizing "artists" column

-- Removing letf and right extra spacing
UPDATE PortfolioProjects..Tracks
SET artists = LOWER(LTRIM(RTRIM(artists))),
    track_name = LOWER(LTRIM(RTRIM(track_name))),
    album_name = LOWER(LTRIM(RTRIM(album_name)))

--- ------------------------------------

--Checking for anormality in names which may be a lot, as an example we are
-- fixing some of them

UPDATE [PortfolioProjects].[dbo].[Tracks]
SET artists = REPLACE(REPLACE(artists, 'ö', 'o'), 'ã', 'a');

-----------------------------------------

--Checking for inconsistencies in Data Formats

--Check if there is any non-numeric value in the duration_ms column
Update PortfolioProjects..Tracks
SET duration_ms = NULL
WHERE TRY_CAST(duration_ms AS INT) IS NULL

--Check if any value in popularity range is below 0 or above 100
UPDATE [PortfolioProjects].[dbo].[Tracks]
SET popularity = NULL
WHERE popularity < 0 OR popularity > 100;

-- Set tempo values outside a common BPM range (50-140) to NULL
SELECT COUNT(tempo)
FROM PortfolioProjects..Tracks
WHERE tempo<50 OR tempo>140

-----------------------------------------

--Checking for any anomality in explicit column (e.g. 1/0, true/false, yes/no)
SELECT DISTINCT(explicit)
FROM PortfolioProjects..Tracks

-------------------------------------------
--Making sure track-genre is not misclassified
SELECT DISTINCT(track_genre)
FROM PortfolioProjects..Tracks

-----------------------------------------
--Checking whether time_signature is in range or not
SELECT DISTINCT(time_signature)
FROM PortfolioProjects..Tracks


SELECT TOP(100)* FROM PortfolioProjects..Tracks


--------------------------------------------------------------------
/*

							Extracting Potential Insights
*/
-- TOP SONG
	
	SELECT TOP 1
		track_id,
		track_name,
		artists,
		popularity
	FROM [PortfolioProjects].[dbo].[Tracks]
	ORDER BY popularity DESC;

--Artist popularity TOP 10

SELECT TOP(10)
    artists,
    AVG(popularity) AS avg_popularity
FROM [PortfolioProjects].[dbo].[Tracks]
GROUP BY artists
ORDER BY avg_popularity DESC;

---- Genre Trends

SELECT TOP(10)
    track_genre,
    AVG(popularity) AS avg_popularity
FROM [PortfolioProjects].[dbo].[Tracks]
GROUP BY track_genre
ORDER BY avg_popularity DESC;

----------------

--Danceability Vs popularity relation
SELECT TOP(10)
    danceability,
    AVG(popularity) AS avg_popularity
FROM [PortfolioProjects].[dbo].[Tracks]
GROUP BY danceability
ORDER BY danceability DESC;
------------------------------------
--Analyze whether explicit songs perform better or worse in terms of popularity

SELECT 
    explicit, 
    AVG(popularity) AS avg_popularity
FROM [PortfolioProjects].[dbo].[Tracks]
GROUP BY explicit
ORDER BY explicit DESC;

-----------------------------

--Compare song lengths across different genres.

SELECT 
    track_genre, 
    AVG(duration_ms) AS avg_duration
FROM [PortfolioProjects].[dbo].[Tracks]
GROUP BY track_genre
ORDER BY avg_duration DESC;
----------------------------------

-- Investigate if higher loudness levels correlate with higher energy levels
-- (max energy level=1)
SELECT 
    loudness, 
    energy
FROM [PortfolioProjects].[dbo].[Tracks]
ORDER BY loudness DESC;
-----------------------------------

--Determine the most common tempos in popular songs.
SELECT 
    tempo,
    AVG(popularity) AS avg_popularity
FROM [PortfolioProjects].[dbo].[Tracks]
GROUP BY tempo
ORDER BY avg_popularity DESC;
-----------------------------------

--Identify which musical keys and modes (major/minor) are most used in popular music.

SELECT 
    [key],
    mode,
    AVG(popularity) AS avg_popularity,
    COUNT(*) AS track_count
FROM [PortfolioProjects].[dbo].[Tracks]
GROUP BY [key], mode
ORDER BY avg_popularity DESC, track_count DESC;
---------------------------------------------------

--Finding tracks belong to most popular genre
	
WITH Top_Popular_Genre AS(
SELECT track_genre,AVG(popularity) as AvG_Popularity
FROM PortfolioProjects..Tracks
GROUP BY track_genre
)
SELECT TOP(1) track_name,track_genre,popularity,artists
FROM Tracks
WHERE track_genre = (
	SELECT TOP(1) track_genre FROM Top_Popular_Genre ORDER BY AvG_Popularity DESC)
ORDER BY Popularity DESC

---------------------------------

--Looking for the lowest danceability track that have energy greater than 0.7

WITH GenreHighEnergy AS (
    SELECT track_genre,
           AVG(energy) AS AVG_energy
    FROM [dbo].[Tracks]
    WHERE energy > 0.7
    GROUP BY track_genre
)
SELECT track_name,
              track_genre,
              danceability
FROM PortfolioProjects..Tracks
WHERE track_genre IN (
    SELECT track_genre
    FROM GenreHighEnergy
)
AND danceability != 0
ORDER BY danceability ASC;

