SELECT node.ToString() as NodeAsString,* FROM teachers
where node is NOT NULL
order by node;

select * from teachers;

insert into teachers(teacher,position,pulpit_id,node)
values ('Касперович Максим','ректор',3,hierarchyid::Parse('/'))

--ALTER TABLE teachers 
  --  ADD node hierarchyid;

--UPDATE TEACHERS
--SET node = hierarchyid::Parse('/2/')
--WHERE TEACHER_ID=2


---------------------------------------------------------------------
---------------------------------------------------------------------
CREATE PROCEDURE GetUnder @node hierarchyid AS
BEGIN
  SELECT teachers.TEACHER_ID,teachers.node.ToString() AS NodeAsString,teachers.node.GetLevel() AS Level
    FROM teachers
    WHERE teachers.node.IsDescendantOf(@node) = 1
    ORDER BY teachers.node
END

exec GetUnder '/';

---------------------------------------------------------------------
---------------------------------------------------------------------
CREATE PROCEDURE AddChild @parentNode hierarchyid,@teacherId INT AS
BEGIN
    DECLARE @newNode hierarchyid

    SELECT @newNode = @parentNode.GetDescendant(MAX(node),NULL)
    FROM teachers
    WHERE node.GetAncestor(1) = @parentNode

    UPDATE teachers
    SET node = @newNode
    WHERE TEACHER_ID = @teacherId
END


begin
declare @parentnode hierarchyid;
select @parentnode = node from teachers where teacher_id = 18;
exec AddChild @parentnode,3
end;


---------------------------------------------------------------------
---------------------------------------------------------------------


CREATE PROCEDURE MoveFromUnder 
    @oldParent hierarchyid,
    @newParent hierarchyid
AS
BEGIN
    DECLARE @newParentLastChild hierarchyid
    DECLARE @newRoot hierarchyid

    SELECT @newParentLastChild = MAX(node)
    FROM teachers
    WHERE node.GetAncestor(1) = @newParent

    SET @newRoot = @newParent.GetDescendant(@newParentLastChild, NULL)

    UPDATE teachers
    SET node = node.GetReparentedValue(@oldParent, @newRoot)
    WHERE node.IsDescendantOf(@oldParent) = 1
      AND node <> @oldParent  
END
drop procedure  MoveFromUnder;

begin
declare @new hierarchyid;   
declare @old hierarchyid;
select @new = node from teachers where teacher_id = 1;
select @old = node from teachers where teacher_id =18;
exec MoveFromUnder @old,@new
end;