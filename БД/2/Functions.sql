---------------1-------------------
CREATE OR ALTER FUNCTION avgGradesByCourse(@course int) returns float
as
BEGIN
declare @ret float;
select @ret=avg(cast(grade as float)) from grades inner join students
on grades.student_id = students.student_id where course =@course
return @ret;
END;

go
DECLARE @result FLOAT = dbo.avgGradesByCourse(4);
PRINT @result;


---------------2-------------------
go
CREATE OR ALTER FUNCTION avgGradesBySpecialty(@specialty nvarchar(50)) returns nvarchar(50)
as
BEGIN
DECLARE @ret float;
DECLARE @msg nvarchar(50);
SELECT @ret = avg(cast(grade as float)) FROM grades 
INNER JOIN students on students.student_id = grades.student_id
INNER JOIN SPECIALTIES on students.specialty_id = SPECIALTIES.specialty_id
where UPPER(specialty) = UPPER(@specialty); 
if @ret IS NULL
        SET @msg = 'Нет оценок'
    ELSE
        SET @msg = 'Средний балл: ' + CAST(@ret AS NVARCHAR(10));

    RETURN @msg;
END;



go
select * from grades
inner join students on grades.student_id = students.student_id
inner join specialties on specialties.specialty_id = students.specialty_id

select * from SPECIALTIES
go
declare @result nvarchar(50) = dbo.avgGradesBySpecialty('кибербезопасность');
PRINT @result;


select * from students
---------------3-------------------
go
CREATE OR ALTER FUNCTION studentsByGroupsOnCourse(@course int,@faculty nvarchar(20)) returns table
as
return
SELECT top(100) student,course,grup,subgroup,faculty from students 
inner join specialties on specialties.specialty_id = students.specialty_id
inner join pulpits on PULPITS.pulpit_id = SPECIALTIES.pulpit_id
inner join faculties on FACULTies.faculty_id = PULPITS.pulpit_id
where students.course = @course AND faculties.faculty = @faculty
order by grup desc
go
select * from faculties
select * from studentsByGroupsOnCourse(2,'ЛХ')

SELECT top(100) student,course,grup,subgroup,faculty from students 
inner join specialties on specialties.specialty_id = students.specialty_id
inner join pulpits on PULPITS.pulpit_id = SPECIALTIES.pulpit_id
inner join faculties on FACULTies.faculty_id = PULPITS.pulpit_id
order by grup

---------------4-------------------
    go
    CREATE or ALTER FUNCTION teacherExamCount() returns table
    as
    return
    select teachers.teacher,count(teachers.teacher) as Exams from teachers inner join exams 
    on teachers.teacher_id = exams.teacher_id
    group by teachers.teacher
    go

    select * from teacherExamCount()

    go
    CREATE OR ALTER FUNCTION teachersCountByPulpits(@faculty nvarchar(20)) returns table
    as 
    return 
    select pulpits.pulpit,count(teachers.teacher) as Teachers from teachers 
    inner join pulpits on teachers.pulpit_id = pulpits.pulpit_id
    inner join faculties on pulpits.faculty_id = faculties.faculty_id
    where upper(faculties.faculty) = upper(@faculty)
    group by pulpits.pulpit
    go

    select * from teachersCountByPulpits('ит')


---------------5-------------------
go
CREATE OR ALTER FUNCTION teachersCountByPulpits(@faculty NVARCHAR(20))
RETURNS TABLE AS
RETURN
    SELECT p.pulpit, COUNT(t.teacher_id) AS Teachers
    FROM teachers t
    JOIN pulpits p ON t.pulpit_id = p.pulpit_id
    JOIN faculties f ON p.faculty_id = f.faculty_id
    WHERE UPPER(f.faculty) = UPPER(@faculty)
    GROUP BY p.pulpit;


GO
SELECT * FROM dbo.teachersCountByPulpits('ИТ');
GO

--------------------------------------------------------------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
----------------------NEW-----------------------------
-------------------------------------------------------
go

CREATE OR ALTER FUNCTION teachersByOverload(@subjects INT) RETURNS TABLE
AS RETURN 
   SELECT teacher, COUNT(subject_teacher.subject_id) AS subject_count
   FROM teachers INNER JOIN subject_teacher ON teachers.teacher_id = subject_teacher.teacher_id
    GROUP BY teachers.teacher HAVING COUNT(subject_teacher.subject_id) > @subjects

select * from dbo.teachersByOverload(2)