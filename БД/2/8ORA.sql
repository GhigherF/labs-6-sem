DROP TABLE OBJ_STUDENTS;
DROP TABLE OBJ_GROUPS;
DROP VIEW V_STUDENT_OBJ;
DROP VIEW V_GROUP_OBJ;

CREATE OR REPLACE TYPE T_STUDENT AS OBJECT (
    student_id   NUMBER,
    full_name    VARCHAR2(150),
    course       NUMBER,
    grup         NUMBER,
    subgroup     NUMBER,

    CONSTRUCTOR FUNCTION T_STUDENT(p_id NUMBER, p_name VARCHAR2) RETURN SELF AS RESULT,

    MAP MEMBER FUNCTION  get_id RETURN NUMBER DETERMINISTIC,

    MEMBER FUNCTION get_group_info RETURN VARCHAR2 DETERMINISTIC,

    MEMBER PROCEDURE promote_course
);

 
CREATE OR REPLACE TYPE BODY T_STUDENT AS
    CONSTRUCTOR FUNCTION T_STUDENT(p_id NUMBER, p_name VARCHAR2) RETURN SELF AS RESULT IS
    BEGIN
        SELF.student_id := p_id;
        SELF.full_name := p_name;
        SELF.course := 1;
        SELF.grup := 1;
        SELF.subgroup := 1;
        RETURN;
    END;

    MAP MEMBER FUNCTION get_id RETURN NUMBER IS
    BEGIN
        RETURN SELF.student_id;
    END;    

    MEMBER FUNCTION get_group_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Группа: ' || SELF.grup || ', Подгруппа: ' || SELF.subgroup;
    END;

    MEMBER PROCEDURE promote_course IS
    BEGIN
        SELF.course := SELF.course + 1;
    END;
END;


CREATE OR REPLACE TYPE T_GROUP AS OBJECT (
    group_id     NUMBER,
    grup         NUMBER,
    course       NUMBER,
    specialty_id NUMBER,

    CONSTRUCTOR FUNCTION T_GROUP(p_id NUMBER, p_grup NUMBER) RETURN SELF AS RESULT,

    MAP MEMBER FUNCTION get_id RETURN NUMBER DETERMINISTIC,

    MEMBER FUNCTION get_specialty_info RETURN VARCHAR2 DETERMINISTIC,

    MEMBER PROCEDURE promote_course
);

CREATE OR REPLACE TYPE BODY T_GROUP AS
    CONSTRUCTOR FUNCTION T_GROUP(p_id NUMBER, p_grup NUMBER) RETURN SELF AS RESULT IS
    BEGIN
        SELF.group_id     := p_id;
        SELF.grup         := p_grup;
        SELF.course       := 1;
        SELF.specialty_id := NULL;
        RETURN;
    END;

    MAP MEMBER FUNCTION get_id RETURN NUMBER IS
    BEGIN
        RETURN SELF.group_id;
    END;

    MEMBER FUNCTION get_specialty_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Группа: ' || SELF.grup || ', Курс: ' || SELF.course || ', Специальность: ' || SELF.specialty_id;
    END;

    MEMBER PROCEDURE promote_course IS
    BEGIN
        SELF.course := SELF.course + 1;
    END;
END;




-------------------------2--------------------------
----------------------------------------------------

CREATE TABLE OBJ_STUDENTS OF T_STUDENT (student_id PRIMARY KEY);

INSERT INTO OBJ_STUDENTS
SELECT T_STUDENT(student_id, student, course, grup, subgroup)
FROM STUDENTS;






CREATE TABLE OBJ_GROUPS OF T_GROUP (group_id PRIMARY KEY);

INSERT INTO OBJ_GROUPS
SELECT T_GROUP(group_id, grup, course, specialty_id)
FROM GROUPS;

COMMIT;



-------------------------3--------------------------
----------------------------------------------------


CREATE OR REPLACE VIEW V_STUDENT_OBJ AS
SELECT T_STUDENT(student_id, student, course, grup, subgroup) AS student_obj
FROM STUDENTS;

SELECT v.student_obj.full_name, v.student_obj.get_group_info() 
FROM V_STUDENT_OBJ v;

CREATE OR REPLACE VIEW V_GROUP_OBJ AS
SELECT T_GROUP(group_id, grup, course, specialty_id) AS group_obj
FROM GROUPS;

SELECT v.group_obj.grup, v.group_obj.get_specialty_info()
FROM V_GROUP_OBJ v;






CREATE INDEX IDX_ATTR_COURSE2 ON OBJ_STUDENTS s (s.course);
CREATE INDEX IDX_METHOD_ID2 ON OBJ_STUDENTS s (s.get_id());

CREATE INDEX IDX_ATTR_GRUP ON OBJ_GROUPS g (g.course);
CREATE INDEX IDX_METHOD_GID ON OBJ_GROUPS g (g.get_id());





EXPLAIN PLAN FOR
SELECT  * 
FROM OBJ_STUDENTS s 
WHERE s.course = 99;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);





EXPLAIN PLAN FOR
SELECT * FROM OBJ_STUDENTS s WHERE s.get_id() = 999999;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


EXPLAIN PLAN FOR
SELECT *
FROM OBJ_GROUPS g
WHERE g.course = 99;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


EXPLAIN PLAN FOR
SELECT * FROM OBJ_GROUPS g WHERE g.get_id() = 999999;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);