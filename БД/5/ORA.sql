-- 1. ПОЛНАЯ ОЧИСТКА
TRUNCATE TABLE GRADES;
TRUNCATE TABLE EXAMS;
TRUNCATE TABLE SUBJECT_TEACHER;
TRUNCATE TABLE STUDENTS;
TRUNCATE TABLE TEACHERS;
TRUNCATE TABLE SUBJECTS;
TRUNCATE TABLE SPECIALTIES;
TRUNCATE TABLE PULPITS;
TRUNCATE TABLE FACULTIES;

-- 2. СПРАВОЧНИКИ (Факультеты, Кафедры, Специальности)
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ИТ','Информационные технологии','Блинова Е.В.');
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ТОВ','Технологический','Смирнов А.А.');

INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) 
VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty = 'ИТ'), 'ПИ', 'Смелов В.В.');

INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) 
VALUES ('Программная инженерия', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ПИ'));

-- 3. ПРЕДМЕТЫ
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Базы данных', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ОАиП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ПСКП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Операционные системы', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ПИ'));

-- 4. ПРЕПОДАВАТЕЛИ И СТУДЕНТЫ
INSERT INTO TEACHERS (teacher, position, pulpit_id) 
VALUES ('Смелов В.В.', 'Зав. кафедрой', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ПИ'));
INSERT INTO TEACHERS (teacher, position, pulpit_id) 
VALUES ('Блинова Е.В.', 'Доцент', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ПИ'));

INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
VALUES ('Дмитроченко Кирилл', (SELECT MAX(specialty_id) FROM SPECIALTIES WHERE specialty = 'Программная инженерия'), 3, 8, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
VALUES ('Иванов Алексей', (SELECT MAX(specialty_id) FROM SPECIALTIES WHERE specialty = 'Программная инженерия'), 3, 6, 1);

-- 5. ЭКЗАМЕНЫ (Распределение по всему году 2026)
-- Q1: Январь и Март
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-01-15', 'YYYY-MM-DD'), '101', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher = 'Смелов В.В.'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Базы данных'));
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-03-20', 'YYYY-MM-DD'), '102', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher = 'Блинова Е.В.'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'ОАиП'));

-- Q2: Май и Июнь
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-05-10', 'YYYY-MM-DD'), '103', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher = 'Смелов В.В.'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'ПСКП'));
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-06-25', 'YYYY-MM-DD'), '104', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher = 'Блинова Е.В.'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Операционные системы'));

-- Q3: Сентябрь
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-09-12', 'YYYY-MM-DD'), '105', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher = 'Смелов В.В.'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Базы данных'));

-- Q4: Ноябрь и Декабрь
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-11-05', 'YYYY-MM-DD'), '106', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher = 'Блинова Е.В.'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'ОАиП'));
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-12-20', 'YYYY-MM-DD'), '107', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher = 'Смелов В.В.'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'ПСКП'));

-- 6. ОЦЕНКИ (С разной успеваемостью для наглядности средних)
-- Студент 1 (Кирилл)
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student = 'Дмитроченко Кирилл'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Базы данных'), 4);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student = 'Дмитроченко Кирилл'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'ОАиП'), 9);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student = 'Дмитроченко Кирилл'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'ПСКП'), 2);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student = 'Дмитроченко Кирилл'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Операционные системы'), 10);

-- Студент 2 (Алексей)
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student = 'Иванов Алексей'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Базы данных'), 5);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student = 'Иванов Алексей'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'ОАиП'), 10);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student = 'Иванов Алексей'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'ПСКП'), 3);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student = 'Иванов Алексей'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Операционные системы'), 8);

COMMIT;





-- 1. ДОБАВЛЯЕМ НОВЫХ СТУДЕНТОВ (для пагинации)
-- Используем анонимный блок, чтобы быстро наплодить записей
BEGIN
  FOR i IN 40..70 LOOP
    INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
    VALUES (
        'Новый Студент ' || i, 
        (SELECT MAX(specialty_id) FROM SPECIALTIES), 
        MOD(i, 4) + 1, 
        20, 
        1
    );
  END LOOP;
END;
/

-- 2. ДОБАВЛЯЕМ ПРЕДМЕТЫ, ЕСЛИ ИХ ЕЩЕ НЕТ
INSERT INTO SUBJECTS (subject, pulpit_id) 
SELECT 'Архитектура ЭВМ', MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ПИ'
WHERE NOT EXISTS (SELECT 1 FROM SUBJECTS WHERE subject = 'Архитектура ЭВМ');

-- 3. СОЗДАЕМ СИТУАЦИЮ С "ПОПЫТКАМИ СДАЧИ"
-- Студент с ID=10 будет "злостным пересдатчиком" (5 попыток по одному предмету)
BEGIN
  FOR i IN 1..5 LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) 
    VALUES (
        10, 
        (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Архитектура ЭВМ'), 
        TRUNC(DBMS_RANDOM.VALUE(2, 5)) -- Оценки 2, 3 или 4
    );
  END LOOP;
END;
/

-- 4. СОЗДАЕМ ЯВНЫЕ ДУБЛИКАТЫ (для твоего запроса с ROW_NUMBER)
-- Вставляем три абсолютно одинаковые записи для Студента 1
INSERT INTO GRADES (student_id, subject_id, grade) 
VALUES (1, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Базы данных'), 9);
INSERT INTO GRADES (student_id, subject_id, grade) 
VALUES (1, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Базы данных'), 9);
INSERT INTO GRADES (student_id, subject_id, grade) 
VALUES (1, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Базы данных'), 9);

-- 5. НАПОЛНЯЕМ ТАБЛИЦУ ДЛЯ ПАГИНАЦИИ (массовые оценки для новых студентов)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'ОАиП'), 7
FROM STUDENTS 
WHERE student LIKE 'Новый Студент%';

-- 6. ДОБАВЛЯЕМ ЭКЗАМЕН В БУДУЩЕМ (для проверки периодов)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-05-15 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), '404-1', 
       (SELECT MAX(teacher_id) FROM TEACHERS), 
       (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Архитектура ЭВМ'));

COMMIT;











-- =========================================================
-- 1. ДОБАВЛЯЕМ ПРЕПОДАВАТЕЛЕЙ И ПРЕДМЕТЫ (СВЯЗКА)
-- =========================================================
INSERT INTO TEACHERS (teacher, position, pulpit_id) 
VALUES ('Урбанович П.П.', 'Профессор', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ИСиТ'));
INSERT INTO TEACHERS (teacher, position, pulpit_id) 
VALUES ('Наркевич А.Л.', 'Доцент', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ПИ'));

INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Компьютерные сети', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ИСиТ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Математическая логика', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit = 'ПИ'));

-- =========================================================
-- 2. ДОБАВЛЯЕМ ГРУППУ РЕАЛЬНЫХ СТУДЕНТОВ
-- =========================================================
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Иванов Даниил Игоревич', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 8, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Петровская Анна Сергеевна', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 8, 2);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Сидоров Максим Олегович', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 6, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Кузнецова Елена Викторовна', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 6, 2);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Федоров Артем Андреевич', (SELECT MAX(specialty_id) FROM SPECIALTIES), 2, 4, 1);

-- =========================================================
-- 3. СОЗДАЕМ ИСТОРИЮ ЭКЗАМЕНОВ (ДЛЯ АНАЛИТИКИ ПО ПЕРИОДАМ)
-- =========================================================
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2025-12-28 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), '212-4', 1, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Компьютерные сети'));

INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-01-10 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), '301-1', 2, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Математическая логика'));

-- =========================================================
-- 4. МАССОВАЯ ГЕНЕРАЦИЯ ОЦЕНОК (ПРАВДОПОДОБНЫЕ)
-- =========================================================

-- Добавляем по 2-3 оценки каждому новому студенту
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Компьютерные сети'), 
       CASE WHEN MOD(student_id, 2) = 0 THEN 9 ELSE 6 END
FROM STUDENTS WHERE student_id > 5;

-- Ситуация: ДУБЛИКАТЫ (Специально вставляем трижды одну запись)
INSERT INTO GRADES (student_id, subject_id, grade) 
VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student LIKE 'Сидоров%'), 
        (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Математическая логика'), 4);
INSERT INTO GRADES (student_id, subject_id, grade) 
VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student LIKE 'Сидоров%'), 
        (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Математическая логика'), 4);

-- Ситуация: МНОГО ПОПЫТОК (Пересдачи у Иванова)
BEGIN
  FOR i IN 1..4 LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) 
    VALUES (
        (SELECT MAX(student_id) FROM STUDENTS WHERE student LIKE 'Иванов%'),
        (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Математическая логика'),
        TRUNC(DBMS_RANDOM.VALUE(2, 6)) -- Сначала не везет (2, 3, 4, 5)
    );
  END LOOP;
END;
/

-- Ситуация: ДЛЯ ПАГИНАЦИИ (заполняем хвосты)
-- Добавим еще 40 записей случайным студентам
BEGIN
  FOR i IN 1..40 LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) 
    VALUES (
        TRUNC(DBMS_RANDOM.VALUE(1, 50)), 
        (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject = 'Базы данных'), 
        TRUNC(DBMS_RANDOM.VALUE(4, 11))
    );
  END LOOP;
END;
/

COMMIT;

















-- =========================================================
-- 1. ПОЛНАЯ ОЧИСТКА БАЗЫ (Сброс всех данных)
-- =========================================================
TRUNCATE TABLE GRADES;
TRUNCATE TABLE EXAMS;
TRUNCATE TABLE SUBJECT_TEACHER;
TRUNCATE TABLE STUDENTS;
TRUNCATE TABLE TEACHERS;
TRUNCATE TABLE SUBJECTS;
TRUNCATE TABLE SPECIALTIES;
TRUNCATE TABLE PULPITS;
TRUNCATE TABLE FACULTIES;

-- =========================================================
-- 2. СПРАВОЧНИКИ: ФАКУЛЬТЕТЫ, КАФЕДРЫ, СПЕЦИАЛЬНОСТИ
-- =========================================================
-- Факультеты
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ИТ', 'Информационные технологии', 'Блинова Е.В.');
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ТОВ', 'Технологии органических веществ', 'Радченко Ю.С.');
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ИЭФ', 'Инженерно-экономический', 'Ольшанская М.Н.');

-- Кафедры
INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty='ИТ'), 'ПИ', 'Смелов В.В.');
INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty='ИТ'), 'ИСиТ', 'Шиман Д.В.');
INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty='ТОВ'), 'ТНВ', 'Орехова С.Е.');

-- Специальности
INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) 
VALUES ('Программная инженерия', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) 
VALUES ('Информационные системы', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ИСиТ'));

-- =========================================================
-- 3. ПРЕДМЕТЫ И ПРЕПОДАВАТЕЛИ
-- =========================================================
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Базы данных', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ОАиП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ПСКП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('СЕТИ', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ИСиТ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Высшая математика', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));

INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Смелов В.В.', 'Зав. кафедрой', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Акулович Л.М.', 'Доцент', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Блинова Е.В.', 'Профессор', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ИСиТ'));

-- =========================================================
-- 4. МАССОВАЯ ГЕНЕРАЦИЯ СТУДЕНТОВ (65 ЧЕЛОВЕК)
-- =========================================================
BEGIN
  FOR i IN 1..65 LOOP
    INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
    VALUES (
      CASE MOD(i, 3) 
        WHEN 0 THEN 'Абрамов ' || i || ' А.А.'
        WHEN 1 THEN 'Белов ' || i || ' Б.Б.'
        ELSE 'Волков ' || i || ' В.В.'
      END,
      (SELECT MAX(specialty_id) FROM SPECIALTIES WHERE specialty = (CASE WHEN i <= 35 THEN 'Программная инженерия' ELSE 'Информационные системы' END)),
      MOD(i, 4) + 1,
      MOD(i, 10) + 1,
      MOD(i, 2) + 1
    );
  END LOOP;
END;
/

-- =========================================================
-- 5. ЭКЗАМЕНЫ (ДЛЯ ТЕСТОВ ПЕРИОДОВ 2025-2026)
-- =========================================================
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES (TO_DATE('2025-06-15', 'YYYY-MM-DD'), '101-1', 1, 1);
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES (TO_DATE('2025-06-28', 'YYYY-MM-DD'), '202-4', 2, 2);
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES (TO_DATE('2026-01-12', 'YYYY-MM-DD'), '105-1', 1, 3);
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES (TO_DATE('2026-01-25', 'YYYY-MM-DD'), '303-2', 3, 4);
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES (TO_DATE('2026-05-20', 'YYYY-MM-DD'), '404-1', 2, 5);

-- =========================================================
-- 6. ГЕНЕРАЦИЯ ОЦЕНОК (БОЛЕЕ 150 ЗАПИСЕЙ)
-- =========================================================

