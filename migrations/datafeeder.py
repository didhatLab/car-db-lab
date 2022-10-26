import psycopg2
from psycopg2.extensions import cursor, connection
from typing import List
from config import get_postgres_dsn
from src.base import SqlClass
from src.filereader import FileReader
from src.tables import Car, Garage, Details, Repair
from src.bootstrap import bootstrap_postgres_inserter

SIGNAL_POINT = "[end]"
SIGNAL = True
END_SIGNAL = False
END_POINT = "[fullend]"
tables_models = [Repair]


def migration():
    conn: connection = psycopg2.connect(get_postgres_dsn())
    cur: cursor = conn.cursor()
    inserter = bootstrap_postgres_inserter(cur)
    tables_model_index = 0
    reader = FileReader(endpoint=END_POINT,
                        point_for_signal=SIGNAL_POINT,
                        end_signal=END_SIGNAL,
                        signal=SIGNAL,
                        data_class_for_converting=Repair)
    keeps: List[SqlClass] = []
    sql_model = tables_models[tables_model_index]
    for obj in reader.read_generator_file("data.txt"):
        if obj == SIGNAL or obj == END_SIGNAL:
            inserter.insert_many_data(keeps, sql_model)
            keeps.clear()
            if obj != END_SIGNAL:
                tables_model_index += 1
            sql_model = tables_models[tables_model_index]
            reader.dataclass_for_converting = sql_model
            continue
        keeps.append(obj)
    conn.commit()
    cur.close()
    conn.close()


if __name__ == "__main__":
    migration()
