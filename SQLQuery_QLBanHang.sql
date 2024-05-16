

-- Phát sinh dữ liệu random cho bảng Khách hàng
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO KhachHang (MaKhachHang, TenKhachHang, DiaChi, SoDienThoai)
    VALUES (@i, CONCAT('Khach Hang ', @i), CONCAT('Dia Chi ', @i), CONCAT('012345678', RIGHT('000' + CAST(@i AS NVARCHAR(3)), 3)));
    SET @i = @i + 1;
END

-- Phát sinh dữ liệu random cho bảng Mặt hàng
DECLARE @i INT = 1;

WHILE @i <= 100
BEGIN
    INSERT INTO MatHang (MaMatHang, TenMatHang, DonGia)
    VALUES (@i, CONCAT('Mat Hang ', @i), ROUND(RAND() * 100000, 2));
    SET @i = @i + 1;
END

-- Phát sinh dữ liệu random cho bảng Đơn hàng
-- Tạo stored procedure để phát sinh dữ liệu cho DonHang và ChiTietDonHang
CREATE PROCEDURE GenerateOrderData
AS
BEGIN
    DECLARE @startDate DATETIME = '2024-03-01';
    DECLARE @endDate DATETIME = '2024-04-30';
    DECLARE @numOrders INT = 1000000;
    DECLARE @orderId BIGINT = 1;
    DECLARE @randomCustomerId INT;
    DECLARE @randomDate DATETIME;
    DECLARE @totalAmount FLOAT;
    DECLARE @maxItemsPerOrder INT = 5; -- Số lượng mặt hàng tối đa mỗi đơn hàng

    -- Bắt đầu transaction
    BEGIN TRANSACTION

    -- Vòng lặp để tạo dữ liệu cho bảng DonHang
    WHILE @orderId <= @numOrders
    BEGIN
        SET @randomCustomerId = FLOOR(RAND() * 100) + 1;
        SET @randomDate = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % 86400, DATEADD(DAY, ABS(CHECKSUM(NEWID())) % DATEDIFF(DAY, @startDate, @endDate), @startDate));
        SET @totalAmount = 0;

        -- Thêm dữ liệu vào bảng DonHang
        INSERT INTO DonHang (MaDonHang, MaKhachHang, NgayBan, TongTien)
        VALUES (@orderId, @randomCustomerId, @randomDate, @totalAmount);

        -- Tạo chi tiết đơn hàng cho mỗi đơn hàng
        DECLARE @numItems INT = FLOOR(RAND() * @maxItemsPerOrder) + 1;
        DECLARE @itemIndex INT = 1;

        WHILE @itemIndex <= @numItems
        BEGIN
            DECLARE @randomItemId INT = FLOOR(RAND() * 100) + 1;
            DECLARE @randomQuantity INT = FLOOR(RAND() * 10) + 1;
            DECLARE @randomPrice DECIMAL(18, 2) = ROUND(RAND() * 1000, 2);

            -- Thêm dữ liệu vào bảng ChiTietDonHang
            INSERT INTO ChiTietDonHang (MaHoaDon, MaMatHang, SoLuong, DonGia)
            VALUES (@orderId, @randomItemId, @randomQuantity, @randomPrice);

            -- Cập nhật tổng tiền cho đơn hàng
            SET @totalAmount = @totalAmount + (@randomQuantity * @randomPrice);

            SET @itemIndex = @itemIndex + 1;
        END

        -- Cập nhật tổng tiền vào bảng DonHang
        UPDATE DonHang
        SET TongTien = @totalAmount
        WHERE MaDonHang = @orderId;

        SET @orderId = @orderId + 1;

        -- Commit mỗi 10000 đơn hàng để giảm tải cho transaction
        IF @orderId % 10000 = 0
        BEGIN
            COMMIT TRANSACTION;
            BEGIN TRANSACTION;
        END
    END

    -- Commit transaction cuối cùng
    COMMIT TRANSACTION;
END
GO
-- Tạo Table Index cho đơn hàng theo năm, tháng
ALTER TABLE DonHang
ADD NgayThangBan DATE;

UPDATE DonHang
SET NgayThangBan = DATEFROMPARTS(YEAR(NgayBan), MONTH(NgayBan), 1);

CREATE INDEX IX_DonHang_NgayThangBan
ON DonHang (NgayThangBan);


-- Gọi stored procedure để tạo dữ liệu
EXEC GenerateOrderData;

CREATE PROCEDURE SearchOrders
    @MaDonHang BIGINT = NULL,
    @MaKhachHang INT = NULL,
    @TenKhachHang NVARCHAR(100) = NULL,
    @MaMatHang INT = NULL,
    @TenMatHang NVARCHAR(100) = NULL,
    @TuNgay DATETIME = NULL,
    @DenNgay DATETIME = NULL
AS
BEGIN
    SELECT DH.MaDonHang, KH.MaKhachHang, KH.TenKhachHang, MH.MaMatHang, MH.TenMatHang, CDH.SoLuong, CDH.DonGia, DH.NgayBan
    FROM DonHang DH
    INNER JOIN KhachHang KH ON DH.MaKhachHang = KH.MaKhachHang
    INNER JOIN ChiTietDonHang CDH ON DH.MaDonHang = CDH.MaHoaDon
    INNER JOIN MatHang MH ON CDH.MaMatHang = MH.MaMatHang
    WHERE (@MaDonHang IS NULL OR DH.MaDonHang = @MaDonHang)
    AND (@MaKhachHang IS NULL OR KH.MaKhachHang = @MaKhachHang)
    AND (@TenKhachHang IS NULL OR KH.TenKhachHang LIKE '%' + @TenKhachHang + '%')
    AND (@MaMatHang IS NULL OR MH.MaMatHang = @MaMatHang)
    AND (@TenMatHang IS NULL OR MH.TenMatHang LIKE '%' + @TenMatHang + '%')
    AND (@TuNgay IS NULL OR DH.NgayBan >= @TuNgay)
    AND (@DenNgay IS NULL OR DH.NgayBan <= @DenNgay);
