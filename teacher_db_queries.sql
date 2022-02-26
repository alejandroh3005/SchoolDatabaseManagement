-- Author: Alejandro Hernandez
-- Date: 2/21/2022

-- instantiate database0
show databases;
create database teacher_system;
use teacher_system;
show tables;
-- drop all tables:
-- drop tables Teacher, Course, Student, LocationNTime;

-- create tables
create table Course (
	courseN int primary key,
    courseName char(20),
    nUnits tinyint
);
create table LocationNTime (
	courseN int,
    schoolQuarter char(20),
    dayTime char(10),
    roomN int,
    primary key (courseN, schoolQuarter, dayTime),
    foreign key (courseN) references Course(courseN)
);
create table Teacher (
	courseN int,
    schoolQuarter char(20),
    teacherName char(30),
    primary key (courseN, schoolQuarter)
);
-- alter table Teacher add foreign key (courseN, schoolQuarter) references Student(courseN, schoolQuarter);
create table Student (
	studentName char(30),
    courseN int, 
    schoolQuarter char(20),
    primary key (studentName, courseN, schoolQuarter)
);
describe Teacher;
show tables;

-- populate tables
insert into Course values
	(000, "AA", 4),
	(111, "BB", 4),
	(222, "CC", 2),
	(333, "DD", 1),
	(444, "EE", 3),
	(555, "FF", 4);
insert into LocationNTime values    
	(000, "Spring2005", "M2:00PM", 34),
	(000, "Fall2005", "M11:00AM", 30),
	(111, "Spring2007", "W12:30PM", 34),
	(222, "Spring2005", "M2:00PM", 30),
	(222, "Fall2006", "M1:00PM", 30),
	(333, "Spring2007", "TH2:00PM", 34),
	(333, "Fall2007", "M2:00PM", 36),
	(333, "Winter2011", "T2:30PM", 36),
	(555, "Winter2010", "M10:00AM", 34),
	(555, "Spring2008", "W2:30PM", 34),
	(555, "Winter2011", "W9:00AM", 36);
insert into Teacher values
	(000, "Spring2005", "Karen Reed"),
	(000, "Fall2005", "Anna Rose"),
	(111, "Spring2007", "Lucy Garfield"),
	(222, "Spring2005", "Lucy Garfield"),
	(222, "Fall2006", "Karen Reed"),
	(333, "Spring2007", "Roger Wilkins"),
	(333, "Fall2007", "Roger Wilkins"),
	(333, "Winter2011", "Roger Wilkins"),
	(555, "Winter2010", "Anna Rose"),
	(555, "Spring2008", "Karen Reed"),
	(555, "Winter2011", "Anna Rose");
insert into Student values
	("David Weidman", 000, "Spring2005"),
	("Ron Smith", 000, "Fall2005"),
    ("David Weidman", 111, "Spring2007"),
    ("Ron Smith", 111, "Spring2007"),
    ("David Weidman", 222, "Spring2005"),
    ("Mica Martinez", 222, "Fall2006"),
    ("Ron Smith", 333, "Spring2007"),
    ("Mica Martinez", 333, "Spring2007"),
    ("Dwayne Baldwin", 333, "Fall2007"),
    ("David Weidman", 555, "Winter2010"),
    ("Mica Martinez", 555, "Winter2011"),
    ("Ron Smith", 555, "Spring2008");

select * from Student;
select * from Teacher;
select * from LocationNTime;
select * from Course;

-- #1. List the name of every teacher (distinct names) who teaches in RoomN ‘34’ in Winter2011
select distinct TeacherName
from Teacher T, LocationNTime L
where T.CourseN=L.CourseN and RoomN=34 and T.SchoolQuarter="Winter2011";

-- #2. List CourseN, CourseName, and TeacherName of every course meets on Monday PM
select T.CourseN, CourseName, TeacherName
from Teacher T, Course C, LocationNTime L
where T.CourseN=C.CourseN and T.CourseN=L.CourseN and DayTime like "M%PM"
group by T.CourseN, CourseName, TeacherName;

-- #3.	List the name of every teacher who taught at least one course in RoomN ‘723’
select distinct TeacherName
from Teacher T, LocationNTime L
where T.CourseN=L.CourseN and RoomN=34;

-- #4.	List the CourseN, Quarter, RoomN and DayTime of every course taught by ‘Karen Reed’ in the Spring 2005
select L.CourseN, T.SchoolQuarter, RoomN, DayTime
from Teacher T, LocationNTime L
where T.SchoolQuarter=L.SchoolQuarter and TeacherName="Karen Reed" and T.SchoolQuarter="Spring2005"
group by CourseN;

-- #5. List the CourseN and TeacherName of every course taken by the student ‘Ron Smith’ or by the student ‘David Weidman’
select S.CourseN, TeacherName
from Student S, Teacher T 
where S.CourseN=T.CourseN and 
	  S.SchoolQuarter=T.SchoolQuarter and 
      StudentName in ("David Weidman","Ron Smith");

-- #6.	List the CourseN and Quarter of every course taught by ‘Karen Reed’ and met or meets in RoomN ‘713’.
select T.CourseN, L.SchoolQuarter
from Teacher T, LocationNTime L
where T.CourseN=L.CourseN and
	  T.SchoolQuarter=L.SchoolQuarter and
	  TeacherName="Karen Reed" and 
      RoomN=34;

-- #7.	List the name of every teacher who has taught the same course at least two times.
select TeacherName
from Teacher 
group by TeacherName, CourseN
having count(SchoolQuarter) > 1;

-- #8. List the name of every teacher (distinct names) who has taught at least two different courses in the same or different quarters.
select TeacherName
from (
	select T.TeacherName
	from Teacher T
	group by T.TeacherName, CourseN
    ) as subT
group by TeacherName
having count(TeacherName) > 1;

-- #9.	List the CourseN, CourseName, and Quarter which meets or met at least two times a week
select CourseN, CourseName, SchoolQuarter
from 
	(select C.CourseN, CourseName, SchoolQuarter, DayTime
	 from Course C, LocationNTime L
     where C.CourseN=L.CourseN) as sub
group by CourseN, CourseName, SchoolQuarter
having count(DayTime) > 1;
-- OR
select C.CourseN, CourseName, SchoolQuarter
from LocationNTime L, Course C
where C.CourseN=L.CourseN
group by L.CourseN, L.SchoolQuarter
having count(L.DayTime) > 1;

-- #10.	List the CourseN and CourseName of every course with number of units > 4
select CourseN, CourseName
from Course
where NUnits >= 4;

-- #11.	List every course number and student’s name who has taken the course at least twice
select CourseN, StudentName
from Student
group by CourseN, StudentName
having count(SchoolQuarter) >= 2;

-- #12. Use ‘*’ to list the CourseN, CourseName, Nunit, Quarter, TeacherName of every course sorted by CourseN ascending, CourseName descending
select *
from Course C, Teacher T
where C.CourseN=T.CourseN
order by C.CourseN asc, C.CourseName desc;

-- #13.	List the CourseN and Quarter of every course taught by two different instructors in the same quarter ordered by the CourseN in descending order
select CourseN, SchoolQuarter
from 
	(select C.CourseN, SchoolQuarter, TeacherName
	 from Course C, Teacher T
     where C.CourseN=T.CourseN) as sub
group by CourseN, SchoolQuarter
having count(TeacherName) > 1
order by CourseN desc;