select * from movie;
select * from ratings;

-- Q1. Find the total number of rows in each table of the schema?

select count(*) as movie_row_count
from movie;

select * from movie; -- (alternative)

-- Q2. Which columns in the 'movie' table have null values?

select count(*) as null_count
from movie
where title = null; -- 0 null values
select count(*) as year_null_count
from movie
where year = null; -- 0 null values
select count(*) as date_published_null_count
from movie
where date_published = null; -- 0 null values
select count(*) as duration_null_count
from movie
where duration = null; -- 0 null values
select count(*) as country_null_count
from movie
where country = null; -- 0 null values
select count(*) as worlwide_gross_income_null_count
from movie
where worlwide_gross_income is null; -- 3724 null values
select count(*) as languages_null_count
from movie
where languages is null; -- 194 null values
select count(*) as production_company_null_count
from movie
where production_company is null; -- 528 null values

-- Q3.1 Find the total number of movies released in each year.

select * from movie;
select year,count(id) as no_of_movies
from movie
group by year;

-- Q3.1 How does the trend look month-wise? 


with cte as
(
select year(date_published) as year_of_release,month(date_published) as no_of_month, count(id) as movies_released
from movie
where date_published between '2017-01-01' and '2019-12-31'
group by year(date_published), month(date_published)
) select year_of_release, no_of_month, movies_released 
from cte
order by year_of_release,no_of_month;

-- Q4. How many movies were produced in the USA or India in the year 2019?

select * from movie;
select count(*)  as no_of_movies
from movie
where country like '%USA%' and year = 2019;
select count(*)  as no_of_movies
from movie
where country like '%india%' and year = 2019;

-----------------------------------------------------------------------------------------------------------------------------------------------------

select * from genre;

select genre, count(*) as no_of_movies from genre
group by genre;

-- Q5. Find the unique list of the genres present in the data set?

select distinct genre
from genre;

/* So, RSVP Movies plans to make a movie on one of these genres.
Now, don't you want to know in which genre were the highest number of movies produced?
Combining both the 'movie' and the 'genre' table can give us interesting insights. */

with cte as
(
select movie_id, genre
from genre
inner join movie on genre.movie_id = movie.id
) select distinct genre, count(movie_id) as no_of_movies
from cte 
group by genre
order by no_of_movies desc
limit 1;

-- Q7. How many movies belong to only one genre?

with movie_genre_summary as
(
select movie_id, genre, count(genre)
over (partition by movie_id) as genre_count
from genre
inner join movie on genre.movie_id = movie.id
) 
select count(distinct movie_id) as single_genre_movie_count
from movie_genre_summary
where genre_count = 1;

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

-- Hint: Utilize a LEFT JOIN to combine the 'genre' and 'movie' tables based on the 'movie_id'.
-- Hint: Specify table aliases for clarity, such as 'g' for 'genre' and 'm' for 'movie'.
-- Hint: Employ the AVG() function to calculate the average duration for each genre.
-- Hint: GROUP BY the 'genre' column to calculate averages for each genre.

select * from movie;
select round(avg(duration),2) as avg_duration_time, genre
from movie cc
left join genre g on g.movie_id = cc.id
group by genre;

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

select * from movie;

with cte as
(
select count(id) as no_of_movies, genre,
rank()
over(order by count(id) desc) as rnk
from movie cc
left join genre g on g.movie_id = cc.id
group by genre
) select * from cte  where genre = "Thriller";

-- Thriller movies are in the top 3 among all genres in terms of the number of movies.

-- Segment 2:

-- Q10.  Find the minimum and maximum values for each column of the 'ratings' table except the movie_id column.

select * from ratings;

select 
min(avg_rating) as min_avg_rating, 
max(avg_rating) as max_avg_rating, 
min(total_votes) as min_total_votes, 
max(total_votes) as max_total_votes, 
min(median_rating) as min_median_rating, 
max(median_rating) as max_median_rating
from ratings;

-- Q11. What are the top 10 movies based on average rating?

