-- COMP3311 Prac 03 Exercise
-- Schema for simple company database

create table Employees (
	tfn         char(11) 
		    constraint ValidTFN
		    check (tfn ~ '[0-9]{3}-[0-9]{3}-[0-9]{3}'),
	givenName   varchar(30) not null,    
	familyName  varchar(30),
	hoursPweek  float 
		    constraint ValidHours
		    check (hoursPweek >= 0 and hoursPweek <= 168),
	primary key (tfn)
);

create table Departments (
	id          char(3)
		    constraint ValidID
		    check (id ~ '[0-9]{3}'),
	name        varchar(100) unique,
	manager     char(11) 
		    constraint ValidE references Employees(tfn),
	primary key (id)
);

create table DeptMissions (
	department  char(3)
		    constraint ValidD references Departments(id),    
	keyword     varchar(20),
	primary key (department, keyword)
);

create table WorksFor (
	employee    char(11)
		    constraint ValidE references Employees(tfn),
	department  char(3)
		    constraint ValidD references Departments(id),
	percentage  float
		    constraint ValidP
		    check (percentage >= 0.0 and percentage <= 100.0),
	primary key (employee, department)
);
