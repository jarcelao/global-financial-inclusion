# Data Pipeline

The data pipeline is run by dbt on DuckDB. It takes the raw data from the `data/raw/` folder and saves the transformed data as a `warehouse.duckdb` file in the `data/` folder.

## Download the raw data

To access the raw data from the World Bank Microdata Library, you will need to create an account and request access to the data. Follow the instructions below:

1. Create an account on the [World Bank Microdata Library](https://microdata.worldbank.org/).
2. Open the [dataset page](https://microdata.worldbank.org/index.php/catalog/4607/get-microdata) and click on "Get Microdata".
3. Fill out the request form.
4. Upon accessing the downloads page, download the data in CSV format.
5. Extract the downloaded zip and place the `micro_world_139countries.csv` file in the `data/raw/` folder.

## Run the data pipeline

Once the raw data is in place you can run the data pipeline by running the below commands:

```bash
cd src/pipeline_dbt
uv run dbt build
```

If all goes well, you should see the `warehouse.duckdb` file in the `data/` folder.

To see the documentation of the data pipeline, run the below commands:
```bash
uv run dbt docs generate
uv run dbt docs serve
```

This will start a local server and point your browser to the documentation site.

## Sources

For more information, you may consult with the below resources:

* [DuckDB Documentation](https://duckdb.org/docs)
* [dbt Documentation](https://docs.getdbt.com/docs)
