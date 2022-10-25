from dataclasses import dataclass
from src.base import SqlClass


@dataclass
class Car(SqlClass):
    car_id: int
    brand: str
    atp_owner: str
    discount_percent: int


@dataclass
class Garage(SqlClass):
    car_id: int
    number_garage: str
    place: str
    commission_percents: int
