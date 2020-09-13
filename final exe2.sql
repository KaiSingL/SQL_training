/*
Display Full Name of all Staff members.  Format of Full Name should be <Last Name>, <First Name>. Do not display comma(,) if either Last Name or First Name is blank.
Do not use CASE and display RP Staff before HK Staffs.	5	STAFF	1. Last Name and First Name have value (with comma)
2. Only Last Name has value (no comma)
3. Only First Name has value (no comma)
4. Both have no value (no comma)	
*/
SELECT FIRST_NAME ||
  DECODE(FIRST_NAME, NULL, '', DECODE(LAST_NAME,NULL,'',', '))
  || LAST_NAME
  FROM STAFF
  ORDER BY LOCATION;
/*
Display the total effort for Comunication and Email in the DRAS project logged by each STAFF for the week of April 12-17, 2004.  Display User ID and Total Effort. 

Notes : 
1. Use PRJ_TC.LEVEL1 = 'Communication and Email'.
2. All USER_ID from STAFF must be displayed. If a STAFF has no effort exerted on DRAS Communication and Email, display 0	15	STAFF
PRJ_EFFORT
PRJ_TC	1. Staffs not a member of DRAS but have logged Communication and Email effort under DRAS (must be retrieved)	
*/

SELECT S.USER_ID, NVL(N.TOTAL_EFFORT,0) TOTAL_EFFORT
  FROM (SELECT USER_ID, SUM(EFFORT) TOTAL_EFFORT
  FROM
  (SELECT USER_ID, EFFORT
  FROM PRJ_EFFORT
  WHERE PROJECT ='DRAS'
  AND EFFORT_DT BETWEEN '12-APR-04' AND '17-APR-04') A
  GROUP BY USER_ID) N, STAFF S
  WHERE S.USER_ID = N.USER_ID (+);
/*
Display the efforts logged by SHENG for the Project EPATCOM for the month of January 2004.  Required columns: Effort Date, PRJ_PD Level Description, PRJ_TC Level Description, Effort, and Notes.  Result must be sorted by Effort Date. 

Column Descriptions:
PRJ_PD Level Description: PRJ_PD.LEVEL0||'->'|| PRJ_PD.LEVEL1||'->'||PRJ_PD.LEVEL2 
PRJ_TC Level Description: PRJ_TC.LEVEL0||'->'||PRJ_TC.LEVEL1||'->'||PRJ_TC.LEVEL2
/*
Notes:
* If LEVEL1 or LEVEL2 is empty, do not display '->' that precedes it.
* Do not consider efforts logged that are 0.
* If notes contains carriage returns (enter), make sure they are displayed correctly.  Replace carriage return with space (use replace() function).  Carrriage return is denoted by Chr(13)||Chr(10).  Also, remove leading/trailing spaces at the start/end of the notes

Assumption: If Level 2 has value, Level 1 has value	15	PRJ_EFFORT
PRJ_TC
PRJ_PD	e.g.
A
B should be displayed as A B

 A B  should be displayed as A B	
*/
SELECT E.EFFORT_DT, 
  P.LEVEL0||
    DECODE(P.LEVEL0,NULL,'',DECODE(P.LEVEL1,NULL,'','->'))||
    P.LEVEL1||
    DECODE(P.LEVEL1,NULL,'',DECODE(P.LEVEL2,NULL,'','->'))
    ||P.LEVEL2 PD_LVL_DESCRIP,
  T.LEVEL0||
    DECODE(T.LEVEL0,NULL,'',DECODE(T.LEVEL1,NULL,'','->'))
    ||T.LEVEL1||
    DECODE(T.LEVEL1,NULL,'',DECODE(T.LEVEL2,NULL,'','->'))
    ||T.LEVEL2 TC_LVL_DESCRIP,
  E.EFFORT,
  E.NOTES
  FROM PRJ_EFFORT E, PRJ_TC T, PRJ_PD P
  WHERE E.PROJECT = T.PROJECT
  AND T.PROJECT = P.PROJECT
  AND E.PROJECT = 'EPATCOM'
  AND E.USER_ID = 'SHENG'
  AND TO_CHAR(E.EFFORT_DT,'MM-YY') = '01-04';
/*
Display all Staff members who takes on both Developer and Tester roles at the same time in different projects; use PROJECT_ROLE.ROLE to identify Developers and Testers (required column: User ID).

Note: There must be one project where the staff member is a developer and another where he is a tester. Include the staff member even if there's a third project where she is both developer and tester.	20	PROJECT_STAFF
PROJECT_ROLE	1. Staff member involved in only one project with both developer and tester roles in that project (must not be retrieved)
2. Staff member involved in more than one project with developer role in one and tester in another (must be retrieved)
3. Staff member involved in only 2 projects wherein role in proj A is developer and tester while role in proj B is not developer and not tester  (must not be retrieved)	
*/
SELECT N.USER_ID, N.PROJECT, N.ROLE, M.PROJECT, M.ROLE
  FROM
  (SELECT A.*, B.ROLE
    FROM PROJECT_STAFF A, PROJECT_ROLE B
    WHERE A.PROJECT_STAFF_ID = B.PROJECT_STAFF_ID) N,
  (SELECT A.*, B.ROLE
    FROM PROJECT_STAFF A, PROJECT_ROLE B
    WHERE A.PROJECT_STAFF_ID = B.PROJECT_STAFF_ID) M
  WHERE N.USER_ID = M.USER_ID
  AND N.PROJECT <> M.PROJECT
  AND N.ROLE = 'DEV'
  AND M.ROLE = 'TEST';