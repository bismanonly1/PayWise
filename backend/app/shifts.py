
import sqlite3
from datetime import datetime
from pathlib import Path

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field, model_validator

router = APIRouter(prefix="/shifts", tags=["Shifts"])

DB_PATH = Path(__file__).resolve().parent.parent / "paywise.db"


class ShiftInput(BaseModel):
    location: str = Field(min_length=1)
    start_time: datetime
    end_time: datetime
    unpaid_break_minutes: int = Field(ge=0)
    hourly_rate: float = Field(ge=0, le=100000)

    @model_validator(mode="after")
    def validate_shift(self):
        if self.start_time.tzinfo != self.end_time.tzinfo:
            raise ValueError("Start and end must use matching timezones")

        if self.end_time <= self.start_time:
            raise ValueError("End time must be after start time")

        total_minutes = (
            self.end_time - self.start_time
        ).total_seconds() / 60

        if self.unpaid_break_minutes >= total_minutes:
            raise ValueError("Unpaid break must be shorter than shift")

        return self


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


initialize_database()


def format_shift(row):
    start = datetime.fromisoformat(row["start_time"])
    end = datetime.fromisoformat(row["end_time"])

    paid_hours = (
        (end - start).total_seconds() / 60
        - row["unpaid_break_minutes"] / 60
    )

    return {
        **dict(row),
        "paid_hours": round(paid_hours, 4),
        "gross_base_pay": round(
            paid_hours * row["hourly_rate"], 2
        ),
    }


@router.post("", status_code=201)
def create_shift(shift: ShiftInput):
    with get_connection() as connection:
        cursor = connection.execute(
            """
            INSERT INTO shifts (
                location, start_time, end_time,
                unpaid_break_minutes, hourly_rate
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
        shift_id = cursor.lastrowid

        row = connection.execute(
            "SELECT * FROM shifts WHERE id = ?",
            (shift_id,),
        ).fetchone()

    if row is None:
        raise HTTPException(status_code=500, detail="Save failed")

    return format_shift(row)


@router.get("")
def list_shifts():
    with get_connection() as connection:
        rows = connection.execute(
            "SELECT * FROM shifts ORDER BY start_time DESC"
        ).fetchall()

    return [format_shift(row) for row in rows]
