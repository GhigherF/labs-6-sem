DELETE FROM GRADES WHERE student_id IN (SELECT student_id FROM STUDENTS WHERE grup IN (101, 102));
DELETE FROM STUDENTS WHERE grup IN (101, 102);

MERGE INTO FACULTIES f 
USING (SELECT 'ИБ' as f, 'Факультет ИБ' as fn, 'Иванов И.И.' as d FROM dual) src
ON (f.faculty = src.f)
WHEN NOT MATCHED THEN INSERT (faculty, faculty_name, dean) VALUES (src.f, src.fn, src.d);

MERGE INTO PULPITS p
USING (SELECT faculty_id FROM FACULTIES WHERE faculty = 'ИБ') f_id
ON (p.faculty_id = f_id.faculty_id AND p.pulpit = 'Кафедра криптографии')
WHEN NOT MATCHED THEN INSERT (faculty_id, pulpit, head_of_pulpit) VALUES (f_id.faculty_id, 'Кафедра криптографии', 'Петров П.П.');

MERGE INTO SPECIALTIES s
USING (SELECT pulpit_id FROM PULPITS WHERE pulpit = 'Кафедра криптографии') p_id
ON (s.pulpit_id = p_id.pulpit_id AND s.specialty = 'Информационная безопасность')
WHEN NOT MATCHED THEN INSERT (specialty, years_of_study, degree, pulpit_id) VALUES ('Информационная безопасность', 4, 'Бакалавр', p_id.pulpit_id);

BEGIN
  FOR i IN 1..4 LOOP
    MERGE INTO SUBJECTS sub
    USING (SELECT pulpit_id FROM PULPITS WHERE pulpit = 'Кафедра криптографии') p_id
    ON (sub.subject = 'Предмет ' || i)
    WHEN NOT MATCHED THEN INSERT (subject, pulpit_id) VALUES ('Предмет ' || i, p_id.pulpit_id);
  END LOOP;
END;


DECLARE
  v_spec_id NUMBER;
BEGIN
  SELECT specialty_id INTO v_spec_id FROM SPECIALTIES WHERE specialty = 'Информационная безопасность' FETCH FIRST 1 ROW ONLY;
  
  FOR i IN 1..3 LOOP
    INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Студент А'||i, v_spec_id, 1, 101, 1);
    INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Студент Б'||i, v_spec_id, 1, 102, 1);
  END LOOP;
END;


DECLARE
    v_sub1 NUMBER; v_sub2 NUMBER; v_sub3 NUMBER; v_sub4 NUMBER;
BEGIN
    SELECT subject_id INTO v_sub1 FROM SUBJECTS WHERE subject = 'Предмет 1';
    SELECT subject_id INTO v_sub2 FROM SUBJECTS WHERE subject = 'Предмет 2';
    SELECT subject_id INTO v_sub3 FROM SUBJECTS WHERE subject = 'Предмет 3';
    SELECT subject_id INTO v_sub4 FROM SUBJECTS WHERE subject = 'Предмет 4';

    FOR rec IN (SELECT student_id, grup FROM STUDENTS WHERE grup IN (101, 102)) LOOP
        INSERT INTO GRADES (student_id, subject_id, grade) VALUES (rec.student_id, v_sub1, CASE WHEN rec.grup = 101 THEN 9 ELSE 8 END);
        INSERT INTO GRADES (student_id, subject_id, grade) VALUES (rec.student_id, v_sub2, CASE WHEN rec.grup = 101 THEN 5 ELSE 4 END);
        INSERT INTO GRADES (student_id, subject_id, grade) VALUES (rec.student_id, v_sub3, CASE WHEN rec.grup = 101 THEN 8 ELSE 9 END);
        INSERT INTO GRADES (student_id, subject_id, grade) VALUES (rec.student_id, v_sub4, CASE WHEN rec.grup = 101 THEN 4 ELSE 3 END);
    END LOOP;
END;
COMMIT;




SELECT 
    s.grup AS Группа,
    g.subject_id AS Порядок,
    ROUND(AVG(g.grade), 2) AS Средний_балл,
    RPAD('*', ROUND(AVG(g.grade)), '*') AS График
FROM STUDENTS s
JOIN GRADES g ON s.student_id = g.student_id
WHERE s.grup IN (101, 102)
GROUP BY s.grup, g.subject_id
ORDER BY s.grup, g.subject_id;





------------------------------------------------
-----------------------------------------------
--
--      +20% у всех

