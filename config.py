import os
from dotenv import load_dotenv

load_dotenv()

postgres_dsn = os.getenv("POSTGRES_DSN")


def get_postgres_dsn():
    return postgres_dsn
