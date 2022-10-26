from dataclasses import asdict, fields
from string import Template
from typing import Type, List, Union

from src.base import SqlClass
from src.tables import Car

sql_for_inserting_template = Template("($values)")


def value2sql(val: Union[str, int]):
    if isinstance(val, int):
        return str(val)
    if isinstance(val, str):
        return f"'{val}'"


def dataclass2sql(obj: SqlClass):
    kek = asdict(obj)
    lol = [value2sql(val) for val in kek.values()]
    string_values = ", ".join(lol)
    return sql_for_inserting_template.substitute(values=string_values)


def build_table_name(sql_class: Type[SqlClass]):
    return sql_class.__name__


def build_insert_instruction(sql_class: Type[SqlClass]):
    table_fields = [field.name for field in fields(sql_class)]
    return ", ".join(table_fields)


def build_insert_values(rows: List[SqlClass]):
    string_rows = []
    for row in rows:
        row_as_string = dataclass2sql(row)
        string_rows.append(row_as_string)
    return ", ".join(string_rows)


def list2sqlclass(values: List[str], sql_class: Type[SqlClass]):
    field_types = [field.type for field in fields(sql_class)]
    values_with_correct_types = [value_type(value)
                                 for value, value_type
                                 in zip(values, field_types)]
    return sql_class(*values_with_correct_types)


if __name__ == "__main__":
    joj = ["1", "kek", "lol", "23"]
    test = list2sqlclass(joj, Car)
    print(test)
