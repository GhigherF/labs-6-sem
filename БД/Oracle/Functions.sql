----------------1-------------------------
CREATE OR REPLACE FUNCTION avgGradesByCourse(p_course IN NUMBER) RETURN NUMBER IS v_avg NUMBER;
BEGIN
    SELECT AVG(grade) INTO v_avg FROM grades 
    JOIN students  ON grades.student_id = students.student_id
    WHERE students.course = p_course;

    RETURN v_avg;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;


DECLARE
    v_result NUMBER;
BEGIN
    v_result := avgGradesByCourse(4);
    DBMS_OUTPUT.PUT_LINE('Средний балл: ' || v_result);
END;



----------------------2-----------------------------
CREATE OR REPLACE FUNCTION avgGradesBySpecialty(p_specialty IN VARCHAR2) RETURN VARCHAR2 IS v_avg NUMBER;
v_msg VARCHAR2(100);
BEGIN
    SELECT AVG(grade) INTO v_avg FROM grades 
    JOIN students  ON grades.student_id = students.student_id
    JOIN specialties  ON students.specialty_id = specialties.specialty_id
    WHERE UPPER(specialties.specialty) = UPPER(p_specialty);


    IF v_avg IS NULL THEN
        v_msg := 'Нет оценок';
    ELSE
        v_msg := 'Средний балл: ' || TO_CHAR(v_avg);
    END IF;

    RETURN v_msg;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Нет оценок';
END;


DECLARE
    v_result VARCHAR2(100);
BEGIN
    v_result := avgGradesBySpecialty('Программная инженерия');
    DBMS_OUTPUT.PUT_LINE(v_result);
END;



----------------------3-----------------------------

CREATE OR REPLACE FUNCTION studentsByGroupsOnCourse(p_course IN NUMBER,p_faculty IN VARCHAR2) RETURN SYS_REFCURSOR IS v_cursor SYS_REFCURSOR; 
BEGIN
    OPEN v_cursor FOR
        SELECT students.student AS student_name,students.course,students.grup,
               students.subgroup,faculties.faculty_name FROM students 
        JOIN specialties ON students.specialty_id = specialties.specialty_id
        JOIN pulpits  ON specialties.pulpit_id = pulpits.pulpit_id
        JOIN faculties  ON pulpits.faculty_id = faculties.faculty_id
        WHERE students.course = p_course
          AND UPPER(faculties.faculty) = UPPER(p_faculty)
        ORDER BY students.grup DESC;

    RETURN v_cursor;
END;



select * from faculties;

SET SERVEROUTPUT ON;
SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    v_cursor SYS_REFCURSOR;      
    v_student_name students.student%TYPE;
    v_course       students.course%TYPE;
    v_grup         students.grup%TYPE;
    v_subgroup     students.subgroup%TYPE;
    v_faculty_name faculties.faculty_name%TYPE;
BEGIN
    v_cursor := studentsByGroupsOnCourse(3, 'ИТ');

    LOOP
        FETCH v_cursor INTO v_student_name, v_course, v_grup, v_subgroup, v_faculty_name;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            v_student_name || ' | ' || v_course || ' | ' ||
            v_grup || ' | ' || v_subgroup || ' | ' || v_faculty_name
        );
    END LOOP;

    CLOSE v_cursor; 
END;



----------------------4-----------------------------


CREATE OR REPLACE FUNCTION teacherExamCount RETURN SYS_REFCURSOR IS v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT teachers.teacher, COUNT(exams.exam_id) AS Exams FROM teachers 
        JOIN exams  ON teachers.teacher_id = exams.teacher_id
        GROUP BY teachers.teacher
        ORDER BY teachers.teacher;
    RETURN v_cursor;
END;




DECLARE
    v_cursor SYS_REFCURSOR;
    v_teacher teachers.teacher%TYPE;
    v_exams NUMBER;
BEGIN
    v_cursor := teacherExamCount_cursor();

    LOOP
        FETCH v_cursor INTO v_teacher, v_exams;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_teacher || ' | ' || v_exams);
    END LOOP;
    CLOSE v_cursor;
END;



----------------------5-----------------------------


CREATE OR REPLACE FUNCTION teachersCountByPulpits(p_faculty IN VARCHAR2)
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT pulpits.pulpit, COUNT(teachers.teacher_id) AS Teachers
        FROM teachers 
        JOIN pulpits  ON teachers.pulpit_id = pulpits.pulpit_id
        JOIN faculties  ON pulpits.faculty_id = faculties.faculty_id
        WHERE UPPER(faculties.faculty) = UPPER(p_faculty)
        GROUP BY pulpits.pulpit
        ORDER BY pulpits.pulpit;
    RETURN v_cursor;
END;



DECLARE
    v_cursor SYS_REFCURSOR;
    v_pulpit pulpits.pulpit%TYPE;
    v_teachers NUMBER;
BEGIN
    v_cursor := teachersCountByPulpits('ИТ');

    LOOP
        FETCH v_cursor INTO v_pulpit, v_teachers;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_pulpit || ' | ' || v_teachers);
    END LOOP;
    CLOSE v_cursor;
END;







----------------------------------
---------------------------------
CREATE OR REPLACE FUNCTION teachersByOverload(v_subjects IN NUMBER)
RETURN SYS_REFCURSOR AS result_cursor SYS_REFCURSOR;
BEGIN
    OPEN result_cursor FOR
        SELECT teachers.teacher,COUNT(subject_teacher.subject_id) AS subjects_count
        FROM teachers INNER JOIN subject_teacher 
            ON teachers.teacher_id = subject_teacher.teacher_id
        GROUP BY teachers.teacher
        HAVING COUNT(subject_teacher.subject_id) > v_subjects;

    RETURN result_cursor;
END;





DECLARE rc SYS_REFCURSOR; v_teacher teachers.teacher%TYPE;v_count NUMBER;
BEGIN
    rc := teachersByOverload(2);
    LOOP
        FETCH rc INTO v_teacher, v_count;
        EXIT WHEN rc%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_teacher || ' ---- ' || v_count||' предмета');
    END LOOP;

    CLOSE rc;
END;