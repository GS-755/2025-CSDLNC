-- 20250725 1047 
-- OK
CREATE PROC CountByLibrarian
AS
BEGIN
	SELECT acc.nameUser AS [Tên thủ thư], COUNT(1) AS [Số mượn trả lập]
	FROM ((MUONTRA mt
	JOIN THUTHU tt ON tt.idLibrarian = mt.idLibrarian)
	JOIN ACCOUNT_USER acc ON acc.idUser = tt.idUser)
	GROUP BY acc.nameUser
	ORDER BY acc.nameUser ASC;
END;

-- 20250725 1047
-- OK 
CREATE PROC AddFee @idborrow INT
AS
BEGIN
	INSERT INTO TIENPHAT
	VALUES (0, 0, @idborrow);
END;

-- 20250725 1048
-- OK 
CREATE PROC AddReasonToFee @idfee INT, @idreason INT
AS
BEGIN
	INSERT INTO JOIN_LISTREASON
	VALUES (@idfee, @idreason)
END;

-- 20250725 1049
-- OK 
CREATE PROC AddReason @name NVARCHAR(100), @fee FLOAT
AS
BEGIN
	INSERT INTO TIENPHATLYDO
	VALUES (@name, @fee);
END;

-- 20250725 1050 
-- OK
CREATE PROC FindMemberByLate
AS
BEGIN
	SELECT ttv.nameCard AS [Tên đọc giả]
	FROM ((THETHUVIEN ttv
	JOIN MUONTRA mt ON mt.idCard = ttv.idCard)
	JOIN JOIN_BOOKBORROW j_bb ON j_bb.idBorrow = mt.idBorrow)
	WHERE j_bb.statusBookBorrow = 'Trễ hạn'
END;
-- 20250725 1050
-- OK 
CREATE TRIGGER UpdateReqFee
ON JOIN_LISTREASON
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @idfee INT, @idreason INT, @fee FLOAT;
	SET @idfee = ISNULL((SELECT idFee FROM INSERTED), (SELECT idFee FROM DELETED));
	SET @idreason = ISNULL((SELECT idReason FROM INSERTED), (SELECT idReason FROM DELETED));
	SET @fee = ISNULL((
		SELECT tpld.feeReason 
		FROM INSERTED i
			JOIN TIENPHATLYDO tpld ON tpld.idReason = i.idReason
		WHERE tpld.idReason = @idreason), (
		SELECT tpld.feeReason 
		FROM DELETED d
			JOIN TIENPHATLYDO tpld ON tpld.idReason = d.idReason
		WHERE tpld.idReason = @idreason));

	UPDATE TIENPHAT
	SET requiredFee = CASE
		WHEN EXISTS (SELECT 1 FROM INSERTED) THEN requiredFee + @fee
		WHEN EXISTS (SELECT 1 FROM DELETED) THEN requiredFee - @fee
	END
	WHERE idFee = @idFee;
END;

--Test Data
EXEC AddUser 0, N'Lê Anh Em', 'asd', '123'
EXEC AddLibrarian 'asd', 1
EXEC AddCard '111111111111', N'Đăng Anh Em', 'asd', 'asd', 'asd', '22221222'
EXEC AddBook '1234', 'asd', 'asd', 'asd', 'asd', 'asd', 'asd', 0x00
EXEC AddBorrow 0, '111111111111', 1
EXEC AddBookToBorrow 1, '1234'
EXEC UpdateStatus 'JOIN_BOOKBORROW', 1, N'Trễ hạn'

EXEC CountByLibrarian
EXEC AddFee NULL
EXEC AddReason 'asd', 100000
EXEC AddReasonToFee 1, 0
EXEC FindMemberByLate
