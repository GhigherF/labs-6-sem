-- =============================================================
-- Лабораторная работа №10
-- Большие объекты в Oracle (LOB)
-- Вариант: Университет — Студенты и группы
-- =============================================================


-- =============================================================
-- РАЗДЕЛ 1. ТАБЛИЧНОЕ ПРОСТРАНСТВО ДЛЯ LOB
-- =============================================================

-- Создаём отдельное табличное пространство для хранения LOB-данных
CREATE TABLESPACE LOB_TBS
    DATAFILE 'lob_tbs01.dbf' SIZE 50M
    AUTOEXTEND ON NEXT 10M MAXSIZE 200M
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;


-- =============================================================
-- РАЗДЕЛ 2. ДИРЕКТОРИЯ ДЛЯ ВНЕШНИХ ФАЙЛОВ (BFILE)
-- Папка на сервере Oracle должна существовать физически!
-- Создайте вручную: C:\LOB_DOCS  (или /oracle/lob_docs на Linux)
-- =============================================================

-- Создаём объект DIRECTORY — псевдоним физической папки на сервере
CREATE OR REPLACE DIRECTORY LOB_DIR AS 'C:\LOB_DOCS';

-- Проверка: список всех директорий
SELECT directory_name, directory_path
FROM all_directories
WHERE directory_name = 'LOB_DIR';


-- =============================================================
-- РАЗДЕЛ 3. ПОЛЬЗОВАТЕЛЬ LOB_USER С ПРИВИЛЕГИЯМИ
-- =============================================================

-- Создаём пользователя (выполнять от SYS/SYSTEM)
CREATE USER lob_user IDENTIFIED BY lob_pass123
    DEFAULT TABLESPACE LOB_TBS
    TEMPORARY TABLESPACE TEMP;

-- Базовые привилегии
GRANT CREATE SESSION     TO lob_user;
GRANT CREATE TABLE       TO lob_user;
GRANT CREATE PROCEDURE   TO lob_user;
GRANT CREATE DIRECTORY   TO lob_user;

-- Привилегии на DML с LOB
GRANT INSERT, UPDATE, DELETE, SELECT ON STUDENTS TO lob_user;

-- Привилегия на чтение директории
GRANT READ, WRITE ON DIRECTORY LOB_DIR TO lob_user;

-- Привилегия на работу с DBMS_LOB
GRANT EXECUTE ON DBMS_LOB TO lob_user;


-- =============================================================
-- РАЗДЕЛ 4. КВОТА НА ТАБЛИЧНОЕ ПРОСТРАНСТВО
-- =============================================================

ALTER USER lob_user QUOTA 100M ON LOB_TBS;

-- Проверка квоты
SELECT username, tablespace_name, max_bytes, bytes
FROM dba_ts_quotas
WHERE username = 'LOB_USER';


-- =============================================================
-- РАЗДЕЛ 5. ДОБАВЛЕНИЕ LOB-СТОЛБЦОВ В ТАБЛИЦУ STUDENTS
-- =============================================================

-- Добавляем BLOB-столбец для фотографии
ALTER TABLE STUDENTS ADD (
    FOTO  BLOB
);

-- Добавляем BFILE-столбец для внешнего документа (PDF)
ALTER TABLE STUDENTS ADD (
    DOC   BFILE
);

-- LOB-сегменты размещаем в нашем табличном пространстве
-- (можно задать при создании таблицы; для ALTER — пересоздаём сегмент)
ALTER TABLE STUDENTS
    MOVE LOB (FOTO) STORE AS SECUREFILE foto_lob (
        TABLESPACE LOB_TBS
        ENABLE STORAGE IN ROW
        COMPRESS HIGH
        DEDUPLICATE
    );

-- Проверяем структуру таблицы
SELECT column_name, data_type, nullable
FROM user_tab_columns
WHERE table_name = 'STUDENTS'
ORDER BY column_id;


-- =============================================================
-- РАЗДЕЛ 6. ВСТАВКА ФОТОГРАФИЙ (BLOB) И ДОКУМЕНТОВ (BFILE)
-- =============================================================

-- ---- 6а. Вставка BFILE (ссылка на внешний PDF-файл) ----
--
-- Файлы должны находиться в C:\LOB_DOCS\ на сервере Oracle:
--   student1.pdf, student2.pdf и т.д.
--
UPDATE STUDENTS
SET DOC = BFILENAME('LOB_DIR', 'student1.pdf')
WHERE student_id = 1;

UPDATE STUDENTS
SET DOC = BFILENAME('LOB_DIR', 'student2.pdf')
WHERE student_id = 2;

UPDATE STUDENTS
SET DOC = BFILENAME('LOB_DIR', 'student3.pdf')
WHERE student_id = 3;

COMMIT;


-- ---- 6б. Загрузка BLOB из файла через DBMS_LOB ----
--
-- Файл-источник: C:\LOB_DOCS\photo1.jpg
-- Загружаем в BLOB через временный BFILE-локатор

DECLARE
    v_blob      BLOB;
    v_bfile     BFILE := BFILENAME('LOB_DIR', 'photo1.jpg');
    v_dest_off  INTEGER := 1;
    v_src_off   INTEGER := 1;
    v_lang      NUMBER  := DBMS_LOB.DEFAULT_LANG_CTX;
    v_warn      INTEGER;
