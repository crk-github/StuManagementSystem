create database SIMS
on
(
	name = SIMS,
	filename ="D:/Engineering being done/GitHub/StuManagementSystem/SIMS/DataBase/SIMS.mdf", 
	size = 5,
	maxsize = 10
)
log on
(
	name=SIMS_log,
	filename ="D:/Engineering being done/GitHub/StuManagementSystem/SIMS/DataBase/SIMS_log.ldf",
	size = 5,
	filegrowth = 10%,
	maxsize = 10
)
use SIMS
GO
--close SIMS --�ر����ݿ�
--drop database SIMS -- ɾ�����ݿ�
---------------��������Ա��--------------------------
create table t_admin
(
	ID		int identity,
	UName	varchar(10) null,
	Pass	varchar(20) null,
	constraint pk_admin primary key (ID)
)
GO
---------------����Ժϵ��--------------------------
create table t_department
(
	ID int not null,
	Name Varchar(30) not null,
	Direc varchar(10) not null,
	Note varchar(100) ,
	constraint pk_department primary key (ID)
)
GO
---------------����רҵ��--------------------------
create table t_major
(
	ID int not null,
	Name varchar(20) not null,
	depart int not null,
	Note varchar(100),
	constraint pk_major primary key(ID),
	constraint fk_major_depart foreign key (depart) references t_department(ID)
)
go
---------------�����༶��--------------------------
create table t_class
(
	ID int not null,
	Name varchar(20) not null,
	major int not null,
	Couns varchar(20) not null,
	constraint pk_class primary key(ID),
	constraint fk_class_major foreign key (major) references t_major(ID)
)
go
---------------����ѧ����--------------------------
create table t_student
(
	UNo		int			 not null,
	Name	varchar(8)	 not null,
	Sex		char (2) check(Sex in ('��','Ů')) not null,
	Birth	varchar (10)	 not null,
	ID		char (18)		 not null,
	Origin	varchar (10)	 not null,
	Addr	varchar (50),
	Tel		varchar (13),
	IYear	varchar (10)	not null,
	class	int				not null,
	Note	varchar (100),
	constraint pk_student primary key (UNo),
	constraint fk_stu_class foreign key (class)  references t_class (ID)
)
GO
--==================ѧԺ��Ϣ��ͼ=====================
select d.ID,d.Name,d.Direc,d.Note
from t_department as d
GO
--==================רҵ��Ϣ��ͼ=====================
create view vi_major_info(���,����,Ժ��,��ע)as 
select m.ID,m.Name,d.Name,m.Note 
from t_major as m, t_department as d 
where  m.depart =  d.ID
GO
--==================�༶��Ϣ��ͼ=====================
create view vi_class_info(���,�༶����,����Ա,רҵ����,ѧԺ����) as
select c.ID,c.Name,c.Couns,m.Name,d.Name
from t_class as c,t_major as m,t_department as d 
where c.major = m.ID and m.depart = d.ID
GO
--==================ѧ����Ϣ��ͼ=====================
create view vi_Stu_info(ѧ��,����,�Ա�,��������,���֤��,����,��ַ,�绰,��ѧʱ��,�༶,רҵ,ѧԺ,��ע) as
select s.UNo,s.Name,s.Sex,s.Birth,s.ID,s.Origin,s.Addr,s.Tel,s.IYear,c.Name,m.Name,d.Name,s.Note
From t_student as s,t_class as c,t_major as m,t_department as d
where s.class = c.ID AND c.major = m.ID AND depart  =d.ID
go
--+++++++++++++++++���ѧԺ��Ϣ�洢����+++++++++++++++++++++
create proc proc_department_insert
(
	@ID	     int,
	@Name	 varchar(30),
	@Direc	 varchar(10),
	@Note	 varchar(100)
)
as
insert into t_department values (@ID,@Name,@Direc,@Note)
go
--+++++++++++++++ɾ��ѧԺ��Ϣ�洢����++++++++++++++++++++++++
create proc proc_department_del
(
	@ID	     int
)
as
begin tran
delete from t_Stu_Cou where S_UNo in 
(select UNo from t_student where class in
	(select ID from t_class where major in
		(select ID from t_major where  depart = @ID)))
delete from t_student where class in 
 (select ID from t_class where major in
	(select  ID from t_major where depart = @ID))
delete from t_class where major in (select ID from t_major where depart = @ID)
delete from t_major where depart = @ID
delete from t_department where ID = @ID
if @@ERROR <> 0
	begin rollback tran
	end
else
	begin commit tran
