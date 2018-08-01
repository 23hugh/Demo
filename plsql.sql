--选择题
--1
D
--2
B
--3
ABCD
--4
B
--5
C
--基础题

--1
create or replace package HAND_PCSQL_TEST_20888_PKG is  

  -- Author  : XY70
  -- Created : 2018/7/27 15:12:26
  -- Purpose :  
function hand_get_core(p_student_no in varchar2, p_course_no in varchar2)
  return number;

end HAND_PCSQL_TEST_20888_PKG;

create or replace package body HAND_PCSQL_TEST_20888_PKG is
 function hand_get_core(p_student_no in varchar2, 
                   p_course_no in varchar2)
  return number
  is p_core number;
  begin
  select core
  into p_core
  from hand_student s,hand_student_core sc,hand_course c
  where s.student_no=sc.student_no
  and sc.course_no=c.course_no;
  return p_core;
exception   
  when no_data_found then     
    return -1;                 
    when too_many_rows then     
      return -2;
      when others then 
        return -3;
        end hand_get_core;
end HAND_PCSQL_TEST_20888_PKG;
--2
procedure hand_log_msg(p_code in varchar2,
                       p_msg  in varchar2,
                       p_key1 in varchar2 default null,
                       p_key2 in varchar2 default null,
                       p_key3 in varchar2 default null,
                       p_key4 in varchar2 default null,
                       p_key5 in varchar2 default null)
procedure hand_log_msg(p_code in varchar2,
                       p_msg  in varchar2,
                       p_key1 in varchar2 default null,
                       p_key2 in varchar2 default null,
                       p_key3 in varchar2 default null,
                       p_key4 in varchar2 default null,
                       p_key5 in varchar2 default null) is
  pragma autonomous_transaction;
begin
  insert into hand_log
    (code, msg, key1, key2, key3, key4, key5)
  values
    (p_code, p_msg, p_key1, p_key2, p_key3, p_key4, p_key5);
  commit;
end hand_log_msg;

--3
procedure hand_insert_ms;
procedure hand_insert_ms is
  lxy_ins hand_student%rowtype;
begin                                                                         begin 
  for i in 1 .. 10 loop                                                        for i in 0..9 loop
    lxy_ins.student_no := 's10' || (i - 1);                                    lxy_ins.student_no:='s10'||(i);
    if i < 10 then                                                             if i<9 then
      lxy_ins.student_name := '王00' || i;                                     lxy_ins.student_name:='王00' ||(i+1)                        
    else                                                                       else 
      lxy_ins.student_name := '王0' || i;                                      lxy_ins.student_name:='王0'||(i+1)
    end if;                                                                    end if;
    lxy_ins.student_age := 22;                                                 lxy_ins.student_age := 22;          
    if mod(i - 1, 2) = 0 then                                                  if mod(i , 2) = 0 then
      lxy_ins.student_gender := '男';                                          lxy_ins.student_gender:='男';
    else                                                                       else
      lxy_ins.student_gender := '女';                                          lxy_ins.student_gender:='女';
    end if;                                                                    end if;
    insert into HAND_STUDENT
    values
      (lxy_ins.student_no,
       lxy_ins.student_name,
       lxy_ins.student_age,
       lxy_ins.student_gender);
  end loop;
end hand_insert_ms;
--4
procedure hand_add_core( p_student_no  in varchar2,
                         p_course_no   in varchar2,
                         v_core        out number);
                           
procedure hand_add_core( p_student_no  in varchar2,
                         p_course_no   in varchar2,
                         v_core        out number) is 
cursor lxy_add is
select sc.core
  from hand_student s, hand_student_core sc, hand_course c
 where s.student_no = sc.student_no
   and sc.course_no = c.course_no
   for update of sc.core;
begin
  for lxy_core in lxy_add loop
    if lxy_core.core*1.20<=100 then
      update hand_student_core 
      set lxy_core.core=lxy_core.core*1.20
      where current of sc.core;
      else
        v_core:=lxy_core.core;
        end if;
        end loop;
