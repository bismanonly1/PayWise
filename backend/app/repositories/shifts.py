
import sqlite3
from pathlib import Path

from app.models.shift import ShiftInput

DB_PATH = Path(__file__).resolve().parents[2] / "paywise.db"


def get_connection():
    connection = sqlite3.connect(DB_PATH)
    connection.row_factory = sqlite3.Row
    return connection


def initialize_database():
    with get_connection() as connection:
        connection.execute("""
            CREATE TABLE IF NOT EXISTS shifts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                location TEXT NOT NULL,
                start_time TEXT NOT NULL,
                end_time TEXT NOT NULL,
                unpaid_break_minutes INTEGER NOT NULL,
                hourly_rate REAL NOT NULL
            )
        """)


def save_shift(shift: ShiftInput) -> dict:
    with get_connection() as connection:
        cursor = connection.execute(
            """
            INSERT INTO shifts (
                location,
                start_time,
                end_time,
                unpaid_break_minutes,
                hourly_rate
            )
            VALUES (?, ?, ?, ?, ?)
            """,
            (
                shift.location.strip(),
                shift.start_time.isoformat(),
                shift.end_time.isoformat(),
                shift.unpaid_break_minutes,
                shift.hourly_rate,
            ),
        )

        row = connection.execute(
            "SELECT * FROM shifts WHERE id = ?",
            (cursor.lastrowid,),
        ).fetchone()

    if row is None:
        raise RuntimeError("Shift could not be retrieved after saving")

    return dict(row)


def get_all_shifts() -> list[dict]:
    with get_connection() as connection:
        rows = connection.execute(
            "SELECT * FROM shifts ORDER BY start_time DESC"
        ).fetchall()

    return [dict(row) for row in rows]
