from typing import List, Type
from string import Template

from src.tables import Car
from src.base import SqlClass
from src.utilis import build_insert_values, build_insert_instruction, build_table_name


class QueryBuilder:
    _insert_template = Template('INSERT INTO $name ($spec) VALUES $values ;')

    def _build_query(self, values, sql_type):
        table_name = build_table_name(sql_type)
        instruction = build_insert_instruction(sql_type)
        values = build_insert_values(values)
        insert_statement = self._insert_template.substitute(name=table_name,
                                                            spec=instruction,
                                                            values=values)
        return insert_statement

    def build_query_for_many_insert(self, values: List[SqlClass],
                                    values_type: Type[SqlClass]):
        insert = self._build_query(values,  values_type)
        return insert


if __name__ == "__main__":
    builder = QueryBuilder()
    kek = [Car(car_id=1, brand="kek", atp_owner="ko", discount_percent=12)]
    res = builder.build_query_for_many_insert(kek, Car)
    print(res)
