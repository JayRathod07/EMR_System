-- 1. TODAY'S FOLLOW-UP APPOINTMENTS
SELECT A.AppointmentID, A.DateTime, A.Type, P.PatientID, P.Name, P.Email
FROM Appointment A
JOIN Patient P ON A.PatientID = P.PatientID
WHERE A.Type = 'Follow-up'
  AND A.DateTime BETWEEN now() AND now() + interval '1 days';

-- 2. PATIENT PRESCRIPTION HISTORY
SELECT PR.PrescriptionID, PR.FollowUpDate, PR.AdditionalNotes, D.Name AS DoctorName, PR.PatientID
FROM Prescription PR
JOIN Doctor D ON PR.DoctorID = D.DoctorID
WHERE PR.PatientID = 56788632;

-- 3. PATIENT LAB RESULTS
SELECT LabReportID, Date, TestType, Results, DoctorNotes
FROM LabReport
WHERE PatientID = 59184520;

-- 4. PENDING PAYMENTS
SELECT B.InvoiceID, B.PatientID, B.TotalBillingAmount, B.PaymentStatus, B.DateofInvoice
FROM Billing B
WHERE B.PaymentStatus = 'Pending';

-- 5. ANTIBIOTIC SALES ANALYSIS
SELECT M.MedicineID, M.Name, M.Composition,
       SUM(MB.Quantity) AS TotalSold,
       SUM(MB.PricePerUnit * MB.Quantity) AS TotalSales
FROM Medicine M
JOIN MedicineBill MB ON M.MedicineID = MB.MedicineID
WHERE lower(M.Composition) LIKE '%antibiotic%'
GROUP BY M.MedicineID, M.Name, M.Composition;

-- 6. UNFILLED PRESCRIPTIONS
SELECT DISTINCT P.PatientID, P.Name
FROM PrescriptionMedicine PM
JOIN Prescription PR ON PM.PrescriptionID = PR.PrescriptionID
JOIN Patient P ON PR.PatientID = P.PatientID
LEFT JOIN MedicineBill MB ON MB.MedicineID = PM.MedicineID
  AND MB.InvoiceID IN (
    SELECT InvoiceID FROM Billing WHERE PatientID = P.PatientID
  )
WHERE MB.InvoiceID IS NULL;

-- 7. DAILY MEDICINE SALES
SELECT Date, SUM(PricePerUnit * Quantity) AS TotalSales
FROM MedicineBill
WHERE Date = '2025-04-10'
GROUP BY Date;

-- 8. POPULAR MEDICATIONS
SELECT MB.MedicineID, M.Name, COUNT(*) AS PurchaseCount
FROM MedicineBill MB
JOIN Medicine M ON MB.MedicineID = M.MedicineID
GROUP BY MB.MedicineID, M.Name
ORDER BY PurchaseCount DESC;

-- 9. EXPIRED MEDICATIONS
SELECT MedicineID, Name, ExpiryDate
FROM Medicine
WHERE ExpiryDate < CURRENT_DATE;

-- 10. LOW STOCK ALERTS
SELECT MedicineID, Name, StockQuantity, ReorderThreshold
FROM Medicine
WHERE StockQuantity < ReorderThreshold;

-- 11. PAYMENT METHODS ANALYSIS
SELECT PaymentMode, SUM(AmountPaid) AS TotalAmount
FROM BillingPayment
GROUP BY PaymentMode;

-- 12. NEW PATIENT COUNT
SELECT COUNT(*) AS NewPatientCount
FROM Patient
WHERE date_trunc('year', RegistrationDate) = date_trunc('year', now());

-- 13. PATIENT BILLING TRENDS
SELECT B.PatientID, date_trunc('month', BP.TimeOfTransaction) AS Month,
       AVG(B.TotalBillingAmount) AS AvgBillingAmount
FROM Billing B
JOIN BillingPayment BP ON B.InvoiceID = BP.InvoiceID
GROUP BY B.PatientID, date_trunc('month', BP.TimeOfTransaction)
ORDER BY B.PatientID, Month;

-- 14. PATIENT CASE TYPE
SELECT PatientID,
       CASE
         WHEN COUNT(CASE WHEN Type = 'Follow-up' THEN 1 END) > 0 THEN 'Follow-up'
         ELSE 'New Case'
       END AS CaseType
FROM Appointment
WHERE PatientID = 1
GROUP BY PatientID;

-- 15. MONTHLY BILLING
SELECT B.InvoiceID, B.TotalBillingAmount, B.DateofInvoice
FROM Billing B
WHERE B.PatientID = 1
  AND B.DateofInvoice BETWEEN '2025-04-01' AND '2025-04-30';

