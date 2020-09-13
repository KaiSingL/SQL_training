--List the department names of all departments that did not hire any employees in 1982.	
SELECT DISTINCT DNAME 
FROM DEPT
MINUS
SELECT D.DNAME 
FROM DEPT D, EMP E
WHERE TO_CHAR(E.HIREDATE,'YY')='82'
AND E.DNO = D.DNO;

--ANS 2
 SELECT DISTINCT D.DNAME
   FROM DEPT D, EMP E
   WHERE D.DNO = E.DNO 
   AND TO_CHAR(E.HIREDATE,'YY') <> '82';
--Display all the department numbers and corresponding department names together with department employees (employee number,  employee name). Display department information even if no employee exists in that department.	
SELECT D.DNO, D.DNAME, E.EMPNO, E.ENAME
FROM DEPT D, EMP E
WHERE E.DNO(+) = D.DNO;
--For each employee whose salary exceeds their supervisor's salary, list the employee's name and salary and the supervisor's name and salary.
--Hint: you can join a table to itself
SELECT E.ENAME EMPLOYEE, E.SAL EMPLOYEE_SAL,   EE.ENAME SUPERVISOR, EE.SAL SUPERVISOR_SAL
  FROM EMP E, EMP EE
  WHERE E.MGR = EE.EMPNO 
  AND E.SAL > EE.SAL;
--List the name, job, and salary of employees who have the same job and salary as RYAN (note: do not include RYAN).	SELECT A.ENAME,A.JOB,A.SAL
  FROM EMP A, EMP B
  WHERE B.ENAME = 'RYAN' 
  AND A.ENAME <> B.ENAME
  AND A.JOB = B.JOB
  AND A.SAL = B.SAL;

--ANS 2
SELECT A.ENAME, A.JOB, A.SAL
  FROM EMP A, (SELECT * FROM EMP B
  WHERE ENAME = 'RYAN') B
  WHERE A.ENAME <> B.ENAME
  AND A.JOB = B.JOB
  AND A.SAL = B.SAL;
--List the employee name, job, salary, grade and department name of employees that earn more than the average salary of employees in their department.  Sort by salary, displaying the highest salary first.	SELECT E.ENAME NAME, E.JOB, E.SAL SALARY, G.GRADE, AVGSAL.DNAME
FROM EMP E, SALGRADE G, 
  (SELECT D.DNO, D.DNAME, AVG(EMP.SAL) AVG_SAL
  FROM EMP, DEPT D
  WHERE EMP.DNO = D.DNO
  GROUP BY D.DNO, D.DNAME) AVGSAL 
WHERE E.SAL <=G.HISAL
AND E.SAL >= G.LOSAL
AND E.SAL >= AVGSAL.AVG_SAL
AND E.DNO = AVGSAL.DNO
ORDER BY E.SAL DESC;

-- ANS 2
SELECT E.ENAME, E.JOB, E.SAL, S.GRADE, D.DNAME
  FROM EMP E, SALGRADE S, DEPT D, 
    (SELECT DNO, AVG(SAL) SAL FROM EMP GROUP BY DNO) A
  WHERE E.SAL BETWEEN S.LOSAL AND S.HISAL
    AND E.DNO = D.DNO
    AND E.DNO = A.DNO
    AND E.SAL >= A.SAL
  ORDER BY E.SAL DESC;
--Write a statement to show the number of employees under each salary grade per department. Display Department No., Salary Grade, and number of employees.
SELECT T.DNO, T.GRADE, COUNT(T.GRADE) NO
FROM EMP E,
(SELECT EE.DNO, G.GRADE
  FROM EMP EE, SALGRADE G
  WHERE EE.SAL <= G.HISAL
  AND EE.SAL >= G.LOSAL) T
WHERE E.DNO = T.DNO
GROUP BY T.DNO, T.GRADE
ORDER BY T.DNO DESC, T.GRADE DESC;
-- Write a statement to show the total salary paid to each department as of the report date.  The salary for each employee must be computed starting from the date he was hired until the report date (inclusive).  Work on the assumption that salary is being paid monthly and one month is equivalent to 30 days.  For Salesman, commission is given every 120 days of employment (for non-Salesman, assume that no commission is given).  Display the Department No. and Total Salary. Do not use months_between()
--Note: report date = current date. Also, there's no need to compute for the salary in excess of 30 days and for the commission in excess of 120 days	

