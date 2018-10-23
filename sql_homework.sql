use  sakila;
-- 1a first and last names of all actors from the table `actor`
select first_name, last_name
from actor;

-- 1b  first and last name of each actor in a single column in upper case letters
select concat_ws(' ',upper(first_name), upper(last_name)) as 'Actor Name'
from actor;

-- 2a find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe.
select actor_id, first_name, last_name
from actor
where first_name='Joe';

-- 2b Find all actors whose last name contain the letters `GEN
select actor_id, first_name, last_name
from actor
where upper(last_name) like '%GEN%';

-- 2c Find all actors whose last names contain the letters `LI` order by last_name then first_name
select actor_id,last_name, first_name 
from actor
where upper(last_name) like '%LI%'
order by last_name, first_name;

-- 2d display  `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country  in ('Afghanistan', 'Bangladesh', 'China');

-- 3a create a column in the table `actor` named `description` and use the data type `BLOB`
alter table actor
add column `description` blob;

-- 3b delete the description column

set sql_safe_updates=0;

alter table actor 
	drop column `description`;
-- verify the column was removed as desired    
select * from actor;

set sql_safe_updates=1;

-- 4a. List the last names of actors, as well as how many actors have that last name
select last_name, count(last_name)
from actor
group by last_name;

-- 4b same as 4a plus only for names that are shared by at least two actors
select last_name, count(last_name)
from actor
group by last_name
having count(last_name)>1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
-- check data
select first_name, last_name
from actor
where last_name = 'WILLIAMS';
-- make the change from groucho to harpo
update actor
 set first_name = 'HARPO' 
 where last_name = 'WILLIAMS' and first_name='GROUCHO';
 
-- verify change
select first_name, last_name
from actor
where last_name = 'WILLIAMS';

-- 4D if the first name of the actor is currently `HARPO`, change it to `GROUCHO` 
-- THESE WERE THE INSTRUCTIONS, BUT I ASSUMED IT ONLY MEANS IF THE LAST NAME IS WILLIAMS
update actor
 set first_name = 'GROUCHO' 
 where last_name = 'WILLIAMS' and first_name='HARPO';
-- verify AGAIN
select first_name, last_name
from actor
where last_name = 'WILLIAMS'; 
 
 -- 5A QUERY TO RECREATE THE CREATE TABLE Statement for address table
 SHOW CREATE TABLE ADDRESS;
 
 -- using Database Reverse Engineer for the schema EER diagram was more helpful though : )
 
--  6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member.
select * from staff;

select first_name, last_name, address
from staff join address
using (address_id);

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005.
select first_name, last_name, sum(amount) as 'total amount rung'
from payment join staff
using (staff_id)
where payment_date between '2005-08-01 00:00:00.000000' and '2005-08-31 23:59:59.999999' 
group by last_name, first_name;

-- 6c. List each film and the number of actors who are listed for that film
select title, count(actor_id) as 'actor count'
from film_actor join film
using (film_id)
group by film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select count(*)
from inventory join film
using(film_id)
where title = 'Hunchback Impossible';

-- 6e. list the total paid by each customer. List the customers alphabetically by last name:
select last_name, first_name,  sum(amount)
from payment join customer
using (customer_id)
group by last_name,first_name
order by last_name, first_name;

-- 7a Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title, language_id
from film join language
using (language_id)
where name = 'English' and film_id in (select film_id
									from film
									where title like 'K%' OR title like 'Q%' );
                                
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.  
select first_name, last_name
from actor join film_actor
using (actor_id) 
where film_id in (                             
				select film_id 
					from film
					where title ='Alone Trip'
                );
                
-- 7c. you will need the names and email addresses of all Canadian customers.
select first_name, last_name, email
from customer join address
using(address_id)
where city_id in( 
			select city_id
				from city join country
				using (country_id)
				where country = 'Canada'
                );
                
-- 7d  Identify all movies categorized as family films
select title
from film_list
where category = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select title, count(*) as rental_count
from film join (inventory,rental)
on(film.film_id= inventory.film_id and inventory.inventory_id=rental.inventory_id)
group by film.film_id
order by rental_count desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- using the view already created in sakila total of amounts 67406.56
select store,total_sales
from sales_by_store;

-- using my own query based on the film as inventory of a given store
-- total of amounts 67406.56
select store_id,sum(amount)
from inventory i join (rental r,payment p)
on(i.inventory_id=r.inventory_id and r.rental_id=p.rental_id)
group by store_id;

-- using my query based on the customer as associated with a given store 
--  different break down total of amounts 67416.51
select store_id,sum(amount)
from customer join payment
using(customer_id)
group by store_id;

-- total payments in the table 67416.51 same total as 2nd query above
select sum(amount)
from payment;

-- so 9.95 from the payment table is not associated with a rental 
-- I found the 5 rows in the payment table where payments have a null rental_id
select payment_id,p.rental_id, amount
from payment p left join rental r
on p.rental_id = r.rental_id
where r.rental_id is null;
                        
--  7g. Write a query to display for each store its store ID, city, and country.
select store_id,city,country
from store s join (address a,city cty,country c)
on (s.address_id = a.address_id and a.city_id=cty.city_id and cty.country_id=c.country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
select c.name as genre, sum(amount) as category_total
from category c join(film_category fc ,inventory i,rental r, payment p)
on (c.category_id=fc.category_id and fc.film_id=i.film_id and i.inventory_id=r.inventory_id and r.rental_id=p.rental_id)
group by c.category_id
order by category_total desc
limit 5;

-- 8a create a view from 7h 
create view top_genre as
select c.name as genre, sum(amount) as category_total
from category c join(film_category fc ,inventory i,rental r, payment p)
on (c.category_id=fc.category_id and fc.film_id=i.film_id and i.inventory_id=r.inventory_id and r.rental_id=p.rental_id)
group by c.category_id
order by category_total desc
limit 5;

-- 8b display the view that you created in 8a
select * from top_genre;

-- 8c delete view from 8a
drop view if exists top_genre;