BEGIN
    -- Инициализируем BLOB пустым локатором
    UPDATE STUDENTS
    SET FOTO = EMPTY_BLOB()
    WHERE student_id = 1
    RETURNING FOTO INTO v_blob;

    -- Открываем источник (BFILE)
    DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY);

    -- Открываем приёмник (BLOB) для записи
    DBMS_LOB.OPEN(v_blob, DBMS_LOB.LOB_READWRITE);

    -- Загружаем содержимое файла в BLOB
    DBMS_LOB.LOADBLOBFROMFILE(
        dest_lob    => v_blob,
        src_bfile   => v_bfile,
        amount      => DBMS_LOB.LOBMAXSIZE,
        dest_offset => v_dest_off,
        src_offset  => v_src_off
    );

    DBMS_LOB.CLOSE(v_blob);
    DBMS_LOB.CLOSE(v_bfile);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE(
        'BLOB загружен. Размер: ' || DBMS_LOB.GETLENGTH(v_blob) || ' байт.'
    );
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
END;
/


-- ---- 6в. Загрузка BLOB для второго студента ----

DECLARE
    v_blob    BLOB;
    v_bfile   BFILE := BFILENAME('LOB_DIR', 'photo2.jpg');
    v_doff    INTEGER := 1;
    v_soff    INTEGER := 1;
BEGIN
    UPDATE STUDENTS
    SET FOTO = EMPTY_BLOB()
    WHERE student_id = 2
    RETURNING FOTO INTO v_blob;

    DBMS_LOB.OPEN(v_bfile, DBMS_LOB.LOB_READONLY);
    DBMS_LOB.OPEN(v_blob,  DBMS_LOB.LOB_READWRITE);

    DBMS_LOB.LOADBLOBFROMFILE(
        dest_lob    => v_blob,
        src_bfile   => v_bfile,
        amount      => DBMS_LOB.LOBMAXSIZE,
        dest_offset => v_doff,
        src_offset  => v_soff
    );

    DBMS_LOB.CLOSE(v_blob);
    DBMS_LOB.CLOSE(v_bfile);
    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Фото студента 2 загружено. Размер: ' || DBMS_LOB.GETLENGTH(v_blob) || ' байт.'
    );
END;
/


-- =============================================================
-- РАЗДЕЛ 7. ПРОВЕРКА И ДЕМОНСТРАЦИЯ DBMS_LOB
-- =============================================================

-- 7а. Размер загруженных BLOB
SELECT student_id,
       student,
       DBMS_LOB.GETLENGTH(FOTO)                          AS foto_bytes,
       CASE WHEN DOC IS NOT NULL THEN 'Есть' ELSE 'Нет' END AS doc_exists
FROM STUDENTS
WHERE FOTO IS NOT NULL OR DOC IS NOT NULL
ORDER BY student_id;


-- 7б. Чтение первых 20 байт BLOB (демонстрация DBMS_LOB.READ)
DECLARE
    v_blob   BLOB;
    v_buf    RAW(20);
    v_amount INTEGER := 20;
    v_offset INTEGER := 1;
BEGIN
    SELECT FOTO INTO v_blob
    FROM STUDENTS
    WHERE student_id = 1;

    IF DBMS_LOB.GETLENGTH(v_blob) > 0 THEN
        DBMS_LOB.READ(v_blob, v_amount, v_offset, v_buf);
        DBMS_OUTPUT.PUT_LINE(
            'Первые ' || v_amount || ' байт BLOB студента 1: ' ||
            RAWTOHEX(v_buf)
        );
    ELSE
        DBMS_OUTPUT.PUT_LINE('BLOB пуст.');
    END IF;
END;
/


-- 7в. Проверка существования BFILE на диске
DECLARE
    v_bfile  BFILE;
    v_exists INTEGER;
BEGIN
    SELECT DOC INTO v_bfile
    FROM STUDENTS
    WHERE student_id = 1;

    v_exists := DBMS_LOB.FILEEXISTS(v_bfile);

    IF v_exists = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Файл PDF студента 1 существует на диске.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Файл PDF студента 1 НЕ найден на диске.');
    END IF;
END;
/


-- 7г. Копирование BLOB от одного студента к другому (DBMS_LOB.COPY)
DECLARE
    v_src  BLOB;
    v_dst  BLOB;
    v_len  INTEGER;
BEGIN
    SELECT FOTO INTO v_src FROM STUDENTS WHERE student_id = 1;
    v_len := DBMS_LOB.GETLENGTH(v_src);

    UPDATE STUDENTS
    SET FOTO = EMPTY_BLOB()
    WHERE student_id = 3
    RETURNING FOTO INTO v_dst;

    DBMS_LOB.OPEN(v_dst, DBMS_LOB.LOB_READWRITE);
    DBMS_LOB.COPY(v_dst, v_src, v_len, 1, 1);
    DBMS_LOB.CLOSE(v_dst);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE(
        'BLOB скопирован от студента 1 к студенту 3. Байт: ' || v_len
    );
END;
/


-- 7д. Сравнение двух BLOB (DBMS_LOB.COMPARE)
DECLARE
    v_b1  BLOB;
    v_b2  BLOB;
    v_cmp INTEGER;
BEGIN
    SELECT FOTO INTO v_b1 FROM STUDENTS WHERE student_id = 1;
    SELECT FOTO INTO v_b2 FROM STUDENTS WHERE student_id = 3;

    v_cmp := DBMS_LOB.COMPARE(v_b1, v_b2);

    IF v_cmp = 0 THEN
        DBMS_OUTPUT.PUT_LINE('BLOB студентов 1 и 3 идентичны.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('BLOB студентов 1 и 3 различаются.');
    END IF;
END;
/