-- А. Рандомные оценки всем студентам (около 130 записей)
BEGIN
  FOR s IN (SELECT student_id FROM STUDENTS) LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) VALUES (s.student_id, 1, TRUNC(DBMS_RANDOM.VALUE(4, 11)));
    INSERT INTO GRADES (student_id, subject_id, grade) VALUES (s.student_id, 2, TRUNC(DBMS_RANDOM.VALUE(3, 10)));
  END LOOP;
END;
/

-- Б. КЕЙС "МНОГО ПОПЫТОК" (Студент №10 сдает ПСКП 8 раз)
BEGIN
  FOR i IN 1..8 LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) 
    VALUES (10, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), 2 + MOD(i, 3));
  END LOOP;
END;
/

-- В. КЕЙС "ДУБЛИКАТЫ" (Студент №1, предмет Базы данных, оценка 9 - вставлено 3 раза)
INSERT INTO GRADES (student_id, subject_id, grade) VALUES (1, 1, 9);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES (1, 1, 9);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES (1, 1, 9);

-- Г. ДОПОЛНИТЕЛЬНЫЕ ДАННЫЕ ДЛЯ ПАГИНАЦИИ (заполняем Высшую математику)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Высшая математика'), TRUNC(DBMS_RANDOM.VALUE(4, 10))
FROM STUDENTS WHERE student_id <= 30;

COMMIT;

-- =========================================================
-- ПОДТВЕРЖДЕНИЕ ЗАГРУЗКИ
-- =========================================================
SELECT 'Факультетов: ' || COUNT(*) FROM FACULTIES
UNION ALL
SELECT 'Студентов: '   || COUNT(*) FROM STUDENTS
UNION ALL
SELECT 'Оценок всего: ' || COUNT(*) FROM GRADES;





















-- 1. ОЧИСТКА
TRUNCATE TABLE GRADES;
TRUNCATE TABLE EXAMS;
TRUNCATE TABLE SUBJECT_TEACHER;
TRUNCATE TABLE STUDENTS;
TRUNCATE TABLE TEACHERS;
TRUNCATE TABLE SUBJECTS;
TRUNCATE TABLE SPECIALTIES;
TRUNCATE TABLE PULPITS;
TRUNCATE TABLE FACULTIES;

-- 2. СТРУКТУРА
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ИТ', 'Информационные технологии', 'Блинова Е.В.');
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ТОВ', 'Технологии органических веществ', 'Радченко Ю.С.');

INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty='ИТ'), 'ПИ', 'Смелов В.В.');

INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) 
VALUES ('Программная инженерия', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));

-- 3. ПРЕДМЕТЫ (Запомним ID в переменные или используем простые подзапросы)
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Базы данных', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ОАиП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ПСКП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));

-- 4. ПРЕПОДАВАТЕЛИ
INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Смелов В.В.', 'Зав. кафедрой', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));

-- 5. СТУДЕНТЫ (60 человек)
BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
    VALUES ('Студент ' || i, (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 10, 1);
  END LOOP;
END;
/

-- 6. ЭКЗАМЕНЫ
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2025-06-15', 'YYYY-MM-DD'), '101', (SELECT MAX(teacher_id) FROM TEACHERS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'));
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-01-10', 'YYYY-MM-DD'), '102', (SELECT MAX(teacher_id) FROM TEACHERS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ОАиП'));

-- 7. ОЦЕНКИ (ПЕРЕПИСАНО: используем прямой JOIN для вставки)
-- Вставляем каждому студенту по оценке за Базы Данных (60 записей)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 8
FROM STUDENTS;

-- Вставляем каждому студенту по оценке за ОАиП (еще 60 записей)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ОАиП'), 6
FROM STUDENTS;

-- 8. АНОМАЛИИ (Дубликаты и Пересдачи)
-- 5 пересдач для Студента №1 по ПСКП
BEGIN
  FOR i IN 1..5 LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) 
    VALUES ((SELECT MIN(student_id) FROM STUDENTS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), 2 + MOD(i,2));
  END LOOP;
END;
/

-- 3 явных дубликата для Студента №2
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MIN(student_id)+1 FROM STUDENTS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 10);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MIN(student_id)+1 FROM STUDENTS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 10);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MIN(student_id)+1 FROM STUDENTS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 10);

COMMIT;

-- ИТОГОВАЯ ПРОВЕРКА
SELECT 'Студентов: ' || COUNT(*) FROM STUDENTS
UNION ALL
SELECT 'Оценок: ' || COUNT(*) FROM GRADES;





-- =========================================================
-- 1. ПОЛНАЯ ОЧИСТКА
-- =========================================================
TRUNCATE TABLE GRADES;
TRUNCATE TABLE EXAMS;
TRUNCATE TABLE SUBJECT_TEACHER;
TRUNCATE TABLE STUDENTS;
TRUNCATE TABLE TEACHERS;
TRUNCATE TABLE SUBJECTS;
TRUNCATE TABLE SPECIALTIES;
TRUNCATE TABLE PULPITS;
TRUNCATE TABLE FACULTIES;

-- =========================================================
-- 2. СТРУКТУРА ВУЗА
-- =========================================================
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ИТ', 'Информационные технологии', 'Блинова Е.В.');
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ТОВ', 'Технологии орг. веществ', 'Радченко Ю.С.');

INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty='ИТ'), 'ПИ', 'Смелов В.В.');
INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty='ИТ'), 'ИСиТ', 'Шиман Д.В.');

INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) 
VALUES ('Программная инженерия', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));

INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Базы данных', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ОАиП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ПСКП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Веб-дизайн', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ИСиТ'));

INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Смелов В.В.', 'Зав. кафедрой', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Акулович Л.М.', 'Доцент', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));

-- =========================================================
-- 3. РЕАЛИСТИЧНЫЕ СТУДЕНТЫ (ФИО)
-- =========================================================
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Дмитроченко Кирилл Александрович', 1, 3, 8, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Иванов Алексей Игоревич', 1, 3, 8, 2);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Петрова Мария Сергеевна', 1, 3, 6, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Васильев Артем Дмитриевич', 1, 3, 6, 2);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Сидоров Максим Витальевич', 1, 2, 4, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Козлова Дарья Алексеевна', 1, 2, 4, 2);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Морозов Егор Николаевич', 1, 1, 1, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Павлова Ольга Михайловна', 1, 1, 1, 2);

