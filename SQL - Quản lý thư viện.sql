USE master; 
IF NOT EXISTS (
	SELECT * 
	FROM sys.databases 
	WHERE name = N'QLTV'
) BEGIN 
	CREATE DATABASE QLTV;
END; 
IF EXISTS (
	SELECT * 
	FROM sys.databases 
	WHERE name = N'QLTV'
) BEGIN 
	USE QLTV;
END;
--Table
CREATE TABLE TAG (
	idTag INT NOT NULL IDENTITY(1,1),
	nameTag NVARCHAR(30) NOT NULL UNIQUE,
	PRIMARY KEY (idTag)
)

CREATE TABLE SACH (
	idBook CHAR(4) NOT NULL UNIQUE,
	nameBook NVARCHAR(100) NOT NULL,
	typeBook NVARCHAR(100) NOT NULL,
	authorBook NVARCHAR(100) NOT NULL,
	publisherBook NVARCHAR(100) NOT NULL,
	dateBook DATE NOT NULL,
	formatBook NVARCHAR(20) NOT NULL,
	noteBook NVARCHAR(200), 
	statusBook NVARCHAR(100) NOT NULL,
	imageBook VARBINARY(MAX) NOT NULL,
	PRIMARY KEY (idBook)
)

CREATE TABLE JOIN_LISTTAGBOOK (
	idBook CHAR(4) NOT NULL,
	idTag INT NOT NULL UNIQUE,
	PRIMARY KEY (idBook, idTag),
	FOREIGN KEY (idBook) REFERENCES SACH(idBook),
	FOREIGN KEY (idTag) REFERENCES TAG(idTag)
)

CREATE TABLE SUUTAP (
	idCollection CHAR(4) UNIQUE,
	nameCollection NVARCHAR(100) NOT NULL,
	descriptionCollection NVARCHAR(200) NOT NULL,
	imageCollection VARBINARY(MAX) NOT NULL,
	PRIMARY KEY (idCollection)
)

CREATE TABLE JOIN_LISTCOLLECTION (
	idCollection CHAR(4) NOT NULL,
	idBook CHAR(4) NOT NULL UNIQUE,
	PRIMARY KEY (idCollection, idBook),
	FOREIGN KEY (idCollection) REFERENCES SUUTAP(idCollection),
	FOREIGN KEY (idBook) REFERENCES SACH(idBook)
)

CREATE TABLE ACCOUNT_USER (
	idUser INT NOT NULL IDENTITY(1,1),
	nameUser NVARCHAR(100) NOT NULL,
	emailUser VARCHAR(100) NOT NULL,
	passwordUser VARCHAR(100) NOT NULL,
	PRIMARY KEY (idUser)
)

CREATE TABLE THETHUVIEN (
	idCard CHAR(12) NOT NULL UNIQUE,
	nameCard NVARCHAR(100) NOT NULL,
	emailCard NVARCHAR(100) NOT NULL,
	addressCard NVARCHAR(200) NOT NULL,
	phoneCard VARCHAR(100) NOT NULL,
	dateCard DATE NOT NULL,
	startCard DATE NOT NULL,
	expireCard DATE NOT NULL,
	statusCard NVARCHAR(100) NOT NULL,
	idBorrow INT,
	PRIMARY KEY (idCard)
)

CREATE TABLE DOCGIA (
	idMember INT NOT NULL IDENTITY(1,1),
	statusMember NVARCHAR(100) NOT NULL,
	idCard CHAR(12) NOT NULL UNIQUE,
	idUser INT NOT NULL,
	PRIMARY KEY (idMember),
	FOREIGN KEY (idCard) REFERENCES THETHUVIEN(idCard),
	FOREIGN KEY (idUser) REFERENCES ACCOUNT_USER(idUser)
)

CREATE TABLE THUTHU (
	idLibrarian INT NOT NULL IDENTITY(1,1),
	roleLibrarian NVARCHAR(30) NOT NULL,
	hireLibrarian DATE NOT NULL,
	statusLibrarian NVARCHAR(100) NOT NULL,
	idUser INT NOT NULL,
	PRIMARY KEY (idLibrarian),
	FOREIGN KEY (idUser) REFERENCES ACCOUNT_USER(idUser)
)	

