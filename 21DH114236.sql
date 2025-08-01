-- Stored Procedures:
-- 	Liệt kê top 10 sách được mượn nhiều nhất
CREATE OR ALTER PROC sp_top10bookborrowed AS BEGIN 
	SELECT TOP 10 s.* 
	FROM SACH s INNER JOIN JOIN_BOOKBORROW j 
		ON(s.idBook = j.idBook);
END;
-- Tìm tất cả sách thuộc idTag (dùng JOIN_LISTTAGBOOK và TAG)
CREATE OR ALTER PROC sp_findbookbytag @idTag INT 
AS BEGIN 
	IF NOT EXISTS (
		SELECT * 
		FROM Tag
		WHERE idTag = @idTag
	) BEGIN
		Raiserror(N'idTag Không tồn tại!', 16, 1); 
		RETURN;
	END;
	SELECT s.* 
	FROM SACH s INNER JOIN JOIN_LISTTAGBOOK t 
		ON(s.idBook = t.idBook)
	WHERE idTag = @idTag; 
END; 
-- Cập nhật trạng thái thành viên dựa vào số sách đang mượn
CREATE OR ALTER PROC sp_updatememberstatus 
AS BEGIN 
	-- Case đang mượn sách 
	UPDATE DOCGIA 
		SET StatusMember = N'Đang mượn'
	SELECT mt.idBorrow
	FROM THETHUVIEN ttv 
		JOIN MUONTRA mt ON (ttv.idCard = mt.idCard) 
		JOIN DOCGIA d ON (d.idCard = ttv.idCard)
		JOIN JOIN_BOOKBORROW jbb ON (mt.idBorrow = jbb.idBorrow)
	WHERE mt.statusBorrow = N'Bình thường' OR jbb.statusBookBorrow = N'Đang mượn';
	-- Case trễ hạn mượn sách 
	UPDATE DOCGIA 
		SET StatusMember = N'Trễ hạn mượn sách'
	SELECT mt.idBorrow
	FROM THETHUVIEN ttv 
		JOIN MUONTRA mt ON (ttv.idCard = mt.idCard) 
		JOIN DOCGIA d ON (d.idCard = ttv.idCard)
		JOIN JOIN_BOOKBORROW jbb ON (mt.idBorrow = jbb.idBorrow)
	WHERE mt.statusBorrow = N'Trễ hạn' OR jbb.statusBookBorrow = N'Trễ hạn';
END;
-- Gộp thông tin thẻ thư viện, người dùng, và thủ thư trong một phiếu mượn
CREATE OR ALTER PROC sp_thongtinmuonsach @idCard INT 
AS BEGIN 
	SELECT ttv.idCard, ttv.nameCard, d.statusMember, mt.idBorrow, mt.dateBorrow, mt.deadlineDate, mt.statusBorrow, tt.idLibrarian, tt.roleLibrarian
	FROM THETHUVIEN ttv 
		JOIN MUONTRA mt ON (ttv.idCard = mt.idCard) 
		JOIN DOCGIA d ON (d.idCard = ttv.idCard)
		JOIN THUTHU tt ON (mt.idLibrarian = tt.idLibrarian);
END;
