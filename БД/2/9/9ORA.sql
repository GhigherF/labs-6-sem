

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE GROUPS CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;


CREATE TABLE GROUPS (
    group_id     NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    grup         NUMBER        NOT NULL UNIQUE,
    course       NUMBER        NOT NULL,
    specialty_id NUMBER,
    CONSTRAINT fk_groups_spec FOREIGN KEY (specialty_id)
        REFERENCES SPECIALTIES (specialty_id)
);

INSERT INTO GROUPS (grup, course, specialty_id)
SELECT DISTINCT s.grup,
                s.course,
                s.specialty_id
FROM STUDENTS s
ORDER BY s.grup;

DECLARE
    v_spec_id NUMBER;
BEGIN
    SELECT MAX(specialty_id) INTO v_spec_id FROM SPECIALTIES;
    INSERT INTO GROUPS (grup, course, specialty_id) VALUES (20, 1, v_spec_id);
    INSERT INTO GROUPS (grup, course, specialty_id) VALUES (21, 2, v_spec_id);
END;



INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup)
SELECT 'Новиков Павел',   MAX(specialty_id), 1, 20, 1 FROM SPECIALTIES;
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup)
SELECT 'Захарова Юлия',   MAX(specialty_id), 1, 20, 2 FROM SPECIALTIES;
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup)
SELECT 'Мельников Степан', MAX(specialty_id), 2, 21, 1 FROM SPECIALTIES;
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup)
SELECT 'Орлова Вера',      MAX(specialty_id), 2, 21, 2 FROM SPECIALTIES;

COMMIT;

SELECT * FROM GROUPS ORDER BY grup;
SELECT * FROM STUDENTS ORDER BY student_id;


-- ================================================================
-- ================================================================

CREATE OR REPLACE TYPE T_GROUP_OBJ AS OBJECT (
    group_id     NUMBER,
    grup         NUMBER,
    course       NUMBER,
    specialty_id NUMBER
);


CREATE OR REPLACE TYPE T_GROUP_NT AS TABLE OF T_GROUP_OBJ;


CREATE OR REPLACE TYPE T_STUDENT_EXT AS OBJECT (
    student_id  NUMBER,
    full_name   VARCHAR2(150),
    course      NUMBER,
    grup        NUMBER,
    subgroup    NUMBER,
    groups      T_GROUP_NT
);  


CREATE OR REPLACE TYPE T_STUDENT_NT AS TABLE OF T_STUDENT_EXT;


BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE K1_TABLE CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;


CREATE TABLE K1_TABLE OF T_STUDENT_EXT
    NESTED TABLE groups STORE AS K2_GROUPS_TAB;

INSERT INTO K1_TABLE
SELECT T_STUDENT_EXT(
    s.student_id,
    s.student,
    s.course,
    s.grup,
    s.subgroup,
    CAST(
        MULTISET(
            SELECT T_GROUP_OBJ(g.group_id, g.grup, g.course, g.specialty_id)
            FROM GROUPS g
            WHERE g.grup = s.grup
        ) AS T_GROUP_NT
    )
)
FROM STUDENTS s;

COMMIT;

-- 2а. Наполнение K1 и K2
SELECT k.student_id,
       k.full_name,
       k.course,
       k.grup,
       CARDINALITY(k.groups) AS groups_count
FROM K1_TABLE k
ORDER BY k.student_id;

SELECT k.student_id,
       k.full_name,
       k.grup,
       g.group_id,
       g.course,
       g.specialty_id
FROM K1_TABLE k,
     TABLE(k.groups) g
ORDER BY k.student_id;

-- 2б
DECLARE
    v_search_grup   NUMBER := 20;
    v_search_course NUMBER := 1;
    v_name          VARCHAR2(150);
BEGIN
    SELECT full_name INTO v_name
    FROM K1_TABLE
    WHERE grup   = v_search_grup
      AND course = v_search_course
      AND ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE(
        'Элемент найден в K1: ' || v_name ||
        ' (grup=' || v_search_grup ||
        ', course=' || v_search_course || ')'
    );
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(
            'Элемент с grup=' || v_search_grup ||
            ', course=' || v_search_course || ' НЕ найден в K1.'
        );
END;

-- 2в. Пустые коллекции K2 в K1
SELECT k.student_id,
       k.full_name,
       k.grup,
       k.course
FROM K1_TABLE k
WHERE k.groups IS EMPTY
ORDER BY k.student_id;

DECLARE
    v_cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cnt
    FROM K1_TABLE k
    WHERE k.groups IS EMPTY;

    IF v_cnt = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Пустых коллекций K2 (groups) в K1 не обнаружено.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Студентов с пустой K2 (groups): ' || v_cnt);
    END IF;
END;

-- 3а
CREATE OR REPLACE TYPE T_STUDENT_VA AS VARRAY(100) OF T_STUDENT_EXT;




