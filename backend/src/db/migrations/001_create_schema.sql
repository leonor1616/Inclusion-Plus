

-- ============================================================================
-- INCLUSION+ DATABASE SCHEMA
-- Migration: 001_create_schema.sql
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS postgis;
-- ============================================================================
-- 1. INDEPENDENT TABLES
-- ============================================================================

CREATE TABLE country (
    code CHAR(2) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    phone_code VARCHAR(10),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE accessibility_feature_type (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon TEXT
);

CREATE TABLE incampus_location_type (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE external_location (
    id BIGSERIAL PRIMARY KEY,
    source VARCHAR(50) NOT NULL,
    external_source_id VARCHAR(255) NOT NULL,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    geom GEOGRAPHY(POINT,4326),
    source_url TEXT,
    user_review_count INT NOT NULL DEFAULT 0,
    average_user_rating DECIMAL(3,2),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (source, external_source_id),
    CHECK (user_review_count >= 0),
    CHECK (average_user_rating IS NULL OR (average_user_rating >= 0 AND average_user_rating <= 5))
);

-- ============================================================================
-- 2. LEVEL 1 DEPENDENCIES
-- ============================================================================

CREATE TABLE country_hotline (
    id BIGSERIAL PRIMARY KEY,
    country_code CHAR(2) NOT NULL REFERENCES country(code),
    title VARCHAR(150) NOT NULL,
    phone_number VARCHAR(30) NOT NULL,
    description TEXT,
    hotline_type VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE university (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    country_code CHAR(2) NOT NULL REFERENCES country(code),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    supports_indoor_routing BOOLEAN NOT NULL DEFAULT FALSE,
    supports_schedule_sync BOOLEAN NOT NULL DEFAULT FALSE,
    supports_campus_alerts BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (name, city, country_code)
);

CREATE TABLE incampus_university_location (
    id BIGSERIAL PRIMARY KEY,
    location_type_id BIGINT NOT NULL REFERENCES incampus_location_type(id),
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    building VARCHAR(100),
    floor VARCHAR(50),
    room_code VARCHAR(50),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    geom GEOGRAPHY(POINT,4326),
    is_indoor BOOLEAN NOT NULL DEFAULT TRUE,
    parent_location_id BIGINT REFERENCES incampus_university_location(id),
    user_review_count INT NOT NULL DEFAULT 0,
    average_user_rating DECIMAL(3,2),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (user_review_count >= 0),
    CHECK (average_user_rating IS NULL OR (average_user_rating >= 0 AND average_user_rating <= 5))
);

CREATE TABLE external_alert (
    id BIGSERIAL PRIMARY KEY,
    country_code CHAR(2) REFERENCES country(code),
    source VARCHAR(50) NOT NULL,
    external_source_id VARCHAR(255),
    title VARCHAR(150) NOT NULL,
    description TEXT,
    alert_type VARCHAR(50) NOT NULL,
    external_location_id BIGINT REFERENCES external_location(id),
    source_url TEXT,
    starts_at TIMESTAMP,
    ends_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (ends_at IS NULL OR starts_at IS NULL OR ends_at > starts_at)
);

-- ============================================================================
-- 3. LEVEL 2 DEPENDENCIES
-- ============================================================================

CREATE TABLE institutional_student (
    id BIGSERIAL PRIMARY KEY,
    university_id BIGINT NOT NULL REFERENCES university(id),
    institutional_student_id VARCHAR(150) NOT NULL,
    institutional_email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    country_code CHAR(2) REFERENCES country(code),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (university_id, institutional_student_id)
);

CREATE TABLE campus_alert (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    alert_type VARCHAR(50) NOT NULL,
    incampus_location_id BIGINT REFERENCES incampus_university_location(id),
    starts_at TIMESTAMP,
    ends_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (ends_at IS NULL OR starts_at IS NULL OR ends_at > starts_at)
);

CREATE TABLE elevator (
    id BIGSERIAL PRIMARY KEY,
    incampus_university_location_id BIGINT NOT NULL REFERENCES incampus_university_location(id),
    name VARCHAR(100) NOT NULL,
    building VARCHAR(100),
    floor_range VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'operating',
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (status IN ('operating', 'out_of_service', 'maintenance'))
);

CREATE TABLE location_specific_accessibility_feature (
    id BIGSERIAL PRIMARY KEY,
    incampus_location_id BIGINT NOT NULL REFERENCES incampus_university_location(id),
    feature_type_id BIGINT NOT NULL REFERENCES accessibility_feature_type(id),
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'available',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (incampus_location_id, feature_type_id),
    CHECK (status IN ('available', 'unavailable', 'limited'))
);

-- ============================================================================
-- 4. LEVEL 3 DEPENDENCIES: USERS
-- ============================================================================

CREATE TABLE "user" (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    institutional_student_id BIGINT UNIQUE REFERENCES institutional_student(id),
    account_type VARCHAR(20) NOT NULL,
    password_hash TEXT NOT NULL,
    university_id BIGINT REFERENCES university(id),
    country_code CHAR(2) REFERENCES country(code),
    city VARCHAR(100),
    profile_picture_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (account_type IN ('institutional', 'normal'))
);

-- ============================================================================
-- 5. LEVEL 4 DEPENDENCIES: USER ACTIVITY
-- ============================================================================

CREATE TABLE accessibility_profile (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES "user"(id),
    disability_types JSONB NOT NULL DEFAULT '[]'::jsonb,
    custom_ui_preferences JSONB,
    navigation_preferences JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE academic_calendar_link (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES "user"(id),
    provider VARCHAR(50) NOT NULL,
    external_account_id VARCHAR(255),
    sync_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    last_synced_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE academic_event (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES "user"(id),
    external_event_id VARCHAR(255),
    title VARCHAR(150),
    event_type VARCHAR(30) NOT NULL,
    incampus_location_id BIGINT REFERENCES incampus_university_location(id),
    room_label VARCHAR(100),
    building VARCHAR(100),
    starts_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled',
    source VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (ends_at > starts_at),
    CHECK (event_type IN ('class', 'exam', 'meeting', 'other')),
    CHECK (status IN ('scheduled', 'updated', 'cancelled'))
);

CREATE TABLE favorite_location (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES "user"(id),
    incampus_university_location_id BIGINT REFERENCES incampus_university_location(id),
    external_location_id BIGINT REFERENCES external_location(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (
        (incampus_university_location_id IS NOT NULL AND external_location_id IS NULL)
        OR
        (incampus_university_location_id IS NULL AND external_location_id IS NOT NULL)
    )
);

CREATE UNIQUE INDEX uq_favorite_location_user_incampus
ON favorite_location(user_id, incampus_university_location_id)
WHERE incampus_university_location_id IS NOT NULL;

CREATE UNIQUE INDEX uq_favorite_location_user_external
ON favorite_location(user_id, external_location_id)
WHERE external_location_id IS NOT NULL;

CREATE TABLE favorite_route (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES "user"(id),
    accessibility_profile_id BIGINT REFERENCES accessibility_profile(id),
    origin_incampus_location_id BIGINT REFERENCES incampus_university_location(id),
    destination_incampus_location_id BIGINT REFERENCES incampus_university_location(id),
    origin_external_location_id BIGINT REFERENCES external_location(id),
    destination_external_location_id BIGINT REFERENCES external_location(id),
    route_modes VARCHAR(50) NOT NULL,
    filters JSONB,
    planned_departure_time TIMESTAMP,
    planned_arrival_time TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (route_modes IN ('walking', 'metro', 'bus', 'train', 'indoor', 'mixed')),
    CHECK (
        (origin_incampus_location_id IS NOT NULL AND origin_external_location_id IS NULL)
        OR
        (origin_incampus_location_id IS NULL AND origin_external_location_id IS NOT NULL)
    ),
    CHECK (
        (destination_incampus_location_id IS NOT NULL AND destination_external_location_id IS NULL)
        OR
        (destination_incampus_location_id IS NULL AND destination_external_location_id IS NOT NULL)
    )
);

CREATE TABLE post (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES "user"(id),
    incampus_university_location_id BIGINT REFERENCES incampus_university_location(id),
    external_location_id BIGINT REFERENCES external_location(id),
    post_type VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    rating INT,
    image_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (post_type IN ('review', 'advice', 'question')),
    CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5)),
    CHECK (
        (incampus_university_location_id IS NOT NULL AND external_location_id IS NULL)
        OR
        (incampus_university_location_id IS NULL AND external_location_id IS NOT NULL)
    )
);

CREATE TABLE help_request (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES "user"(id),
    incampus_university_location_id BIGINT NOT NULL REFERENCES incampus_university_location(id),
    request_type VARCHAR(50) NOT NULL,
    message TEXT,
    urgency_level VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'submitted',
    scheduled_for TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (request_type IN ('call_support', 'text_support', 'emergency_help')),
    CHECK (urgency_level IN ('now', 'scheduled'))
);

CREATE TABLE report (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES "user"(id),
    incampus_university_location_id BIGINT REFERENCES incampus_university_location(id),
    elevator_id BIGINT REFERENCES elevator(id),
    external_location_id BIGINT REFERENCES external_location(id),
    feature_type_id BIGINT REFERENCES accessibility_feature_type(id),
    report_type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'submitted',
    image_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CHECK (status IN ('submitted', 'analyzing', 'resolved')),
    CHECK (
        incampus_university_location_id IS NOT NULL
        OR elevator_id IS NOT NULL
        OR external_location_id IS NOT NULL
    )
);

-- ============================================================================
-- 6. LEVEL 5 DEPENDENCIES: POST ACTIVITY
-- ============================================================================

CREATE TABLE comment (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES post(id),
    user_id BIGINT NOT NULL REFERENCES "user"(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 7. INDEXES
-- ============================================================================

CREATE INDEX idx_university_country_code ON university(country_code);
CREATE INDEX idx_institutional_student_university_id ON institutional_student(university_id);
CREATE INDEX idx_institutional_student_country_code ON institutional_student(country_code);
CREATE INDEX idx_user_country_code ON "user"(country_code);
CREATE INDEX idx_user_university_id ON "user"(university_id);

CREATE INDEX idx_incampus_location_type_id ON incampus_university_location(location_type_id);
CREATE INDEX idx_incampus_parent_location_id ON incampus_university_location(parent_location_id);
CREATE INDEX idx_incampus_building ON incampus_university_location(building);
CREATE INDEX idx_incampus_room_code ON incampus_university_location(room_code);
CREATE INDEX idx_external_location_category ON external_location(category);

CREATE INDEX idx_location_specific_feature_location_id ON location_specific_accessibility_feature(incampus_location_id);
CREATE INDEX idx_location_specific_feature_type_id ON location_specific_accessibility_feature(feature_type_id);
CREATE INDEX idx_elevator_location_id ON elevator(incampus_university_location_id);
CREATE INDEX idx_elevator_status ON elevator(status);

CREATE INDEX idx_country_hotline_country_code ON country_hotline(country_code);
CREATE INDEX idx_external_alert_country_code ON external_alert(country_code);
CREATE INDEX idx_external_alert_external_location_id ON external_alert(external_location_id);
CREATE INDEX idx_external_alert_alert_type ON external_alert(alert_type);
CREATE INDEX idx_campus_alert_location_id ON campus_alert(incampus_location_id);
CREATE INDEX idx_campus_alert_alert_type ON campus_alert(alert_type);

CREATE INDEX idx_academic_event_user_id ON academic_event(user_id);
CREATE INDEX idx_academic_event_incampus_location_id ON academic_event(incampus_location_id);
CREATE INDEX idx_academic_event_starts_at ON academic_event(starts_at);
CREATE INDEX idx_academic_calendar_link_user_id ON academic_calendar_link(user_id);

CREATE INDEX idx_post_user_id ON post(user_id);
CREATE INDEX idx_post_incampus_location_id ON post(incampus_university_location_id);
CREATE INDEX idx_post_external_location_id ON post(external_location_id);
CREATE INDEX idx_post_post_type ON post(post_type);
CREATE INDEX idx_comment_post_id ON comment(post_id);
CREATE INDEX idx_comment_user_id ON comment(user_id);

CREATE INDEX idx_report_user_id ON report(user_id);
CREATE INDEX idx_report_incampus_location_id ON report(incampus_university_location_id);
CREATE INDEX idx_report_elevator_id ON report(elevator_id);
CREATE INDEX idx_report_external_location_id ON report(external_location_id);
CREATE INDEX idx_report_feature_type_id ON report(feature_type_id);
CREATE INDEX idx_report_status ON report(status);
CREATE INDEX idx_help_request_user_id ON help_request(user_id);
CREATE INDEX idx_help_request_incampus_location_id ON help_request(incampus_university_location_id);
CREATE INDEX idx_help_request_status ON help_request(status);

CREATE INDEX idx_favorite_location_user_id ON favorite_location(user_id);
CREATE INDEX idx_favorite_route_user_id ON favorite_route(user_id);
CREATE INDEX idx_favorite_route_accessibility_profile_id ON favorite_route(accessibility_profile_id);
CREATE INDEX idx_favorite_route_origin_incampus ON favorite_route(origin_incampus_location_id);
CREATE INDEX idx_favorite_route_destination_incampus ON favorite_route(destination_incampus_location_id);
CREATE INDEX idx_favorite_route_origin_external ON favorite_route(origin_external_location_id);
CREATE INDEX idx_favorite_route_destination_external ON favorite_route(destination_external_location_id);

CREATE INDEX idx_accessibility_profile_user_id ON accessibility_profile(user_id);

CREATE INDEX idx_external_location_geom
ON external_location
USING GIST (geom);

CREATE INDEX idx_incampus_location_geom
ON incampus_university_location
USING GIST (geom);