---------------------1--------------------------
CREATE OR REPLACE PROCEDURE promoteStudent(p_student IN VARCHAR2) IS
    v_course students.course%TYPE;
    v_years_of_study specialties.years_of_study%TYPE;
BEGIN
    SELECT course, s.years_of_study INTO v_course, v_years_of_study FROM students st
    JOIN specialties s ON st.specialty_id = s.specialty_id
    WHERE st.student = p_student;

    IF v_course >= v_years_of_study THEN
        RAISE_APPLICATION_ERROR(-20001, 'Последний курс');
    END IF;

    UPDATE students
    SET course = course + 1
    WHERE student = p_student;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Неверное ФИО студента');
        rollback;
END;


select * from students where student = 'Дмитроченко Кирилл';
BEGIN
    promoteStudent('Дмитроченко Кирилл');
    commit;
END;


---------------------2--------------------------
CREATE OR REPLACE PROCEDURE addSubject(p_subject IN VARCHAR2,p_teacher IN VARCHAR2,p_pulpit IN VARCHAR2) IS
    v_teacher_id teachers.teacher_id%TYPE;
    v_pulpit_id pulpits.pulpit_id%TYPE;
    v_subject_id subjects.subject_id%TYPE;
BEGIN
    BEGIN
        SELECT teacher_id INTO v_teacher_id FROM teachers WHERE teacher = p_teacher;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Преподаватель не существует');
    END;

    BEGIN
        SELECT pulpit_id INTO v_pulpit_id FROM pulpits WHERE pulpit = p_pulpit;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Кафедра не найдена');
    END;

    BEGIN
        SELECT subject_id INTO v_subject_id FROM subjects WHERE subject = p_subject;
        RAISE_APPLICATION_ERROR(-20005, 'Предмет уже существует');
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;

    INSERT INTO subjects(subject) VALUES (p_subject);
    SELECT subject_id INTO v_subject_id FROM subjects WHERE subject = p_subject;
    INSERT INTO subject_teacher(teacher_id, subject_id) VALUES(v_teacher_id, v_subject_id);
END;

select * from teachers;
BEGIN
ADDSUBJECT('ООП','Смелов В.В.','ПИ');
commit;
END;



---------------------3--------------------------
CREATE OR REPLACE PROCEDURE fireTeacher(p_teacher IN VARCHAR2) IS
    v_teacher_id teachers.teacher_id%TYPE;
BEGIN
    BEGIN
        SELECT teacher_id INTO v_teacher_id
        FROM teachers
        WHERE teacher = p_teacher;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010,'Преподаватель не существует');
    END;

    UPDATE exams SET teacher_id = NULL
    WHERE teacher_id = v_teacher_id;

    DELETE FROM subject_teacher
    WHERE teacher_id = v_teacher_id;

    FOR rec IN (SELECT subjects.subject_id FROM subjects 
        LEFT JOIN subject_teacher ON subjects.subject_id = subject_teacher.subject_id
        LEFT JOIN exams ON subjects.subject_id = exams.subject_id
        WHERE subject_teacher.subject_id IS NULL
        AND exams.subject_id IS NULL)
        
        LOOP
        DELETE FROM subjects
        WHERE subject_id = rec.subject_id;
        END LOOP;

    DELETE FROM teachers
    WHERE teacher_id = v_teacher_id;
END;

select * from teachers;
select * from exams;


BEGIN
    fireTeacher('Иванов И.И.');
    commit;
END;



---------------------4-----------------------
CREATE OR REPLACE PROCEDURE addExam(p_teacher IN VARCHAR2,p_subject IN VARCHAR2,p_exam_date IN DATE,p_auditorium IN VARCHAR2) IS
    v_teacher_id teachers.teacher_id%TYPE;
    v_subject_id subjects.subject_id%TYPE;
    v_cnt NUMBER;
