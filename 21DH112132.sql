-- 20250729 0738
-- OK
CREATE OR ALTER PROC ThongKeSoLuongMuon_TheoThuThu
AS
BEGIN
    SELECT 
        TT.idLibrarian,
        AU.nameUser AS tenThuThu,
        COUNT(MT.idBorrow) AS soLuongMuon
    FROM MUONTRA MT
    INNER JOIN THUTHU TT ON MT.idLibrarian = TT.idLibrarian
    INNER JOIN ACCOUNT_USER AU ON TT.idUser = AU.idUser
    GROUP BY TT.idLibrarian, AU.nameUser;
END;
EXEC ThongKeSoLuongMuon_TheoThuThu;


-- 20250729 0741 
-- Added idReason check logic 
CREATE OR ALTER PROC ThemTienPhatMoi
    @requiredFee FLOAT,
    @progressFee FLOAT,
    @idBorrow INT,
    @idReason INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM TIENPHATLYDO WHERE idReason = @idReason)
    BEGIN
        RAISERROR(N'Lý do phạt không tồn tại!', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM MUONTRA WHERE idBorrow = @idBorrow)
    BEGIN
        RAISERROR(N'Mã mượn trả không tồn tại!', 16, 1);
        RETURN;
    END;
    INSERT INTO TIENPHAT (requiredFee, progressFee, idBorrow)
    VALUES (@requiredFee, @progressFee, @idBorrow);

    DECLARE @newIdFee INT = SCOPE_IDENTITY();

    INSERT INTO JOIN_LISTREASON (idFee, idReason)
    VALUES (@newIdFee, @idReason);
END;

-- 20250729 0743 
-- NG: Only prints late-returning customers.
CREATE OR ALTER PROC DanhSachDocGia_MuonQuaHan
AS
BEGIN
    SELECT 
        DG.idMember,
        AU.nameUser AS tenDocGia,
        TV.idCard,
        BB.idBook,
        BB.returnDate,
        BB.statusBookBorrow
    FROM JOIN_BOOKBORROW BB
    INNER JOIN MUONTRA MT ON BB.idBorrow = MT.idBorrow
    INNER JOIN THETHUVIEN TV ON MT.idCard = TV.idCard
    INNER JOIN DOCGIA DG ON TV.idCard = DG.idCard
    INNER JOIN ACCOUNT_USER AU ON DG.idUser = AU.idUser
    WHERE BB.statusBookBorrow = N'Trễ hạn'
       OR DATEDIFF(DAY, BB.returnDate, MT.deadlineDate) < 0;
END;
-- 20250729 0813 
-- Fix Late-borrow logic
CREATE OR ALTER PROC CapNhatTrangThaiQuaHan
AS
BEGIN
    UPDATE BB
    SET statusBookBorrow = N'Trễ hạn'
    FROM JOIN_BOOKBORROW BB 
    WHERE DATEDIFF(DAY, (SELECT MT.deadlineDate FROM MUONTRA MT WHERE MT.idBorrow = BB.idBorrow), BB.returnDate) < 0
		AND BB.statusBookBorrow != N'Trễ hạn';
END;

--TEST
INSERT INTO ACCOUNT_USER (nameUser, emailUser, passwordUser) VALUES
(N'Nguyễn Thị Lan', 'lannt@gmail.com', '123456'),
(N'Lê Văn Bình', 'binhlv@gmail.com', '123456'),
(N'Trần Hoàng Nam', 'namth@gmail.com', '123456');

INSERT INTO THUTHU (roleLibrarian, hireLibrarian, statusLibrarian, idUser) VALUES
(N'Thủ thư chính', '2024-01-01', N'Đang làm việc', 1);

INSERT INTO THETHUVIEN (idCard, nameCard, emailCard, addressCard, phoneCard, dateCard, startCard, expireCard, statusCard, idBorrow) VALUES
('TV00112233', N'Lê Văn Bình', 'binhlv@gmail.com', N'1 Trần Phú, Hà Nội', '0901122334', '2024-01-01', '2024-01-01', '2026-01-01', N'Đang hoạt động', NULL),
('TV00998877', N'Trần Hoàng Nam', 'namth@gmail.com', N'10 Nguyễn Huệ, Đà Nẵng', '0911223344', '2024-01-01', '2024-01-01', '2026-01-01', N'Đang hoạt động', NULL);


INSERT INTO DOCGIA (statusMember, idCard, idUser) VALUES
(N'Bình thường', 'TV00112233', 2),
(N'Bình thường', 'TV00998877', 3);

INSERT INTO SACH (idBook, nameBook, typeBook, authorBook, publisherBook, dateBook, formatBook, noteBook, statusBook, imageBook) VALUES
('S010', N'Hóa học 12 nâng cao', N'Giáo khoa', N'Nguyễn Văn Cường', N'NXB Giáo Dục', '2022-09-01', N'Bìa mềm', NULL, N'Còn hàng', 0x),
('S011', N'Phép màu buổi sáng', N'Tiểu thuyết', N'Lê Thị Mai', N'NXB Trẻ', '2021-04-20', N'Bìa cứng', NULL, N'Còn hàng', 0x);

INSERT INTO TIENPHATLYDO (nameReason, feeReason) VALUES
(N'Trễ hạn', 10000);

INSERT INTO MUONTRA (dateBorrow, statusBorrow, idCard, idLibrarian) VALUES
('2025-07-10', N'Đang mượn', 'TV00112233', 1),
('2025-07-01', N'Đã trả', 'TV00998877', 1);

INSERT INTO JOIN_BOOKBORROW (idBorrow, idBook, startDate, returnDate, statusBookBorrow)
VALUES
(1, 'S010', '2025-07-10', '2025-07-15', N'Trễ hạn');

INSERT INTO JOIN_BOOKBORROW (idBorrow, idBook, startDate, returnDate, statusBookBorrow)
VALUES
(2, 'S011', '2025-07-01', '2025-07-07', N'Đã trả');

INSERT INTO TIENPHAT (requiredFee, progressFee, idBorrow)
VALUES (10000, 0, 1);

INSERT INTO JOIN_LISTREASON (idFee, idReason)
VALUES (1, 1);

EXEC ThongKeSoLuongMuon_TheoThuThu

EXEC ThemTienPhatMoi 15000, 5000, 1, 1

EXEC DanhSachDocGia_MuonQuaHan
EXEC CapNhatTrangThaiQuaHan
