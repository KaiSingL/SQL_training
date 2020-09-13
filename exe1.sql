--Create a new table called LOANS with columns named LNO INTEGER, EMPNO INTEGER, TYPE varchar2(1), AMNT number(10,2), DESCRIP varchar2(400).  Column LNO is the primary key.  DESCRIP cannot contain null values.
create table LOANS(
  LNO integer,
  EMPNO integer,
  TYPE varchar2(1),
  AMNT number(10,2),
  DESCRIP varchar2(400) not null,
  constraint LOANS$PK primary key (LNO)
)
--Check the data in the Data sheet of this file; Create insert statements to insert those data into the LOANS table.
insert into LOANS (LNO, EMPNO, TYPE, AMNT, DESCRIP)
values (23, 7499, 'M', 20000, 'inital loan')

insert into LOANS (LNO, EMPNO, TYPE, AMNT, DESCRIP)
values (42, 7499, 'C', 20000, 'loan paid')

insert into LOANS (LNO, EMPNO, TYPE, AMNT, DESCRIP)
values (65, 7844, 'M', 3565.2, 'inital on existing loan')

--"Create a series of SQL statements that will update the LOANS  table by decreasing the length of DESCRIP column to only hold up to 200 bytes of data (values of more than 200 bytes must be truncated) 

--Hint: It is recommended that you insert your own records to test your created script.

You could use the Oracle function substr to extract the first n characters of a string (ie. substr (x, 1, 200) gets the first 200 chars of x)"
update LOANS set DESCRIP = substr(DESCRIP, 1, 200)

alter table LOANS modify DESCRIP varchar2(200)"