end hand_add_core; 
--脚本代码
--1
declare
  cursor every_core is
    select s.student_name,
           s.student_no,
           c.course_name,
           HAND_PCSQL_TEST_20888_PKG.hand_get_core(lxy_ins.student_no,
                                                   lxy_ins.student_no) core
  from hand_student s,hand_course c,hand_student_core sc 
  where  s.student_no=lxy_ins.student_no
  and lxy_ins.course_no=c.course_no
  and exists (select *
              from hand_student s,hand_course c,hand_student_core sc ,hand_teacher t
              where s.student_no=lxy_ins.student_no
              and lxy_ins.course_no=c.course_no
              and t.teacher_no=c.teacher_no
              and t.teacher_name='胡明星'）;
begin
/*  dbms_output.put_line('姓名','学号','课程','成绩');*/
  for as_so in every_core loop
    if as_so.core not in (-1,-2,-3)then 
      dbms_output.put_line(as_so.student_name||'  '||as_so.student_no||'  '||as_so.course_name||'  '||as_so.core);
      else
        HAND_PCSQL_TEST_20888_PKG.hand_get_core(p_code=>lxy_core.core,
                                                p_msg=>lxy_core.student_name);
    end if;
    end loop; 
end;
--2
declare
  p_count number;
begin
  HAND_PCSQL_TEST_20888_PKG.hand_insert_ms;
  select count(*)
    into p_count
    from all_tables
   where table_name = 'HAND_STUDENT_TEMP_20999';
  IF p_count > 0 THEN
    execute immediate 'drop table hand_student_temp_20999';
  end if;
  execute immediate 'create table hand_student_temp_20999 as select * from hand_student';
end;
  
  select * from HAND_STUDENT_TEMP_20999
--3 
declare
  new_core number;
  cursor cur_core is
    select s.student_name, s.student_no, c.course_no, sc.core old_core
      from hand_student s, hand_course c, hand_student_core sc
     where s.student_no = sc.student_no
       and sc.course_no = c.course_no
       and exists (select s.student_no
              from hand_student_core sc, hand_student s
             where s.student_no = sc.student_no
             group by s.student_no
            having avg(sc.core) < 70);
begin
  dbms_output.put_line('姓名  学号  课程  加分前成绩  加分后成绩');
  for cur_a in cur_core loop
    HAND_PCSQL_TEST_20888_PKG.hand_add_core(p_student_no => cur_a.student_no,
                                            p_course_no  => cur_a.course_no,
                                            v_core       => new_core);
    dbms_output.put_line(cur_a.student_name || '  ' || cur_a.student_no ||
                         '   ' || cur_a.course_no || '  ' ||
                         cur_a.old_core || '  ' || new_core);
  end loop;
end;
--进阶题
--1
CREATE OR REPLACE TRIGGER hand_student_trg_20888
  AFTER INSERT OR UPDATE OR DELETE ON hand_student
  FOR EACH ROW
DECLARE
BEGIN
  IF inserting THEN
    INSERT INTO hand_student_his
      (student_no,
       Student_Name,
       student_age,
       student_gender,
       last_update_date,
       status)
    VALUES
      (:NEW.student_no,
       :NEW.Student_Name,
       :NEW.student_age,
       :NEW.student_gender,
       SYSDATE,
       'N');
  ELSIF updating THEN
    INSERT INTO hand_student_his
      (student_no,
       Student_Name,
       student_age,
       student_gender,
       last_update_date,
       status)
    VALUES
      (:NEW.student_no,
       :NEW.Student_Name,
       :NEW.student_age,
       :NEW.student_gender,
       SYSDATE,
       'U');
  ELSIF deleting THEN
    INSERT INTO hand_student_his
      (student_no,
       Student_Name,
       student_age,
       student_gender,
       last_update_date,
       status)
    VALUES
      (:OLD.student_no,
       :OLD.Student_Name,
       :OLD.student_age,
       :OLD.student_gender,
       SYSDATE,
       'D');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END hand_student_trg;
--2
declare
  type core_rec is record(
    student_name hand_student.student_name%type,
    student_no   hand_student.student_no%type,
    course_name  hand_course.course_name%type,
    core         hand_student_core.core%type);
  type core_a_type is table of core_rec index by hand_student.student_no%type;
  core_a core_a_type;
  cursor cur_a is
    select s.student_name, s.student_no, c.course_name, sc.core
      from hand_student s, hand_course c, hand_student_core sc
     where s.student_no = sc.student_no
       and sc.course_no = c.course_no;
  l_student_no hand_student.student_no%type;
begin
  for rec_core in cur_a loop
    core_a(rec_core.student_no).student_name := rec_core.student_name;
    core_a(rec_core.student_no).student_no := rec_core.student_no;
    core_a(rec_core.student_no).course_name := rec_core.course_name;
    core_a(rec_core.student_no).core := rec_core.core;
    dbms_output.put_line(rec_core.student_no   || '    ' ||
                         rec_core.student_name || '    ' ||
                         rec_core.course_name  || '    ' || rec_core.core);
  end loop;
  begin
    l_student_no := core_a('s200').student_no;
  exception
    when no_data_found then
      core_a('s200').student_name := '张三丰';
      core_a('s200').student_no := 's200';
      core_a('s200').course_name := 'php';
      core_a('s200').core := 80;
    when others then
      null;
  end;
end;
--3   
GRANT CREATE ANY DIRECTORY TO hand_student;

CREATE OR REPLACE DIRECTORY FILENAME AS 'D:\EXAM';

CREATE OR REPLACE PROCEDURE process_core_info IS
  CURSOR cur_stu_core IS
    SELECT hs.student_name,
           hs.student_no,
           hsc1.core max_core,
           hc1.course_name max_course_name,
           hsc2.core min_core,
           hc2.course_name min_course_name
      FROM hand_student_core hsc1, 
           hand_course hc1, 
           hand_student hs,
           hand_student_core hsc2,
           hand_course hc2
     WHERE hsc1.course_no = hc1.course_no
       AND hsc1.student_no = hs.student_no
       AND hsc1.student_no = hsc2.student_no
       AND hsc2.course_no = hc2.course_no
       AND hsc1.core = (SELECT MAX(hsc.core)
                         FROM hand_student_core hsc
                        WHERE hsc.student_no = hsc1.student_no)
       AND hsc2.core = (SELECT MIN(hsc.core)
                         FROM hand_student_core hsc
                        WHERE hsc.student_no = hsc1.student_no);
  CURSOR cur_teh_core IS
    SELECT ht.teacher_name,
           hc1.course_name,
           hsc1.core max_core,
           hs1.student_name max_student_name,
           hsc2.core min_core,
           hs2.student_name min_student_name
      FROM hand_student_core hsc1, 
           hand_course hc1, 
           hand_teacher ht,
           hand_student hs1,
           hand_student_core hsc2,
           hand_course hc2,
           hand_student hs2
     WHERE hsc1.course_no = hc1.course_no
       AND hc1.teacher_no = ht.teacher_no
       AND hsc1.student_no = hs1.student_no
       AND hsc2.course_no = hc2.course_no
       AND hc1.teacher_no = hc2.teacher_no
       AND hsc2.student_no = hs2.student_no
       AND hsc1.core = (SELECT MAX(hsc.core)
                         FROM hand_student_core hsc,
                              hand_course hc
                        WHERE hsc.course_no = hc.course_no
                          AND hc.teacher_no = hc1.teacher_no)
       AND hsc2.core = (SELECT MIN(hsc.core)
                         FROM hand_student_core hsc,
                              hand_course hc
                        WHERE hsc.course_no = hc.course_no
                          AND hc.teacher_no = hc2.teacher_no);
  FILEHANDLE UTL_FILE.FILE_TYPE;
BEGIN
  FILEHANDLE := UTL_FILE.FOPEN('FILENAME','student.txt','W');
  UTL_FILE.PUT_LINE('姓名,学号,最高分,最高分课程名,最低分,最低分课程名');
  FOR rec_stu_core IN cur_stu_core LOOP
    UTL_FILE.PUT_LINE(FILEHANDLE,rec_stu_core.student_name||','||rec_stu_core.student_no||','||
                                 rec_stu_core.max_core||','||rec_stu_core.max_course_name||','||
                                 rec_stu_core.min_core||','||rec_stu_core.min_course_name);
  END LOOP;
  UTL_FILE.FCLOSE(FILEHANDLE);
  
  FILEHANDLE := UTL_FILE.FOPEN('FILENAME','teacher.txt','W');
  UTL_FILE.PUT_LINE('教师名,课程名,课程最高分,最高分学生姓名,课程最低分,最低分学生姓名');
  FOR rec_teh_core IN cur_teh_core LOOP
    UTL_FILE.PUT_LINE(FILEHANDLE,rec_teh_core.teacher_name||','||rec_teh_core.course_name||','||
                                 rec_teh_core.max_core||','||rec_teh_core.max_student_name||','||
                                 rec_teh_core.min_core||','||rec_teh_core.min_student_name);
  END LOOP;
  UTL_FILE.FCLOSE(FILEHANDLE);
  
END process_core_info;


SELECT * FROM HAND_STUDENT;

SELECT * FROM HAND_TEACHER;

SELECT * FROM HAND_COURSE;

SELECT * FROM HAND_STUDENT_CORE;

SELECT * FROM HAND_STUDENT_HIS;

SELECT * FROM HAND_LOG;
