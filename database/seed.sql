-- Insert Restaurants
INSERT INTO users (username, password, role, restaurant_name, contact_phone, contact_email) 
VALUES ('kamesh_kitchen', 'hashed123', 'restaurant', 'Kamesh''s Kitchen', '9876543210', 'contact@kameshkitchen.com');

INSERT INTO users (username, password, role, restaurant_name, contact_phone, contact_email) 
VALUES ('spice_hub', 'hashed456', 'restaurant', 'The Spice Hub', '9988776655', 'hello@spicehub.in');

-- Insert NGOs
INSERT INTO users (username, password, role, contact_phone, contact_email) 
VALUES ('hope_foundation', 'hashed789', 'ngo', '9123456780', 'relief@hopefoundation.org');

INSERT INTO users (username, password, role, contact_phone, contact_email) 
VALUES ('food_for_all', 'hashed000', 'ngo', '9001100220', 'info@foodforall.in');

-- Insert Donations (Expiry set to 1 day and 2 days from current time)
INSERT INTO food_donations (user_id, food_type, quantity, expiry_time, pickup_notes, pickup_location) 
VALUES (1, 'Mixed Veg Curry & Rice', 50, SYSTIMESTAMP + INTERVAL '1' DAY, 'Packaged in containers. Bring your own transport.', 'Sector 15 Main Market');

INSERT INTO food_donations (user_id, food_type, quantity, expiry_time, pickup_notes, pickup_location) 
VALUES (2, 'Baked Bread & Pastries', 30, SYSTIMESTAMP + INTERVAL '2' DAY, 'Fragile, handle with care.', 'Downtown Bakery Plaza');

COMMIT;