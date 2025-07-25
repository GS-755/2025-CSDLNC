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

CREATE PROC AddFee @idborrow INT
AS
BEGIN
	INSERT INTO TIENPHAT
	VALUES (0, 0, @idborrow);
END;

CREATE PROC AddReasonToFee @idfee INT, @idreason INT
AS
BEGIN
	INSERT INTO JOIN_LISTREASON
	VALUES (@idfee, @idreason)
END;

CREATE PROC AddReason @name NVARCHAR(100), @fee FLOAT
AS
BEGIN
	INSERT INTO TIENPHATLYDO
	VALUES (@name, @fee);
END;

CREATE PROC FindMemberByLate
AS
BEGIN
	SELECT ttv.nameCard AS [Tên đọc giả]
	FROM ((THETHUVIEN ttv
	JOIN MUONTRA mt ON mt.idCard = ttv.idCard)
	JOIN JOIN_BOOKBORROW j_bb ON j_bb.idBorrow = mt.idBorrow)
	WHERE j_bb.statusBookBorrow = 'Trễ hạn'
END;
