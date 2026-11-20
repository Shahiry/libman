-- LibMan - MySQL 8.0.16+ ; tên bảng/cột theo biểu đồ CSDL (trang 34)
-- CẢNH BÁO: script xoá và tạo lại toàn bộ bảng.
CREATE DATABASE IF NOT EXISTS libman CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE libman;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS tblReturnSlipDetail, tblReturnSlip, tblBorrowSlipDetail, tblBorrowingSlip,
  tblDocumentImportNote, tblImportNote, tblDocumentForLend, tblDocument, tblLibraryCard,
  tblSupplier, tblManager, tblLibrarian, tblReader, tblUser;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE tblUser (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(255) NOT NULL UNIQUE,
  password    VARCHAR(255) NOT NULL,                 -- SHA-256 dạng hex
  fullName    VARCHAR(255) NOT NULL,
  email       VARCHAR(255),
  phoneNumber VARCHAR(255),
  avatar      VARCHAR(255),
  role        VARCHAR(255) NOT NULL,                 -- READER | LIBRARIAN | MANAGER
  CONSTRAINT chk_user_role CHECK (role IN ('READER','LIBRARIAN','MANAGER'))
) ENGINE=InnoDB;

CREATE TABLE tblReader (
  studentCode VARCHAR(255) NOT NULL UNIQUE,
  classCode   VARCHAR(255),
  tblUserid   INT PRIMARY KEY,
  CONSTRAINT fk_reader_user FOREIGN KEY (tblUserid) REFERENCES tblUser(id)
) ENGINE=InnoDB;

CREATE TABLE tblLibrarian (
  tblUserid INT PRIMARY KEY,
  CONSTRAINT fk_librarian_user FOREIGN KEY (tblUserid) REFERENCES tblUser(id)
) ENGINE=InnoDB;

CREATE TABLE tblManager (
  tblUserid INT PRIMARY KEY,
  CONSTRAINT fk_manager_user FOREIGN KEY (tblUserid) REFERENCES tblUser(id)
) ENGINE=InnoDB;

