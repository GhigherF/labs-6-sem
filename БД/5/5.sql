INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES
('2024-03-10T10:00:00','101',1,1),
('2024-03-15T10:00:00','102',2,2),
('2024-05-12T10:00:00','103',3,3),
('2024-05-18T10:00:00','104',4,4),

('2024-09-10T10:00:00','201',5,5),
('2024-09-15T10:00:00','202',6,6),
('2024-11-12T10:00:00','203',7,7),
('2024-11-18T10:00:00','204',8,8);

INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES
('2025-02-10T10:00:00','101',1,1),
('2025-02-15T10:00:00','102',2,2),
('2025-04-12T10:00:00','103',3,3),
('2025-04-18T10:00:00','104',4,4),

('2025-08-10T10:00:00','201',5,5),
('2025-08-15T10:00:00','202',6,6),
('2025-10-12T10:00:00','203',7,7),
('2025-10-18T10:00:00','204',8,8);

INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES
('2026-03-10T10:00:00','301',1,1),
('2026-03-15T10:00:00','302',2,2),
('2026-04-12T10:00:00','303',3,3),
('2026-04-18T10:00:00','304',4,4),

('2026-09-10T10:00:00','401',5,5),
('2026-09-15T10:00:00','402',6,6),
('2026-11-12T10:00:00','403',7,7),
('2026-11-18T10:00:00','404',8,8);


INSERT INTO GRADES (student_id, subject_id, grade)
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    1,
    (ABS(CHECKSUM(NEWID())) % 3) + 8  -- 8-10
FROM sys.objects;

INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    2,
    (ABS(CHECKSUM(NEWID())) % 5) + 4  -- 4-8
FROM sys.objects;

INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    5,
    (ABS(CHECKSUM(NEWID())) % 4) + 1  -- 1-4
FROM sys.objects;

INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    7,
    (ABS(CHECKSUM(NEWID())) % 10) + 1
FROM sys.objects;



INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    1,
    (ABS(CHECKSUM(NEWID())) % 3) + 1
FROM sys.objects;

INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    3,
    (ABS(CHECKSUM(NEWID())) % 3) + 8
FROM sys.objects;

INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    5,
    (ABS(CHECKSUM(NEWID())) % 5) + 5
FROM sys.objects;

-- 2025 октябрь (разброс)
INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    7,
    (ABS(CHECKSUM(NEWID())) % 10) + 1
FROM sys.objects;



INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    1,
    (ABS(CHECKSUM(NEWID())) % 2) + 9
FROM sys.objects;

-- 2026 апрель (очень низкие)
INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    2,
    (ABS(CHECKSUM(NEWID())) % 2) + 1
FROM sys.objects;

-- 2026 сентябрь (средние)
INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    5,
    (ABS(CHECKSUM(NEWID())) % 5) + 3
FROM sys.objects;

-- 2026 ноябрь (хаос)
INSERT INTO GRADES
SELECT TOP 20
    (ABS(CHECKSUM(NEWID())) % 20) + 1,
    7,
    (ABS(CHECKSUM(NEWID())) % 10) + 1
FROM sys.objects;




INSERT INTO GRADES (student_id, subject_id, grade)
SELECT 
    s.student_id,
    (ABS(CHECKSUM(NEWID())) % 10) + 1,
    (ABS(CHECKSUM(NEWID())) % 10) + 1
FROM STUDENTS s
WHERE s.specialty_id <> 1;





INSERT INTO GRADES (student_id, subject_id, grade)
SELECT 
    s.student_id,
    sub.subject_id,
    (ABS(CHECKSUM(NEWID())) % 10) + 1
FROM STUDENTS s
JOIN SUBJECTS sub ON sub.pulpit_id = (
    SELECT TOP 1 pulpit_id 
    FROM SPECIALTIES sp 
    WHERE sp.specialty_id = s.specialty_id
)
WHERE s.student_id > 10;






