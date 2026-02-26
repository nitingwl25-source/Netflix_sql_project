-- LIBRARY_PROJECT2


create table branch(
branch_id varchar(10) primary key,
manager_id varchar(10),
branch_address varchar(55),
contact_no varchar(10)
);

alter table branch
alter column contact_no  type varchar(30)





select * from branch

drop table if exists employees;
create table employees(
emp_id varchar(10) primary key	,
emp_name varchar(25),
position varchar(15),
salary int ,
branch_id varchar(25)
);

alter table employees
alter column salary type float 


create table books
(
isbn varchar(25) primary key,
book_title varchar(100),
category varchar(35),
rental_price float,
status varchar(15),
author varchar(50),
publisher varchar(100)

);

drop table if exists members;
create table members(
member_id varchar(20) primary key,
member_name	varchar(50),
member_address varchar(75),
reg_date date

);


create table issued_status(
issued_id varchar(20) primary key	,
issued_member_id varchar(50)	,
issued_book_name varchar(75)	,
issued_date	date ,
issued_book_isbn varchar(30)	,
issued_emp_id varchar(10)

)

create table return_status(
return_id varchar(20) primary key	,
issued_id varchar(20)	,
return_book_name varchar(75)	,
return_date	date ,
return_book_isbn varchar(20)

)

 -- add constaints
 alter table issued_status
 add constraint fk_members
 foreign key(issued_member_id)
 references members(member_id);

 alter table issued_status
 add constraint fk_books
 foreign key(issued_book_isbn)
 references books(isbn);

 alter table issued_status
 add constraint fk_employees
 foreign key(issued_emp_id)
 references employees(emp_id);

 alter table employees
 add constraint fk_branch
 foreign key(branch_id)
 references branch(branch_id);

 alter table return_status
 add constraint fk_return_status
 foreign key(issued_id)
 references issued_status(issued_id);




select * from return_status;

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
select * from members;
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101'

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

select * from issued_status

delete from issued_status
where issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id ,
count(issued_book_isbn) as total_books_issued 
from issued_status
group by 1
having count(issued_book_isbn) >1;


-- . CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**
create table no_of_book_issued as (
select b.isbn , b.book_title , 
count(ist.issued_id) as total_book_count
from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1 , 2 
order by total_book_count desc);


select * from no_of_book_issued;

-- Task 7. Retrieve All Books in a Specific Category:
select * from books
where category = 'Classic';

select category , count(book_title) as total_books
from books
group by 1

-- Task 8: Find Total Rental Income by Category:
select 
b.category , 
sum(b.rental_price) as total_rental,
count(*) total_no_of_books
from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1  
order by 2  desc;

-- 9 List Members Who Registered in the Last 180 Days:
select member_id , member_name from members
where reg_date >= current_date - interval '180 days'

-- 10 List Employees with Their Branch Manager's Name and their branch details:
select e.* , e2.emp_name, b.manager_id as manager from branch b 
join employees e
on e.branch_id = b.branch_id
join employees e2
on e2.emp_id = b.manager_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold (7):
create table books_greater_than_7 as 
select * from books
where rental_price > 7 ;

select * from books_greater_than_7


-- Task 12: Retrieve the List of Books Not Yet Returned
select * from issued_status ist
left join return_status rs
on ist.issued_id = rs.issued_id
where rs.return_id is null;


