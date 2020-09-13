--List the department names of all departments that did not hire any employees in 1982.	
select DNAME
  from DEPT D
 where not exists (select 1
                     from EMP E
                    where E.DNO = D.DNO
                      and to_char(E.HIREDATE,'YYYY') = '1982')

--Display all the department numbers and corresponding department names together with department employees (employee number,  employee name). Display department information even if no employee exists in that department.	

select E.DNO, D.DNAME, E.EMPNO, E.ENAME
  from EMP E, DEPT D
 where E.DNO (+) = D.DNO;

-- For each employee whose salary exceeds their supervisor's salary, list the employee's name and salary and the supervisor's name and salary.
-- Hint: you can join a table to itself	
select A.ENAME EMPLOYEE, A.SAL EMPLOYEE_SAL, 
       B.ENAME SUPERVISOR, B.SAL SUPERVISOR_SAL
  from EMP A, EMP B
 where A.MGR = B.EMPNO
   and A.SAL > B.SAL

--List the name, job, and salary of employees who have the same job and salary as RYAN (note: do not include RYAN).	

select A.ENAME, A.JOB, A.SAL
  from EMP A, EMP B
 where A.SAL=B.SAL
   and A.JOB=B.JOB
   and B.ENAME = 'RYAN'
   and A.ENAME <> 'RYAN'

-- List the employee name, job, salary, grade and department name of employees that earn more than the average salary of employees in their department.  Sort by salary, displaying the highest salary first.	
select e1.ename, e1.job, e1.sal, grade, avgsal.dname
  from emp e1,
       (select d.DNO, d.dname, avg(e.sal) average
          from emp e, dept d
         where e.DNO = d.DNO
         group by d.DNO, d.dname
       ) avgsal,
       salgrade s
 where e1.DNO = avgsal.DNO
   and e1.sal > avgsal.average
   and e1.sal >= s.losal
   and e1.sal <= s.hisal
 order by e1.sal desc
--Write a statement to show the number of employees under each salary grade per department. Display Department No., Salary Grade, and number of employees.	
select d.DNO, s.GRADE, count(e.EMPNO)
  from EMP e, DEPT d, SALGRADE s
 where e.DNO = d.DNO
   and e.SAL between s.LOSAL and s.HISAL
 group by d.DNO, s.GRADE

-- Write a statement to show the total salary paid to each department as of the report date.  The salary for each employee must be computed starting from the date he was hired until the report date (inclusive).  Work on the assumption that salary is being paid monthly and one month is equivalent to 30 days.  For Salesman, commission is given every 120 days of employment (for non-Salesman, assume that no commission is given).  Display the Department No. and Total Salary. Do not use months_between()
--Note: report date = current date. Also, there's no need to compute for the salary in excess of 30 days and for the commission in excess of 120 days	


select d.DNO, 
       sum(e.SAL*floor((sysdate - e.HIREDATE + 1)/30)+decode(e.JOB,'SALESMAN',nvl(e.COMM,0),0)*floor((sysdate-e.HIREDATE)/120)) TOTAL_SAL
  from EMP e, DEPT d
 where e.DNO(+) = d.DNO
 group by d.DNO
 ORDER BY d.DNO;
--List all employees who have no subordinates. Use EMP.MGR. Do not use set operations for this.	
select *
from EMP E1
where not exists (select EMPNO
                   from EMP E2
                  where E2.MGR = E1.EMPNO);
--List all managers who are handling employees from a different department. Display the following columns: ENAME of Manager, DNO of Manager, ENAME of Employee (who is from a different department), DNO of Employee.
--Note: Manager is the person whose JOB = 'MANAGER'	
select M.ENAME, M.DNO MDEPT, E.ENAME, E.DNO EMPDEPT
  from EMP E, EMP M
 where E.MGR = M.EMPNO
   and M.JOB = 'MANAGER'
   and M.DNO <> E.DNO;
--List all departments and the employee with the lowest salary for each department. Display Department No., Department Name, Employee Number, Employee Name, Salary.	
select A.DNO, B.DNAME, C.EMPNO, C.ENAME, C.SAL
  from (select min(SAL) MIN_SAL, DNO
          from EMP
         group by DNO) A,
       DEPT B, EMP C
 where (A.DNO = B.DNO)
   and C.DNO = A.DNO
   and C.SAL = A.MIN_SAL;
--Display the manager who has the most no. of employees assigned to him.  Field to be displayed: Manager name	SELECT M.ENAME 
  FROM EMP M, EMP E
 WHERE E.MGR = M.EMPNO
 GROUP BY M.EMPNO, M.ENAME
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) 
                     FROM EMP M, EMP E
                    WHERE E.MGR = M.EMPNO
                    GROUP BY M.EMPNO);
--List employees belonging to a higher salary grade than other employees of the same department which was hired earlier than him/her. Fields to be displayed: Name, Salary, Grade, Dept No of the employee earning more	
SELECT DISTINCT E1.ENAME, E1.SAL, G1.GRADE, E1.DNO
  FROM EMP E1, SALGRADE G1, EMP E2, SALGRADE G2
 WHERE E1.DNO = E2.DNO
   AND E1.SAL BETWEEN G1.LOSAL AND G1.HISAL
   AND E2.SAL BETWEEN G2.LOSAL AND G2.HISAL
   AND G1.GRADE > G2.GRADE
   AND E1.HIREDATE > E2.HIREDATE;   