----------------------1-------------------------------
CREATE OR ALTER PROCEDURE promoteStudent(@student nvarchar(150)) as
begin
begin try 
if not exists (SELECT * FROM students WHERE student = @student)
BEGIN RAISERROR('Неверное ФИО студента', 16, 1); END

begin tran;
update students set course=course+1
where student = @student
and course<(select years_of_study from specialties inner join students
on STUDENTS.specialty_id = specialties.specialty_id where students.student = @student)

if @@ROWCOUNT = 0 begin raiserror('Последний курс',16,1) end; 
commit;
end try
begin catch  rollback; throw; end catch;
end;


select * from students where student = 'Дмитроченко Кирилл'
execute promoteStudent 'Дмитроченко Кирилл'

----------------------2-------------------------------
go
CREATE or alter PROCEDURE addSubject(@subject nvarchar(150),@teacher nvarchar(150),@pulpit nvarchar(150)) as
begin
begin try
begin tran;
if not exists (SELECT * FROM teachers WHERE teacher= @teacher)
BEGIN RAISERROR('Преподаватель не существует', 16, 1); RETURN; END

DECLARE @teacher_id int;
select @teacher_id = teacher_id from  teachers where teacher = @teacher; 

if exists (SELECT * FROM subjects WHERE subject=@subject)
BEGIN RAISERROR('Предмет уже существует', 16, 1); RETURN; END

DECLARE @pulpit_id int;
select @pulpit_id=pulpit_id from pulpits where pulpit = @pulpit; 

INSERT INTO SUBJECTS VALUES(@subject,@pulpit_id);

DECLARE @subject_id int;
select @subject_id=subject_id from subjects where subject = @subject; 


INSERT INTO SUBJECT_TEACHER values(@teacher_id,@subject_id);
commit;
end try
begin catch
rollback;
throw;
end catch;

end;


go;
select * from TEACHERS;
select * from subjects;
select * from pulpits;
select * from subject_teacher;
select count(*) from SUBJECT_TEACHER
delete subjects where subject = 'ООП'

execute addSubject N'ООП',N'Смелов В.В.',N'ИСиТ'

----------------------3-------------------------------
go
CREATE OR ALTER PROCEDURE fireTeacher(@teacher nvarchar(150)) AS
BEGIN
begin try
begin tran;
    IF NOT EXISTS (SELECT * FROM teachers WHERE teacher = @teacher)
    BEGIN RAISERROR('Преподаватель не существует', 16, 1); RETURN;END


    DECLARE @teacher_id INT;
    SELECT @teacher_id = teacher_id FROM teachers 
    WHERE teacher = @teacher;

        UPDATE exams
        SET teacher_id = NULL
        WHERE teacher_id = @teacher_id;

        DECLARE @subjects TABLE(subject_id INT);

        INSERT INTO @subjects
        SELECT SUBJECT_TEACHER.subject_id
        FROM subject_teacher 
        WHERE subject_teacher.teacher_id = @teacher_id
        AND NOT EXISTS (SELECT * FROM subject_teacher 
                        WHERE subject_teacher.subject_id = subject_teacher.subject_id
                         AND subject_teacher.teacher_id <> @teacher_id);




        DELETE FROM subject_teacher
        WHERE teacher_id = @teacher_id;
        DELETE FROM subjects
        WHERE subject_id IN (SELECT subject_id FROM @subjects);
        DELETE FROM teachers
        WHERE teacher_id = @teacher_id;
commit;
end try
begin catch
rollback;
throw;
end catch;
END;

select * from exams
select * from teachers;
select * from subject_teacher;

execute fireTeacher 'Дмитриев Д.Д.'


