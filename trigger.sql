-- 1. Ngày hết hạn thẻ phải lớn hơn ngày cấp
CREATE TRIGGER trg_CheckExpireCard
ON THETHUVIEN
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE expireCard <= dateCard
    )
    BEGIN
        RAISERROR(N'Ngày hết hạn thẻ phải lớn hơn ngày cấp!', 16, 1);
        ROLLBACK;
    END
END;
-- 2. Email người dùng không được trùng
CREATE TRIGGER trg_CheckUniqueEmailUser
ON USER_ACCOUNT
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT emailUser
        FROM USER_ACCOUNT
        GROUP BY emailUser
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR(N'Email người dùng đã tồn tại!', 16, 1);
        ROLLBACK;
    END
END;
-- 3. Số điện thoại phải đủ 10 số và không trùng
CREATE TRIGGER trg_CheckPhoneUser
ON USER_ACCOUNT
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE LEN(phoneUser) != 10
    )
    BEGIN
        RAISERROR(N'Số điện thoại phải đủ 10 số!', 16, 1);
        ROLLBACK;
    END

    IF EXISTS (
        SELECT phoneUser FROM USER_ACCOUNT
        GROUP BY phoneUser
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR(N'Số điện thoại đã tồn tại!', 16, 1);
        ROLLBACK;
    END
END;
-- 4. Ngày trả sách phải sau ngày mượn
CREATE TRIGGER trg_CheckReturnDate
ON JOIN_BOOKBORROW
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE ReturnDate < StartDate
    )
    BEGIN
        RAISERROR(N'Ngày trả phải sau hoặc bằng ngày mượn!', 16, 1);
        ROLLBACK;
    END
END;
END;
-- 5. Phạt không âm & không vượt quá yêu cầu
CREATE TRIGGER trg_CheckFeeProgress
ON TIENPHAT
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE progressFee < 0 OR progressFee > requiredFee
    )
    BEGIN
        RAISERROR(N'Tiền phạt không hợp lệ!', 16, 1);
        ROLLBACK;
    END
END;
-- 6. Cập nhật tiền phạt khi thêm lý do mới
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
