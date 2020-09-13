/*
Display all Staff members who have more than one project role throughout all the projects he is involved in (required column: User ID).  

Note: The staff member may belong to multiple projects but must have more than one role in EACH project.	15	PROJECT_STAFF
PROJECT_ROLE	1. Staff member is involved in multiple projects wherein he has one role in some projects but multiple roles in some (must not be retrieved)	
*/
SELECT DISTINCT N.USER_ID
  FROM
  (SELECT A.*, B.ROLE
    FROM PROJECT_STAFF A, PROJECT_ROLE B
    WHERE A.PROJECT_STAFF_ID = B.PROJECT_STAFF_ID) N,
  (SELECT A.*, B.ROLE
    FROM PROJECT_STAFF A, PROJECT_ROLE B
    WHERE A.PROJECT_STAFF_ID = B.PROJECT_STAFF_ID) M
  WHERE N.USER_ID = M.USER_ID
  AND N.ROLE <>M.ROLE;
/*  
Retrieve all project modules (required columns: Project, Functiond ID, Function Description) that satisfy the following conditions:

i.) Current status is 'FT' (For Testing) or 'T' (Testing)
ii.) No bug fixing effort has been logged for the Function (PRJ_TC.LEVEL1 = 'Bug fixing'. Use PRJ_PD.LEVEL2 to get the Function ID of a task in a project).

Notes:
* We can have the same Function ID for different projects which will be considered as different module.
* Bug fixing effort doesn't necessarily have to be done by developers assigned to the module	20	PRJ_TASK
PRJ_EFFORT
PRJ_PD
PRJ_TC	1. Project module with status For Testing and has no Bug Fixing effort (must be retrieved)
2. Project module with status Coding (must not be retrieved)
3. Project module with status For Testing and has Bug Fixing effort (must not be retrieved)	

*/
SELECT DISTINCT A.PROJECT, A.FUNC_ID, A.FUNC_DESCRIP
  FROM PRJ_TASK A, PRJ_EFFORT E, PRJ_PD P, PRJ_TC T
  WHERE A.STATUS IN ('FT','T')
  AND T.LEVEL1 <> 'Bug fixing'
  AND T.PROJECT = P.PROJECT
  AND P.LEVEL2 = A.FUNC_ID;

/*
Display the total development effort and testing effort spent by each project in each year (required columns: Project, Year, Dev Effort, Testing Effort). Only display projects with effort.

Development effort is effort logged with PRJ_TC.LEVEL1 = 'Coding'
Testing effort is effort logged with PRJ_TC.LEVEL1 = 'Testing'
Output must be sorted by Project, Year.

Example:
Project      Year  Dev Effort Testing Effort
DRAS        2003  1000.98    0
DRAS        2004  1000.98    2000.45
EPATCOM 2000  1000.98    2000.45
EPATCOM 2001  1000.98    2000.45	15	PRJ_TC
PRJ_EFFORT	1. Have Dev Effort but no Testing Effort (project must still be retrieved)
2. Have Testing Effort but no Dev Effort (project must still be retrieved)
3. Both have no effort (must not be retrieved)	
*/
CREATE OR REPLACE VIEW DEV_EFF AS 
  SELECT E.PROJECT,
  TO_CHAR(E.EFFORT_DT,'YYYY') YEAR, 
  SUM(E.EFFORT) DEV_EFFORT
  FROM PRJ_TC T, PRJ_EFFORT E
  WHERE T.LEVEL1 = 'Coding'
  AND E.PRJ_TC = T.CODE
  GROUP BY TO_CHAR(E.EFFORT_DT,'YYYY'), E.PROJECT;

CREATE OR REPLACE VIEW TEST_EFF AS
  SELECT E.PROJECT,
  TO_CHAR(E.EFFORT_DT, 'YYYY') YEAR,
  SUM(E.EFFORT) TESTING_EFFORT
  FROM PRJ_TC T, PRJ_EFFORT E
  WHERE T.LEVEL1 = 'Testing'
  AND E.PRJ_TC = T.CODE
  GROUP BY E.PROJECT,  TO_CHAR(E.EFFORT_DT, 'YYYY');

CREATE VIEW COM_EFF AS
  SELECT E.PROJECT P, E.YEAR Y, D.DEV_EFFORT D, T.TESTING_EFFORT T
  FROM TEST_EFF T, DEV_EFF D, 
  (SELECT PROJECT, YEAR FROM DEV_EFF UNION 
  SELECT PROJECT, YEAR FROM TEST_EFF) E
  WHERE E.PROJECT = D.PROJECT (+)
  AND E.PROJECT = T.PROJECT (+)
  AND T.YEAR (+) = E.YEAR
  AND D.YEAR (+) = E.YEAR;

SELECT P PROJECT, 
  Y YEAR, 
  NVL(D,0) DEV_EFFORT, 
  NVL(T,0) TESTING_EFFORT
  FROM COM_EFF;

