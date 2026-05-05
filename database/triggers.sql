CREATE OR REPLACE TRIGGER trg_before_donation_insert
BEFORE INSERT ON food_donations
FOR EACH ROW
BEGIN
    IF :NEW.quantity <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Quantity must be a positive number');
    END IF;
    
    IF :NEW.expiry_time <= SYSTIMESTAMP THEN
        RAISE_APPLICATION_ERROR(-20002, 'Expiry time must be in the future');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_after_donation_insert
AFTER INSERT ON food_donations
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (action, table_name, record_id, new_value)
    VALUES ('INSERT', 'food_donations', :NEW.id, 'Available');
END;
/

CREATE OR REPLACE TRIGGER trg_after_donation_update
AFTER UPDATE ON food_donations
FOR EACH ROW
BEGIN
    IF :OLD.status != :NEW.status THEN
        INSERT INTO audit_log (action, table_name, record_id, old_value, new_value)
        VALUES ('UPDATE_STATUS', 'food_donations', :NEW.id, :OLD.status, :NEW.status);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_before_donation_delete
BEFORE DELETE ON food_donations
FOR EACH ROW
BEGIN
    IF :OLD.status = 'Claimed' THEN
        RAISE_APPLICATION_ERROR(-20003, 'Cannot delete a donation that has already been claimed.');
    END IF;
END;
/