CREATE TABLE MUONTRA (
	idBorrow INT NOT NULL IDENTITY(1,1),
	dateBorrow DATE NOT NULL DEFAULT GETDATE(),
	deadlineDate DATE,
	statusBorrow NVARCHAR(100) NOT NULL,
	idCard CHAR(12) NOT NULL,
	idLibrarian INT,
	PRIMARY KEY (idBorrow),
	FOREIGN KEY (idCard) REFERENCES THETHUVIEN(idCard),
	FOREIGN KEY (idLibrarian) REFERENCES THUTHU(idLibrarian)
)

-- 20250729 0805
-- Fix missing column
ALTER TABLE MUONTRA ADD deadlineDate DATE;
UPDATE MUONTRA SET deadlineDate = NULL FROM MUONTRA;
CREATE TABLE JOIN_BOOKBORROW (
	idBorrow INT NOT NULL,
	idBook CHAR(4) NOT NULL UNIQUE,
	startDate DATE NOT NULL,
	returnDate DATE NOT NULL,
	statusBookBorrow NVARCHAR(100) NOT NULL,
	PRIMARY KEY (idBorrow, idBook),
	FOREIGN KEY (idBorrow) REFERENCES MUONTRA(idBorrow),
	FOREIGN KEY (idBook) REFERENCES SACH(idBook)
)

CREATE TABLE TIENPHAT (
	idFee INT NOT NULL IDENTITY(1,1),
	requiredFee FLOAT NOT NULL,
	progressFee FLOAT NOT NULL,
	idBorrow INT UNIQUE,
	PRIMARY KEY (idFee),
	FOREIGN KEY (idBorrow) REFERENCES MUONTRA(idBorrow)
)

CREATE TABLE TIENPHATLYDO (
	idReason INT NOT NULL IDENTITY(1,1),
	nameReason NVARCHAR(100) NOT NULL,
	feeReason FLOAT NOT NULL,
	PRIMARY KEY (idReason)
)

CREATE TABLE JOIN_LISTREASON (
	idFee INT NOT NULL,
	idReason INT NOT NULL,
	PRIMARY KEY (idFee, idReason),
	FOREIGN KEY (idFee) REFERENCES TIENPHAT(idFee),
	FOREIGN KEY (idReason) REFERENCES TIENPHATLYDO(idReason)
)

ALTER TABLE THETHUVIEN
ADD FOREIGN KEY (idBorrow) REFERENCES MUONTRA(idBorrow)


declare @sql nvarchar(max) = (
    select 
        'alter table ' + quotename(schema_name(schema_id)) + '.' +
        quotename(object_name(parent_object_id)) +
        ' drop constraint '+quotename(name) + ';'
    from sys.foreign_keys
    for xml path('')
);
exec sp_executesql @sql;

DECLARE @sql NVARCHAR(max)=''

SELECT @sql += ' Drop table ' + QUOTENAME(TABLE_SCHEMA) + '.'+ QUOTENAME(TABLE_NAME) + '; '
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE'

Exec Sp_executesql @sql


--Procerdure 
--TAG
CREATE PROC AddTag @name NVARCHAR(30)
AS
BEGIN
	INSERT INTO TAG
	VALUES (@name);
