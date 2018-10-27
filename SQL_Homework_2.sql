use sakila; 
set sql_safe_updates = 0

-- 1a Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

select first_name as first_name
		 , last_name as last_name
		 , CONCAT(first_name, " ", last_name) as "Actor Name"
	  from actor;

-- 2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name FROM sakila.actor
where sakila.actor.first_name="Joe" ;

-- 2b  Find all actors whose last name contain the letters GEN
select * from sakila.actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order
select last_name, first_name from sakila.actor where last_name like ('%LI%');

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

-- 3a Create a column in the table actor named description and use the data type BLOB
alter table sakila.actor
add description BLOB;

-- 3b drop description
alter table actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name,count(*)
from actor      
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select last_name,count(*)
from actor
group by last_name
having count(*)>1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

update actor
set first_name = 'HARPO'
where actor_id = 172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

update actor
set first_name = 'GROUCHO'
where first_name ='HARPO';

-- 5a. 

show create table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address (and store) 

select first_name, last_name, address from staff
join store
on staff.store_id=store.store_id
join address
on staff.address_id=address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

select first_name, last_name, sum(amount) from payment
join staff
on payment.staff_id=staff.staff_id
where payment_date>='2005/08/01' and payment_date<='2005/08/31'
group by staff.staff_id; 

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select title, count(*) from film
inner join film_actor
on film.film_id=film_actor.film_id
group by film.film_id; 

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select count(*) from inventory
join film 
on inventory.film_id=film.film_id
where title='HUNCHBACK IMPOSSIBLE'
group by film.film_id; 

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

select first_name, last_name, sum(amount) from payment
inner join customer
on payment.customer_id=customer.customer_id
group by payment.customer_id
order by last_name ASC;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film 
where title like 'K%' or title like 'Q%' and language_id=1; 

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip

select first_name, last_name
	from actor
		where actor_id in
			(select actor_id 
			 	from film_actor 
			 		where film_id IN
			 			(select film_id 
						 	from film
						 		where title='Alone Trip'
						 )
			 )

-- 7c Use joins to retrive names and email addresses of all Canadian customers.

select first_name, last_name, email from customer
inner join address
on address.address_id=customer.address_id
inner join city
on city.city_id=address.city_id
inner join country
on country.country_id=city.country_id
where country='Canada';

-- 7d all movies that are family films

select title, name from film
inner join film_category
on film.film_id=film_category.film_id
inner join category
on category.category_id=film_category.category_id
where category.name='Family';

-- 7e Display the most frequently rented movies in descending order.

select title, count(rental_id) from film
inner join inventory
on film.film_id=inventory.film_id
inner join rental 
on inventory.inventory_id=rental.inventory_id
group by title
order by count(rental_id) desc;

-- 7f Write a query to display how much business, in dollars, each store brought in

select store.store_id, sum(amount) from store
inner join inventory
on inventory.store_id=store.store_id
inner join rental 
on inventory.inventory_id=rental.inventory_id
inner join payment
on rental.rental_id=payment.rental_id 
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select store_id, city, country from store
inner join address
on store.address_id=address.address_id
inner join city
on address.city_id=city.city_id
inner join country
on city.country_id=country.country_id;

-- 7h top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select category.name, sum(amount) from payment
inner join rental
on payment.rental_id=rental.rental_id
inner join inventory
on rental.inventory_id=inventory.inventory_id
inner join film_category
on inventory.film_id=film_category.film_id
inner join category
on film_category.category_id=category.category_id
group by category.name
order by sum(amount) desc
limit 5;


-- 8a Create view

create view top_five_genres as select category.name, sum(amount) from payment
inner join rental
on payment.rental_id=rental.rental_id
inner join inventory
on rental.inventory_id=inventory.inventory_id
inner join film_category
on inventory.film_id=film_category.film_id
inner join category
on film_category.category_id=category.category_id
group by category.name
order by sum(amount) desc
limit 5;

-- 8b How would you display the view that you created in 8a?

select * from `top_five_genres`;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view top_five_genres;