INSERT INTO GRADES (student_id, subject_id, grade)
SELECT TOP 50
    s.student_id,
    16 + ABS(CHECKSUM(NEWID())) % 5, -- предметы экономики
    4 + ABS(CHECKSUM(NEWID())) % 7
FROM students s
JOIN specialties sp ON s.specialty_id = sp.specialty_id
JOIN pulpits p ON sp.pulpit_id = p.pulpit_id
WHERE p.faculty_id = 5;



INSERT INTO GRADES (student_id, subject_id, grade) VALUES
-- студенты 6,7
(6,10,5),(6,24,6),(6,10,4),(6,24,7),(6,10,5),
(7,10,6),(7,24,5),(7,10,7),(7,24,4),(7,10,6),

(6,24,5),(6,10,6),(6,24,4),(6,10,7),(6,24,5),
(7,24,6),(7,10,5),(7,24,7),(7,10,4),(7,24,6);



INSERT INTO GRADES (student_id, subject_id, grade) VALUES
-- студенты экономики (9,10)
(9,16,8),(9,17,7),(9,18,9),(9,16,6),(9,17,8),
(10,16,7),(10,17,6),(10,18,8),(10,16,9),(10,17,7),

(9,18,7),(9,16,8),(9,17,6),(9,18,9),(9,16,7),
(10,18,6),(10,16,8),(10,17,7),(10,18,9),(10,16,6);



INSERT INTO GRADES (student_id, subject_id, grade) VALUES
-- студент 1 (у тебя почти нет данных по ТОВ — исправляем)
(1,21,4),(1,22,5),(1,21,3),(1,22,6),(1,21,4),
(1,21,5),(1,22,4),(1,21,3),(1,22,5),(1,21,4),

(1,22,3),(1,21,4),(1,22,5),(1,21,2),(1,22,6),
(1,21,3),(1,22,4),(1,21,5),(1,22,3),(1,21,4);





SELECT DISTINCT f.faculty
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN specialties sp ON s.specialty_id = sp.specialty_id
JOIN pulpits p ON sp.pulpit_id = p.pulpit_id
JOIN faculties f ON p.faculty_id = f.faculty_id;




SELECT f.faculty, COUNT(*) AS cnt
FROM STUDENTS s
JOIN SPECIALTIES sp ON s.specialty_id = sp.specialty_id
JOIN PULPITS p ON sp.pulpit_id = p.pulpit_id
JOIN FACULTIES f ON p.faculty_id = f.faculty_id
GROUP BY f.faculty
ORDER BY cnt DESC;



UPDATE STUDENTS SET specialty_id = 6 WHERE student_id BETWEEN 1 AND 3;   -- ХТ
UPDATE STUDENTS SET specialty_id = 7 WHERE student_id BETWEEN 4 AND 6;   -- ХТ
UPDATE STUDENTS SET specialty_id = 8 WHERE student_id BETWEEN 7 AND 9;   -- ЛХ
UPDATE STUDENTS SET specialty_id = 9 WHERE student_id BETWEEN 10 AND 12; -- ФЭ
UPDATE STUDENTS SET specialty_id = 11 WHERE student_id BETWEEN 13 AND 15;-- ТОВ



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
SELECT  
    s.student,
    YEAR(e.exam_date) AS Exam_Year,
    MONTH(e.exam_date) AS Exam_Month,
    AVG(CAST(g.grade AS FLOAT)) AS MONTH,
    AVG(AVG(CAST(g.grade AS FLOAT))) OVER (
        PARTITION BY s.student_id, YEAR(e.exam_date), DATEPART(QUARTER, e.exam_date)) AS KVARTAL,
    AVG(AVG(CAST(g.grade AS FLOAT))) OVER (
        PARTITION BY s.student_id, YEAR(e.exam_date), 
        (CASE WHEN MONTH(e.exam_date) <= 6 THEN 1 ELSE 2 END)) AS POLGODA,
    AVG(AVG(CAST(g.grade AS FLOAT))) OVER (
        PARTITION BY s.student_id, YEAR(e.exam_date)) AS YEAR
