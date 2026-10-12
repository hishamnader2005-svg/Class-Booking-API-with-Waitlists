CREATE TABLE users (
    id          SERIAL PRIMARY KEY,
    email       TEXT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    role        TEXT NOT NULL DEFAULT 'member'
                CHECK (role IN ('member', 'instructor', 'admin')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE classes (
    id             SERIAL PRIMARY KEY,
    title          TEXT NOT NULL,
    description    TEXT,
    instructor_id  INT REFERENCES users(id),
    default_capacity INT NOT NULL CHECK (default_capacity > 0)
);

-- one class on a specific date/time
CREATE TABLE class_sessions (
    id          SERIAL PRIMARY KEY,
    class_id    INT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    starts_at   TIMESTAMPTZ NOT NULL,
    ends_at     TIMESTAMPTZ NOT NULL,
    capacity    INT NOT NULL CHECK (capacity > 0),
    CHECK (ends_at > starts_at)
);

CREATE TABLE bookings (
    id          SERIAL PRIMARY KEY,
    session_id  INT NOT NULL REFERENCES class_sessions(id) ON DELETE CASCADE,
    user_id     INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status      TEXT NOT NULL DEFAULT 'confirmed'
                CHECK (status IN ('confirmed', 'waitlisted', 'cancelled')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- a user can't hold two active bookings for the same session
CREATE UNIQUE INDEX one_active_booking_per_user
    ON bookings (session_id, user_id)
    WHERE status IN ('confirmed', 'waitlisted');

CREATE INDEX idx_bookings_session_status ON bookings (session_id, status);
CREATE INDEX idx_sessions_starts_at ON class_sessions (starts_at);