-- 16. MONTHLY INCOME
SELECT date_trunc('month', BP.TimeOfTransaction) AS Month,
       SUM(B.TotalBillingAmount) AS MonthlyIncome
FROM Billing B
JOIN BillingPayment BP ON B.InvoiceID = BP.InvoiceID
GROUP BY Month
ORDER BY Month;

-- 17. FREQUENT VISITORS
SELECT P.PatientID, P.Name, COUNT(A.AppointmentID) AS VisitCount
FROM Patient P
JOIN Appointment A ON P.PatientID = A.PatientID
WHERE A.DateTime >= now() - interval '1 month'
GROUP BY P.PatientID, P.Name
HAVING COUNT(A.AppointmentID) > 5;

-- 18. DOCTOR'S PATIENT LIST
SELECT DISTINCT P.PatientID, P.Name, P.Email
FROM Appointment A
JOIN Patient P ON A.PatientID = P.PatientID
WHERE A.DoctorID = 6931;

-- 19. URGENT LAB REPORTS
SELECT LabReportID, PatientID, Date, TestType, Results, DoctorNotes
FROM LabReport
WHERE LOWER(DoctorNotes) LIKE '%urgent%';

-- 20. SURGERY SCHEDULE
SELECT S.AppointmentID, S.Date_StartTime, S.SurgeryName, S.Duration,
       S.SuggestedBy, S.Outcome, S.EndTime
FROM Surgery S
WHERE date(S.Date_StartTime) = '2024-06-25';

-- 21. TOP PATIENTS BY VISITS
SELECT p.PatientID, p.Name, COUNT(*) AS VisitCount,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS VisitRank
FROM Patient p
JOIN Appointment a ON p.PatientID = a.PatientID
GROUP BY p.PatientID, p.Name
ORDER BY VisitCount DESC
LIMIT 10;

-- 22. MEDICINE INVENTORY STATUS
SELECT m.MedicineID, m.Name, m.StockQuantity, m.ReorderThreshold,
       ph.Name AS Pharmacist,
       CASE
         WHEN m.StockQuantity < m.ReorderThreshold THEN 'Reorder Now'
         WHEN m.StockQuantity < m.ReorderThreshold * 1.5 THEN 'Monitor Closely'
         ELSE 'Adequate Stock'
       END AS InventoryStatus
FROM Medicine m
JOIN Pharmacist ph ON m.PharmacistID = ph.PharmacistID
ORDER BY InventoryStatus, m.StockQuantity ASC;

-- 23. PATIENT HEALTH SUMMARY
SELECT p.PatientID, p.Name, p.Age, p.Gender,
       COUNT(DISTINCT a.AppointmentID) AS TotalVisits,
       COUNT(DISTINCT pr.PrescriptionID) AS TotalPrescriptions,
       COUNT(DISTINCT lr.LabReportID) AS TotalLabTests,
       COALESCE(SUM(b.TotalBillingAmount), 0) AS TotalSpend,
       MAX(a.DateTime) AS LastVisitDate,
       CASE
         WHEN EXISTS (
           SELECT 1 FROM Surgery
           WHERE AppointmentID IN (
             SELECT AppointmentID FROM Appointment WHERE PatientID = p.PatientID
           )
         ) THEN 'Yes'
         ELSE 'No'
       END AS HasSurgicalHistory
FROM Patient p
LEFT JOIN Appointment a ON p.PatientID = a.PatientID
LEFT JOIN Prescription pr ON p.PatientID = pr.PatientID
LEFT JOIN LabReport lr ON p.PatientID = lr.PatientID
LEFT JOIN Billing b ON p.PatientID = b.PatientID
GROUP BY p.PatientID
ORDER BY TotalSpend DESC
LIMIT 10;

-- 24. MISSED FOLLOW-UPS
SELECT p.PatientID, p.Name, p.ContactNumber, pr.PrescriptionID,
       pr.FollowUpDate, CURRENT_DATE - pr.FollowUpDate AS DaysOverdue
FROM Prescription pr
JOIN Patient p ON pr.PatientID = p.PatientID
WHERE pr.FollowUpDate < CURRENT_DATE
  AND NOT EXISTS (
    SELECT 1 FROM Appointment a
    WHERE a.PatientID = p.PatientID
      AND a.DateTime > pr.FollowUpDate
      AND a.Type = 'Follow-up'
  )
ORDER BY DaysOverdue DESC;

