/*
"Display the ff. fields of projects.
* Project - Defined as <Name> (<Descrip>) - <Type>
* Start Date
* End Date
* Estimated Cost"
*/
select NAME || '(' || DESCRIP || ') - ' || TYPE, START_DT, END_DT, EST_COST
from PROJECTS;

-- Display the Name and Estimate Cost of all projects whose estimate cost does not exceed $3,000,000.
select NAME, EST_COST 
where
EST_COST <= 3000000;

-- Display the Name, Estimate Cost and Mandays of all projects whose Mandays is between 50 and 200
select NAME, EST_COST, MANDAYS 
from PROJECTS 
where 
MANDAYS between 50 and 200; 

-- Display all columns for those projects whose name contains the word 'System'.
select * 
from PROJECTS 
where NAME like '%System%'; 

-- Retrieve the Name, End Date and Mandays of completed projects.  Completed Projects are projects which has ended before today.
select NAME, START_DT, END_DT 
FROM PROJECTS 
WHERE END_DT < to_date('23-JUN-20');
or
WHERE END_DT < sysdate; 

-- "Display the Name, Start Date and End Date of all projects where the duration is different from the number of mandays.

-- Duration - counting starts from Start Date and ends at End Date. 
E.g. a Monday to Friday project duration is 5 days, Jan 1 to Jan 31 is 31 days.

/*Hint: you can subtract dates."
select NAME, START_DT, END_DT 
FROM PROJECTS 
WHERE END_DT - START_DT +1 <> MANDAYS; 
*/

/* "Retrieve the Name and Duration of projects which lasted more than 3 months (assume that 1 month = 30 days)

Note: Refer to item above for description of duration" 
*/

select NAME, END_DT - START_DT+1 DURATION
FROM PROJECTS
WHERE END_DT - START_DT +1 >90; 

-- Display the name and estimated cost per manday of all projects in increasing order of estimated cost per manday.

select NAME, EST_CSOT/MANDAYS COST_PER_MANDAY
FROM PROJECTS
ORDER BY COST_PER_MANDAY; 

/*
"Retrieve the Name and Start Date, Mandays Spent of ongoing projects.  Order the result in increasing order of Start Date.

Ongoing projects are projects whose End Date is later than current date or End Date is empty.  
Mandays Spent refer to the number of days between start date of project and today (ie. Start Date = 01-Jan-2006, Current Date = 02-Jan-2006, Mandays Spent = 2)

Note: you can subtract dates."
*/

select NAME, START_DT, 
sysdate - START_DT +1 MANDAYS_SPENT
FROM PROJECTS
WHERE END_DT IS NULL or END_DT > sysdate
ORDER BY START_DT; 

-- Retrieve the first 3 projects and order the result in decreasing order of Estimated Cost
SELECT * 
FROM PROJECTS 
WHERE ROWNUM <=3
ORDER BY EST_COST desc; 

-- Display the disctinct Project Types from Projects
SELECT DISTINCT TYPE 
FROM PROJECTS; 