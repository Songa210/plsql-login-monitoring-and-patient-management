# Database Development with PL/SQL  
## Assignment Projects – Triggers & Packages 
## Group: C 
### Author: Elyse Niyomwungere 28273

## Overview
This repository contains two PL/SQL-based database development projects completed for **INSY 8311 – Database Development with PL/SQL**. The projects demonstrate skills in SQL table design, PL/SQL triggers, PL/SQL packages, bulk processing, error handling, security enforcement, and use of cursors.


# Project 1: Login Security Monitoring System (Trigger-Based)
**File:** `Assignment.sql Q3 About Trigger.sql`  

This project implements a security mechanism that monitors failed login attempts and automatically generates alerts when suspicious activity is detected.

## Background

Modern systems require reliable mechanisms to track user login activities and detect suspicious behavior. Without automated monitoring, repeated failed login attempts may go unnoticed, creating vulnerabilities within the system. Databases like Oracle provide features such as triggers that can capture critical events in real time and support automated security responses.

## Problem Statement

Many systems rely on manual review of logs or basic application-level checks to detect failed login attempts. This often leads to delayed identification of intrusion attempts, inconsistent tracking of user behavior, and increased security risks. Without a proper automated process, repeated failed logins may compromise system integrity.

## Proposed Solution

This project uses Oracle PL/SQL to create a database-driven login monitoring mechanism. A trigger automatically records all login attempts and checks how many failures a user has made within a day. When failed attempts reach three or more, a security alert is generated and stored for administrative review. This solution ensures instant detection of suspicious behavior and strengthens system security.

## Features
- Records all login attempts in `login_audit`
- Tracks failed attempts per user per day
- Generates alerts when a user fails 3 or more times
- Uses a compound trigger for efficient event handling  
- Stores alerts in `security_alerts`
  
  ## Screenshots from Oracle Developer
  ![alt text](/Images/Q3%20run%20queries.png)
  ![alt text](/Images/Q3%20Test%20trigger.png)



# Project 2: Hospital Management System (Package-Based)
**File:** `AssignmentQ4.sql About Package.sql`  

## Background

Hospitals handle large amounts of patient information, and managing this data manually is often slow and prone to errors. As patient volume increases, updating records individually becomes inefficient. Using Oracle PL/SQL packages allows hospitals to centralize operations, automate data handling, and maintain accurate patient information.

## Problem Statement

Manual patient record management results in slow data entry, difficulty tracking admissions, and challenges retrieving complete patient information. These limitations lead to delays in service delivery and potential inaccuracies in patient status, especially during peak hours.

## Proposed Solution

This project implements a PL/SQL package that automates patient data processing. It supports bulk loading of patient information, retrieving patient lists through cursors, counting admitted patients, and updating admission status. By grouping these procedures into one package, the system improves efficiency, reduces errors, and provides a simple structure for managing hospital data.

## Features
- Bulk insertion of multiple patient records  
- Efficient processing with `FORALL`  
- Returns all patients via a cursor  
- Counts currently admitted patients  
- Updates patient admission status  
- Includes package specification, body, and test scripts

---

# 📦 Running the Projects
1. Open **Oracle SQL Developer**.  
2. Execute the provided SQL scripts in this order:
   - `Assignment.sql Q3 About Trigger.sql`  
   - `AssignmentQ4.sql About Package.sql`  
3. Run test blocks and `SELECT` queries as shown in the scripts.  
4. Use `SET SERVEROUTPUT ON` when running PL/SQL blocks that print output.



## Technologies Used
- Oracle SQL  
- Oracle PL/SQL  
- Compound Triggers  
- Packages  
- REFCURSOR  
- Bulk Processing (`FORALL`)  
- Exception Handling  

## Screenshots From Oracle Developer
![alt text](/Images/Creating%20tables%20for%20Q4.png)
![alt text](/Images/Procedure%20for%20Q4.png)
![alt text](/Images/Patients%20Admitted%20for%20Q4.png)
![alt text](/Images/Admitted%20Status%20for%20Q4.png)



# References 
1. Oracle PL/SQL Triggers Documentation  
   https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/triggers.html

2. Oracle PL/SQL Packages and Procedures Guide  
   https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/plsql-packages-and-program-units.html

3. Oracle REFCURSOR Usage  
   https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/static-sql.html#GUID-4AF77E5D-BAF9-4A46-BAB0-2C1BFD5F2C03

### **Books & Learning Resources**
4. *Oracle PL/SQL Programming* by Steven Feuerstein  
   https://www.oreilly.com/library/view/oracle-plsql-programming/9781449324445/

5. *Learning Oracle PL/SQL* – Packt Publishing  
   https://www.packtpub.com/product/learning-oracle-pl-sql/9781785283677

### **Tutorial Websites**
6. Tutorialspoint: PL/SQL Triggers  
   https://www.tutorialspoint.com/plsql/plsql_triggers.htm

7. GeeksforGeeks: PL/SQL Packages  
  https://www.geeksforgeeks.org/pl-sql-packages/

