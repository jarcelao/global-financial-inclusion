#! /bin/bash

set -e

pipx install pre-commit
pre-commit install

cd src/pipeline_dbt

pipx install uv
uv sync
uv run dbt deps

cd ../dashboard_evidence
npm i