select title, avg_rating,
row_number()
over (order by avg_rating desc) as movie_rank
from ratings
left join movie on ratings.movie_id= movie.id
limit 10;


-- Q12. Summarise the ratings table based on the movie counts by median ratings.(order by median_rating)

select median_rating,count(movie_id) as movie_count
from ratings
group by median_rating
order by movie_count desc;

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)?

select production_company, count(movie_id) as movies_count,
dense_rank()
over(order by count(movie_id) desc) as rnk
from ratings
inner join movie on ratings.movie_id = movie.id
group by production_company;

-- Q14. How many movies released in each genre in March 2017 in the USA had more than 1,000 votes?
-- (Split the question into parts and try to understand it.)

select * from movie;
select * from ratings;
select * from genre;

with cte as
(
select genre, id, date_published,country,total_votes
from movie
inner join genre on genre.movie_id = movie.id
inner join ratings on ratings.movie_id = movie.id
where country like "%USA%" and lower(country) like '%usa%' and total_votes > 1000 and date_published between "2017-05-01" and "2017-05-31"
)
select genre, count(id) as movie_count
from cte
group by genre;

-- Q15. Find the movies in each genre that start with the characters ‘The’ and have an average rating > 8.

SELECT title, g.genre,avg_rating
FROM genre g
INNER JOIN movie m ON g.movie_id = m.id
INNER JOIN ratings r ON r.movie_id = m.id
WHERE m.title LIKE 'The%' and avg_rating > 8;

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

with cte as  
(
select count(id) as movie_count, median_rating
from movie
inner join ratings on ratings.movie_id= movie.id
where date_published between "2018-04-01" and "2019-04-01" and median_rating = 8
group by median_rating
) 
select movie_count from cte;

-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.

with cte as
(
select count(id) as movie_count, languages, sum(total_votes) as total_votes
from movie
inner join ratings on ratings.movie_id= movie.id
where languages like '%german%' or languages like '%Italian'
group by languages
) select round((total_votes/movie_count),2) as avg_votes, languages from cte;

with cte as 
(
select 
count(case when m.languages like '%german%' then m.id end) as german_movies_count,
count(case when m.languages like '%italian%' then m.id end) as italina_movie_count,
sum(case when m.languages like '%german%' then r.total_votes end) as german_movie_votes,
sum(case when m.languages like '%italian%' then r.total_votes end) as italian_movie_votes
from movie m
inner join ratings r on m.id = r.movie_id
) 
select round((german_movie_votes/german_movies_count),2) as german_votes_per_movie,
	   round((italian_movie_votes/italina_movie_count),2) as italian_votes_per_movie 
from cte;

-- YES GERMAN MOVIES HAS MORE VOTES PER MOVIE COMPARED TO ITALIAN MOVIES.

-- Segment 3:

-- Q18. Find the number of null values in each column of the 'names' table, except for the 'id' column.

select * from names;

select sum(name is null) as name_null,
	   sum(height is null) as height_null,
	   sum(date_of_birth is null) as date_of_birth,
	   sum(known_for_movies is null) as known_for_movies
       from names;
       
-- Solution 2
-- use case statements to write the query to find null values of each column in names table

select
sum(case when name is null then 1 else 0 end) as name_null,
sum(case when height is null then 1 else 0 end) as height_null,
sum(case when date_of_birth is null then 1 else 0 end) as date_of_birth_null,
sum(case when known_for_movies is null then 1 else 0 end) as known_for_movies_null
from names;

-- Q19. Who are the top three directors in each of the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)

with cte as
(
select genre, count(m.id) as movies_count,
rank()
over(order by count(m.id) desc) as rnk
from genre g
left join movie m on g.movie_id = m.id
inner join ratings r on m.id = r.movie_id
where avg_rating >8
group by genre 
) select n.name as director_name, count(m.id) as movie_count
 from names n
 inner join director_mapping d on n.id = d.name_id
 inner join movie m on d.movie_id = m.id
 inner join ratings r on m.id = r.movie_id
 inner join genre g on g.movie_id = m.id
 where genre in (select distinct genre from cte where rnk<=3) and avg_rating>8
 group by name
 order by movie_count desc
 limit 3;