-- Добиваем до 60 записей для пагинации (технические ФИО, но уже похожие на правду)
BEGIN
  FOR i IN 9..60 LOOP
    INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
    VALUES ('Абитуриент_' || i || ' Ф.И.О.', 1, MOD(i,4)+1, 10+i, 1);
  END LOOP;
END;
/

-- =========================================================
-- 4. ЭКЗАМЕНЫ
-- =========================================================
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES (TO_DATE('2025-06-15', 'YYYY-MM-DD'), '101-1', 1, 1);
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES (TO_DATE('2025-06-20', 'YYYY-MM-DD'), '202-4', 2, 2);
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) VALUES (TO_DATE('2026-01-12', 'YYYY-MM-DD'), '105-1', 1, 3);

-- =========================================================
-- 5. МАССОВЫЕ РАЗНООБРАЗНЫЕ ОЦЕНКИ
-- =========================================================

-- Предмет 1: Базы данных (Хорошая успеваемость)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 
       TRUNC(DBMS_RANDOM.VALUE(6, 11))
FROM STUDENTS;

-- Предмет 2: ОАиП (Средняя успеваемость)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ОАиП'), 
       TRUNC(DBMS_RANDOM.VALUE(4, 10))
FROM STUDENTS;

-- Предмет 3: ПСКП (Сложный предмет, есть хвосты)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), 
       TRUNC(DBMS_RANDOM.VALUE(2, 9))
FROM STUDENTS WHERE student_id <= 40;

-- =========================================================
-- 6. КЕЙСЫ: ПЕРЕСДАЧИ И ДУБЛИКАТЫ
-- =========================================================

-- ПЕРЕСДАЧИ: Иванов А.И. не мог сдать ПСКП 5 раз
BEGIN
  FOR i IN 1..5 LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) 
    VALUES (2, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), 2 + MOD(i,2));
  END LOOP;
END;
/

-- ДУБЛИКАТЫ: Петрова М.С. получила "9" за Веб-дизайн три раза (ошибка ввода)
INSERT INTO GRADES (student_id, subject_id, grade) VALUES (3, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Веб-дизайн'), 9);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES (3, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Веб-дизайн'), 9);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES (3, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Веб-дизайн'), 9);

COMMIT;

-- =========================================================
-- ПРОВЕРКА
-- =========================================================
SELECT 'ИТОГО ОЦЕНОК: ' || COUNT(*) FROM GRADES;












-- =========================================================
-- 1. ОЧИСТКА
-- =========================================================
TRUNCATE TABLE GRADES;
TRUNCATE TABLE EXAMS;
TRUNCATE TABLE SUBJECT_TEACHER;
TRUNCATE TABLE STUDENTS;
TRUNCATE TABLE TEACHERS;
TRUNCATE TABLE SUBJECTS;
TRUNCATE TABLE SPECIALTIES;
TRUNCATE TABLE PULPITS;
TRUNCATE TABLE FACULTIES;

-- =========================================================
-- 2. СТРУКТУРА (ФАКУЛЬТЕТЫ И КАФЕДРЫ)
-- =========================================================
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ИТ', 'Информационные технологии', 'Блинова Е.В.');
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ТОВ', 'Технологии орг. веществ', 'Радченко Ю.С.');

INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty='ИТ'), 'ПИ', 'Смелов В.В.');
INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty='ИТ'), 'ИСиТ', 'Шиман Д.В.');

INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) 
VALUES ('Программная инженерия', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));

-- =========================================================
-- 3. ПРЕДМЕТЫ И ПРЕПОДАВАТЕЛИ
-- =========================================================
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Базы данных', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ОАиП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ПСКП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Веб-дизайн', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ИСиТ'));

INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Смелов В.В.', 'Зав. кафедрой', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Акулович Л.М.', 'Доцент', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));

-- =========================================================
-- 4. СТУДЕНТЫ (ФИО)
-- =========================================================
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Дмитроченко Кирилл Александрович', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 8, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Иванов Алексей Игоревич', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 8, 2);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Петрова Мария Сергеевна', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 6, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Васильев Артем Дмитриевич', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 6, 2);

-- Добиваем массу студентов для пагинации
BEGIN
  FOR i IN 1..50 LOOP
    INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
    VALUES ('Студент_' || i || ' Ф.И.О.', (SELECT MAX(specialty_id) FROM SPECIALTIES), 2, 10, 1);
  END LOOP;
END;
/

-- =========================================================
-- 5. ЭКЗАМЕНЫ
-- =========================================================
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2025-06-15', 'YYYY-MM-DD'), '101-1', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher LIKE 'Смелов%'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'));

-- =========================================================
-- 6. ОЦЕНКИ (БЕЗ ЖЕСТКИХ ID)
-- =========================================================

-- Массовые оценки
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), TRUNC(DBMS_RANDOM.VALUE(4, 11)) FROM STUDENTS;

INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ОАиП'), TRUNC(DBMS_RANDOM.VALUE(2, 10)) FROM STUDENTS;

-- ПЕРЕСДАЧИ (Иванов А.И.)
BEGIN
  FOR i IN 1..5 LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) 
    VALUES (
      (SELECT MAX(student_id) FROM STUDENTS WHERE student LIKE 'Иванов%'), 
      (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), 
      2 + MOD(i, 2)
    );
  END LOOP;
END;
/

-- ДУБЛИКАТЫ (Петрова М.С.)
BEGIN
  FOR i IN 1..3 LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) 
    VALUES (
      (SELECT MAX(student_id) FROM STUDENTS WHERE student LIKE 'Петрова%'), 
      (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Веб-дизайн'), 
      9
    );
  END LOOP;
END;
/

COMMIT;

-- ПРОВЕРКА
SELECT 'ИТОГО ОЦЕНОК: ' || COUNT(*) FROM GRADES;





















-- 1. ОЧИСТКА (Сбрасываем всё, чтобы ID не конфликтовали)
TRUNCATE TABLE GRADES;
TRUNCATE TABLE EXAMS;
TRUNCATE TABLE SUBJECT_TEACHER;
TRUNCATE TABLE STUDENTS;
TRUNCATE TABLE TEACHERS;
TRUNCATE TABLE SUBJECTS;
TRUNCATE TABLE SPECIALTIES;
TRUNCATE TABLE PULPITS;
TRUNCATE TABLE FACULTIES;

-- 2. СТРУКТУРА
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ИТ', 'Информационные технологии', 'Блинова Е.В.');
INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES), 'ПИ', 'Смелов В.В.');
INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) VALUES ('Программная инженерия', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS));

