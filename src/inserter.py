from typing import List, Type
from psycopg2.extensions import cursor

from src.base import SqlClass


class PostgresInserter:

    def __init__(self, query_builder):
        self.query_builder = query_builder

    def insert_many_data(self, cur: cursor,
                         data: List[SqlClass],
                         table_spec: Type[SqlClass]):
        query = self.query_builder.build_query_for_many_insert(data, table_spec)
        cur.execute(query)


