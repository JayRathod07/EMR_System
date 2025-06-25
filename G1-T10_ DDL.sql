-- ============================
-- Table: Patient
-- ============================
CREATE TABLE Patient (
    PatientID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Age INT,
    Gender VARCHAR(50),
    EmergencyContact VARCHAR(255),
    Email VARCHAR(255),
    ContactNumber VARCHAR(20),
    DateOfBirth DATE,
    InsuranceDetails VARCHAR(255)
);

-- ============================
-- Table: PatientMedicalHistory
-- ============================
CREATE TABLE PatientMedicalHistory (
    PatientID INT NOT NULL,
    ConditionName VARCHAR(255) NOT NULL,
    DiagnosisDate DATE NOT NULL,
    DiagnosisDetails TEXT,
    TreatmentDetails TEXT,
    Status VARCHAR(50) CHECK (Status IN ('Active', 'Resolved', 'Chronic', 'In Treatment')),
    PRIMARY KEY (PatientID, ConditionName, DiagnosisDate),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON DELETE CASCADE
);

-- ============================
-- Table: Doctor
-- ============================
CREATE TABLE Doctor (
    DoctorID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Specialization VARCHAR(255),
    EmergencyContact VARCHAR(255),
    Email VARCHAR(255)
);

-- ============================
-- Table: Pharmacist
-- ============================
CREATE TABLE Pharmacist (
    PharmacistID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    ContactInformation VARCHAR(255)
);

-- ============================
-- Table: Medicine
-- ============================
CREATE TABLE Medicine (
    MedicineID VARCHAR(255) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    StockQuantity INT,
    ExpiryDate DATE,
    ReorderThreshold INT,
    PharmacistID INT NOT NULL,
    Composition VARCHAR(512) NOT NULL,
    FOREIGN KEY (PharmacistID) REFERENCES Pharmacist(PharmacistID) ON DELETE CASCADE
);

-- ============================
-- Table: Appointment
-- ============================
CREATE TABLE Appointment (
    AppointmentID SERIAL PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    DateTime TIMESTAMP NOT NULL,
    Type VARCHAR(50) CHECK (Type IN ('Surgery', 'OPD', 'Follow-up')),
    Status VARCHAR(50) CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled')),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE
);

-- ============================
-- Table: Prescription
-- ============================
CREATE TABLE Prescription(
    PrescriptionID SERIAL PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    FollowUpDate DATE,
    AdditionalNotes TEXT,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE
);

-- ============================
-- Table: PrescriptionMedicine
-- ============================
CREATE TABLE PrescriptionMedicine (
    PrescriptionID INT NOT NULL,
    MedicineID VARCHAR(255) NOT NULL,
    Dosage VARCHAR(255) NOT NULL,
    PRIMARY KEY (PrescriptionID, MedicineID),
    FOREIGN KEY (PrescriptionID) REFERENCES Prescription(PrescriptionID) ON DELETE CASCADE,
    FOREIGN KEY (MedicineID) REFERENCES Medicine(MedicineID) ON DELETE CASCADE
);

-- ============================
-- Table: LabReport
-- ============================
CREATE TABLE LabReport (
    LabReportID SERIAL PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    TestType VARCHAR(255) NOT NULL,
    Date DATE NOT NULL,
    Results TEXT NOT NULL,
    DoctorNotes TEXT,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE
);

-- ============================
-- Table: Billing
-- ============================
CREATE TABLE Billing (
    InvoiceID SERIAL PRIMARY KEY,
    PatientID INT NOT NULL,
    TotalBillingAmount DECIMAL(10,2) NOT NULL,
    DateofInvoice DATE,
    PaymentStatus VARCHAR(50) CHECK (PaymentStatus IN ('Paid', 'Pending', 'Partially Paid')),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID) ON DELETE CASCADE
);

-- ============================
-- Table: BillingService
-- ============================
CREATE TABLE BillingService (
    InvoiceID INT NOT NULL,
    ServiceName VARCHAR(255) NOT NULL,
    ServiceCost DECIMAL(10,2) NOT NULL,
    TimeOfUsage TIMESTAMP,
    PRIMARY KEY (InvoiceID, TimeofUsage),
    FOREIGN KEY (InvoiceID) REFERENCES Billing(InvoiceID) ON DELETE CASCADE
);

-- ============================
-- Table: BillingPayment
-- ============================
CREATE TABLE BillingPayment (
    InvoiceID INT NOT NULL,
    PaymentMode VARCHAR(50),
    AmountPaid DECIMAL(10,2) NOT NULL,
    TimeOfTransaction TIMESTAMP NOT NULL,
    PRIMARY KEY (InvoiceID, TimeOfTransaction),
    FOREIGN KEY (InvoiceID) REFERENCES Billing(InvoiceID) ON DELETE CASCADE
);

-- ============================
-- Table: MedicineBill
-- ============================
CREATE TABLE MedicineBill (
    InvoiceID INT NOT NULL,
    MedicineID VARCHAR(255) NOT NULL,
    Quantity INT NOT NULL,
    PricePerUnit DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (InvoiceID, MedicineID),
    FOREIGN KEY (InvoiceID) REFERENCES Billing(InvoiceID) ON DELETE CASCADE,
    FOREIGN KEY (MedicineID) REFERENCES Medicine(MedicineID) ON DELETE CASCADE
);

-- ============================
-- Table: Surgery
-- ============================
CREATE TABLE Surgery (
    AppointmentID INT NOT NULL,
    Date_StartTime TIMESTAMP NOT NULL,
    SurgeryName VARCHAR(255) NOT NULL,
    Duration INTERVAL,
    SuggestedBy VARCHAR(255),
    Outcome VARCHAR(255),
    EndTime TIMESTAMP,
    PRIMARY KEY (AppointmentID, Date_StartTime),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID) ON DELETE CASCADE
);

-- ============================
-- Table: PerformedBy
-- ============================
CREATE TABLE PerformedBy (
    AppointmentID INT NOT NULL,
    DoctorID INT NOT NULL,
    PRIMARY KEY (AppointmentID, DoctorID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID) ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE
);