-- 3. ПРЕДМЕТЫ И ПРЕПОДАВАТЕЛИ
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Базы данных', (SELECT MAX(pulpit_id) FROM PULPITS));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ОАиП', (SELECT MAX(pulpit_id) FROM PULPITS));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ПСКП', (SELECT MAX(pulpit_id) FROM PULPITS));
INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Смелов В.В.', 'Зав. кафедрой', (SELECT MAX(pulpit_id) FROM PULPITS));

-- 4. СТУДЕНТЫ (60 РЕАЛЬНЫХ ФИО ЧЕРЕЗ ЦИКЛ)
BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
    VALUES (
      CASE MOD(i, 3) 
        WHEN 0 THEN 'Абрамов '||i||' А.А.' 
        WHEN 1 THEN 'Белов '||i||' Б.Б.' 
        ELSE 'Волков '||i||' В.В.' 
      END, 
      (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 8, 1
    );
  END LOOP;
END;
/

-- 5. ЭКЗАМЕНЫ В РАЗНЫХ КВАРТАЛАХ (КЛЮЧ К ТВОЕЙ АНАЛИТИКЕ)
-- Q1 (Январь)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-01-15', 'YYYY-MM-DD'), '101', (SELECT MAX(teacher_id) FROM TEACHERS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'));

-- Q2 (Май)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-05-20', 'YYYY-MM-DD'), '102', (SELECT MAX(teacher_id) FROM TEACHERS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ОАиП'));

-- Q3 (Сентябрь)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-09-10', 'YYYY-MM-DD'), '103', (SELECT MAX(teacher_id) FROM TEACHERS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'));

-- 6. ОЦЕНКИ (РАЗНЫЕ ДЛЯ КАЖДОГО ПЕРИОДА)
-- Январь: Базы данных (Оценки 4-6)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), TRUNC(DBMS_RANDOM.VALUE(4, 7))
FROM STUDENTS;

-- Май: ОАиП (Оценки 8-10 — тут среднее вырастет!)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ОАиП'), TRUNC(DBMS_RANDOM.VALUE(8, 11))
FROM STUDENTS;

-- Сентябрь: ПСКП (Разброс 2-10)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), TRUNC(DBMS_RANDOM.VALUE(2, 11))
FROM STUDENTS WHERE student_id <= 30;

-- 7. КЕЙСЫ (ПЕРЕСДАЧИ И ДУБЛИКАТЫ)
-- Пересдача (много попыток)
BEGIN
  FOR i IN 1..5 LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) 
    VALUES ((SELECT MIN(student_id) FROM STUDENTS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), 2);
  END LOOP;
END;
/

-- Дубликат (одинаковые оценки для ROW_NUMBER)
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MAX(student_id) FROM STUDENTS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 10);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES ((SELECT MAX(student_id) FROM STUDENTS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 10);

COMMIT;






SELECT 
    s.student,
    sub.subject,
    e.exam_date,
    g.grade,
    -- Среднее по месяцу (Январь покажет 4.0, Март 10.0)
    ROUND(AVG(g.grade) OVER (PARTITION BY TRUNC(e.exam_date, 'MM')), 2) as MONTH_AVG,
    -- Среднее по кварталу (И Январь, и Март покажут 7.0!)
    ROUND(AVG(g.grade) OVER (PARTITION BY TRUNC(e.exam_date, 'Q')), 2) AS QUARTER_AVG,
    -- Среднее по полугодию (Все записи выше покажут 7.25)
    ROUND(AVG(g.grade) OVER (PARTITION BY CASE WHEN EXTRACT(MONTH FROM e.exam_date) <= 6 THEN 1 ELSE 2 END), 2) AS HALFYEAR_AVG
FROM GRADES g
JOIN EXAMS e ON g.subject_id = e.subject_id
JOIN STUDENTS s ON g.student_id = s.student_id
JOIN SUBJECTS sub ON e.subject_id = sub.subject_id
ORDER BY e.exam_date;-- 1. ОЧИСТКА
TRUNCATE TABLE GRADES;
TRUNCATE TABLE EXAMS;
TRUNCATE TABLE SUBJECT_TEACHER;
TRUNCATE TABLE STUDENTS;
TRUNCATE TABLE TEACHERS;
TRUNCATE TABLE SUBJECTS;
TRUNCATE TABLE SPECIALTIES;
TRUNCATE TABLE PULPITS;
TRUNCATE TABLE FACULTIES;

-- 2. БАЗОВАЯ СТРУКТУРА
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ИТ', 'Информационные технологии', 'Блинова Е.В.');
INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES), 'ПИ', 'Смелов В.В.');
INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) VALUES ('Программная инженерия', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS));

-- 3. ПРЕДМЕТЫ
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Базы данных', (SELECT MAX(pulpit_id) FROM PULPITS));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ОАиП', (SELECT MAX(pulpit_id) FROM PULPITS));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ПСКП', (SELECT MAX(pulpit_id) FROM PULPITS));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Алгоритмы', (SELECT MAX(pulpit_id) FROM PULPITS));

INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Смелов В.В.', 'Зав. кафедрой', (SELECT MAX(pulpit_id) FROM PULPITS));

-- 4. СТУДЕНТЫ (Реальные ФИО)
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Дмитроченко Кирилл Александрович', 1, 3, 8, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Иванов Алексей Игоревич', 1, 3, 8, 2);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Петрова Мария Сергеевна', 1, 3, 6, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Васильев Артем Дмитриевич', 1, 3, 6, 2);
BEGIN
  FOR i IN 5..50 LOOP
    INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
    VALUES ('Студент_' || i || ' Ф.И.О.', 1, 2, 10, 1);
  END LOOP;
END;
/

-- 5. ЭКЗАМЕНЫ (РАЗНОСИМ ПО МЕСЯЦАМ ВНУТРИ КВАРТАЛОВ)
-- Квартал 1 (Январь + Март)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-01-15', 'YYYY-MM-DD'), '101', 1, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'));
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-03-20', 'YYYY-MM-DD'), '102', 1, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ОАиП'));

-- Квартал 2 (Апрель + Июнь)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-04-10', 'YYYY-MM-DD'), '103', 1, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'));
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-06-25', 'YYYY-MM-DD'), '104', 1, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Алгоритмы'));

-- 6. ОЦЕНКИ (КОНТРАСТНЫЕ, ЧТОБЫ СРЕДНЕЕ ОТЛИЧАЛОСЬ)

