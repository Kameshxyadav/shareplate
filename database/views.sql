-- View 1: Available donations
CREATE OR REPLACE VIEW available_donations_view AS
SELECT 
    fd.id, 
    u.restaurant_name, 
    u.contact_phone,
    fd.food_type, 
    fd.quantity, 
    fd.expiry_time,
    fd.pickup_notes, 
    fd.pickup_location, 
    fd.created_at
FROM food_donations fd
INNER JOIN users u ON fd.user_id = u.id
WHERE fd.status = 'Available' AND fd.expiry_time > SYSTIMESTAMP;
/

-- View 2: Restaurant Statistics
CREATE OR REPLACE VIEW restaurant_donation_stats AS
SELECT 
    u.id AS user_id,
    u.restaurant_name,
    COUNT(fd.id) AS total_donations,
    SUM(CASE WHEN fd.status = 'Available' THEN 1 ELSE 0 END) AS available_count,
    SUM(CASE WHEN fd.status = 'Claimed' THEN 1 ELSE 0 END) AS claimed_count,
    SUM(CASE WHEN fd.status = 'Expired' THEN 1 ELSE 0 END) AS expired_count,
    NVL(SUM(fd.quantity), 0) AS total_quantity
FROM users u
LEFT JOIN food_donations fd ON u.id = fd.user_id
WHERE u.role = 'restaurant'
GROUP BY u.id, u.restaurant_name;
/