/*
Consider the EVENTS table.Create a report to show the number of receipt and send events in the last year and also in the last 2 days. The send events are the following event types: TY, LO, LL. The receipt events are AX, AH, AB. Your query will return four columns: receipt and send events for the last year; receipt and send events for the last 2 days.

To synchronize queries: 
last year is from ADD_MONTHS(sysdate, -12) to sysdate. 
last 2 days is from sysdate-2 to sysdate.	
*/
SELECT 
  SUM(CASE 
    WHEN SYSDATE-2<EVENT_DATE
    AND EVENT_TYPE IN('AX','AH','AB')
    THEN 1
    ELSE 0 END) RECEIPT_LAST_2_DAYS,
  SUM(CASE
    WHEN SYSDATE-2<EVENT_DATE
    AND EVENT_TYPE IN ('TY','LO','LL')
    THEN 1
    ELSE 0 END) SEND_LAST_2_DAYS,
  SUM(CASE
    WHEN ADD_MONTHS(SYSDATE, -12)<EVENT_DATE
    AND EVENT_TYPE IN('AX','AH','AB')
    THEN 1
    ELSE 0 END) RECEIPT_LAST_YEAR,
  SUM(CASE
    WHEN ADD_MONTHS(SYSDATE, -12)<EVENT_DATE
    AND EVENT_TYPE IN ('TY','LO','LL')
    THEN 1
    ELSE 0 END) SEND_LAST_YEAR
  FROM EVENTS
  WHERE EVENT_DATE >= ADD_MONTHS(SYSDATE,-12)
  AND EVENT_DATE <= SYSDATE
  AND EVENT_TYPE IN ('TY','LO','LL','AX','AH','AB');
  /*
In http://ojtserver/twiki/bin/view/Main/PoDBeyondEquality, there is a query that returns the total salary for the entire company if all employees whose salary was less than P10,000 received an increase of P1,000. Now, using decode, formulate a query that returns the total salary for the entire company if all employees who receive from P2,000 to P4,000 was given a P500.00 increase.	
*/
SELECT SUM(CASE 
    WHEN SAL BETWEEN 2000 AND 4000
    THEN SAL+500
    ELSE SAL END) TOTAL_SALARY
  FROM EMP;