SELECT D.DNO, ROUND(SUM(A.TOTAL_SAL),2) TOTAL_SAL
  FROM (SELECT DNO, FLOOR((SYSDATE-HIREDATE+1)/30)*SAL+NVL(COMM,0)*FLOOR((SYSDATE-HIREDATE)/120) TOTAL_SAL
  FROM EMP) A, DEPT D
  WHERE A.DNO (+) = D.DNO
  GROUP BY D.DNO
  ORDER BY D.DNO;

--ANS 2
SELECT D.DNO, ROUND(SUM(FLOOR((SYSDATE-E.HIREDATE+1)/30)*E.SAL+
  NVL(E.COMM,0)*FLOOR((SYSDATE-E.HIREDATE)/120))) TOTAL_SAL
  FROM EMP E, DEPT D
  WHERE E.DNO(+) = D.DNO
  GROUP BY D.DNO
  ORDER BY D.DNO;
--List all employees who have no subordinates. Use EMP.MGR. Do not use set operations for this.	

SELECT * FROM EMP A
  WHERE NOT EXISTS 
  (SELECT EMPNO FROM EMP B
  WHERE B.MGR = A.EMPNO)
  ORDER BY ENAME;

-- ANS 2
SELECT * 
  FROM EMP A
  WHERE EMPNO NOT IN (SELECT
  B.MGR FROM EMP B WHERE A.EMPNO = B.MGR);
--List all managers who are handling employees from a different department. Display the following columns: ENAME of Manager, DNO of Manager, ENAME of Employee (who is from a different department), DNO of Employee.
--Note: Manager is the person whose JOB = 'MANAGER'	
SELECT E1.ENAME MAN_NAME, E1.DNO MAN_DNO, E2.ENAME EMP_NAME, E2.DNO EMP_DNO
  FROM EMP E1, EMP E2
  WHERE E1.JOB = 'MANAGER'
  AND E1.EMPNO = E2.MGR
  AND E1.DNO <> E2.DNO
  ORDER BY E1.DNO;  

--ANS 2
SELECT E1.ENAME, E1.DNO, E2.ENAME, E2.DNO
  FROM EMP E1, EMP E2
  WHERE E1.DNO <> E2.DNO
  AND E1.EMPNO = E2.MGR
  ORDER BY E1.DNO;

-- ANS 3
SELECT E.*
  FROM EMP E, (SELECT MGR, COUNT(1) COUNT
  FROM EMP GROUP BY MGR) A
  WHERE E.EMPNO = A.MGR (+)
  AND A.COUNT IS NULL
  ORDER BY E.ENAME;
-- List all departments and the employee with the lowest salary for each department. Display Department No., Department Name, Employee Number, Employee Name, Salary.
SELECT D.DNO, D.DNAME, E1.EMPNO, E1.ENAME, E1.SAL
  FROM DEPT D, EMP E1, (SELECT DNO, MIN(SAL) SAL FROM EMP 
  GROUP BY DNO) E2
  WHERE D.DNO = E2.DNO
  AND E1.SAL = E2.SAL
  ORDER BY D.DNO;

-- ANS 2
SELECT D.DNO, D.DNAME, E.EMPNO, E.ENAME, E.SAL
  FROM DEPT D, EMP E, (SELECT DNO, MIN(SAL) SAL FROM EMP GROUP BY DNO) A
  WHERE D.DNO = E.DNO
  AND E.SAL = A.SAL;
--Display the manager who has the most no. of employees assigned to him.  Field to be displayed: Manager name	
SELECT * FROM 
  (SELECT MGR, COUNT(1) COUNT, DENSE_RANK() OVER (ORDER BY COUNT(1) DESC) AS RANK 
  FROM EMP GROUP BY MGR)
  WHERE RANK <=1;

--List employees belonging to a higher salary grade than other employees of the same department which was hired earlier than him/her. Fields to be displayed: Name, Salary, Grade, Dept No of the employee earning more	

SELECT DISTINCT A.ENAME, A.SAL, A.GRADE, A.DNO
  FROM 
  (SELECT E.*, S.GRADE
    FROM EMP E, SALGRADE S
    WHERE E.SAL BETWEEN LOSAL AND HISAL) A,
  (SELECT E.*, S.GRADE
    FROM EMP E, SALGRADE S
    WHERE E.SAL BETWEEN LOSAL AND HISAL) B
  WHERE A.DNO = B.DNO
  AND A.GRADE > B.GRADE
  AND A.HIREDATE > B.HIREDATE;