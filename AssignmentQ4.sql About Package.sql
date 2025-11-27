-- DROP if exists (uncomment if you re-run tests)
-- DROP TABLE patients CASCADE CONSTRAINTS;
-- DROP TABLE doctors CASCADE CONSTRAINTS;
-- DROP SEQUENCE seq_patient_id;
-- DROP SEQUENCE seq_doctor_id;

CREATE TABLE doctors (
    doctor_id   NUMBER PRIMARY KEY,
    name        VARCHAR2(100) NOT NULL,
    specialty   VARCHAR2(100)
);

CREATE TABLE patients (
    patient_id      NUMBER PRIMARY KEY,
    name            VARCHAR2(100) NOT NULL,
    age             NUMBER,
    gender          VARCHAR2(10),
    admitted_status VARCHAR2(5) DEFAULT 'NO'  -- 'YES' or 'NO'
);
-- simple sequences to generate ids
CREATE SEQUENCE seq_patient_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_doctor_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;


CREATE OR REPLACE PACKAGE hospital_pkg AS
  -- Record type for a single patient (for bulk loading)
  TYPE t_patient_rec IS RECORD (
    patient_id      NUMBER,
    name            VARCHAR2(100),
    age             NUMBER,
    gender          VARCHAR2(10),
    admitted_status VARCHAR2(5)
  );

  -- Nested table type (collection) holding multiple patients
  TYPE t_patient_table IS TABLE OF t_patient_rec;

  -- Bulk load: insert multiple patients at once using bulk collection
  PROCEDURE bulk_load_patients(p_list IN t_patient_table);

  -- Return a cursor that selects all patients
  FUNCTION show_all_patients RETURN SYS_REFCURSOR;

  -- Return number of currently admitted patients ('YES')
  FUNCTION count_admitted RETURN NUMBER;

  -- Admit a single patient (set admitted_status = 'YES')
  PROCEDURE admit_patient(p_id IN NUMBER);
END hospital_pkg;
/




CREATE OR REPLACE PACKAGE BODY hospital_pkg AS

  ---------------------------------------------------------
  -- bulk_load_patients: insert many patients using FORALL
  -- Expectation: p_list is a nested table (1..N)
  ---------------------------------------------------------
  PROCEDURE bulk_load_patients(p_list IN t_patient_table) IS
  BEGIN
    IF p_list IS NULL OR p_list.COUNT = 0 THEN
      RETURN;
    END IF;

    -- Use FORALL for efficient bulk DML
    FORALL i IN 1 .. p_list.COUNT
      INSERT INTO patients (patient_id, name, age, gender, admitted_status)
      VALUES (p_list(i).patient_id,
              p_list(i).name,
              p_list(i).age,
              p_list(i).gender,
              NVL(p_list(i).admitted_status, 'NO'));

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      -- rollback on error and re-raise for visibility
      ROLLBACK;
      RAISE;
  END bulk_load_patients;

  ---------------------------------------------------------
  -- show_all_patients: returns SYS_REFCURSOR of all patients
  ---------------------------------------------------------
  FUNCTION show_all_patients RETURN SYS_REFCURSOR IS
    rc SYS_REFCURSOR;
  BEGIN
    OPEN rc FOR
      SELECT patient_id, name, age, gender, admitted_status
      FROM patients
      ORDER BY patient_id;
    RETURN rc;
  END show_all_patients;

  ---------------------------------------------------------
  -- count_admitted: number of patients with admitted_status = 'YES'
  ---------------------------------------------------------
  FUNCTION count_admitted RETURN NUMBER IS
    cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO cnt
    FROM patients
    WHERE admitted_status = 'YES';
    RETURN cnt;
  END count_admitted;

  ---------------------------------------------------------
  -- admit_patient: set a patient's status to 'YES'
  ---------------------------------------------------------
  PROCEDURE admit_patient(p_id IN NUMBER) IS
  BEGIN
    UPDATE patients
    SET admitted_status = 'YES'
    WHERE patient_id = p_id;

    IF SQL%ROWCOUNT = 0 THEN
      -- no such patient -> raise a friendly error
      RAISE_APPLICATION_ERROR(-20001, 'No patient found with ID ' || p_id);
    END IF;

    COMMIT;
  END admit_patient;

END hospital_pkg;
/

BEGIN
  INSERT INTO doctors(doctor_id, name, specialty)
  VALUES (seq_doctor_id.NEXTVAL, 'Dr. Alice Smith', 'Cardiology');

  INSERT INTO doctors(doctor_id, name, specialty)
  VALUES (seq_doctor_id.NEXTVAL, 'Dr. Bob Kamau', 'General Surgery');

  COMMIT;
END;
/



DECLARE
  pt_list hospital_pkg.t_patient_table := hospital_pkg.t_patient_table();
BEGIN
  -- create 3 patients in the collection
  pt_list.EXTEND(3);

  pt_list(1).patient_id := seq_patient_id.NEXTVAL;
  pt_list(1).name := 'John Doe';
  pt_list(1).age := 34;
  pt_list(1).gender := 'M';
  pt_list(1).admitted_status := 'NO';

  pt_list(2).patient_id := seq_patient_id.NEXTVAL;
  pt_list(2).name := 'Mary Jane';
  pt_list(2).age := 45;
  pt_list(2).gender := 'F';
  pt_list(2).admitted_status := 'YES';

  pt_list(3).patient_id := seq_patient_id.NEXTVAL;
  pt_list(3).name := 'Sam Lee';
  pt_list(3).age := 29;
  pt_list(3).gender := 'M';
  pt_list(3).admitted_status := 'NO';

  -- Call the bulk loader
  hospital_pkg.bulk_load_patients(pt_list);
END;
/


-- Show all patients (using ref cursor)
SET SERVEROUTPUT ON
DECLARE
  rc SYS_REFCURSOR;
  v_id patients.patient_id%TYPE;
  v_name patients.name%TYPE;
  v_age patients.age%TYPE;
  v_gender patients.gender%TYPE;
  v_status patients.admitted_status%TYPE;
BEGIN
  rc := hospital_pkg.show_all_patients();
  LOOP
    FETCH rc INTO v_id, v_name, v_age, v_gender, v_status;
    EXIT WHEN rc%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('ID='||v_id||', Name='||v_name||', Age='||v_age||
                         ', Gender='||v_gender||', Admitted='||v_status);
  END LOOP;
  CLOSE rc;
END;
/
-- Admit a patient
BEGIN
  -- replace 1 with any patient_id from your table
  hospital_pkg.admit_patient(1);
END;
/

-- Count admitted patients
SELECT hospital_pkg.count_admitted AS admitted_count FROM dual;

-- drop and recreate or alter column type
ALTER TABLE patients DROP COLUMN admitted_status;

ALTER TABLE patients ADD (admitted_status NUMBER(1) DEFAULT 0); -- 1 = admitted, 0 = not

COMMIT;




