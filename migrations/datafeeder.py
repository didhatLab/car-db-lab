import pathlib
import psycopg2
from config import get_postgres_dsn
from src.filereader import FileReader
from src.tables import Car, Garage

SIGNAL_POINT = "[end]"
SIGNAL = True
END_POINT = "[fullend]"
list_tables_data = [Car, Garage]


def migration():
    conn = psycopg2.connect(get_postgres_dsn())
    cur = conn.cursor()
    reader = FileReader(endpoint=END_POINT,
                        point_for_signal=SIGNAL_POINT,
                        signal=SIGNAL,
                        data_class_for_converting=Car)
    for obj in reader.read_generator_file("data.txt"):
        print(obj)


if __name__ == "__main__":
    migration()
