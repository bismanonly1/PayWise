
from datetime import datetime
from decimal import Decimal, ROUND_HALF_UP


def calculate_shift_pay(
    start_time: datetime,
    end_time: datetime,
    unpaid_break_minutes: int,
    hourly_rate: float,
) -> dict:
    duration_seconds = Decimal(
        str((end_time - start_time).total_seconds())
    )

    paid_seconds = duration_seconds - (
        Decimal(unpaid_break_minutes) * Decimal("60")
    )

    paid_hours = paid_seconds / Decimal("3600")

    gross_pay = (
        paid_hours * Decimal(str(hourly_rate))
    ).quantize(
        Decimal("0.01"),
        rounding=ROUND_HALF_UP,
    )

    return {
        "paid_hours": float(
            paid_hours.quantize(Decimal("0.0001"))
        ),
        "gross_base_pay": float(gross_pay),
    }
