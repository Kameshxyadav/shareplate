-- ==========================================
-- SECTION 1: FUNCTIONS
-- ==========================================

CREATE OR REPLACE FUNCTION GetTotalDonations(p_user_id IN NUMBER) 
RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM food_donations WHERE user_id = p_user_id;
    RETURN v_count;
END GetTotalDonations;
/

CREATE OR REPLACE FUNCTION GetClaimedQuantity(p_user_id IN NUMBER) 
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(quantity), 0) INTO v_total 
    FROM food_donations 
    WHERE user_id = p_user_id AND status = 'Claimed';
    RETURN v_total;
END GetClaimedQuantity;
/

CREATE OR REPLACE FUNCTION IsDonationClaimable(p_donation_id IN NUMBER) 
RETURN NUMBER IS
    v_status VARCHAR2(20);
    v_expiry TIMESTAMP;
BEGIN
    SELECT status, expiry_time INTO v_status, v_expiry 
    FROM food_donations WHERE id = p_donation_id;
    
    IF v_status = 'Available' AND v_expiry > SYSTIMESTAMP THEN 
        RETURN 1; 
    ELSE 
        RETURN 0; 
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END IsDonationClaimable;
/

-- ==========================================
-- SECTION 2: PROCEDURES
-- ==========================================

CREATE OR REPLACE PROCEDURE AddDonation(
    p_user_id IN NUMBER, 
    p_food_type IN VARCHAR2,
    p_quantity IN NUMBER, 
    p_expiry_time IN TIMESTAMP,
    p_pickup_notes IN VARCHAR2,
    p_donation_id OUT NUMBER, 
    p_message OUT VARCHAR2
) IS
BEGIN
    IF p_quantity <= 0 THEN
        p_message := 'Quantity must be greater than 0';
        p_donation_id := -1;
    ELSIF p_expiry_time <= SYSTIMESTAMP THEN
        p_message := 'Expiry time must be in the future';
        p_donation_id := -1;
    ELSE
        INSERT INTO food_donations(user_id, food_type, quantity, expiry_time, pickup_notes)
        VALUES(p_user_id, p_food_type, p_quantity, p_expiry_time, p_pickup_notes)
        RETURNING id INTO p_donation_id;
        
        p_message := 'Donation added successfully';
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_donation_id := -1;
        p_message := 'Database Error: ' || SQLERRM;
END AddDonation;
/

CREATE OR REPLACE PROCEDURE ClaimDonation(
    p_donation_id IN NUMBER, 
    p_ngo_user_id IN NUMBER,
    p_success OUT NUMBER, 
    p_message OUT VARCHAR2
) IS
    v_status VARCHAR2(20);
BEGIN
    SELECT status INTO v_status 
    FROM food_donations 
    WHERE id = p_donation_id FOR UPDATE;

    IF v_status = 'Available' THEN
        UPDATE food_donations SET status = 'Claimed' WHERE id = p_donation_id;
        
        INSERT INTO donation_claims(donation_id, ngo_user_id)
        VALUES(p_donation_id, p_ngo_user_id);
        
        SAVEPOINT after_claim;
        
        INSERT INTO audit_log(action, table_name, record_id, old_value, new_value)
        VALUES('CLAIM', 'food_donations', p_donation_id, 'Available', 'Claimed');
        
        p_success := 1; 
        p_message := 'Donation claimed successfully';
        COMMIT;
    ELSE
        p_success := 0;
        p_message := 'Donation is already ' || v_status;
        ROLLBACK;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        p_success := 0;
        p_message := 'Donation record not found.';
    WHEN OTHERS THEN
        ROLLBACK;
        p_success := 0;
        p_message := 'Database Error: ' || SQLERRM;
END ClaimDonation;
/

CREATE OR REPLACE PROCEDURE ExpireOldDonations(p_expired_count OUT NUMBER) IS
    v_count NUMBER := 0;
BEGIN
    FOR rec IN (SELECT id FROM food_donations WHERE expiry_time < SYSTIMESTAMP AND status = 'Available') 
    LOOP
        UPDATE food_donations SET status = 'Expired' WHERE id = rec.id;
        
        INSERT INTO audit_log(action, table_name, record_id, old_value, new_value)
        VALUES('AUTO_EXPIRE', 'food_donations', rec.id, 'Available', 'Expired');
        
        v_count := v_count + 1;
    END LOOP;
    
    p_expired_count := v_count;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_expired_count := 0;
        RAISE; 
END ExpireOldDonations;
/