FROM GRADES g
JOIN STUDENTS s ON g.student_id = s.student_id
JOIN EXAMS e ON g.subject_id = e.subject_id
GROUP BY 
    s.student_id, 
    s.student, 
    YEAR(e.exam_date), 
    MONTH(e.exam_date), 
    DATEPART(QUARTER, e.exam_date)
ORDER BY 
    s.student, 
    Exam_Year, 
    Exam_Month;
--------------------------------------------------------------

DECLARE @START DATE = '2025-02-19T10:00:00';
DECLARE @END DATE = '2026-09-25T10:00:00';

WITH FilteredExams AS (
    SELECT subject_id, exam_date 
    FROM EXAMS 
    WHERE exam_date BETWEEN @START AND @END
)

SELECT 
    s.student,
    f.faculty,
    AVG(CAST(g.grade AS FLOAT)) AS Student_Avg,
    AVG(AVG(CAST(g.grade AS FLOAT))) OVER (PARTITION BY f.faculty) AS Faculty_Avg,
    ROUND(
        (AVG(CAST(g.grade AS FLOAT)) / 
         NULLIF(AVG(AVG(CAST(g.grade AS FLOAT))) OVER (PARTITION BY f.faculty), 0)) * 100, 
    2) AS FACULTY,
    ROUND(
        (AVG(CAST(g.grade AS FLOAT)) / 
         NULLIF(MAX(AVG(CAST(g.grade AS FLOAT))) OVER (), 0)) * 100, 
    2) AS MAX

FROM FilteredExams fe
JOIN GRADES g       ON g.subject_id = fe.subject_id
JOIN STUDENTS s     ON g.student_id = s.student_id
JOIN SPECIALTIES sp ON s.specialty_id = sp.specialty_id
JOIN PULPITS p      ON sp.pulpit_id = p.pulpit_id
JOIN FACULTIES f    ON p.faculty_id = f.faculty_id

GROUP BY s.student_id, s.student, f.faculty
ORDER BY f.faculty, Student_Avg DESC;


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


DECLARE @Page INT = 1;
DECLARE @PageSize INT = 20;

WITH Data AS (SELECT grades.grade_id,students.student,grades.grade,exams.exam_date,
        ROW_NUMBER() OVER (ORDER BY exams.exam_date, grades.grade_id) AS rn
    FROM GRADES 
    JOIN STUDENTS  ON grades.student_id =students.student_id
    LEFT JOIN EXAMS  ON grades.subject_id = exams.subject_id)

SELECT * FROM Data WHERE rn BETWEEN (@Page - 1) * @PageSize + 1 AND @Page * @PageSize;











WITH Dups AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY student_id, subject_id, grade ORDER BY grade_id) AS rn
FROM GRADES )

DELETE FROM Dups WHERE rn > 1;

---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------

WITH Ranked AS (SELECT students.student_id,students.student,grades.grade,exams.exam_date,
ROW_NUMBER() OVER (PARTITION BY students.student_id ORDER BY exams.exam_date DESC) AS rn
FROM GRADES 
JOIN STUDENTS  ON grades.student_id = students.student_id
JOIN EXAMS  ON grades.subject_id = exams.subject_id)

SELECT student_id,student,
AVG(CAST(grade AS FLOAT)) AS avg_last_3
FROM Ranked
WHERE rn <= 3
GROUP BY student_id, student
ORDER BY student_id;






WITH Attempts AS (SELECT 
        grades.subject_id,
        subjects.subject,
        grades.student_id,
        students.student,
        COUNT(*) AS attempt_count
    FROM GRADES 
    JOIN STUDENTS  ON grades.student_id = students.student_id
    JOIN SUBJECTS  ON grades.subject_id = subjects.subject_id
    GROUP BY grades.subject_id, subjects.subject, grades.student_id, students.student),

Ranked AS (SELECT *,ROW_NUMBER() OVER (PARTITION BY subject_id ORDER BY attempt_count DESC) AS rn
FROM Attempts)
SELECT subject_id,subject,student_id,student,attempt_count
FROM Ranked WHERE rn = 1
ORDER BY subject;