end
go
--+++++++++++++++����ѧԺ��Ϣ�洢����++++++++++++++++++++++++
create proc proc_department_update
(
	@ID	     int,
	@Name	 varchar(30),
	@Direc	 varchar(10),
	@Note	 varchar(100)
)
as
update t_department set Name = @Name,Direc = @Direc,Note = @Note where ID  = @ID
go
--+++++++++++++++���רҵ��Ϣ�洢����++++++++++++++++++++++++
create proc proc_major_insert
(
	@ID	     int,
	@Name	 varchar(20),
	@depart	 int,
	@Note	 varchar(100)
)
as
insert into t_major values (@ID,@Name,@depart,@Note)
go
--+++++++++++++++ɾ��רҵ��Ϣ�洢����++++++++++++++++++++++++
create proc proc_major_del
(
	@ID	     int
)
as
begin tran
delete from t_student where class in (select ID from t_class where major = @ID)
delete from t_class where major = @ID
delete from t_major where ID = @ID
if @@ERROR <> 0
	begin rollback tran
	end
else
	begin commit tran
end
go
--+++++++++++++++����רҵ��Ϣ�洢����++++++++++++++++++++++++
create proc proc_major_update
(
	@ID	     int,
	@Name	 varchar(20),
	@depart	 int,
	@Note	 varchar(100)
)
as
update t_major set Name = @Name,depart = @depart,Note = @Note where ID  = @ID
go
--+++++++++++++++��Ӱ༶��Ϣ�洢����++++++++++++++++++++++++
create proc proc_class_insert
(
	@ID		int,
	@Name	varchar(20),
	@major	int,
	@Couns	varchar(20)
)
as 
insert into t_class values (@ID,@Name,@major,@Couns)
go
--+++++++++++++++ɾ���༶��Ϣ�洢����++++++++++++++++++++++++
create proc proc_class_del
(
	@ID  int
)
as
begin tran
delete from t_student where class = @ID
delete from t_class where ID = @ID
if @@ERROR <> 0
	begin rollback tran
	end
else
	begin commit tran
end
go
--+++++++++++++++���°༶��Ϣ�洢����++++++++++++++++++++++++
create proc proc_class_update
(
	@ID		int,
	@Name	varchar(20),
	@major	int,
	@Couns	varchar(20)
)
as
update t_class set Name = @Name,major = @major,Couns = @Couns where ID  = @ID
go
--+++++++++++++++���ѧ����Ϣ�洢����++++++++++++++++++++++++
create proc proc_student_insert
(
	@UNo	int,
	@Name	varchar(8),
	@Sex	char(2),
	@Birth	varchar(10),
	@ID		char(18),
	@Origin	varchar(10),
	@Addr	varchar(50),
	@Tel	varchar(13),
	@IYear	varchar(10),
	@class	int,
	@Note	varchar (100)
)
as
insert into t_student values (@UNo,@Name,@Sex,@Birth,@ID,@Origin,@Addr,@Tel,@IYear,@class,@Note)
go
--+++++++++++++++ɾ��ѧ����Ϣ�洢����++++++++++++++++++++++++
create proc proc_student_del
(
	@UNo int
)
as
begin tran
delete from t_student where UNo = @UNo
if @@ERROR <> 0
	begin rollback tran
	end
else
	begin commit tran
end
go
--+++++++++++++++����ѧ����Ϣ�洢����++++++++++++++++++++++++
create proc proc_student_update
(
	@UNo	int,
	@Name	varchar(8),
	@Sex	char(2),
	@Birth	varchar(10),
	@ID		char(18),
	@Origin	varchar(10),
	@Addr	varchar(50),
	@Tel	varchar(13),
	@IYear	varchar(10),
	@class	int,
	@Note	varchar (100)
)
as
update t_student set Name = @Name,Sex =@Sex,Birth = @Birth,ID = @ID,Origin = @Origin,Addr = @Addr,Tel = @Tel,IYear = @IYear,class = @class,Note = @Note where UNo = @UNo
go
--+++++++++++++++��ӹ���Ա��Ϣ�洢����++++++++++++++++++++++
create proc proc_admin_insert
(
	@UName  varchar(10),
	@Pass varchar(20)
)
as
insert into t_admin (UName,Pass)values (@UName,@Pass)
go
--+++++++++++++++���Ĺ���Ա����洢����++++++++++++++++++++++
create proc proc_admin_update
(
	@UName  varchar(10),
	@Pass varchar(20)
)
as
update t_admin set Pass =@Pass where UName = @UName
go