CREATE TABLE tblSupplier (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(255) NOT NULL,
  email       VARCHAR(255),
  phoneNumber VARCHAR(255),
  address     VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE tblLibraryCard (
  id                INT AUTO_INCREMENT PRIMARY KEY,   -- id chính là mã thẻ bạn đọc
  cardStatus        VARCHAR(255) NOT NULL DEFAULT 'ACTIVE',   -- ACTIVE | DISABLED
  dateOfIssue       DATE NOT NULL,
  expireDate        DATE NOT NULL,
  tblReadertblUserid INT NOT NULL UNIQUE,             -- 1 bạn đọc tối đa 1 thẻ
  CONSTRAINT chk_card_status CHECK (cardStatus IN ('ACTIVE','DISABLED')),
  CONSTRAINT fk_card_reader FOREIGN KEY (tblReadertblUserid) REFERENCES tblReader(tblUserid)
) ENGINE=InnoDB;

CREATE TABLE tblDocument (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  coverPicture   VARCHAR(255),
  name           VARCHAR(255) NOT NULL,
  type           VARCHAR(255),
  author         VARCHAR(255),
  publicYear     INT,
  publicHouse    VARCHAR(255),
  description    TEXT NULL,
  quantity       INT NOT NULL DEFAULT 0,
  borrowDuration INT NOT NULL DEFAULT 14,             -- số ngày được mượn
  INDEX idx_document_name (name)
) ENGINE=InnoDB;

CREATE TABLE tblDocumentForLend (
  id             INT AUTO_INCREMENT PRIMARY KEY,      -- id chính là mã tài liệu
  lendingStatus  VARCHAR(255) NOT NULL DEFAULT 'AVAILABLE',  -- AVAILABLE | BORROWED | UNAVAILABLE
  physicalStatus VARCHAR(255) NOT NULL DEFAULT 'NORMAL',     -- NORMAL | WARPED | TORN
  tblDocumentid  INT NOT NULL,
  CONSTRAINT chk_lend_status CHECK (lendingStatus IN ('AVAILABLE','BORROWED','UNAVAILABLE')),
  CONSTRAINT chk_phys_status CHECK (physicalStatus IN ('NORMAL','WARPED','TORN')),
  CONSTRAINT fk_dfl_document FOREIGN KEY (tblDocumentid) REFERENCES tblDocument(id)
) ENGINE=InnoDB;

CREATE TABLE tblImportNote (
  id                 INT AUTO_INCREMENT PRIMARY KEY,
  totalCost          DECIMAL(12,2) NOT NULL DEFAULT 0,
  paymentMethod      VARCHAR(255),
  paymentStatus      VARCHAR(255),
  tblSupplierid      INT NOT NULL,
  tblLibrariantblUserid INT NOT NULL,
  CONSTRAINT fk_in_supplier  FOREIGN KEY (tblSupplierid) REFERENCES tblSupplier(id),
  CONSTRAINT fk_in_librarian FOREIGN KEY (tblLibrariantblUserid) REFERENCES tblLibrarian(tblUserid)
) ENGINE=InnoDB;

CREATE TABLE tblDocumentImportNote (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  price           DECIMAL(12,2) NOT NULL,
  quantity        INT NOT NULL,
  tblImportNoteid INT NOT NULL,
  tblDocumentid   INT NOT NULL,
  CONSTRAINT fk_din_note FOREIGN KEY (tblImportNoteid) REFERENCES tblImportNote(id),
  CONSTRAINT fk_din_doc  FOREIGN KEY (tblDocumentid)   REFERENCES tblDocument(id)
) ENGINE=InnoDB;

CREATE TABLE tblBorrowingSlip (
  id                    INT AUTO_INCREMENT PRIMARY KEY,   -- id chính là mã phiếu mượn
  borrowDate            DATE NOT NULL,
  tblReadertblUserid    INT NOT NULL,
  tblLibrariantblUserid INT NOT NULL,
  CONSTRAINT fk_bs_reader    FOREIGN KEY (tblReadertblUserid)    REFERENCES tblReader(tblUserid),
  CONSTRAINT fk_bs_librarian FOREIGN KEY (tblLibrariantblUserid) REFERENCES tblLibrarian(tblUserid)
) ENGINE=InnoDB;

CREATE TABLE tblBorrowSlipDetail (
  id                   INT AUTO_INCREMENT PRIMARY KEY,
  returnDeadline       DATE NOT NULL,
  tblBorrowingSlipid   INT NOT NULL,
  tblDocumentForLendid INT NOT NULL,
  CONSTRAINT fk_bsd_slip FOREIGN KEY (tblBorrowingSlipid)   REFERENCES tblBorrowingSlip(id),
  CONSTRAINT fk_bsd_dfl  FOREIGN KEY (tblDocumentForLendid) REFERENCES tblDocumentForLend(id)
) ENGINE=InnoDB;

CREATE TABLE tblReturnSlip (
  id                    INT AUTO_INCREMENT PRIMARY KEY,
  returnDate            DATE NOT NULL,
  totalExtraFee         DECIMAL(12,2) NULL,
  tblLibrariantblUserid INT NOT NULL,
  tblReadertblUserid    INT NOT NULL,
  CONSTRAINT fk_rs_librarian FOREIGN KEY (tblLibrariantblUserid) REFERENCES tblLibrarian(tblUserid),
  CONSTRAINT fk_rs_reader    FOREIGN KEY (tblReadertblUserid)    REFERENCES tblReader(tblUserid)
) ENGINE=InnoDB;

CREATE TABLE tblReturnSlipDetail (
  id                   INT AUTO_INCREMENT PRIMARY KEY,
  documentReturnStatus VARCHAR(255),
  delayFee             DECIMAL(12,2) NULL,
  damageFee            DECIMAL(12,2) NULL,
  tblReturnSlipid      INT NOT NULL,
  tblDocumentForLendid INT NOT NULL,
  tblBorrowSlipDetailid INT NOT NULL,
  CONSTRAINT fk_rsd_slip FOREIGN KEY (tblReturnSlipid)       REFERENCES tblReturnSlip(id),
  CONSTRAINT fk_rsd_dfl  FOREIGN KEY (tblDocumentForLendid)  REFERENCES tblDocumentForLend(id),
  CONSTRAINT fk_rsd_bsd  FOREIGN KEY (tblBorrowSlipDetailid) REFERENCES tblBorrowSlipDetail(id)
) ENGINE=InnoDB;

-- ===================== DỮ LIỆU MẪU (mật khẩu tất cả: 123456) =====================
-- tblUser.id: 1 thuthu1, 2 quanly1, 3 bandoc1, 4 bandoc2, 5 bandoc3
INSERT INTO tblUser (username,password,fullName,email,phoneNumber,avatar,role) VALUES
 ('thuthu1',SHA2('123456',256),'Nguyễn Thị Thủ Thư','thuthu1@libman.local','0900000001',NULL,'LIBRARIAN'),
 ('quanly1',SHA2('123456',256),'Trần Văn Quản Lý','quanly1@libman.local','0900000002',NULL,'MANAGER'),
 ('bandoc1',SHA2('123456',256),'Bạn đọc B','bandoc1@libman.local','0900000003',NULL,'READER'),
 ('bandoc2',SHA2('123456',256),'Bạn đọc thẻ hết hạn','bandoc2@libman.local','0900000004',NULL,'READER'),
 ('bandoc3',SHA2('123456',256),'Bạn đọc thẻ bị khoá','bandoc3@libman.local','0900000005',NULL,'READER');
INSERT INTO tblLibrarian (tblUserid) VALUES (1);
INSERT INTO tblManager   (tblUserid) VALUES (2);
INSERT INTO tblReader (studentCode,classCode,tblUserid) VALUES
 ('B23DCCN003','D23CQCN01-B',3),('B23DCCN004','D23CQCN01-B',4),('B23DCCN005','D23CQCN01-B',5);
-- Mã thẻ (tblLibraryCard.id): 1 còn hạn, 2 hết hạn, 3 bị vô hiệu hoá
INSERT INTO tblLibraryCard (cardStatus,dateOfIssue,expireDate,tblReadertblUserid) VALUES
 ('ACTIVE','2024-09-01','2030-09-01',3),
 ('ACTIVE','2020-09-01','2021-09-01',4),
 ('DISABLED','2024-09-01','2030-09-01',5);

INSERT INTO tblDocument (coverPicture,name,type,author,publicYear,publicHouse,description,borrowDuration) VALUES
 (NULL,'Giải tích hàm một biến số','Giáo trình','Phạm Ngọc Anh',2013,'HV Công nghệ Bưu chính Viễn thông','Giáo trình giải tích 1 của HVCN Bưu Chính Viễn Thông',30),
 (NULL,'Giải tích 1 (2005)','Giáo trình','Phạm Ngọc Anh',2005,'HV Công nghệ Bưu chính Viễn thông','Giáo trình giải tích 1 (bản 2005)',30),
 (NULL,'Giải tích 2 (2011)','Giáo trình','Phạm Ngọc Anh',2011,'HV Công nghệ Bưu chính Viễn thông','Giáo trình giải tích 2',30),
 (NULL,'Cơ sở dữ liệu','Sách','Nguyễn Văn A',2018,'NXB Giáo dục','Nhập môn cơ sở dữ liệu quan hệ',14);

-- Mã tài liệu (tblDocumentForLend.id): 1 bình thường, 2 cong vênh, 3 rách (không cho mượn),
-- 4 và 5 bình thường, 6..19 là 14 bản "Cơ sở dữ liệu" (để thử giới hạn 13)
INSERT INTO tblDocumentForLend (lendingStatus,physicalStatus,tblDocumentid) VALUES
 ('AVAILABLE','NORMAL',1),('AVAILABLE','WARPED',1),('UNAVAILABLE','TORN',1),
 ('AVAILABLE','NORMAL',2),('AVAILABLE','NORMAL',3);
INSERT INTO tblDocumentForLend (lendingStatus,physicalStatus,tblDocumentid)
  SELECT 'AVAILABLE','NORMAL',4 FROM
  (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7
   UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14) x;

UPDATE tblDocument d SET quantity =
  (SELECT COUNT(*) FROM tblDocumentForLend f WHERE f.tblDocumentid=d.id AND f.lendingStatus='AVAILABLE');
