use QLTV
go

-- TAG 
INSERT INTO TAG (nameTag) VALUES 
(N'Khoa học viễn tưởng'), (N'Lịch sử Việt Nam'), (N'Giáo dục'), (N'Thiếu nhi'), (N'Tiểu thuyết tình cảm');

-- SACH
INSERT INTO SACH (idBook, nameBook, typeBook, authorBook, publisherBook, dateBook, formatBook, noteBook, statusBook, imageBook) VALUES
('S001', N'Dưới bóng cây gạo', N'Văn học', N'Trịnh Công Sơn', N'NXB Trẻ', '2021-05-20', N'Bìa mềm', NULL, N'Còn hàng', 0x),
('S002', N'Lịch sử cận đại Việt Nam', N'Lịch sử', N'Nguyễn Văn Hòa', N'NXB Giáo Dục', '2018-09-15', N'Bìa cứng', NULL, N'Còn hàng', 0x),
('S003', N'Vật lý lượng tử cơ bản', N'Khoa học', N'Phạm Quang Vinh', N'NXB Khoa Học Tự Nhiên', '2022-03-01', N'Sách điện tử', N'Phiên bản đầy đủ', N'Đang mượn', 0x),
('S004', N'Cổ tích Việt Nam', N'Thiếu nhi', N'Tổng hợp', N'NXB Kim Đồng', '2020-11-11', N'Bìa cứng', NULL, N'Còn hàng', 0x);

-- SUUTAP (Bộ sưu tập)
INSERT INTO SUUTAP (idCollection, nameCollection, descriptionCollection, imageCollection) VALUES
('ST01', N'Sách bán chạy', N'Những đầu sách được yêu thích nhất năm', 0x),
('ST02', N'Kho học thuật', N'Các tài liệu nghiên cứu tiêu biểu', 0x);

-- ACCOUNT_USER (Người dùng)
INSERT INTO ACCOUNT_USER (nameUser, emailUser, passwordUser) VALUES
(N'Nguyễn Văn A', 'nguyenvana@gmail.com', 'matkhau123'),
(N'Trần Thị B', 'tranthib@yahoo.com', 'baomat456'),
(N'Lê Quang Cường', 'cuongle@outlook.com', 'cuongpass789');

-- JOIN_LISTTAGBOOK
INSERT INTO JOIN_LISTTAGBOOK (idBook, idTag) VALUES
('S001', 5),  -- Tiểu thuyết tình cảm
('S002', 2),  -- Lịch sử Việt Nam
('S003', 1),  -- Khoa học viễn tưởng
('S004', 4);  -- Thiếu nhi

-- JOIN_LISTCOLLECTION
INSERT INTO JOIN_LISTCOLLECTION (idCollection, idBook) VALUES
('ST01', 'S001'),
('ST01', 'S002'),
('ST02', 'S003');

-- THETHUVIEN
INSERT INTO THETHUVIEN (idCard, nameCard, emailCard, addressCard, phoneCard, dateCard, startCard, expireCard, statusCard, idBorrow) VALUES
('TV00000123', N'Nguyễn Văn A', 'nguyenvana@gmail.com', N'12 Nguyễn Trãi, Hà Nội', '0987654321', '2024-01-01', '2024-01-01', '2026-01-01', N'Đang hoạt động', NULL),
('TV00000456', N'Trần Thị B', 'tranthib@yahoo.com', N'88 Lý Tự Trọng, TP.HCM', '0912345678', '2024-03-15', '2024-03-15', '2026-03-15', N'Đang hoạt động', NULL);

-- DOCGIA
INSERT INTO DOCGIA (statusMember, idCard, idUser) VALUES
(N'Hoạt động bình thường', 'TV00000123', 1),
(N'Quá hạn trả sách', 'TV00000456', 2);

-- THUTHU
INSERT INTO THUTHU (roleLibrarian, hireLibrarian, statusLibrarian, idUser) VALUES
(N'Thủ thư chính', '2023-01-10', N'Đang làm việc', 3);

-- MUONTRA
INSERT INTO MUONTRA (dateBorrow, statusBorrow, idCard, idLibrarian) VALUES
('2025-07-01', N'Đang mượn', 'TV00000123', 1),
('2025-07-15', N'Đã trả', 'TV00000456', 1);

-- JOIN_BOOKBORROW
INSERT INTO JOIN_BOOKBORROW (idBorrow, idBook, startDate, returnDate, statusBookBorrow) VALUES
(1, 'S003', '2025-07-01', '2025-07-20', N'Chưa trả'),
(2, 'S002', '2025-07-15', '2025-07-22', N'Đã trả');

-- TIENPHAT
INSERT INTO TIENPHAT (requiredFee, progressFee, idBorrow) VALUES
(10000, 5000, 1),
(0, 0, 2);

-- TIENPHATLYDO
INSERT INTO TIENPHATLYDO (nameReason, feeReason) VALUES
(N'Làm rách sách', 10000),
(N'Trả trễ', 5000);

-- JOIN_LISTREASON
INSERT INTO JOIN_LISTREASON (idFee, idReason) VALUES
(1, 1),
(1, 2);

INSERT INTO LOG_DELETEJOIN_LISTTAGBOOK (idBook, idTag, dateDeleted)
VALUES 
('S001', 5, '2025-07-24'),  -- 'Tiểu thuyết tình cảm'
('S003', 1, '2025-07-24'),  -- 'Khoa học viễn tưởng'
('S004', 4, '2025-07-24');  -- 'Thiếu nhi'

INSERT INTO LOG_DELETETAG (idTag, nameTag, dateDeleted)
VALUES
(5, N'Tiểu thuyết tình cảm', '2025-07-24'),
(1, N'Khoa học viễn tưởng', '2025-07-24'),
(4, N'Thiếu nhi', '2025-07-24');