-- Q20. Who are the top two actors whose movies have a median rating >= 8?

select n.name,count(v.id) as movies_count
from names n
inner join role_mapping r on n.id = r.name_id
inner join movie v on r.movie_id = v.id
inner join ratings s on v.id = s.movie_id
where s.median_rating >= 8
group by n.name
order by movies_count desc
limit 2;

-- Q21. Which are the top three production houses based on the number of votes received by their movies?

select production_company,sum(total_votes) as total_votes,
dense_rank()
over( order by sum(total_votes) desc) as rnk
from movie m
inner join ratings r on m.id = r.movie_id
group by production_company
order by total_votes desc
limit 3;

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the
-- list?
-- Note: The actor should have acted in at least five Indian movies. 


with cte as
(
 select n.name as actor_name, count(m.id) as movie_count, sum(r.total_votes) as total_votes,
 ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actor_avg_rating,
 dense_rank()
 over(order by count(m.id) desc ) as actor_rank
 from names n
 inner join role_mapping a on n.id = a.name_id
 inner join movie m on a.movie_id = m.id
 inner join ratings r on m.id = r.movie_id
 where category = 'actor' and country like '%india%' 
 group by actor_name
 ) select *, 
 dense_rank()
 over(order by actor_avg_rating desc, total_votes desc) as actor_rank
 from cte
 where movie_count>=5;

-- Q23.Find the top five actresses in Hindi movies released in India based on their average ratings.
-- Note: The actresses should have acted in at least three Indian movies. 

with cte as
(
 select n.name as actress_name, count(m.id) as movie_count, sum(r.total_votes) as total_votes,
 ROUND(SUM(r.avg_rating*r.total_votes)/SUM(r.total_votes),2) AS actress_avg_rating,
 dense_rank()
 over(order by count(m.id) desc ) as actress_rank
 from names n
 inner join role_mapping a on n.id = a.name_id
 inner join movie m on a.movie_id = m.id
 inner join ratings r on m.id = r.movie_id
 where category = 'actress' and country like '%india%' and languages like '%Hindi%'
 group by actress_name
 ) select *, 
 dense_rank()
 over(order by actress_avg_rating desc, total_votes desc) as actress_rank
 from cte
 where movie_count>=3
 limit 5;

-- Now let us divide all the thriller movies in the following categories and find out their numbers.
/* Q24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories: 
			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop   */

SELECT m.title,
       CASE 
           WHEN avg_rating > 8 THEN 'Superhit'
           WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit'
           WHEN avg_rating BETWEEN 5 AND 7 THEN 'One Time Watch'
           ELSE 'Flop'
       END AS movie_category
FROM genre
INNER JOIN ratings USING(movie_id)
INNER JOIN movie m ON m.id = ratings.movie_id
WHERE total_votes >= 25000
GROUP BY m.title, avg_rating;

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to get the output according to the output format given below.)

with cte as
(
select g.genre, round(avg(duration),2) as avg_duration
from genre g
left join movie m on g.movie_id=m.id
group by g.genre
) select *,
sum(avg_duration)
over(order by genre rows unbounded preceding) as running_averageround,
round(avg(avg_duration)
over (order by genre rows between 4 preceding and current row),2) as movie_running_average
from cte
order by genre;

-- Q26. Which are the five highest-grossing movies in each year for each of the top three genres?
-- (Note: The top 3 genres would have the most number of movies.)

with cte as 
(
select genre, count(m.id) as movie_count,
rank()
over(order by count(m.id) desc) as genre_rank
from genre g
inner join movie m on g.movie_id = m.id
group by genre
), 
top_grossing as
(
select genre, year, m.title as movie_title, worlwide_gross_income,
rank()
over(partition by genre,year order by convert(replace(trim(worlwide_gross_income), "$ ",""), unsigned int)desc) as movie_rank
from movie m
inner join genre g on g.movie_id=m.id
where g.genre in (select distinct genre from cte where genre_rank<=3)
)
select * 
from top_grossing 
where movie_rank<=3
limit 3;