DECLARE
    v_arr  T_STUDENT_VA := T_STUDENT_VA();
    v_idx  PLS_INTEGER  := 0;
BEGIN
    FOR rec IN (SELECT VALUE(k) AS obj FROM K1_TABLE k
                ORDER BY k.student_id FETCH FIRST 55 ROWS ONLY) LOOP
        v_idx := v_idx + 1;
        v_arr.EXTEND;
        v_arr(v_idx) := rec.obj;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('VARRAY создан, элементов: ' || v_arr.COUNT);
    FOR i IN 1..v_arr.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            '  [' || i || '] ' || v_arr(i).full_name ||
            ', grup=' || v_arr(i).grup ||
            ', групп в K2=' || v_arr(i).groups.COUNT
        );
    END LOOP;
END;

-- 3б. TABLE()
SELECT k.student_id,
       k.full_name,
       k.course,
       k.subgroup,
       g.group_id,
       g.grup,
       g.specialty_id
FROM K1_TABLE k,
     TABLE(k.groups) g
ORDER BY k.student_id;

-- 4а. BULK 
DECLARE
    TYPE t_id_list   IS TABLE OF NUMBER        INDEX BY PLS_INTEGER;
    TYPE t_name_list IS TABLE OF VARCHAR2(150)  INDEX BY PLS_INTEGER;
    TYPE t_grp_list  IS TABLE OF NUMBER        INDEX BY PLS_INTEGER;
    TYPE t_crs_list  IS TABLE OF NUMBER        INDEX BY PLS_INTEGER;

    v_ids    t_id_list;
    v_names  t_name_list;
    v_grps   t_grp_list;
    v_crs    t_crs_list;
BEGIN
    SELECT k.student_id, k.full_name, k.grup, k.course
    BULK COLLECT INTO v_ids, v_names, v_grps, v_crs
    FROM K1_TABLE k
    ORDER BY k.student_id;

    DBMS_OUTPUT.PUT_LINE('BULK COLLECT: загружено студентов = ' || v_ids.COUNT);
    FOR i IN 1..LEAST(v_ids.COUNT, 5) LOOP
        DBMS_OUTPUT.PUT_LINE(
            '  ID=' || v_ids(i) ||
            ', ' || v_names(i) ||
            ', grup=' || v_grps(i) ||
            ', course=' || v_crs(i)
        );
    END LOOP;
END;

-- 4б. BULK COLLECT + FORALL UPDATE
DECLARE
    TYPE t_sid_list IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE t_crs_list IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE t_grp_list IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

    v_sids  t_sid_list;
    v_crs   t_crs_list;
    v_grps  t_grp_list;
BEGIN
    SELECT student_id, course, grup
    BULK COLLECT INTO v_sids, v_crs, v_grps
    FROM STUDENTS
    WHERE course < 5;

    DBMS_OUTPUT.PUT_LINE('Студентов для перевода на след. курс: ' || v_sids.COUNT);

    FOR i IN 1..v_crs.COUNT LOOP
        v_crs(i) := v_crs(i) + 1;
    END LOOP;

    FORALL i IN 1..v_sids.COUNT
        UPDATE STUDENTS
        SET    course = v_crs(i)
        WHERE  student_id = v_sids(i);

    DBMS_OUTPUT.PUT_LINE('FORALL UPDATE STUDENTS: обновлено ' || SQL%ROWCOUNT || ' строк.');

    FORALL i IN 1..v_grps.COUNT
        UPDATE GROUPS
        SET    course = v_crs(i)
        WHERE  grup   = v_grps(i);

    DBMS_OUTPUT.PUT_LINE('FORALL UPDATE GROUPS: обновлено ' || SQL%ROWCOUNT || ' строк.');

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Изменения откачены (ROLLBACK).');
END;

-- 4в. BULK COLLECT с LIMIT
DECLARE
    v_batch_nt  T_STUDENT_NT;
    CURSOR c_k1 IS SELECT VALUE(k) FROM K1_TABLE k ORDER BY k.student_id;
    v_limit     CONSTANT PLS_INTEGER := 5;
    v_page      PLS_INTEGER := 0;
BEGIN
    OPEN c_k1;
    LOOP
        FETCH c_k1 BULK COLLECT INTO v_batch_nt LIMIT v_limit;
        EXIT WHEN v_batch_nt.COUNT = 0;
        v_page := v_page + 1;
        DBMS_OUTPUT.PUT_LINE(
            'Страница ' || v_page ||
            ': получено ' || v_batch_nt.COUNT || ' студентов'
        );
        FOR i IN 1..v_batch_nt.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
                '    ' || v_batch_nt(i).full_name ||
                ', grup=' || v_batch_nt(i).grup ||
                ', course=' || v_batch_nt(i).course ||
                ', групп в K2=' || v_batch_nt(i).groups.COUNT
            );
        END LOOP;
        EXIT WHEN v_batch_nt.COUNT < v_limit;
    END LOOP;
    CLOSE c_k1;
END;
