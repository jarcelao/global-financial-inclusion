# Environment Setup

## Option 1: Dev Container

This project contains a Dev Container specification (`.devcontainer/`) that will install all dependencies for you.

You can launch this repo in a Codespace, or locally with VSCode and the Dev Containers extension.

## Option 2: Local

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

## What's Next?

After setting up, you can run the data pipeline to extract and transform the raw data. Refer to [pipeline.md](pipeline.md) for this process.

When the data has been processed, you can now open the included dashboard or use the data warehouse for your own analyses. Refer to [data.md](data.md) for more information.