----------------------4-------------------------------
go
CREATE OR ALTER PROCEDURE addExam (@teacher NVARCHAR(150),@subject NVARCHAR(150),@date DATETIME,@auditorium NVARCHAR(15))
AS
BEGIN
begin try
begin tran;
    DECLARE @teacher_id INT, @subject_id INT;

    SELECT @teacher_id = teacher_id FROM teachers WHERE teacher = @teacher;
    IF @teacher_id IS NULL
    BEGIN RAISERROR('Преподаватель не найден',16,1); RETURN; END

    SELECT @subject_id = subject_id FROM subjects WHERE subject = @subject;
    IF @subject_id IS NULL
    BEGIN RAISERROR('Предмет не найден',16,1); RETURN; END

    if NOT EXISTS (SELECT * FROM subject_teacher WHERE teacher_id = @teacher_id AND subject_id = @subject_id)
    BEGIN RAISERROR('Преподаватель не ведёт этот предмет',16,1); RETURN; END

    IF EXISTS (SELECT * FROM exams WHERE teacher_id = @teacher_id AND DAY(EXam_date) = DAY(@date))
    BEGIN RAISERROR('У преподавателя уже есть экзамен в этот день',16,1); RETURN; END

    INSERT INTO exams(exam_date, exam_auditorium, teacher_id, subject_id)
    VALUES(@date, @auditorium, @teacher_id, @subject_id);
commit;
end try
begin catch
rollback;
throw;
end catch;
END;

select * from teachers;
select * from exams;
execute addExam 'Смелов В.В.','Очередной предмет','2026-01-28T10:00:00','228-4';
execute addExam 'Смелов В.В.2','Очередной предмет','2026-01-28T10:00:00','228-4';
execute addExam 'Смелов В.В.','ПСКП','2026-01-28T10:00:00','228-4';

execute addExam 'Смелов В.В.','ПСКП','2026-01-29T10:00:00','228-4';


----------------------5-------------------------------
go
CREATE OR ALTER PROCEDURE replaceExamTeacher (@exam_id INT,@new_teacher NVARCHAR(150)) AS
BEGIN
begin try
begin tran;
    DECLARE @new_teacher_id INT;
    DECLARE @subject_id INT;
    DECLARE @exam_date DATETIME;

    IF NOT EXISTS (SELECT * FROM exams WHERE exam_id = @exam_id) 
    BEGIN RAISERROR('Экзамен не найден',16,1); RETURN; eND

    SELECT @subject_id = subject_id, @exam_date = exam_date FROM exams
    WHERE exam_id = @exam_id;

    SELECT @new_teacher_id = teacher_id FROM teachers 
    WHERE teacher = @new_teacher;

    IF @new_teacher_id IS NULL
    BEGIN RAISERROR('Преподаватель не найден',16,1);RETURN; END


    IF EXISTS (SELECT * FROM exams WHERE teacher_id = @new_teacher_id AND exam_date = @exam_date)
    BEGIN RAISERROR('У преподавателя уже есть экзамен в это время',16,1); RETURN; END

    UPDATE exams
    SET teacher_id = @new_teacher_id
    WHERE exam_id = @exam_id;
commit;
end try

begin catch
rollback;
throw
end catch;
END;



-----------------VIEW----------------
go
CREATE VIEW studentPerformanceView
AS
SELECT students.student,specialties.specialty,subjects.subject,
teachers.teacher,grades.grade FROM grades 
INNER JOIN students  ON grades.student_id = students.student_id
INNER JOIN specialties  ON students.specialty_id = specialties.specialty_id
INNER JOIN subjects  ON grades.subject_id = subjects.subject_id
LEFT JOIN subject_teacher  ON subjects.subject_id = subject_teacher.subject_id
LEFT JOIN teachers  ON SUBJECT_TEACHER.teacher_id = teachers.teacher_id;

go
select * from studentPerformanceView;

-----------------INDEX----------------
CREATE NONCLUSTERED INDEX idx_grades_student_subject
ON grades(student_id, subject_id)
INCLUDE (grade);

select students.student,subjects.subject,grade from grades 
inner join students on grades.student_id = grades.student_id
inner join subjects on subjects.subject_id = grades.subject_id 
where students.student_id = 2 and grade>5


----------------TRIGGER----------------
go
CREATE OR ALTER TRIGGER gradeVerification
ON grades
AFTER INSERT, UPDATE AS
BEGIN IF EXISTS (SELECT 1 FROM inserted WHERE grade < 1 OR grade > 10)
         BEGIN RAISERROR('Оценка должна быть от 1 до 10',16,1); ROLLBACK; END
END;

select * from grades;
insert into grades values(2,7,11)

-------------SEQUENCE--------------------
CREATE SEQUENCE SMELOV_GRADE
AS INT
START WITH 1
INCREMENT BY 1
MAXVALUE 5
MINVALUE 1
CYCLE
NO CACHE; 

drop sequence smelov_grade

SELECT NEXT VALUE FOR SMELOV_GRADE