-- Advanced SQL Operations
--Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books 
-- (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;



select mbr.member_id, mbr.member_name , 
bk.book_title , ist.issued_date , 
current_date - ist.issued_date as overdues_days
from issued_status ist
join members mbr
on mbr.member_id = ist.issued_member_id
join books bk
on bk.isbn = ist.issued_book_isbn
left join return_status rs
on rs.issued_id = ist.issued_id
where return_date is null
and(current_date - ist.issued_date)  > 30 
order by 1;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table 
-- to "Yes" when they are returned (based on entries in the return_status table).


select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

CREATE OR REPLACE PROCEDURE add_return_record(p_return_id varchar(20)  ,p_issued_id varchar(20))
LANGUAGE plpgsql
AS $$

DECLARE
 v_isbn varchar(50);
 v_book_name varchar(75);
BEGIN
	INSERT INTO return_status(return_id , issued_id, return_date)
	VALUES
	(p_return_id, p_issued_id,current_date);


	SELECT 
	issued_book_isbn , issued_book_name into v_isbn  , v_book_name from issued_status
	where issued_id = p_issued_id;

	UPDATE books
    SET status = 'Yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'thank you for returning the book :';

END;
$$



call add_return_record('RS138','IS135')


select * from issued_status

select * from return_status

SELECT * FROM BOOKS
WHERE ISBN = '978-0-307-58837-1'




-- Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch, 
--showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
create table branch_reports as 
select b.branch_id , b.branch_address,count(ist.issued_id) as total_no_Issuedbooks,
count(rs.return_id) as total_return_books , sum(bk.rental_price) as total_revenue

from issued_status ist
join employees e 
on ist.issued_emp_id = e.emp_id
join branch as b 
on e.branch_id = b.branch_id
left join return_status as rs
on rs.issued_id = ist.issued_id
join books bk
on ist.issued_book_isbn = bk.isbn

group by 1 , 2
order by total_revenue desc;



select * from branch_reports;


--Task 16: CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
--containing members who have issued at least one book in the last 6 months.

create table active_members as 
select * from members where member_id 
IN 
(select distinct issued_member_id  from issued_status 
where 
issued_date >= current_date -  interval  '6 month')
;

select * from active_members;

--Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
--Display the employee name, number of books processed, and their branch.

select  e.emp_name, b.*, count(ist.issued_id) as total_counts
from issued_status ist
join employees e 
on ist.issued_emp_id  = e.emp_id
join branch b
on e.branch_id = b.branch_id 
group by 1 , 2 
order by total_counts desc
limit 3;

-- Task 18: Identify Members Issuing High-Risk Books
--Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
-- Display the member name, book title, and the number of times they've issued damaged books.


SELECT 
    m.member_name,
    b.book_title,
    COUNT(*) AS damaged_issue_count
FROM issued_status ist
JOIN members m 
    ON m.member_id = ist.issued_member_id
JOIN books b 
    ON b.isbn = ist.issued_book_isbn
WHERE ist.status = 'damaged'
GROUP BY m.member_name, b.book_title
HAVING COUNT(*) > 2
ORDER BY damaged_issue_count DESC;

   
---- 19




-- 20 Task 20: Create Table As Select (CTAS) Objective: Create a CTAS 
--(Create Table As Select) query to identify overdue books and calculate fines.

-- Description: Write a CTAS query to create a new table that lists each member and the books they have 
-- issued but not returned within 30 days. The table should include: The number of overdue books. 
--The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
-- The resulting table should show: Member ID Number of overdue books Total fines

CREATE TABLE overdue_summary AS
SELECT 
    issued_member_id AS member_id,

    -- Count overdue books
    COUNT(
        CASE 
            WHEN current_date - issued_date > 30 
            THEN 1 
        END
    ) AS number_of_overdue_books,

    -- Calculate total fine
    SUM(
        CASE 
            WHEN current_date - issued_date > 30 
            THEN (current_date - issued_date - 30) * 0.50
            ELSE 0
        END
    ) AS total_fines,

    -- Total books issued
    COUNT(*) AS total_books_issued

FROM issued_status
GROUP BY issued_member_id;



-- Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a 
--library system. Description: Write a stored procedure that updates the status of a book in the library based -
--on its issuance. The procedure should function as follows: The stored procedure should take the book_id as an input 
--parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it 
--should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'),
--the procedure should return an error message indicating that the book is currently not available.



select * from issued_status;

select * from books;

CREATE OR REPLACE PROCEDURE  book_issuance(p_issued_id varchar(20) , 
p_issued_member_id varchar(50), p_issued_book_isbn varchar(30), p_issued_emp_id varchar(10))
LANGUAGE plpgsql

AS $$

DECLARE 
v_status varchar(15);

BEGIN

SELECT status into v_status from books
where isbn  = p_issued_book_isbn;

	IF 
		 v_status = 'yes' then 
		 insert into issued_status(issued_id , issued_member_id, issued_date , issued_book_isbn,issued_emp_id)
		 values
		 (p_issued_id,p_issued_member_id, current_date ,p_issued_book_isbn, p_issued_emp_id);

		UPDATE books
	    SET status = 'no'
		WHERE isbn = p_issued_book_isbn;
		
		 RAISE NOTICE 'Book record added succesfully for the book : %',p_issued_book_isbn;
	 
	
	ELSE
		 RAISE NOTICE  'sorry book is not available for the book : %',p_issued_book_isbn;
	
	END IF;	 
		 

END ; 
$$

CALL book_issuance('IS145','C108','978-0-553-29698-2','E104')

CALL book_issuance('IS146','C108','978-0-7432-7357-1','E104')


select * from issued_status;

select * from books
where isbn  = '978-0-553-29698-2' -- yes   978-0-7432-7357-1  -- no