BEGIN
    BEGIN
        SELECT teacher_id INTO v_teacher_id FROM teachers
        WHERE teacher = p_teacher;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20020, 'Преподаватель не найден');
    END;

    BEGIN
        SELECT subject_id INTO v_subject_id
        FROM subjects
        WHERE subject = p_subject;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20021, 'Предмет не найден');
    END;

    SELECT COUNT(*) INTO v_cnt FROM subject_teacher
    WHERE teacher_id = v_teacher_id AND subject_id = v_subject_id;

    IF v_cnt = 0 THEN
        RAISE_APPLICATION_ERROR(-20022, 'Преподаватель не ведет этот предмет');
    END IF;

    SELECT COUNT(*) INTO v_cnt FROM exams
    WHERE teacher_id = v_teacher_id
      AND TRUNC(exam_date) = TRUNC(p_exam_date);

    IF v_cnt > 0 THEN
        RAISE_APPLICATION_ERROR(-20023, 'У преподавателя уже есть экзамен в этот день');
    END IF;

    INSERT INTO exams(exam_date, exam_auditorium, teacher_id, subject_id)
    VALUES(p_exam_date, p_auditorium, v_teacher_id, v_subject_id);

    DBMS_OUTPUT.PUT_LINE('Экзамен успешно добавлен');
END;





SET SERVEROUTPUT ON;

BEGIN
   Begin
    addExam('Смелов В.В.','ПСКП',TO_DATE('2026-01-29 10:00','YYYY-MM-DD HH24:MI'),'228-4');
end;
    
    BEGIN
        addExam('Неизвестный','Очередной предмет',TO_DATE('2026-01-28 10:00','YYYY-MM-DD HH24:MI'),'228-4');
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;

    select * from subjects;
    BEGIN
        addExam('Смелов В.В.','Физика',TO_DATE('2026-01-28 10:00','YYYY-MM-DD HH24:MI'),'228-4');
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;

    BEGIN
        addExam('Смелов В.В.','ПСКП',TO_DATE('2026-01-28 10:00','YYYY-MM-DD HH24:MI'),'228-4');
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
    END;
END;




---------------------5-----------------------
CREATE OR REPLACE PROCEDURE replaceExamTeacher(p_exam_id IN NUMBER,p_new_teacher IN VARCHAR2) IS
    v_new_teacher_id teachers.teacher_id%TYPE;
    v_subject_id    exams.subject_id%TYPE;
    v_exam_date     exams.exam_date%TYPE;
    v_cnt           NUMBER;
BEGIN
    BEGIN
        SELECT subject_id, exam_date INTO v_subject_id, v_exam_date FROM exams
        WHERE exam_id = p_exam_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20030, 'Экзамен не найден');
    END;

    BEGIN
        SELECT teacher_id INTO v_new_teacher_id FROM teachers
        WHERE teacher = p_new_teacher;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20031, 'Преподаватель не найден');
    END;


    SELECT COUNT(*) INTO v_cnt FROM exams
    WHERE teacher_id = v_new_teacher_id AND TRUNC(exam_date) = TRUNC(v_exam_date);

    IF v_cnt > 0 THEN
        RAISE_APPLICATION_ERROR(-20032, 'У преподавателя уже есть экзамен в это время');
    END IF;

    UPDATE exams
    SET teacher_id = v_new_teacher_id
    WHERE exam_id = p_exam_id;

    DBMS_OUTPUT.PUT_LINE('Преподаватель успешно заменен');
END;



BEGIN
    
    BEGIN
        replaceExamTeacher(1, 'Смелов В.В.');
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END;

    
    BEGIN
        replaceExamTeacher(999, 'Смелов В.В.');
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END;

    
    BEGIN
        replaceExamTeacher(1, 'LoL');
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END;

    BEGIN
        replaceExamTeacher(1, 'Смелов В.В.');  
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    END;
END;

-----------------------------------------------
----------------------------------------------
CREATE OR REPLACE PROCEDURE checkAllTeacherExamConflicts IS result_cursor SYS_REFCURSOR;
    v_teacher teachers.teacher%TYPE;
    v_exam_date exams.exam_date%TYPE;
