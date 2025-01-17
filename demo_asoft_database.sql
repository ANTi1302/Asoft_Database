USE [Asoft_QLBanHang]
GO
/****** Object:  Table [dbo].[ChiTietDonHang]    Script Date: 5/16/2024 9:59:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChiTietDonHang](
	[MaHoaDon] [bigint] NOT NULL,
	[MaMatHang] [int] NOT NULL,
	[SoLuong] [int] NULL,
	[DonGia] [decimal](18, 2) NULL,
 CONSTRAINT [PK_ChiTietDonHang] PRIMARY KEY CLUSTERED 
(
	[MaHoaDon] ASC,
	[MaMatHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DonHang]    Script Date: 5/16/2024 9:59:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DonHang](
	[MaDonHang] [bigint] NOT NULL,
	[MaKhachHang] [int] NULL,
	[NgayBan] [date] NULL,
	[TongTien] [float] NULL,
	[NgayThangBan] [date] NULL,
 CONSTRAINT [PK__DonHang__129584AD320DDDF8] PRIMARY KEY CLUSTERED 
(
	[MaDonHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KhachHang]    Script Date: 5/16/2024 9:59:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KhachHang](
	[MaKhachHang] [int] NOT NULL,
	[TenKhachHang] [nvarchar](50) NULL,
	[DiaChi] [nvarchar](100) NULL,
	[SoDienThoai] [nvarchar](15) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaKhachHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MatHang]    Script Date: 5/16/2024 9:59:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MatHang](
	[MaMatHang] [int] NOT NULL,
	[TenMatHang] [nvarchar](50) NULL,
	[DonGia] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaMatHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChiTietDonHang]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietDonHang_DonHang] FOREIGN KEY([MaHoaDon])
REFERENCES [dbo].[DonHang] ([MaDonHang])
GO
ALTER TABLE [dbo].[ChiTietDonHang] CHECK CONSTRAINT [FK_ChiTietDonHang_DonHang]
GO
ALTER TABLE [dbo].[ChiTietDonHang]  WITH CHECK ADD  CONSTRAINT [FK_ChiTietDonHang_MatHang] FOREIGN KEY([MaMatHang])
REFERENCES [dbo].[MatHang] ([MaMatHang])
GO
ALTER TABLE [dbo].[ChiTietDonHang] CHECK CONSTRAINT [FK_ChiTietDonHang_MatHang]
GO
ALTER TABLE [dbo].[DonHang]  WITH CHECK ADD  CONSTRAINT [FK__DonHang__MaKhach__286302EC] FOREIGN KEY([MaKhachHang])
REFERENCES [dbo].[KhachHang] ([MaKhachHang])
GO
ALTER TABLE [dbo].[DonHang] CHECK CONSTRAINT [FK__DonHang__MaKhach__286302EC]
GO
/****** Object:  StoredProcedure [dbo].[GenerateOrderData]    Script Date: 5/16/2024 9:59:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GenerateOrderData]
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
/****** Object:  StoredProcedure [dbo].[GetTopCustomers]    Script Date: 5/16/2024 9:59:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetTopCustomers]
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
/****** Object:  StoredProcedure [dbo].[GetTopMinCustomers]    Script Date: 5/16/2024 9:59:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Hàm procedure GetTopCustomers lấy KH mau nhiều nhất từ... đến ...
	CREATE PROCEDURE [dbo].[GetTopMinCustomers]
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
        TongTien ASC;

    -- Lấy top 10 khách hàng mua nhiều tiền nhất
    SELECT TOP 10 *
    FROM #CustomerSpending
    ORDER BY TongTien ASC;

    -- Xóa bảng tạm
    DROP TABLE #CustomerSpending;

    SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[GetTopProducts]    Script Date: 5/16/2024 9:59:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetTopProducts]
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
/****** Object:  StoredProcedure [dbo].[SearchOrders]    Script Date: 5/16/2024 9:59:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SearchOrders]
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
GO