END;
-- Procedure xóa Tag 
-- Seeding table 
CREATE TABLE LOG_DELETEJOIN_LISTTAGBOOK (
	numOrder INT IDENTITY(1, 1) PRIMARY KEY, 
	idBook CHAR(4) NOT NULL,
	idTag INT NOT NULL,
	dateDeleted DATE DEFAULT GETDATE()
);
CREATE TABLE LOG_DELETETAG (
	numOrder INT IDENTITY(1, 1) PRIMARY KEY, 
	idTag INT NOT NULL,
	nameTag NVARCHAR(30) NOT NULL, 
	dateDeleted DATE DEFAULT GETDATE()
);
-- Mô tả: 
-- 1. Query dữ liệu của JOIN_LISTTAGBOOK có tồn tại idTag = @id, sau đó xóa và ghi log các dữ liệu tìm được
-- 2. Ghi log dữ liệu Tag đã xóa và xóa dữ liệu có Tag.idTag = @id 
CREATE OR ALTER PROC RemoveTag @id INT
AS
BEGIN
	IF NOT EXISTS (
		SELECT * 
		FROM Tag 
		WHERE idTag = @id
	) BEGIN 
		Raiserror(N'Queried idTag does not exist!', 16, 1);
		RETURN;
	END;
	DECLARE @cnt_joinlst INT; 
	SELECT @cnt_joinlst = (
		SELECT COUNT(idTag) 
		FROM JOIN_LISTTAGBOOK
		WHERE idTag = @id 
	);
	IF(@cnt_joinlst > 0) BEGIN 
		INSERT INTO LOG_DELETEJOIN_LISTTAGBOOK(idBook, idTag)
			SELECT idBook, idTag 
			FROM JOIN_LISTTAGBOOK 
			WHERE idTag = @id; 
		DELETE FROM JOIN_LISTTAGBOOK
			WHERE idTag = @id;
	END;
	INSERT INTO LOG_DELETETAG(idTag, nameTag) 
		SELECT idTag, nameTag 
		FROM Tag 
		WHERE idTag = @id;
	DELETE FROM TAG
	WHERE idTag = @id;
END;

--SACH
CREATE OR ALTER PROC AddBook @id CHAR(4), @name NVARCHAR(100), @type NVARCHAR(100), @author NVARCHAR(100), @publisher NVARCHAR(100), @format NVARCHAR(20), @image VARBINARY(MAX)
AS
BEGIN
	INSERT INTO SACH
	VALUES(@id, @name, @type, @author, @publisher, GETDATE(), @format, NULL, 'CREATED', @image)
END;

CREATE OR ALTER PROC DeleteBook @id CHAR(4)
AS
BEGIN
	DELETE FROM SACH
	WHERE idBook = @id;
END;

CREATE PROC SearchBook @id CHAR(4), @name NVARCHAR(100)
AS
BEGIN
	SELECT *
	FROM SACH
	WHERE idBook LIKE '%' + @id + '%' OR nameBook LIKE '%' + @name + '%';
END;

--SUUTAP
CREATE PROC AddCollection @id CHAR(4) OUTPUT, @name NVARCHAR(100), @description NVARCHAR(200), @image VARBINARY(MAX)
AS
BEGIN
	INSERT INTO SUUTAP
	VALUES (@id, @name, @description, @image)
END;

CREATE PROC DeleteCollection @id CHAR(4)
AS
BEGIN
	DELETE FROM SUUTAP
	WHERE idCollection = @id;
END;

CREATE PROC AddToCollection @idcollection CHAR(4), @idbook CHAR(4)
AS
BEGIN
	INSERT INTO JOIN_LISTCOLLECTION
	VALUES (@idcollection, @idbook);
END;

CREATE PROC RemoveFromCollection @idcollection CHAR(4), @idbook CHAR(4)
AS
BEGIN
	DELETE FROM JOIN_LISTCOLLECTION
	WHERE idCollection = @idcollection AND idBook = @idbook;
END;

CREATE PROC SearchCollection @id CHAR(4), @name NVARCHAR(100)
AS
BEGIN
	SELECT *
	FROM SUUTAP
	WHERE idCollection LIKE '%' + @id + '%' OR nameCollection LIKE '%' + @name + '%';
END;

--MUONTRA
CREATE PROC AddBorrow @idborrow INT OUTPUT, @idcard CHAR(12), @idlibrarian INT
AS
BEGIN
	INSERT INTO MUONTRA
	VALUES (GETDATE(), 'CREATED', @idcard, @idlibrarian);

	SET @idborrow = SCOPE_IDENTITY();
END;

CREATE PROC DeleteBorrow @id INT
AS
BEGIN
	DELETE FROM MUONTRA
	WHERE idBorrow = @id;

	DELETE FROM JOIN_BOOKBORROW
	WHERE idBorrow = @id;
END;

CREATE PROC AddBookToBorrow @idborrow INT, @idbook CHAR(4)
AS
BEGIN
	INSERT INTO JOIN_BOOKBORROW
	VALUES (@idborrow, @idbook, GETDATE(), DATEADD(DAY, 21, GETDATE()), 'PENDING');