BEGIN
    OPEN result_cursor FOR
    SELECT DISTINCT teachers.teacher,e1.exam_date FROM exams e1
        INNER JOIN exams e2 ON e1.teacher_id = e2.teacher_id
           AND e1.exam_date = e2.exam_date
           AND e1.exam_id < e2.exam_id
        INNER JOIN teachers ON teachers.teacher_id = e1.teacher_id;

    FETCH result_cursor INTO v_teacher, v_exam_date;

    IF result_cursor%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('Конфликтов расписания не найдено');
        CLOSE result_cursor;
        RETURN;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Найдены конфликты расписания:');

    CLOSE result_cursor;

    LOOP
        FETCH result_cursor INTO v_teacher, v_exam_date;
        EXIT WHEN result_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_teacher || ' -> ' || v_exam_date);
    END LOOP;

    CLOSE result_cursor;
END;

begin
CHECKALLTEACHEREXAMCONFLICTS();
end;
-----------------------------------------------
----------------------------------------------

CREATE OR REPLACE PROCEDURE dataIntegrityCheck
AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Кафедры без преподавателей:');
    FOR r IN (SELECT pulpits.pulpit
        FROM pulpits
        LEFT JOIN teachers ON pulpits.pulpit_id = teachers.pulpit_id
        WHERE teachers.teacher_id IS NULL) 
        LOOP
        DBMS_OUTPUT.PUT_LINE(r.pulpit);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Предметы без преподавателей:');
    FOR r IN (SELECT subjects.subject
        FROM subjects 
        LEFT JOIN subject_teacher  ON subjects.subject_id = subject_teacher.subject_id
        WHERE subject_teacher.teacher_id IS NULL)
        LOOP
        DBMS_OUTPUT.PUT_LINE(r.subject);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Преподаватели без предметов:');
    FOR r IN (SELECT teachers.teacher
        FROM teachers 
        LEFT JOIN subject_teacher   ON teachers.teacher_id = subject_teacher.teacher_id
        WHERE subject_teacher.subject_id IS NULL
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(r.teacher);
    END LOOP;

END;

BEgin
DATAINTEGRITYCHECK();
end;


-----------------VIEW----------------
CREATE OR REPLACE VIEW studentPerformanceView AS
SELECT students.student,specialties.specialty,subjects.subject,
teachers.teacher,grades.grade FROM grades 
INNER JOIN students  ON grades.student_id = students.student_id
INNER JOIN specialties  ON students.specialty_id = specialties.specialty_id
INNER JOIN subjects  ON grades.subject_id = subjects.subject_id
LEFT JOIN subject_teacher  ON subjects.subject_id = subject_teacher.subject_id
LEFT JOIN teachers  ON subject_teacher.teacher_id = teachers.teacher_id;


SELECT * FROM studentPerformanceView;


-----------------INDEX----------------
CREATE INDEX idx_grades_student_subject
ON grades(student_id, subject_id);


explain plan for SELECT students.student, subjects.subject, grades.grade FROM grades 
INNER JOIN students  ON grades.student_id = students.student_id
INNER JOIN subjects  ON grades.subject_id = subjects.subject_id
WHERE students.student_id = 2 AND grades.grade > 5;

SELECT * 
FROM TABLE(DBMS_XPLAN.DISPLAY());


----------------TRIGGER----------------
CREATE OR REPLACE TRIGGER gradeVerification
BEFORE INSERT OR UPDATE ON grades
FOR EACH ROW
BEGIN
    IF :NEW.grade < 1 OR :NEW.grade > 10 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Оценка должна быть от 1 до 10');
    END IF;
END;



SELECT * FROM grades;

BEGIN
    INSERT INTO grades(student_id, subject_id, grade) VALUES(2,7,11);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


-------------SEQUENCE--------------------
CREATE SEQUENCE smelov_grade
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 4
CYCLE
NOCACHE;

SELECT smelov_grade.NEXTVAL FROM dual;









