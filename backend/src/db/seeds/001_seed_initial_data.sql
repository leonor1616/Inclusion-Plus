

-- ============================================================================
-- INCLUSION+ INITIAL SEED DATA
-- Seed: 001_seed_initial_data.sql
-- ============================================================================

-- Countries
INSERT INTO country (code, name, phone_code)
VALUES
('PT', 'Portugal', '+351'),
('TR', 'Turkey', '+90')
ON CONFLICT (code) DO NOTHING;

-- Universities
INSERT INTO university (
    name,
    city,
    country_code,
    is_verified,
    supports_indoor_routing,
    supports_schedule_sync,
    supports_campus_alerts
)
VALUES
('ISCTE-IUL', 'Lisbon', 'PT', TRUE, TRUE, TRUE, TRUE),
('Galatasaray University', 'Istanbul', 'TR', TRUE, FALSE, FALSE, FALSE)
ON CONFLICT (name, city, country_code) DO NOTHING;

-- Campus location types
INSERT INTO incampus_location_type (name, description)
VALUES
('building', 'Campus building'),
('room', 'Room or classroom'),
('elevator_area', 'Elevator-related location'),
('service', 'Service or support point'),
('restroom', 'Restroom or toilet area'),
('food_court', 'Food court or cafeteria area'),
('entrance', 'Campus or building entrance')
ON CONFLICT (name) DO NOTHING;

-- Accessibility feature types
INSERT INTO accessibility_feature_type (name, description, icon)
VALUES
('wheelchair_access', 'Wheelchair-accessible area', 'wheelchair'),
('accessible_restroom', 'Accessible restroom available', 'restroom'),
('elevator_access', 'Elevator access available', 'elevator'),
('ramp_access', 'Ramp access available', 'ramp'),
('step_free_access', 'Step-free access available', 'step_free'),
('automatic_door', 'Automatic door available', 'door'),
('tactile_paving', 'Tactile paving available', 'tactile')
ON CONFLICT (name) DO NOTHING;

-- Country hotlines
INSERT INTO country_hotline (
    country_code,
    title,
    phone_number,
    description,
    hotline_type,
    is_active
)
VALUES
('PT', 'Emergency Number', '112', 'Police, fire and medical emergency', 'emergency', TRUE),
('PT', 'SNS 24', '808 24 24 24', 'Non-emergency health advice', 'health', TRUE),
('TR', 'Emergency Number', '112', 'General emergency line', 'emergency', TRUE)
ON CONFLICT DO NOTHING;

-- In-campus locations test data
INSERT INTO incampus_university_location (
    location_type_id,
    name,
    description,
    category,
    building,
    floor,
    room_code,
    latitude,
    longitude,
    is_indoor
)
VALUES
(
    (SELECT id FROM incampus_location_type WHERE name = 'room'),
    'Room 1E08',
    'Classroom on floor 1',
    'classroom',
    'Building 1',
    '1',
    '1E08',
    38.747000,
    -9.153000,
    TRUE
),
(
    (SELECT id FROM incampus_location_type WHERE name = 'elevator_area'),
    'Elevator 1 Area',
    'Elevator area near Room 1E08',
    'elevator',
    'Building 1',
    '1',
    NULL,
    38.747010,
    -9.153010,
    TRUE
)
ON CONFLICT DO NOTHING;