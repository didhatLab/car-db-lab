from typing import List, Type
from psycopg2.extensions import cursor

from src.base import SqlClass


class PostgresInserter:

    def __init__(self, cur: cursor, query_builder):
        self._cur = cur
        self.query_builder = query_builder

    def insert_many_data(self,
                         data: List[SqlClass],
                         table_spec: Type[SqlClass]):
        query = self.query_builder.build_query_for_many_insert(data, table_spec)
        self._cur.execute(query)

        return
