#! /bin/bash

set -e

pipx install uv
uv sync
uv run pre-commit install

cd pipeline_dbt
uv run dbt deps