END;

CREATE PROC RemoveBookFromBorrow @idborrow INT, @idbook CHAR(4)
AS
BEGIN
	DELETE FROM JOIN_BOOKBORROW
	WHERE idBorrow = @idborrow AND idBook = @idBook
END;

CREATE PROC SearchBorrow @idborrow INT, @idcard CHAR(12)
AS
BEGIN
	SELECT *
	FROM MUONTRA
	WHERE idBorrow LIKE '%' + @idborrow + '%' OR idCard LIKE '%' + @idCard + '%'
END;

--THETHUVIEN
CREATE PROC AddCard @id CHAR(12), @name NVARCHAR(100), @email NVARCHAR(100), @address NVARCHAR(100), @phone VARCHAR(100), @date DATE
AS
BEGIN
	INSERT INTO THETHUVIEN
	VALUES (@id, @name, @email, @address, @phone, @date, GETDATE(), DATEADD(YEAR, 3, GETDATE()), 'CREATED', NULL);
END;

CREATE PROC RemoveCard @id CHAR(12)
AS
BEGIN
	DELETE FROM THETHUVIEN
	WHERE idCard = @id;
END;

CREATE PROC SearchCard @id CHAR(12), @name NVARCHAR(100)
AS
BEGIN
	SELECT *
	FROM THETHUVIEN
	WHERE idCard LIKE '%' + @id + '%' OR nameCard LIKE '%' + @name + '%'
END;

--DOCGIA
CREATE PROC AddMember @idcard CHAR(12), @iduser INT
AS
BEGIN
	INSERT INTO DOCGIA
	VALUES ('CREATED', @idcard, @iduser);
END;

--THUTHU
CREATE PROC AddLibrarian @role NVARCHAR(30), @iduser INT
AS
BEGIN
	INSERT INTO THUTHU
	VALUES (@role, GETDATE(), 'CREATED', @iduser);
END;

--ACCOUNT_USER
CREATE PROC AddUser @id INT OUTPUT, @name VARCHAR(100), @email VARCHAR(100), @password VARCHAR(100)
AS
BEGIN
	INSERT INTO ACCOUNT_USER
	VALUES (@name, @email, @password)

	SET @id = SCOPE_IDENTITY();
END;

--ALL
CREATE PROC UpdateField @table CHAR(20), @id CHAR(12), @field CHAR(20), @newdata CHAR(200)
AS
BEGIN
	DECLARE @runupdate NVARCHAR(MAX), @idname CHAR(12), @fieldname CHAR(20);

	SELECT @idname = COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @table AND COLUMN_NAME LIKE 'id%';

	SELECT @fieldname = COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @table AND COLUMN_NAME = @field;

	SET @runupdate = 'UPDATE ' + QUOTENAME(@table) + 
					 ' SET ' + QUOTENAME(@fieldname) + ' = @p_newdata' +
					 ' WHERE ' + QUOTENAME(@idname) + ' = @p_id';
	EXEC sp_executesql @runupdate, N'@p_newdata CHAR(200), @p_id CHAR(12)', @p_newdata = @newdata, @p_id = @id;
END;

CREATE PROC UpdateStatus @table CHAR(20), @id CHAR(12), @newstatus NVARCHAR(100)
AS
BEGIN
	DECLARE @runupdate NVARCHAR(MAX), @idname CHAR(12), @statusname CHAR(20);

	SELECT @idname = COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @table AND COLUMN_NAME LIKE 'id%';

	SELECT @statusname = COLUMN_NAME
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @table AND COLUMN_NAME LIKE 'status%';

	SET @runupdate = 'UPDATE ' + QUOTENAME(@table) + 
					 ' SET ' + QUOTENAME(@statusname) + ' = @p_newstatus' +
					 ' WHERE ' + QUOTENAME(@idname) + ' = @p_id';
	EXEC sp_executesql @runupdate, N'@p_newstatus NVARCHAR(100), @p_id CHAR(12)', @p_newstatus = @newstatus, @p_id = @id;
END;
 
