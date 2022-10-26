from dataclasses import dataclass
from typing import Optional

from src.base import SqlClass


@dataclass
class Car(SqlClass):
    car_id: int
    brand: str
    atp_owner: str
    discount_percent: int


@dataclass
class Garage(SqlClass):
    garage_id: int
    number_garage: str
    place: str
    commission_percents: int


@dataclass
class Details(SqlClass):
    detail_id: int
    detail_name: str
    vendor: str
    cost: int
    cost: int
    max_number: int = None


@dataclass
class Repair(SqlClass):
    order_number: int
    car_id: int
    day_month_date: str
    garage_id: int
    detail_id: int
    detail_number: int
    price: int
