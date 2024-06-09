 --Q1: who is the senior most employee based on job title?

 select * from employee
 ORDER BY levels DESC
 select top 1 * from employee
 where levels=7.00

 --Q2: which countries have the most invoices?
  
 select count(*) as [countries ],billing_country
 from invoice 
 group by billing_country
 order by countries  desc

 --Q3 What are top three values of total invoices?

 select  total 
 from invoice
 order by total desc
 
  
--Q4:Which city has the  best customers? we would we would like to throw a promotional music festival in the city we made the most money.Wrte a  querry that returns one city that has the highest sum of invoice  totals .Return  both the city name and sum of invoice totals.

select sum(total) as [invoice_total] ,billing_city
from invoice
group by billing_city
order by invoice_total desc

--Q5:who is the best customer ? The customer who has spent the most money will be declared  the best  customer .Write a query that returns the person who has spent the most money .

SELECT 
    TOP 1
    customer.customer_id, 
    customer.first_name, 
    customer.last_name, 
    SUM(invoice.total) AS [total]
FROM 
    customer
JOIN 
    invoice 
ON 
    customer.customer_id = invoice.customer_id
GROUP BY 
    customer.customer_id, 
    customer.first_name, 
    customer.last_name
ORDER BY 
    [total] DESC;

 --Q6: Write query to return the email, first name , last name  & Genre of all Rock Music listeners.Return your list ordered alphabetically by email starting with A?
 SELECT DISTINCT email, first_name,last_name
 FROM customer
 JOIN invoice on customer.customer_id = invoice.customer_id 
 JOIN invoice_line on invoice.invoice_id = invoice_line.invoice_id
 where track_id in(
       select track_id from track
	   join genre on track.genre_id = genre.genre_id
	   where genre.name like 'Rock'

)
order by email;

--Q7: let's invite the artist who have written  the most rock music in our dataset. Write a query  that returns the artist  name and total track count of top 10 rock bands.
SELECT TOP 10 artist.artist_id, artist.name, COUNT(track.track_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC;

-
--Q8: Return all the track names that have a song length longer than the average song lenth. Return the Name and  Milliseconds for each track  Order by  song length with the longest  songs listed first.
SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

--Q9:Find how much amount spent by each customer on artist?Write a query to return customer name ,artist name and total spent.

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, 
	       artist.name AS artist_name, 
	       SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id, artist.name
)
SELECT c.customer_id, 
       c.first_name, 
       c.last_name, 
       bsa.artist_name, 
       SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;


 --Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.For countries where 
--the maximum number of purchases is shared return all Genres.


 WITH sales_per_country AS (
    SELECT COUNT(*) AS purchases_per_genre, 
           customer.country, 
           genre.name, 
           genre.genre_id
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
),
max_genre_per_country AS (
    SELECT MAX(purchases_per_genre) AS max_genre_number, 
           country
    FROM sales_per_country
    GROUP BY country
)
SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country 
    ON sales_per_country.country = max_genre_per_country.country
   AND sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number
ORDER BY sales_per_country.country;

-- Q11: Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.
WITH Customer_with_country AS (
    SELECT 
        customer.customer_id,
        first_name,
        last_name,
        billing_country,
        SUM(total) AS total_spending,
        ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, first_name, last_name, billing_country
)
SELECT * 
FROM Customer_with_country 
WHERE RowNo = 1
ORDER BY billing_country ASC, total_spending DESC;




