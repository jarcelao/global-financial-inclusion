## Environment Setup

### Option 1: Dev Container

This project contains a Dev Container specification (`.devcontainer/`) that will install all dependencies for you.

You can launch this repo in a Codespace, or locally with VSCode and the Dev Containers extension.

### Option 2: Local

Before working with the project, make sure you have the following installed:

* Python 3.12+
    * [pipx](https://pipx.pypa.io/stable/installation/)
    * [uv](https://docs.astral.sh/uv/getting-started/installation)
* Node 18+

Perform the following steps:

1. Clone the repo
```bash
git clone https://github.com/jarcelao/global-financial-inclusion.git
cd global-financial-inclusion
```
2. Setup `pre-commit` for the repository.
```bash
pipx install pre-commit
pre-commit install
```

3. Install the dependencies for the dbt project.
```bash
cd src/pipeline_dbt
uv sync
uv run dbt deps
```

4. Install the dependencies for the Evidence project.
```bash
cd src/pipeline_evidence
npm i
```

## Data Pipeline

The data pipeline is run by dbt on DuckDB. It takes the raw data from the `data/raw/` folder and saves the transformed data as a `warehouse.duckdb` file in the `data/` folder.

### Download the raw data

To access the raw data from the World Bank Microdata Library, you will need to create an account and request access to the data.

Due to the above restriction and the size of the file (~40MB), the raw data is not included in this repository. To download it, follow the instructions below:

1. Create an account on the [World Bank Microdata Library](https://microdata.worldbank.org/).
2. Open the [dataset page](https://microdata.worldbank.org/index.php/catalog/4607/get-microdata) and click on "Get Microdata".
3. Fill out the request form.
4. Upon accessing the downloads page, download the data in CSV format.
5. Extract the downloaded zip and place the `micro_world_139countries.csv` file in the `data/raw/` folder.

### Run the data pipeline

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

## Data Schema

`warehouse.duckdb` contains the following tables which serve as the data marts:

![](schema/schema.png)

You are free to use this file to create your own visualizations using other BI tools. However, keep in mind that this data is still under the World Bank's [Terms of Use](https://microdata.worldbank.org/index.php/terms-of-use) for Public Use data.

## Evidence Site

To run the Evidence dashboard locally, run the below commands. This assumes that you have already run the data pipeline:

```bash
cd src/pipeline_evidence

# If running for the first time
npm run sources

npm run dev

# If using devcontainer
# npm run dev -- --host 0.0.0.0
```

This will start a local server and point your browser to the site.

## Sources

For more information, you may consult with the below resources:

* [World Bank Microdata Library](https://microdata.worldbank.org/)
* [DuckDB Documentation](https://duckdb.org/docs)
* [dbt Documentation](https://docs.getdbt.com/docs)
* [Evidence Documentation](https://docs.evidence.dev)