-- 25. REVENUE BY SPECIALTY
WITH PatientSpending AS (
  SELECT p.PatientID, p.Name, d.Specialization,
         SUM(b.TotalBillingAmount) AS TotalSpend
  FROM Patient p
  JOIN Appointment a ON p.PatientID = a.PatientID
  JOIN Doctor d ON a.DoctorID = d.DoctorID
  JOIN Billing b ON p.PatientID = b.PatientID
  GROUP BY p.PatientID, p.Name, d.Specialization
)
SELECT Specialization, AVG(TotalSpend) AS AvgSpend,
       SUM(TotalSpend) AS TotalSpecialtyRevenue,
       COUNT(DISTINCT PatientID) AS PatientCount
FROM PatientSpending
GROUP BY Specialization
ORDER BY TotalSpecialtyRevenue DESC;

-- 26. OVERBOOKED DOCTORS
SELECT d.DoctorID, d.Name, d.Specialization,
       COUNT(a.AppointmentID) AS TotalAppointments,
       COUNT(DISTINCT DATE(a.DateTime)) AS DaysWorked,
       COUNT(a.AppointmentID) / COUNT(DISTINCT DATE(a.DateTime)) AS ApptsPerDay,
       COUNT(CASE WHEN a.Status = 'Cancelled' THEN 1 END) AS Cancellations
FROM Doctor d
JOIN Appointment a ON d.DoctorID = a.DoctorID
WHERE a.DateTime BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
GROUP BY d.DoctorID, d.Name, d.Specialization
HAVING COUNT(a.AppointmentID) / COUNT(DISTINCT DATE(a.DateTime)) > 3
ORDER BY ApptsPerDay DESC;

-- 27. SURGERY HISTORY
SELECT p.Name AS Patient, s.SurgeryName, s.Date_StartTime, d.Name AS Surgeon
FROM Surgery s
JOIN Appointment a ON s.AppointmentID = a.AppointmentID
JOIN Patient p ON a.PatientID = p.PatientID
JOIN Doctor d ON a.DoctorID = d.DoctorID
WHERE s.Date_StartTime >= CURRENT_DATE - INTERVAL '1 year'
ORDER BY s.Date_StartTime DESC;

-- 28. UNREVIEWED LAB REPORTS
SELECT p.Name, lr.TestType, lr.Date
FROM LabReport lr
JOIN Patient p ON lr.PatientID = p.PatientID
WHERE lr.DoctorNotes IS NULL
  AND lr.Date > CURRENT_DATE - 7
ORDER BY lr.Date DESC;

-- 29. DELINQUENT BILLS
SELECT p.Name, b.InvoiceID, b.TotalBillingAmount, b.DateofInvoice
FROM Billing b
JOIN Patient p ON b.PatientID = p.PatientID
WHERE b.PaymentStatus != 'Paid'
  AND b.DateofInvoice < CURRENT_DATE - 30
ORDER BY b.DateofInvoice;

-- 30. TOP MEDICATIONS
SELECT m.Name, COUNT(*) AS PrescriptionCount
FROM PrescriptionMedicine pm
JOIN Medicine m ON pm.MedicineID = m.MedicineID
GROUP BY m.Name
ORDER BY PrescriptionCount DESC
LIMIT 10;

-- 31. DETAILED MEDICAL HISTORY
SELECT p.Name, p.Age, p.Gender,
       pmh.ConditionName, pmh.DiagnosisDate,
       pmh.Status, pmh.TreatmentDetails
FROM PatientMedicalHistory pmh
JOIN Patient p ON pmh.PatientID = p.PatientID
WHERE p.PatientID = 29752728
ORDER BY pmh.DiagnosisDate DESC;

-- 32. DIAGNOSIS IN LAST 3 MONTHS
SELECT p.Name, p.ContactNumber,
       pmh.ConditionName, pmh.DiagnosisDate
FROM PatientMedicalHistory pmh
JOIN Patient p ON pmh.PatientID = p.PatientID
WHERE pmh.DiagnosisDate >= CURRENT_DATE - INTERVAL '3 months'
ORDER BY pmh.DiagnosisDate DESC;

-- 33. SURGERY ANALYSIS DURATION
SELECT d.Name,
       AVG(EXTRACT(EPOCH FROM (s.EndTime - s.Date_StartTime)) / 60) AS avg_minutes,
       MIN(EXTRACT(EPOCH FROM (s.EndTime - s.Date_StartTime)) / 60) AS shortest_minutes,
       MAX(EXTRACT(EPOCH FROM (s.EndTime - s.Date_StartTime)) / 60) AS longest_minutes
FROM Doctor d
JOIN PerformedBy pb ON d.DoctorID = pb.DoctorID
JOIN Surgery s ON pb.AppointmentID = s.AppointmentID
WHERE s.EndTime IS NOT NULL
GROUP BY d.Name;