/*Q27. What are the top two production houses that have produced the highest number of hits (median rating >= 8) among
multilingual movies? */

WITH cte1 AS 
(
SELECT m.production_company, COUNT(m.id) AS movies_count, m.languages, r.median_rating
FROM movie m
LEFT JOIN ratings r ON r.movie_id = m.id
WHERE r.median_rating >= 8 AND POSITION(',' IN m.languages) > 0
GROUP BY m.production_company, m.languages, r.median_rating
),cte2 AS 
(
SELECT cte1.production_company, cte1.movies_count
FROM cte1
)
SELECT cte2.production_company, cte2.movies_count,
row_number() 
OVER (ORDER BY cte2.movies_count DESC) AS rnk
FROM cte2
ORDER BY rnk
limit 3;

-- Q28. Who are the top 3 actresses based on the number of Super Hit movies (average rating > 8) in 'drama' genre?

WITH cte AS 
(
SELECT n.name, 
COUNT(m.id) AS movies_count, 
ROUND(AVG(s.avg_rating), 2) AS actress_avg_rating, 
SUM(s.total_votes) AS total_votes
FROM names n
LEFT JOIN role_mapping r ON r.name_id = n.id
INNER JOIN genre g ON g.movie_id = r.movie_id
INNER JOIN movie m ON m.id = g.movie_id
INNER JOIN ratings s ON s.movie_id = m.id
WHERE r.category = 'actress' AND LOWER(g.genre) = 'drama'
GROUP BY n.name
)
SELECT name, total_votes, movies_count, actress_avg_rating,
DENSE_RANK() 
OVER (ORDER BY actress_avg_rating DESC, total_votes DESC) AS rnk
FROM cte
ORDER BY rnk
LIMIT 3;

-- Q29. Get the following details for top 9 directors (based on number of movies):

-- Director id
-- Name
-- Number of movies
-- Average inter movie duration in days
-- Average movie ratings
-- Total votes
-- Min rating
-- Max rating
-- Total movie duration 

WITH cte AS (
    SELECT n.id AS director_id, 
           n.name AS director_name, 
           COUNT(m.id) AS movies_count,
           RANK() OVER (ORDER BY COUNT(m.id) DESC) AS rnk
    FROM names n
    INNER JOIN director_mapping d ON n.id = d.name_id
    INNER JOIN movie m ON m.id = d.movie_id
    GROUP BY n.id, n.name
),
cte2 AS (
    SELECT n.id AS director_id, 
           n.name AS director_name,
           m.id AS movie_id,
           m.date_published,
           r.avg_rating,
           r.total_votes,
           m.duration,
           LEAD(m.date_published) OVER (PARTITION BY n.id ORDER BY m.date_published) AS next_date_published,
           DATEDIFF(
               LEAD(m.date_published) OVER (PARTITION BY n.id ORDER BY m.date_published),
               m.date_published
           ) AS inter_movie_days
    FROM names n
    INNER JOIN director_mapping d ON n.id = d.name_id
    INNER JOIN movie m ON m.id = d.movie_id
    INNER JOIN ratings r ON m.id = r.movie_id
    WHERE n.id IN (
        SELECT director_id 
        FROM cte 
        WHERE rnk <= 9
    )
)
SELECT 
    cte2.director_id,
    cte2.director_name,
    COUNT(DISTINCT cte2.movie_id) AS number_of_movies,
    ROUND(AVG(cte2.inter_movie_days), 0) AS avg_inter_movie_days,
    ROUND(SUM(cte2.avg_rating * cte2.total_votes) / SUM(cte2.total_votes), 2) AS avg_rating,
    SUM(cte2.total_votes) AS total_votes,
    MIN(cte2.avg_rating) AS min_rating,
    MAX(cte2.avg_rating) AS max_rating,
    SUM(cte2.duration) AS total_duration
FROM cte2
GROUP BY cte2.director_id, cte2.director_name
ORDER BY number_of_movies DESC, avg_rating DESC;









