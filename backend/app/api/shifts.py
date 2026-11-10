
from datetime import datetime

from fastapi import APIRouter

from app.models.shift import ShiftInput
from app.repositories.shifts import save_shift, get_all_shifts
from app.services.payroll import calculate_shift_pay

router = APIRouter(prefix="/shifts", tags=["Shifts"])


def build_shift_response(row: dict) -> dict:
    start = datetime.fromisoformat(row["start_time"])
    end = datetime.fromisoformat(row["end_time"])

    calculations = calculate_shift_pay(
        start_time=start,
        end_time=end,
        unpaid_break_minutes=row["unpaid_break_minutes"],
        hourly_rate=row["hourly_rate"],
    )

    return {
        **row,
        **calculations,
    }


@router.post("", status_code=201)
def create_shift(shift: ShiftInput):
    saved_shift = save_shift(shift)
    return build_shift_response(saved_shift)


@router.get("")
def list_shifts():
    rows = get_all_shifts()
    return [build_shift_response(row) for row in rows]
