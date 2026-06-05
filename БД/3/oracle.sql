ALTER TABLE teachers
ADD parent_id NUMBER;

select * from teachers;

INSERT INTO teachers (teacher_id,teacher, position, pulpit_id, parent_id)
VALUES (21,'Касперович Максим', 'ректор', 3, NULL);


UPDATE teachers
SET parent_id = 21 
WHERE teacher_id IN (1, 2);


UPDATE teachers
SET parent_id = 1
WHERE teacher_id IN (3, 10);

UPDATE teachers
SET parent_id = 3
WHERE teacher_id = 4;






select  parent_id,teacher_id,teacher from teachers
where parent_id is not null or teacher_id = 21;




CREATE OR REPLACE PROCEDURE GetUnder(p_node_id NUMBER) IS
BEGIN
    FOR rec IN (
        SELECT teacher_id, parent_id, LEVEL AS node_level
        FROM teachers
        START WITH teacher_id = p_node_id
        CONNECT BY PRIOR teacher_id = parent_id
        ORDER BY LEVEL, teacher_id
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.teacher_id || ' | parent=' ||
            NVL(TO_CHAR(rec.parent_id), 'NULL') ||
            ' | level=' || rec.node_level
        );
    END LOOP;
END;


begin
GetUnder(21);
END;




CREATE OR REPLACE PROCEDURE AddChild(p_parent_id NUMBER,p_teacher_id NUMBER) IS
BEGIN
    UPDATE teachers
    SET parent_id = p_parent_id
    WHERE teacher_id = p_teacher_id;
END;


DECLARE
   v_parent NUMBER;
BEGIN
    SELECT teacher_id INTO v_parent FROM teachers WHERE teacher_id = 1;
    AddChild(v_parent, 14);
END;


DECLARE
   v_parent NUMBER;
 BEGIN
     SELECT teacher_id INTO v_parent FROM teachers WHERE teacher_id = 3;
     AddChild(v_parent, 15);
 END;



select  parent_id,teacher_id,teacher from teachers
where parent_id is not null or teacher_id =21;


CREATE OR REPLACE PROCEDURE MoveFromUnder(
    p_old_parent NUMBER,
    p_new_parent NUMBER
) IS
    v_cycle_check NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_cycle_check
    FROM teachers
    WHERE teacher_id = p_new_parent
    START WITH teacher_id = p_old_parent
    CONNECT BY PRIOR teacher_id = parent_id;

    IF v_cycle_check > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Нельзя переместить в потомка');
    END IF;

    UPDATE teachers
    SET parent_id = p_new_parent
    WHERE teacher_id IN (
        SELECT teacher_id
        FROM teachers
        START WITH parent_id = p_old_parent  
        CONNECT BY PRIOR teacher_id = parent_id
    );

END;


 DECLARE
     v_new NUMBER;
     v_old NUMBER;
 BEGIN
     SELECT teacher_id INTO v_new FROM teachers WHERE teacher_id = 4;
     SELECT teacher_id INTO v_old FROM teachers WHERE teacher_id = 2;
     MoveFromUnder(v_old, v_new);
 END;


select  parent_id,teacher_id,teacher from teachers
where parent_id is not null or teacher_id =21;
commit;
--rollback;