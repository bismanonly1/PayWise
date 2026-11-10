
from datetime import datetime
from math import isfinite

from pydantic import BaseModel, Field, model_validator


class ShiftInput(BaseModel):
    location: str = Field(min_length=1)
    start_time: datetime
    end_time: datetime
    unpaid_break_minutes: int = Field(ge=0)
    hourly_rate: float = Field(ge=0, le=100000)

    @model_validator(mode="after")
    def validate_shift(self):
        if not self.location.strip():
            raise ValueError("Location cannot be blank")

        if not isfinite(self.hourly_rate):
            raise ValueError("Hourly rate must be finite")

        if (self.start_time.tzinfo is None) != (
            self.end_time.tzinfo is None
        ):
            raise ValueError("Both timestamps must use the same timezone format")

        try:
            total_minutes = (
                self.end_time - self.start_time
            ).total_seconds() / 60
        except TypeError as exc:
            raise ValueError("Incompatible timestamps") from exc

        if total_minutes <= 0:
            raise ValueError("End time must be after start time")

        if self.unpaid_break_minutes >= total_minutes:
            raise ValueError("Unpaid break must be shorter than shift")

        return self