END

-- Test

-- Test 1: Tìm kiếm theo mã đơn hàng
EXEC SearchOrders @MaDonHang = 1;

-- Test 2: Tìm kiếm theo mã khách hàng
EXEC SearchOrders @MaKhachHang = 10;

-- Test 3: Tìm kiếm theo tên khách hàng
EXEC SearchOrders @TenKhachHang = N'Khach Hang 10';

-- Test 4: Tìm kiếm theo mã mặt hàng
EXEC SearchOrders @MaMatHang = 5;

-- Test 5: Tìm kiếm theo tên mặt hàng
EXEC SearchOrders @TenMatHang = N'Mat Hang 5';

-- Test 6: Tìm kiếm theo khoảng thời gian
EXEC SearchOrders @TuNgay = '2024-03-01', @DenNgay = '2024-03-31';

-- Test 7: Kết hợp nhiều điều kiện tìm kiếm
EXEC SearchOrders 
    @MaKhachHang = 10,
    @TenMatHang = N'Mat Hang 5',
    @TuNgay = '2024-03-01', 
    @DenNgay = '2024-03-31';

-- Hàm procedure GetTopCustomers lấy KH mau nhiều nhất từ... đến ...
	CREATE PROCEDURE GetTopCustomers
    @TuNgay DATE = NULL,
    @DenNgay DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm để lưu kết quả trung gian
    CREATE TABLE #CustomerSpending (
        MaKhachHang INT,
        TenKhachHang NVARCHAR(100),
        TongTien DECIMAL(18, 2)
    );

    -- Chèn dữ liệu vào bảng tạm dựa trên điều kiện thời gian
    INSERT INTO #CustomerSpending (MaKhachHang, TenKhachHang, TongTien)
    SELECT
        KH.MaKhachHang,
        KH.TenKhachHang,
        SUM(DH.TongTien) AS TongTien
    FROM
        DonHang DH
        INNER JOIN KhachHang KH ON DH.MaKhachHang = KH.MaKhachHang
    WHERE
        (@TuNgay IS NULL OR DH.NgayThangBan >= @TuNgay) AND
        (@DenNgay IS NULL OR DH.NgayThangBan <= @DenNgay)
    GROUP BY
        KH.MaKhachHang,
        KH.TenKhachHang
    ORDER BY
        TongTien DESC;

    -- Lấy top 10 khách hàng mua nhiều tiền nhất
    SELECT TOP 10 *
    FROM #CustomerSpending
    ORDER BY TongTien DESC;

    -- Xóa bảng tạm
    DROP TABLE #CustomerSpending;

    SET NOCOUNT OFF;
END
GO
-- Test
-- Test hàm tìm top KH mua nhiều nhất từ ngày này đến ngày
EXEC GetTopCustomers @TuNgay = '2024-03-01', @DenNgay = '2024-04-30';

-- Tạo stored procedure lấy top 10 mặt hàng được mua nhiều nhất trong một tháng 

CREATE PROCEDURE GetTopProducts
    @Thang INT,
    @Nam INT,
    @TopType NVARCHAR(3) -- 'MAX' hoặc 'MIN' để chỉ định lấy mặt hàng nhiều nhất hoặc ít nhất
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm để lưu kết quả trung gian
    CREATE TABLE #ProductSales (
        MaMatHang INT,
        TenMatHang NVARCHAR(100),
        TongSoLuong INT
    );

    -- Chèn dữ liệu vào bảng tạm dựa trên tháng và năm
    INSERT INTO #ProductSales (MaMatHang, TenMatHang, TongSoLuong)
    SELECT
        MH.MaMatHang,
        MH.TenMatHang,
        SUM(CTDH.SoLuong) AS TongSoLuong
    FROM
        ChiTietDonHang CTDH
        INNER JOIN DonHang DH ON CTDH.MaHoaDon = DH.MaDonHang
        INNER JOIN MatHang MH ON CTDH.MaMatHang = MH.MaMatHang
    WHERE
        MONTH(DH.NgayBan) = @Thang AND
        YEAR(DH.NgayBan) = @Nam
    GROUP BY
        MH.MaMatHang,
        MH.TenMatHang;

    -- Lấy top 10 mặt hàng dựa trên yêu cầu 'MAX' hoặc 'MIN'
    IF @TopType = 'MAX'
    BEGIN
        SELECT TOP 10 *
        FROM #ProductSales
        ORDER BY TongSoLuong DESC;
    END
    ELSE IF @TopType = 'MIN'
    BEGIN
        SELECT TOP 10 *
        FROM #ProductSales
        ORDER BY TongSoLuong ASC;
    END

    -- Xóa bảng tạm
    DROP TABLE #ProductSales;

    SET NOCOUNT OFF;
END
GO

-- Test
-- Tìm top 10 mặt hàng được mua nhiều nhất trong tháng 3 năm 2024
EXEC GetTopProducts @Thang = 3, @Nam = 2024, @TopType = 'MAX';
-- Tìm top 10 mặt hàng được mua ít nhất trong tháng 3 năm 2024
EXEC GetTopProducts @Thang = 3, @Nam = 2024, @TopType = 'MIN';
