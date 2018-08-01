

  -- Author  : XY70
  -- Created : 2018/7/26 15:46:02
  -- Purpose : 
  CREATE OR REPLACE PACKAGE emp_job_pkg
IS
  PROCEDURE add_jobs
    (p_jobid   IN jobs.job_id%TYPE,
     p_jobtitle  IN jobs.job_title%TYPE,
     p_minsal  IN jobs.min_salary%TYPE
    ); 
  PROCEDURE add_job_hist
    (p_empid   IN employees.employee_id%TYPE, p_jobid IN jobs.job_id%TYPE);
  PROCEDURE upd_sal
     (p_jobid   IN jobs.job_id%type,
      p_minsal  IN jobs.min_salary%type,
      p_maxsal  IN jobs.max_salary%type);
  FUNCTION get_service_yrs
    (p_empid  IN  employees.employee_id%TYPE)
    RETURN number;
END emp_job_pkg;
  
/
CREATE OR REPLACE PACKAGE BODY emp_job_pkg
IS
  PROCEDURE add_jobs
  (p_jobid   IN jobs.job_id%TYPE,
   p_jobtitle  IN jobs.job_title%TYPE,
   p_minsal  IN jobs.min_salary%TYPE
  )
  IS
     v_maxsal  jobs.max_salary%TYPE;
  BEGIN
     v_maxsal := 2 * p_minsal; 
     INSERT INTO jobs (job_id, job_title, min_salary, max_salary)
      VALUES (p_jobid, p_jobtitle, p_minsal, v_maxsal);
     DBMS_OUTPUT.PUT_LINE ('Added the following row into the JOBS table ...');
     DBMS_OUTPUT.PUT_LINE (p_jobid||'  '||p_jobtitle||'  '||p_minsal||'  '||v_maxsal);
  END add_jobs;

  PROCEDURE add_job_hist
    (p_empid   IN employees.employee_id%TYPE,
     p_jobid IN jobs.job_id%TYPE)
  IS
  BEGIN
   INSERT INTO job_history    
     SELECT employee_id, hire_date, SYSDATE, job_id, department_id
     FROM   employees
     WHERE  employee_id = p_empid;
   UPDATE employees
     SET  hire_date = SYSDATE,
          job_id = p_jobid,
          salary = (SELECT min_salary+500
                    FROM   jobs
                    WHERE  job_id = p_jobid)
   WHERE employee_id = p_empid;
   DBMS_OUTPUT.PUT_LINE ('Added employee ' ||p_empid|| ' details to the JOB_HISTORY table');
   DBMS_OUTPUT.PUT_LINE ('Updated current job of employee ' ||p_empid|| ' to '|| p_jobid);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RAISE_APPLICATION_ERROR (-20001, 'Employee does not exist!');
  END add_job_hist;

  PROCEDURE upd_sal
     (p_jobid   IN jobs.job_id%type,
      p_minsal  IN jobs.min_salary%type,
      p_maxsal  IN jobs.max_salary%type)
  IS
      v_dummy          VARCHAR2(1);
      e_resource_busy  EXCEPTION;
      sal_error        EXCEPTION;
      PRAGMA           EXCEPTION_INIT (e_resource_busy , -54);
  BEGIN
      IF (p_maxsal < p_minsal) THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR ... MAX SAL SHOULD BE > MIN SAL'); 
        RAISE sal_error;
      END IF;
      SELECT ''
       INTO v_dummy
       FROM jobs
       WHERE job_id = p_jobid
      FOR UPDATE OF min_salary NOWAIT;
      UPDATE jobs
       SET    min_salary =  p_minsal,
              max_salary =  p_maxsal
       WHERE  job_id  = p_jobid;
  EXCEPTION
      WHEN e_resource_busy THEN
       RAISE_APPLICATION_ERROR (-20001, 'Job information is currently locked, try later.');
      WHEN NO_DATA_FOUND THEN
       RAISE_APPLICATION_ERROR (-20001, 'This job ID does not exist');
      WHEN sal_error THEN
        RAISE_APPLICATION_ERROR(-20001,'Data error..Max salary should be more than min salary');
  END upd_sal;

  FUNCTION get_service_yrs
    (p_empid  IN  employees.employee_id%TYPE)
    RETURN number
  IS
    CURSOR emp_yrs_cur IS 
      SELECT (end_date - start_date)/365 service
      FROM   job_history
      WHERE  employee_id = p_empid;
    v_srvcyrs  NUMBER(2) := 0;
    v_yrs NUMBER(2) := 0;
  BEGIN
    FOR r_yrs IN emp_yrs_cur LOOP
      EXIT WHEN emp_yrs_cur%NOTFOUND;
      v_srvcyrs := v_srvcyrs + r_yrs.service;
    END LOOP;
    SELECT (SYSDATE - hire_date)
     INTO  v_yrs
     FROM   employees
     WHERE  employee_id = p_empid;
    v_srvcyrs := v_srvcyrs + v_yrs;
    RETURN v_srvcyrs;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20348, 'There is no employee with the specified ID');
  END get_service_yrs;

END  emp_job_pkg;
/
