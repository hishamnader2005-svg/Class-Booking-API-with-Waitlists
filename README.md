# Class Booking API

A backend API for booking spots in classes (swim lessons, gym classes, appointment slots) with waitlists. Built to handle the hard part of booking systems: **two people grabbing the last spot at the same time**.

Built with **Python, FastAPI and PostgreSQL**.

> Status: in development. See the [Roadmap](#roadmap) for what's done and what's next.

## Features

- Browse classes and upcoming sessions
- Book and cancel a spot
- Capacity enforced safely under concurrent requests (DB transactions + row locking)
- Waitlist with automatic promotion when someone cancels
- Role-based access: member, instructor, admin
- Idempotent booking requests (retries and double-clicks never double-book)
- Background jobs for reminders and expiring holds
- Auto-generated API docs (Swagger UI at `/docs`)

## Tech Stack

| Layer | Choice |
|-------|--------|
| Language | Python 3.11+ |
| Framework | FastAPI |
| Database | PostgreSQL 16 |
| ORM / DB access | SQLAlchemy + psycopg |
| Tests | pytest |

## Getting Started

### Prerequisites

- Python 3.11+
- PostgreSQL (via [Postgres.app](https://postgresapp.com) or `brew install postgresql@16`)

### Setup

```bash
# clone
git clone https://github.com/hishamnader2005-svg/REPO-NAME.git
cd REPO-NAME

# virtual environment
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# database
createdb bookings
psql bookings -f schema.sql

# run the server
uvicorn main:app --reload
```

The API runs at `http://localhost:8000` and the interactive docs are at `http://localhost:8000/docs`.

### Reset the database (during development)

```bash
dropdb bookings && createdb bookings && psql bookings -f schema.sql
```

## Database Schema

| Table | Purpose |
|-------|---------|
| `users` | Members, instructors and admins |
| `classes` | A class definition (title, instructor, default capacity) |
| `class_sessions` | One class on a specific date/time, with its own capacity |
| `bookings` | A user's spot in a session. Status is `confirmed`, `waitlisted` or `cancelled` |

Key design points:

- A **partial unique index** stops a user holding two active bookings for the same session, so the database itself blocks duplicates.
- The waitlist is just `status = 'waitlisted'` ordered by `created_at`. No separate table needed.
- Sessions are separate from classes so one class can run on many dates with different capacities.

## Planned Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check |
| GET | `/sessions` | List upcoming sessions with spots left |
| POST | `/bookings` | Book a spot (waitlisted if full) |
| DELETE | `/bookings/{id}` | Cancel a booking and promote the next person |
| GET | `/me/bookings` | List my bookings |

## Design Decisions

_To be filled in as I build. Planned topics:_

- Why Postgres row locking (`SELECT ... FOR UPDATE`) for capacity
- How the waitlist promotion works inside a single transaction
- How idempotency keys are stored and checked
- Trade-offs of Postgres-backed background jobs vs. a separate queue

## Testing

```bash
pytest
```

Includes a concurrency test that fires 100 simultaneous booking requests at a session with 10 spots and asserts exactly 10 are confirmed.

## Roadmap

- [x] Project setup and schema
- [ ] `/health` endpoint and DB connection
- [ ] List sessions, book a spot, cancel
- [ ] Concurrency-safe booking + concurrency test
- [ ] Waitlist and auto-promotion on cancel
- [ ] Auth and roles
- [ ] Idempotency keys
- [ ] Background jobs (reminders, hold expiry)
- [ ] Alembic migrations
- [ ] GitHub Actions CI
- [ ] Deployment

## License

MIT