-- Январь (Оценки низкие: 4)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 4 FROM STUDENTS;

-- Март (Оценки высокие: 10). ТЕПЕРЬ СРЕДНЕЕ ЗА Q1 БУДЕТ (4+10)/2 = 7, А НЕ 4 ИЛИ 10!
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ОАиП'), 10 FROM STUDENTS;

-- Апрель (Оценки средние: 6)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), 6 FROM STUDENTS;

-- Июнь (Оценки отличные: 9). СРЕДНЕЕ ЗА Q2 БУДЕТ (6+9)/2 = 7.5
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Алгоритмы'), 9 FROM STUDENTS;

-- 7. ПЕРЕСДАЧИ И ДУБЛИКАТЫ (Для твоих спец-запросов)
INSERT INTO GRADES (student_id, subject_id, grade) VALUES (1, 3, 2);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES (1, 3, 3);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES (2, 1, 10);
INSERT INTO GRADES (student_id, subject_id, grade) VALUES (2, 1, 10);

COMMIT;









-- 1. ПОЛНАЯ ОЧИСТКА (В правильном порядке, чтобы не ругались FK)
TRUNCATE TABLE GRADES;
TRUNCATE TABLE EXAMS;
TRUNCATE TABLE SUBJECT_TEACHER;
TRUNCATE TABLE STUDENTS;
TRUNCATE TABLE TEACHERS;
TRUNCATE TABLE SUBJECTS;
TRUNCATE TABLE SPECIALTIES;
TRUNCATE TABLE PULPITS;
TRUNCATE TABLE FACULTIES;

-- 2. СТРУКТУРА (ФАКУЛЬТЕТЫ И КАФЕДРЫ)
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ИТ', 'Информационные технологии', 'Блинова Е.В.');
INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES), 'ПИ', 'Смелов В.В.');
INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) VALUES ('Программная инженерия', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS));

-- 3. ПРЕДМЕТЫ И ПРЕПОДАВАТЕЛИ
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Базы данных', (SELECT MAX(pulpit_id) FROM PULPITS));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ОАиП', (SELECT MAX(pulpit_id) FROM PULPITS));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ПСКП', (SELECT MAX(pulpit_id) FROM PULPITS));
INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Смелов В.В.', 'Зав. кафедрой', (SELECT MAX(pulpit_id) FROM PULPITS));

-- 4. СТУДЕНТЫ (Реальные ФИО)
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Дмитроченко Кирилл Александрович', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 8, 1);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Иванов Алексей Игоревич', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 8, 2);
INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) VALUES ('Петрова Мария Сергеевна', (SELECT MAX(specialty_id) FROM SPECIALTIES), 3, 6, 1);

BEGIN
  FOR i IN 1..50 LOOP
    INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
    VALUES ('Студент_' || i || ' Ф.И.О.', (SELECT MAX(specialty_id) FROM SPECIALTIES), 2, 10, 1);
  END LOOP;
END;
/

-- 5. ЭКЗАМЕНЫ (РАЗНЫЕ МЕСЯЦЫ ДЛЯ АНАЛИТИКИ)
-- Январь 2026 (Квартал 1)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-01-15', 'YYYY-MM-DD'), '101', (SELECT MAX(teacher_id) FROM TEACHERS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'));

-- Март 2026 (Квартал 1)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-03-20', 'YYYY-MM-DD'), '102', (SELECT MAX(teacher_id) FROM TEACHERS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ОАиП'));

-- Май 2026 (Квартал 2)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-05-10', 'YYYY-MM-DD'), '103', (SELECT MAX(teacher_id) FROM TEACHERS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'));

-- 6. ОЦЕНКИ (ДИНАМИЧЕСКАЯ ВСТАВКА БЕЗ ID)

-- Оценки за Январь (Базы данных, средний балл ~4)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 4
FROM STUDENTS;

-- Оценки за Март (ОАиП, средний балл ~10)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ОАиП'), 10
FROM STUDENTS;

-- Оценки за Май (ПСКП, средний балл ~7)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), 7
FROM STUDENTS WHERE MOD(student_id, 2) = 0;

-- 7. ПЕРЕСДАЧИ И ДУБЛИКАТЫ (ДЛЯ ТВОИХ ЗАПРОСОВ)
-- Иванов А.И. пересдает ПСКП (5 попыток)
BEGIN
  FOR i IN 1..5 LOOP
    INSERT INTO GRADES (student_id, subject_id, grade) 
    VALUES (
      (SELECT MAX(student_id) FROM STUDENTS WHERE student LIKE 'Иванов%'), 
      (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), 
      2
    );
  END LOOP;
END;
/

-- Дубликаты (Петрова М.С., 2 одинаковые оценки)
INSERT INTO GRADES (student_id, subject_id, grade) 
VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student LIKE 'Петрова%'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 5);
INSERT INTO GRADES (student_id, subject_id, grade) 
VALUES ((SELECT MAX(student_id) FROM STUDENTS WHERE student LIKE 'Петрова%'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 5);

COMMIT;

-- ИТОГ
SELECT 'СТУДЕНТОВ: ' || COUNT(*) FROM STUDENTS UNION ALL SELECT 'ОЦЕНОК: ' || COUNT(*) FROM GRADES;
























-- 1. ОЧИСТКА (В строгом порядке из-за связей)
TRUNCATE TABLE GRADES;
TRUNCATE TABLE EXAMS;
TRUNCATE TABLE SUBJECT_TEACHER;
TRUNCATE TABLE STUDENTS;
TRUNCATE TABLE TEACHERS;
TRUNCATE TABLE SUBJECTS;
TRUNCATE TABLE SPECIALTIES;
TRUNCATE TABLE PULPITS;
TRUNCATE TABLE FACULTIES;

-- 2. ФАКУЛЬТЕТЫ И КАФЕДРЫ
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ИТ', 'Информационные технологии', 'Блинова Е.В.');
INSERT INTO FACULTIES (faculty, faculty_name, dean) VALUES ('ТОВ', 'Технологии органических веществ', 'Радченко Ю.С.');

INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty='ИТ'), 'ПИ', 'Смелов В.В.');
INSERT INTO PULPITS (faculty_id, pulpit, head_of_pulpit) VALUES ((SELECT MAX(faculty_id) FROM FACULTIES WHERE faculty='ИТ'), 'ИСиТ', 'Шиман Д.В.');

