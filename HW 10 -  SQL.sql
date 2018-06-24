use sakila;
-- 1a. Display the first and last names of all actors from the table actor.

SELECT 
    first_name, last_name
FROM
    actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
    CONCAT(first_name, ' ', last_name)
FROM
    actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of_whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT 
    *
FROM
    actor
WHERE
    last_name LIKE '%gen%';
    
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT 
    *
FROM
    actor
WHERE
    last_name LIKE '%li%'
ORDER BY last_name , first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor
add column middle_name varchar(45) after first_name;


-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.

ALTER TABLE actor
modify column middle_name blob;

-- 3c. Now delete the middle_name column.
alter table actor
drop column middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*)
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(*) as actor_count
from actor
group by last_name
having actor_count > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.

update actor
set first_name = 'HARPO'
where first_name = 'groucho' and last_name = 'williams';


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor 
-- is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error.
--  BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
-- I don't feel like reinstalling sakila after applying this change.  adding savepoint to rollback to.

start transaction;
SAVEPOINT ugh;
SET SQL_SAFE_UPDATES=0;


UPDATE actor 
SET 
    first_name = CASE
        WHEN first_name = 'harpo' THEN 'GROUCHO'
        ELSE 'MUCHO GROUCHO'
    END;


ROLLBACK to ugh;
SET SQL_SAFE_UPDATES=1;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT 
    first_name, last_name, address
FROM
    staff AS s
        INNER JOIN
    address AS a ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT 
    first_name, last_name, SUM(amount) AS 'August 2005 Payments'
FROM
    staff AS s
        INNER JOIN
    payment AS p ON s.staff_id = p.staff_id
WHERE
    YEAR(payment_date) = 2005
        AND MONTH(payment_date) = 8
GROUP BY first_name , last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT 
    f.title, COUNT(a.actor_id)
FROM
    film AS f
        INNER JOIN
    film_actor AS fa ON f.film_id = fa.film_id
        INNER JOIN
    actor AS a ON a.actor_id = fa.actor_id
GROUP BY f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT 
    f.title, COUNT(*) AS 'Copies'
FROM
    inventory AS i
        INNER JOIN
    film AS f ON i.film_id = f.film_id
WHERE
    f.title = 'hunchback impossible'
GROUP BY f.title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'customer',
    SUM(p.amount)
FROM
    payment AS p
        INNER JOIN
    customer AS c ON p.customer_id = c.customer_id
GROUP BY customer
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT 
    *
FROM
    film AS f
WHERE
    language_id IN (SELECT 
            language_id
        FROM
            language
        WHERE
            name = 'English')
        AND REGEXP_LIKE(title, '^[kq]');  



-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT 
    *
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT 
    first_name, last_name, email
FROM
    customer AS c
        INNER JOIN
    address AS a ON a.address_id = c.address_id
        INNER JOIN
    city AS c2 ON c2.city_id = a.city_id
        INNER JOIN
    country AS c3 ON c3.country_id = c2.country_id
WHERE
    country = 'canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT 
    title, c.name
FROM
    film AS f
        INNER JOIN
    film_category AS fc ON f.film_id = fc.film_id
        INNER JOIN
    category AS c ON fc.category_id = c.category_id
WHERE
    c.name = 'family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT 
    title, COUNT(rental_id) AS times_rented
FROM
    rental AS r
        INNER JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
        INNER JOIN
    film AS f ON f.film_id = i.film_id
GROUP BY title
ORDER BY times_rented DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(amount) from store as s
inner join staff as s2 on s.manager_staff_id = s2.staff_id
inner join payment as p on p.staff_id = s2.staff_id
group by s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT 
    s.store_id, city, country
FROM
    store AS s
        INNER JOIN
    address AS a ON s.address_id = a.address_id
        INNER JOIN
    city AS c ON c.city_id = a.city_id
        INNER JOIN
    country AS c2 ON c2.country_id = c.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 
    c.name, SUM(p.amount) AS total_gross
FROM
    category AS c
        INNER JOIN
    film_category AS fc ON c.category_id = fc.category_id
        INNER JOIN
    inventory AS i ON i.film_id = fc.film_id
        INNER JOIN
    rental AS r ON r.inventory_id = i.inventory_id
        INNER JOIN
    payment AS p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY total_gross DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres
as SELECT 
    c.name, SUM(p.amount) AS total_gross
FROM
    category AS c
        INNER JOIN
    film_category AS fc ON c.category_id = fc.category_id
        INNER JOIN
    inventory AS i ON i.film_id = fc.film_id
        INNER JOIN
    rental AS r ON r.inventory_id = i.inventory_id
        INNER JOIN
    payment AS p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY total_gross DESC
LIMIT 5;


-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;