WITH base_data AS (
    SELECT
        TRIM(s.student) AS clean_name,
        s.course,
        AVG(g.grade) AS avg_grade
    FROM STUDENTS s
    JOIN GRADES g ON g.student_id = s.student_id
    GROUP BY TRIM(s.student), s.course
),
future_slots AS (
    SELECT clean_name, course, avg_grade, 0 as is_forecast FROM base_data
    UNION ALL
    SELECT clean_name, MAX(course) + 1, CAST(NULL AS NUMBER), 1 
    FROM base_data GROUP BY clean_name
),
model_applied AS (
    SELECT * FROM future_slots
    MODEL
        PARTITION BY (clean_name)
        DIMENSION BY (course)
        MEASURES (avg_grade, is_forecast)
        RULES (
            avg_grade[ANY] = CASE 
                WHEN avg_grade[CV()] IS NULL THEN
                    LEAST(avg_grade[CV() - 1] + avg_grade[CV()-1]*0.2, 10)
                ELSE avg_grade[CV()]
            END
        )
)
SELECT 
    clean_name AS Студент,
    (course - 1) AS Курс_факт,
    ROUND(prev_grade, 2) AS Старая_оценка,
    ROUND(avg_grade, 2) AS Прогноз_оценка
FROM (
    SELECT 
        clean_name, 
        course, 
        avg_grade, 
        is_forecast,
        LAG(avg_grade) OVER (PARTITION BY clean_name ORDER BY course) as prev_grade
    FROM model_applied
)
WHERE is_forecast = 1
ORDER BY clean_name;




--------------------------------------------------------------------------
WITH base_data AS (
    SELECT
        TRIM(s.student) AS clean_name,
        s.course,
        AVG(g.grade) AS avg_grade
    FROM STUDENTS s
    JOIN GRADES g ON g.student_id = s.student_id
    GROUP BY TRIM(s.student), s.course
),
future_slots AS (
    SELECT clean_name, course, avg_grade, 0 as is_forecast FROM base_data
    UNION ALL
    SELECT clean_name, MAX(course) + 1, CAST(NULL AS NUMBER), 1 
    FROM base_data GROUP BY clean_name
),
model_applied AS (
    SELECT * FROM future_slots
    MODEL
        PARTITION BY (clean_name)
        DIMENSION BY (course)
        MEASURES (avg_grade, is_forecast)
RULES (
    avg_grade[ANY] = CASE 
        WHEN avg_grade[CV()] IS NULL THEN
            CASE 
                WHEN avg_grade[CV() - 1] > 6.5 THEN avg_grade[CV() - 1]
                ELSE GREATEST(avg_grade[CV() - 1] - avg_grade[CV()-1]*0.2, 2)
            END
        ELSE avg_grade[CV()]
    END
)
)
SELECT 
    clean_name AS Студент,
    (course - 1) AS Курс_факт,
    ROUND(prev_grade, 2) AS Старая_оценка,
    ROUND(avg_grade, 2) AS Прогноз_оценка
FROM (
    SELECT 
        clean_name, 
        course, 
        avg_grade, 
        is_forecast,
        LAG(avg_grade) OVER (PARTITION BY clean_name ORDER BY course) as prev_grade
    FROM model_applied
)
WHERE is_forecast = 1
ORDER BY clean_name;






----------------------------------------------------
SELECT 
    ГРУППА, 
    БАЛЛ_1, 
    БАЛЛ_2, 
    БАЛЛ_3,
    БАЛЛ_4
FROM (
    SELECT 
        s.GRUP AS ГРУППА,
        g.SUBJECT_ID AS ПОРЯДОК,
        AVG(g.GRADE) AS СРЕДНИЙ_БАЛЛ
    FROM STUDENTS s
    JOIN GRADES g ON s.STUDENT_ID = g.STUDENT_ID
    GROUP BY s.GRUP, g.SUBJECT_ID 
)
MATCH_RECOGNIZE (
    PARTITION BY ГРУППА
    ORDER BY ПОРЯДОК
    MEASURES
        ROUND(A.СРЕДНИЙ_БАЛЛ, 2) AS БАЛЛ_1,
        ROUND(B.СРЕДНИЙ_БАЛЛ, 2) AS БАЛЛ_2,
        ROUND(C.СРЕДНИЙ_БАЛЛ, 2) AS БАЛЛ_3,
        ROUND(D.СРЕДНИЙ_БАЛЛ, 2) AS БАЛЛ_4
    PATTERN (A B C D)
    DEFINE
        B AS B.СРЕДНИЙ_БАЛЛ < A.СРЕДНИЙ_БАЛЛ,
        C AS C.СРЕДНИЙ_БАЛЛ > B.СРЕДНИЙ_БАЛЛ, 
        D AS D.СРЕДНИЙ_БАЛЛ < C.СРЕДНИЙ_БАЛЛ  
)
ORDER BY ГРУППА;