from psycopg2.extensions import cursor

from src.inserter import PostgresInserter
from src.querybuilder import QueryBuilder


def bootstrap_postgres_inserter(cur: cursor) -> PostgresInserter:
    querybuilder = QueryBuilder()

    return PostgresInserter(cur, querybuilder)