-- 3. СПЕЦИАЛЬНОСТИ И ПРЕДМЕТЫ
INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) 
VALUES ('Программная инженерия', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SPECIALTIES (specialty, years_of_study, degree, pulpit_id) 
VALUES ('Информационные системы', 4, 'Бакалавр', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ИСиТ'));

INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Базы данных', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Алгоритмы', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('ПСКП', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO SUBJECTS (subject, pulpit_id) VALUES ('Веб-технологии', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ИСиТ'));

-- 4. ПРЕПОДАВАТЕЛИ
INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Смелов В.В.', 'Зав. кафедрой', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Григ Г.К.', 'Доцент', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ПИ'));
INSERT INTO TEACHERS (teacher, position, pulpit_id) VALUES ('Наркевич А.Л.', 'Старший преп.', (SELECT MAX(pulpit_id) FROM PULPITS WHERE pulpit='ИСиТ'));

-- 5. РЕАЛЬНЫЕ СТУДЕНТЫ (60 человек с именами)
DECLARE
    TYPE name_list IS TABLE OF VARCHAR2(100);
    first_names name_list := name_list('Александр', 'Дмитрий', 'Кирилл', 'Максим', 'Артем', 'Илья', 'Никита', 'Егор');
    last_names  name_list := name_list('Иванов', 'Петров', 'Сидоров', 'Васильев', 'Кузнецов', 'Смирнов', 'Новиков', 'Морозов');
    spec_id INT;
BEGIN
    SELECT MAX(specialty_id) INTO spec_id FROM SPECIALTIES WHERE specialty='Программная инженерия';
    FOR i IN 1..60 LOOP
        INSERT INTO STUDENTS (student, specialty_id, course, grup, subgroup) 
        VALUES (
            last_names(MOD(i, 8) + 1) || ' ' || first_names(MOD(i+1, 8) + 1) || ' ' || i,
            spec_id, 3, 8, 1
        );
    END LOOP;
END;
/

-- 6. ЭКЗАМЕНЫ (КЛЮЧ К РАЗНОЙ АНАЛИТИКЕ: РАЗНЫЕ МЕСЯЦЫ В ОДНОМ КВАРТАЛЕ)
-- Q1: Январь (Среднее будет низким)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-01-15', 'YYYY-MM-DD'), '101', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher LIKE 'Смелов%'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'));

-- Q1: Март (Среднее будет высоким)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-03-20', 'YYYY-MM-DD'), '102', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher LIKE 'Григ%'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Алгоритмы'));

-- Q2: Май (Пересдачи и среднее)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (TO_DATE('2026-05-10', 'YYYY-MM-DD'), '103', (SELECT MAX(teacher_id) FROM TEACHERS WHERE teacher LIKE 'Наркевич%'), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'));

-- 7. ОЦЕНКИ (РАЗНЫЕ ДЛЯ РАЗНЫХ ПЕРИОДОВ)

-- Январь (Все получили 4-5)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), TRUNC(DBMS_RANDOM.VALUE(4, 6)) FROM STUDENTS;

-- Март (Все получили 9-10). ТЕПЕРЬ СРЕДНЕЕ ПО МЕСЯЦУ (10) И КВАРТАЛУ (7.5) БУДУТ РАЗНЫМИ!
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Алгоритмы'), TRUNC(DBMS_RANDOM.VALUE(9, 11)) FROM STUDENTS;

-- Май (Средние оценки 6-8)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='ПСКП'), TRUNC(DBMS_RANDOM.VALUE(6, 9)) FROM STUDENTS;

