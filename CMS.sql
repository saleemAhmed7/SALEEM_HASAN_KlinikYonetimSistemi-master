CREATE DATABASE CMS;
GO


USE CMS;
GO


CREATE TABLE [User] (
    user_id INT PRIMARY KEY,
    user_username VARCHAR(50) NOT NULL,
    user_password VARCHAR(100) NOT NULL
);
GO


CREATE TABLE [Account] (
    account_id INT PRIMARY KEY,
    account_user_id INT NULL,
    account_name VARCHAR(100) NOT NULL,
    account_dob DATE NULL,
    account_creation_date DATETIME NOT NULL,
    account_notes VARCHAR(200) NULL,
    account_type INT NOT NULL,
    account_phone VARCHAR(20) NULL,
    FOREIGN KEY (account_user_id) REFERENCES [User](user_id) ON DELETE SET NULL ON UPDATE CASCADE
);
GO

CREATE TABLE [Reservation] (
    reservation_id INT PRIMARY KEY,
    reservation_patient_id INT NOT NULL,
    reservation_secretary_id INT NOT NULL,
    reservation_visit_date DATE NOT NULL,
    reservation_visit_slot INT NOT NULL,
    reservation_date DATETIME NOT NULL,
    FOREIGN KEY (reservation_patient_id) REFERENCES [Account](account_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (reservation_secretary_id) REFERENCES [Account](account_id) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

CREATE TABLE [Visit] (
    visit_id INT PRIMARY KEY,
    visit_reservation_id INT NOT NULL,
    visit_doctor_id INT NOT NULL,
    visit_date DATE NOT NULL,
    visit_reasons VARCHAR(200) NULL,
    visit_diagnosis VARCHAR(200) NOT NULL,
    visit_notes VARCHAR(200) NULL,
    FOREIGN KEY (visit_reservation_id) REFERENCES [Reservation](reservation_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (visit_doctor_id) REFERENCES [Account](account_id) ON DELETE CASCADE ON UPDATE CASCADE
);

GO

--	sorgular
DECLARE @KULLANICI_ID INT = 1; 
SELECT * FROM [Account] WHERE account_user_id = @KULLANICI_ID;

DECLARE @HESAP_ID INT = 2;
SELECT * FROM [Reservation] WHERE reservation_patient_id = @HESAP_ID;


DECLARE @RANDUVU_ID INT = 3; 
SELECT * FROM [Visit] WHERE visit_reservation_id = @RANDUVU_ID;


DECLARE @HESAP_ID_FOR_VISITS INT = 4; 
SELECT * FROM [Visit] WHERE visit_doctor_id = @HESAP_ID_FOR_VISITS;


DECLARE @RANDUVU_ID_INFO INT = 5; 
SELECT * FROM [Reservation]
JOIN [Visit] ON [Reservation].reservation_id = [Visit].visit_reservation_id
WHERE [Reservation].reservation_id = @RANDUVU_ID_INFO;



--Stored Procedures
CREATE PROCEDURE sp_AddUser
    @Username VARCHAR(50),
    @Password VARCHAR(100)
AS
BEGIN
    INSERT INTO [User] ([user_username], [user_password])
    VALUES (@Username, @Password);
END;
GO




CREATE PROCEDURE sp_AddAccount
    @UserID INT,
    @Name VARCHAR(100),
    @DOB DATE,
    @CreationDate DATETIME,
    @Notes VARCHAR(200),
    @Type INT,
    @Phone VARCHAR(20)
AS
BEGIN
    INSERT INTO [Account] (account_user_id, account_name, account_dob, account_creation_date, account_notes, account_type, account_phone)
    VALUES (@UserID, @Name, @DOB, @CreationDate, @Notes, @Type, @Phone);
END;
GO


CREATE PROCEDURE sp_AddReservation
    @PatientID INT,
    @SecretaryID INT,
    @VisitDate DATE,
    @VisitSlot INT,
    @ReservationDate DATETIME
AS
BEGIN
    INSERT INTO [Reservation] (reservation_patient_id, reservation_secretary_id, reservation_visit_date, reservation_visit_slot, reservation_date)
    VALUES (@PatientID, @SecretaryID, @VisitDate, @VisitSlot, @ReservationDate);
END;
GO


CREATE PROCEDURE sp_AddVisit
    @ReservationID INT,
    @DoctorID INT,
    @VisitDate DATE,
    @Reasons VARCHAR(200),
    @Diagnosis VARCHAR(200),
    @Notes VARCHAR(200)
AS
BEGIN
    INSERT INTO [Visit] (visit_reservation_id, visit_doctor_id, visit_date, visit_reasons, visit_diagnosis, visit_notes)
    VALUES (@ReservationID, @DoctorID, @VisitDate, @Reasons, @Diagnosis, @Notes);
END;
GO

--	kullanıcı tanımlı fonksiyonlar 

CREATE FUNCTION dbo.fn_GetTotalAppointments(@PatientID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalAppointments INT;
    SELECT @TotalAppointments = COUNT(*) 
    FROM [Reservation] 
    WHERE reservation_patient_id = @PatientID;
    RETURN @TotalAppointments;
END;
GO


CREATE FUNCTION dbo.fn_GetLastVisitDate(@AccountID INT)
RETURNS DATE
AS
BEGIN
    DECLARE @LastVisitDate DATE;
    SELECT TOP 1 @LastVisitDate = visit_date
    FROM [Visit] 
    WHERE visit_doctor_id = @AccountID
    ORDER BY visit_date DESC;
    RETURN @LastVisitDate;
END;
GO


CREATE FUNCTION dbo.fn_GetTotalVisits(@AccountID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalVisits INT;
    SELECT @TotalVisits = COUNT(*) 
    FROM [Visit] 
    WHERE visit_doctor_id = @AccountID;
    RETURN @TotalVisits;
END;
GO

--Trigger


CREATE TRIGGER UpdateAccountNotesOnReservation
ON [Reservation]
AFTER INSERT
AS
BEGIN
    UPDATE [Account]
    SET account_notes = 'Randevu Oluşturuldu'
    WHERE account_id IN (SELECT reservation_patient_id FROM INSERTED)
END;
GO


CREATE TRIGGER UpdateReservationAndAccountOnVisit
ON [Visit]
AFTER INSERT
AS
BEGIN
    UPDATE [Reservation]
    SET reservation_date = GETDATE()
    WHERE reservation_id IN (SELECT visit_reservation_id FROM INSERTED)

    UPDATE [Account]
    SET account_notes = 'Ziyaret Kaydı Eklenmiş'
    WHERE account_id IN (SELECT reservation_patient_id FROM [Reservation] WHERE reservation_id IN (SELECT visit_reservation_id FROM INSERTED))
END;
GO


CREATE TRIGGER UpdateAccountAndReservationOnCancellation
ON [Reservation]
AFTER DELETE
AS
BEGIN
    UPDATE [Account]
    SET account_notes = 'Randevu İptal Edildi'
    WHERE account_id IN (SELECT reservation_patient_id FROM DELETED)

    UPDATE [Reservation]
    SET reservation_date = NULL
    WHERE reservation_id IN (SELECT reservation_id FROM DELETED)
END;
GO



