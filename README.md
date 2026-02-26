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
```sql SELECT 
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
WHERE ranking = 1;```



## -- 3. List all movies released in 2020
```sql SELECT *
FROM netflix
WHERE type = 'Movie'
  AND release_year = 2020;```