-- 8. СПЕЦ-КЕЙСЫ (ПЕРЕСДАЧИ И ДУБЛИКАТЫ)
-- Кузнецов Максим (студент 5) сдает Веб-технологии 5 раз (пересдачи)
BEGIN
    FOR i IN 1..5 LOOP
        INSERT INTO GRADES (student_id, subject_id, grade) 
        VALUES (
            (SELECT MIN(student_id)+4 FROM STUDENTS), 
            (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Веб-технологии'), 
            2 + MOD(i, 2)
        );
    END LOOP;
END;
/

-- Дубликат (оценка 10 дважды для одного студента)
INSERT INTO GRADES (student_id, subject_id, grade) 
VALUES ((SELECT MIN(student_id) FROM STUDENTS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 10);
INSERT INTO GRADES (student_id, subject_id, grade) 
VALUES ((SELECT MIN(student_id) FROM STUDENTS), (SELECT MAX(subject_id) FROM SUBJECTS WHERE subject='Базы данных'), 10);

COMMIT;

-- ИТОГОВАЯ ПРОВЕРКА
SELECT 'СТУДЕНТОВ: ' || COUNT(*) FROM STUDENTS;
SELECT 'ОЦЕНОК: ' || COUNT(*) FROM GRADES;



















-- =========================================================
-- 1. ДОБАВЛЯЕМ ЭКЗАМЕНЫ НА 2-Е ПОЛУГОДИЕ (Q3 И Q4)
-- =========================================================

-- Экзамен в Сентябре (Q3, 2-е полугодие)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (
    TO_DATE('2026-09-15', 'YYYY-MM-DD'), 
    '305', 
    (SELECT MIN(teacher_id) FROM TEACHERS), 
    (SELECT MIN(subject_id) FROM SUBJECTS)
);

-- Экзамен в Декабре (Q4, 2-е полугодие)
INSERT INTO EXAMS (exam_date, exam_auditorium, teacher_id, subject_id) 
VALUES (
    TO_DATE('2026-12-20', 'YYYY-MM-DD'), 
    '410', 
    (SELECT MAX(teacher_id) FROM TEACHERS), 
    (SELECT MAX(subject_id) FROM SUBJECTS)
);

-- =========================================================
-- 2. ДОБАВЛЯЕМ ОЦЕНКИ С РАЗБРОСОМ (ДЛЯ РАЗНОЙ АНАЛИТИКИ)
-- =========================================================

-- Сентябрь: ставим всем студентам плохие оценки (2-5), чтобы провалить среднее Q3
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT 
    student_id, 
    (SELECT MIN(subject_id) FROM SUBJECTS), 
    TRUNC(DBMS_RANDOM.VALUE(2, 6)) 
FROM STUDENTS;

-- Декабрь: ставим всем отличные оценки (9-10), чтобы завысить среднее Q4
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT 
    student_id, 
    (SELECT MAX(subject_id) FROM SUBJECTS), 
    TRUNC(DBMS_RANDOM.VALUE(9, 11)) 
FROM STUDENTS;

-- =========================================================
-- 3. СОЗДАЕМ "АНОМАЛИИ" ДЛЯ ТВОИХ ЗАПРОСОВ (ПОВЕРХ СУЩЕСТВУЮЩИХ)
-- =========================================================

-- Добавляем еще 10 явных дубликатов (одинаковый студент, предмет и оценка)
INSERT INTO GRADES (student_id, subject_id, grade)
SELECT student_id, subject_id, grade 
FROM (SELECT * FROM GRADES ORDER BY grade_id DESC)
WHERE ROWNUM <= 10;

-- Добавляем "мучительные пересдачи" для топ-3 студентов по списку
BEGIN
  FOR r IN (SELECT student_id FROM STUDENTS WHERE ROWNUM <= 3) LOOP
    FOR i IN 1..4 LOOP
      INSERT INTO GRADES (student_id, subject_id, grade) 
      VALUES (r.student_id, (SELECT MAX(subject_id) FROM SUBJECTS), 2);
    END LOOP;
  END LOOP;
END;
/

COMMIT;

-- =========================================================
-- ПРОВЕРКА РЕЗУЛЬТАТА
-- =========================================================
SELECT 
    to_char(e.exam_date, 'YYYY-"H"Q') as HalfYear,
    to_char(e.exam_date, 'Q') as Quarter,
    count(g.grade_id) as Grades_Count,
    round(avg(g.grade), 2) as Average_Grade
FROM GRADES g
JOIN SUBJECTS s ON g.subject_id = s.subject_id
JOIN EXAMS e ON s.subject_id = e.subject_id
GROUP BY to_char(e.exam_date, 'YYYY-"H"Q'), to_char(e.exam_date, 'Q')
ORDER BY 1, 2;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------




SELECT 
    AVG(AVG(g.grade)) OVER (
        PARTITION BY s.student_id, EXTRACT(YEAR FROM e.exam_date), TO_CHAR(e.exam_date, 'Q')
    ) AS KVARTAL,
    
    AVG(AVG(g.grade)) OVER (
        PARTITION BY s.student_id, EXTRACT(YEAR FROM e.exam_date), 
        (CASE WHEN EXTRACT(MONTH FROM e.exam_date) <= 6 THEN 1 ELSE 2 END)
    ) AS POLGODA,
    
    AVG(AVG(g.grade)) OVER (
        PARTITION BY s.student_id, EXTRACT(YEAR FROM e.exam_date)
    ) AS YEAR_AVG,
    EXTRACT(YEAR FROM e.exam_date) AS Exam_Year,
    EXTRACT(MONTH FROM e.exam_date) AS Exam_Month,
    AVG(g.grade) AS MONTH_AVG,
    s.student

FROM GRADES g
JOIN STUDENTS s ON g.student_id = s.student_id
JOIN EXAMS e ON g.subject_id = e.subject_id
GROUP BY 
    s.student_id, 
    s.student, 
    EXTRACT(YEAR FROM e.exam_date), 
    EXTRACT(MONTH FROM e.exam_date), 
    TO_CHAR(e.exam_date, 'Q')
ORDER BY 
    s.student, 
    Exam_Year, 
    Exam_Month;




WITH FilteredExams AS (
    SELECT subject_id, exam_date 
    FROM EXAMS 
    WHERE exam_date BETWEEN TO_DATE('2025-02-19 10:00:00', 'YYYY-MM-DD HH24:MI:SS') 
                        AND TO_DATE('2026-09-25 10:00:00', 'YYYY-MM-DD HH24:MI:SS')
)
SELECT 
    s.student,
    f.faculty,
    AVG(g.grade) AS Student_Avg,
    
    ROUND(
        (AVG(g.grade) / 
         NULLIF(AVG(AVG(g.grade)) OVER (PARTITION BY f.faculty), 0)) * 100, 
    2) AS FACULTY,

    ROUND(
        (AVG(g.grade) / 
         NULLIF(MAX(AVG(g.grade)) OVER (), 0)) * 100, 
    2) AS MAX

FROM FilteredExams fe
JOIN GRADES g       ON g.subject_id = fe.subject_id
JOIN STUDENTS s     ON g.student_id = s.student_id
JOIN SPECIALTIES sp ON s.specialty_id = sp.specialty_id
JOIN PULPITS p      ON sp.pulpit_id = p.pulpit_id
JOIN FACULTIES f    ON p.faculty_id = f.faculty_id

GROUP BY s.student_id, s.student, f.faculty
ORDER BY f.faculty, Student_Avg DESC;




SELECT 
    grades.grade_id,
    students.student,
    grades.grade,
    exams.exam_date
FROM GRADES 
JOIN STUDENTS ON grades.student_id = students.student_id
LEFT JOIN EXAMS ON grades.subject_id = exams.subject_id
ORDER BY exams.exam_date, grades.grade_id
OFFSET 50 ROWS FETCH NEXT 20 ROWS ONLY; 





    WITH Dups AS (
        SELECT 
            g.*, 
            ROW_NUMBER() OVER (PARTITION BY student_id, subject_id, grade ORDER BY grade_id) AS rn
        FROM GRADES g
    )
    SELECT * FROM Dups WHERE rn > 2;







    WITH Ranked AS (
    SELECT 
        students.student_id,
        students.student,
        grades.grade,
        exams.exam_date,
        ROW_NUMBER() OVER (PARTITION BY students.student_id ORDER BY exams.exam_date DESC) AS rn
    FROM GRADES 
    JOIN STUDENTS ON grades.student_id = students.student_id
    JOIN EXAMS ON grades.subject_id = exams.subject_id
)
SELECT 
    student_id,
    student,
    AVG(grade) AS avg_last_3
FROM Ranked
WHERE rn <= 3
GROUP BY student_id, student
ORDER BY student_id;









WITH Attempts AS (
    SELECT 
        grades.subject_id,
        subjects.subject,
        grades.student_id,
        students.student,
        COUNT(*) AS attempt_count
    FROM GRADES 
    JOIN STUDENTS ON grades.student_id = students.student_id
    JOIN SUBJECTS ON grades.subject_id = subjects.subject_id
    GROUP BY grades.subject_id, subjects.subject, grades.student_id, students.student
),
Ranked AS (
    SELECT 
        a.*,
        ROW_NUMBER() OVER (PARTITION BY subject_id ORDER BY attempt_count DESC) AS rn
    FROM Attempts a
)
SELECT 
    subject_id,
    subject,
    student_id,
    student,
    attempt_count
FROM Ranked 
WHERE rn = 1
ORDER BY subject;