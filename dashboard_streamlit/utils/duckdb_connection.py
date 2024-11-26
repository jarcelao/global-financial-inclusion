import duckdb

DUCKDB_PATH = "../data/warehouse.duckdb"


class DuckDBConnection:
    def __init__(self):
        self.conn = duckdb.connect(DUCKDB_PATH)

    def get_connection(self) -> duckdb.DuckDBPyConnection:
        return self.conn