/*
Retrieve all staff members that do not have an EDC effort on the previous day (SYSDATE -1) for all of the project he/she is involved in (required column: User ID). Use PROJECT_STAFF to get information on staff's involvement in a project. Do not retrieve staff members who are not assigned to any project.

Example:
John is involved in projects X and Y.
John is included in the result set if John has no EDC effort in both X and Y.

Note: 
* Use of set operations is NOT allowed.
* Zero (0) logged effort is the same has no logged effort.	10	PROJECT_STAFF
PRJ_EFFORT	1. Staff member involved in project A and B, but has effort only in A, no effort in B (must NOT be retrieved)
2. Staff member involved in project A and B but has no effort logged in project A and B and has effort logged in Project C, in which he is not involved (this staff member must still be retrieved since he is not involved in Project C).	
*/
SELECT * FROM PROJECT_STAFF S
  WHERE NOT EXISTS (SELECT * FROM 
    PRJ_EFFORT E
    WHERE E.EFFORT_DT = SYSDATE-1
    AND S.USER_ID = E.USER_ID);

/*
Definitions: For items 9 and 10
A delayed task is a scheduled task that satisfies either one of the following:
Delayed Development Task:
i.) Status is 'FC' and Dev Start Date has lapsed. 
ii.) Status is 'CD' and Dev End Date has lapsed.
Delayed Testing Task:
iii.) Status is 'FT' and Test Start Date has lapsed.
iv.) Status is 'T' and Test End Date has lapsed.				
Retrieve demo projects with more than 1 delayed development task with respect to the report date.  Required column: Project, Function ID, Number of Days delayed

Number of days delayed is defined to be as follows:
* If lapsed date is start date then report date - start date 
* if lapsed date is end date then report date - end date

Notes:
* To make the problem simple, we will not handle cases of non-working days.  
* Use bind variable which will be of dd/mm/yyyy format to allow users to specify their desired report date	25	PROJECT
PRJ_TASK		
*/
CREATE OR REPLACE VIEW T AS
  SELECT PROJECT, FUNC_ID, DSTART_DT, DEND_DT, TSTART_DT, TEND_DT, STATUS, 
  DECODE(STATUS,
    'FC',DSTART_DT,
    'CD', DEND_DT,
    'FT', TSTART_DT,
    'T', TEND_DT) LAPSED_COUNT
  FROM PRJ_TASK 
  WHERE STATUS IN  ('FC','CD','FT','T');

SELECT T.PROJECT, T.FUNC_ID, ROUND(:REPORT_DT - LAPSED_COUNT) NO_OF_DAYS_DELAYED
  FROM PROJECT P, T
  WHERE P.TYPE = 'DEMO'
  AND P.CODE= T.PROJECT;
/*
Display all testers with their delayed testing tasks with respect to the report date (required columns: User ID, Project, and Function ID of the delayed testing task) satisfying the conditions below:
i.) Tester worked for more than 10 hours in the previous day. 


Notes:
* To make the problem simple, we will not handle cases of non-working days.  
* Use bind variable which will be of dd/mm/yyyy format to allow users to specify their desired report date	20	PRJ_EFFORT
PRJ_TASK		
*/
CREATE OR REPLACE VIEW T AS
  SELECT P.*,
  DECODE(STATUS,
    'FC',DSTART_DT,
    'CD', DEND_DT,
    'FT', TSTART_DT,
    'T', TEND_DT) LAPSED_COUNT
  FROM PRJ_TASK P
  WHERE STATUS IN  ('FC','CD','FT','T');

SELECT T.TESTER USER_ID, T.PROJECT, T.FUNC_ID FUNCTION_ID
  FROM PRJ_EFFORT E, T
  WHERE T.PROJECT = E.PROJECT
  AND TO_CHAR(E.EFFORT_DT,'DD-MM-YY') 
    = TO_CHAR(:REPORT_DT,'DD-MM-YY')
  AND E.EFFORT >= 10;
--Consider the BOXERS and BOXING_SKED tables. Assume you are scheduling a round-robin match for the boxers. There are 4 boxers, and so there will be 6 round-robin matches (4 taken 2 at a time) - and therefore there are 6 BOXING_SKED records. Create a query to display a boxing match schedule, displaying the boxers and the corresponding date. There should only be 6 records displayed (one for each record in BOXING_SKED).	15			
SELECT C.P1, C.P2, D.BOX_DATE
  FROM 
  (SELECT A.BOXER P1, B.BOXER P2, ROWNUM NUM
  FROM
  (SELECT B.*, ROWNUM 
    FROM BOXERS B) A,
  (SELECT B.*, ROWNUM 
    FROM BOXERS B) B
  WHERE A.BOXER > B.BOXER) C,
  (SELECT BOX_DATE, ROWNUM NUM FROM BOXING_SKED) D
  WHERE C.NUM = D.NUM;