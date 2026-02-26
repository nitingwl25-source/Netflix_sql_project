# Netflix movie and TV shows data analysis using SQL

![Netflix Logo](https://github.com/nitingwl25-source/Netflix_sql_project/blob/main/images%20(1).png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives
Analyze the distribution of content types (movies vs TV shows).
Identify the most common ratings for movies and TV shows.
List and analyze content based on release years, countries, and durations.
Explore and categorize content based on specific criteria and keywords.

## Dataset
The data for this project is sourced from the Kaggle dataset:

## Create Table
```sql
CREATE TABLE netflix (
    show_id       VARCHAR(10),
    type          VARCHAR(10),
    title         VARCHAR(150),
    director      VARCHAR(208),
    casts         VARCHAR(1000),
    country       VARCHAR(150),
    date_added    VARCHAR(50),
    release_year  INT,
    rating        VARCHAR(10),
    duration      VARCHAR(15),
    listed_in     VARCHAR(155),
    description   VARCHAR(250)
);
```

##  15 BUSINESS PROBLEMS

## -- 1. Count the number of Movies vs TV Shows
```sql
SELECT 
    type,
    COUNT(*) AS total_count
FROM netflix
GROUP BY type;
```


## -- 2. Find the most common rating for Movies and TV Shows
```sql
SELECT 
    type,
    rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS total_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) sub
WHERE ranking = 1;
```


## -- 3. List all movies released in 2020
```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND release_year = 2020;
```

## -- 4. Top 5 countries with the most content
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
    COUNT(*) AS total_content
FROM netflix
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;
```


## -- 5. Identify the longest movie
```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND duration = (
        SELECT MAX(duration)
        FROM netflix
        WHERE type = 'Movie'
    );
```


## -- 6. Content added in the last 5 years
```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') 
      >= CURRENT_DATE - INTERVAL '5 years';
```


## -- 7. Content by director 'Rajiv Chilaka'
```sql
SELECT 
    type,
    director,
    title
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

## -- 8. TV Shows with more than 5 seasons
```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::NUMERIC > 5;
```

## -- 9. Count content items in each genre
```sql
SELECT  
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC;
```


##  -- 10. Top 5 years with highest Indian content release
```sql
WITH indian_content AS (
    SELECT 
        release_year,
        COUNT(*) AS total_content
    FROM netflix
    WHERE country ILIKE '%India%'
    GROUP BY release_year
)
SELECT 
    release_year,
    ROUND(AVG(total_content), 2) AS avg_content
FROM indian_content
GROUP BY release_year
ORDER BY avg_content DESC
LIMIT 5;
```


## -- 11. List all documentaries
```sql
SELECT *
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';
```


## -- 12. Find all content without a director
```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```


## -- 13. Movies Salman Khan appeared in last 10 years
```sql
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

## -- 14. Top 10 actors in Indian productions
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(title) AS movie_count
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;
```


## -- 15. Categorize content as 'Bad' or 'Good'
```sql
WITH categorized_content AS (
    SELECT 
        *,
        CASE
            WHEN description ILIKE '%violence%'
              OR description ILIKE '%kill%'
            THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
)
SELECT 
    category,
    COUNT(*) AS total_content
FROM categorized_content
GROUP BY category;
```

