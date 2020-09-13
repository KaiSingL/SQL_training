/*
Consider the EVENTS table.Create a report to show the number of receipt and send events in the last year and also in the last 2 days. The send events are the following event types: TY, LO, LL. The receipt events are AX, AH, AB. Your query will return four columns: receipt and send events for the last year; receipt and send events for the last 2 days.

To synchronize queries: 
last year is from ADD_MONTHS(sysdate, -12) to sysdate. 
last 2 days is from sysdate-2 to sysdate.	
*/
SELECT 
  SUM(
    DECODE(LEAST(SYSDATE-2,EVENT_DATE),
      SYSDATE-2,
      DECODE(EVENT_TYPE, 'AX',1,'AH',1,'AB',1,0),0)
  ) RECEIPT_LAST_2_DAYS,
  SUM(
    DECODE(LEAST(SYSDATE-2,EVENT_DATE),
      SYSDATE-2,
      DECODE(EVENT_TYPE, 'TY',1,'LO',1,'LL',1,0),0)
  ) SEND_LAST_2_DAYS,
  SUM(
    DECODE(LEAST(ADD_MONTHS(SYSDATE,-12),EVENT_DATE),
      ADD_MONTHS(SYSDATE,-12),
      DECODE(EVENT_TYPE, 'AX',1,'AH',1,'AB',1,0),0)
  ) RECEIPT_LAST_YEAR,
  SUM(
    DECODE(LEAST(ADD_MONTHS(SYSDATE,-12),EVENT_DATE),
      ADD_MONTHS(SYSDATE,-12),
      DECODE(EVENT_TYPE, 'TY',1,'LO',1,'LL',1,0),0)
  ) SEND_LAST_YEAR
  FROM EVENTS
  WHERE EVENT_DATE >= ADD_MONTHS(SYSDATE,-12)
  AND EVENT_DATE <= SYSDATE
  AND EVENT_TYPE IN ('TY','LO','LL','AX','AH','AB');
  /*
In http://ojtserver/twiki/bin/view/Main/PoDBeyondEquality, there is a query that returns the total salary for the entire company if all employees whose salary was less than P10,000 received an increase of P1,000. Now, using decode, formulate a query that returns the total salary for the entire company if all employees who receive from P2,000 to P4,000 was given a P500.00 increase.	
*/
SELECT SUM(
    DECODE(LEAST(SAL,2000), 2000,
      DECODE(GREATEST(SAL,4000), 4000, SAL+500, SAL),SAL))
  TOTAL_SAL
  FROM EMP;