-- This table records all login attempts
CREATE TABLE login_audit (
    audit_id      NUMBER GENERATED ALWAYS AS IDENTITY, -- auto-increment
    username      VARCHAR2(50),
    attempt_time  DATE DEFAULT SYSDATE,                -- time of attempt
    status        VARCHAR2(10),                        -- SUCCESS or FAILED
    ip_address    VARCHAR2(50)
);

CREATE TABLE security_alerts (
    alert_id        NUMBER GENERATED ALWAYS AS IDENTITY,
    username        VARCHAR2(50),
    failed_attempts NUMBER,
    alert_time      DATE DEFAULT SYSDATE,
    alert_message   VARCHAR2(200),
    contact_email   VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER tr_failed_login_alert
FOR INSERT ON login_audit
COMPOUND TRIGGER

    TYPE t_usernames IS TABLE OF VARCHAR2(50);
    failed_users t_usernames := t_usernames();

AFTER EACH ROW IS
BEGIN
    -- Only collect users with FAILED login
    IF :NEW.status = 'FAILED' THEN
        failed_users.EXTEND;
        failed_users(failed_users.LAST) := :NEW.username;
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_failed_attempts NUMBER;
BEGIN
    -- For each failed user inserted in this statement
    FOR i IN 1 .. failed_users.COUNT LOOP

        -- Count how many failed attempts this user has today
        SELECT COUNT(*)
        INTO v_failed_attempts
        FROM login_audit
        WHERE username = failed_users(i)
          AND status   = 'FAILED'
          AND TRUNC(attempt_time) = TRUNC(SYSDATE);

        -- If 3 or more failed attempts, insert alert
        IF v_failed_attempts >= 3 THEN
            INSERT INTO security_alerts (
                username,
                failed_attempts,
                alert_message,
                contact_email
            ) VALUES (
                failed_users(i),
                v_failed_attempts,
                'Suspicious login behavior: more than 2 failed attempts.',
                'securityteam@company.com'
            );
        END IF;

    END LOOP;
END AFTER STATEMENT;

END tr_failed_login_alert;
/

INSERT INTO login_audit (username, status, ip_address)
VALUES ('john', 'FAILED', '127.0.0.1');
COMMIT;
SELECT * FROM login_audit;
SELECT * FROM security_alerts;





