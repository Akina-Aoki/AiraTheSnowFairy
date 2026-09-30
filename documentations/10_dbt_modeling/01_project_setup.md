# 1. Start from an empty repository

## What and why

Create an isolated Python environment and reproduce the lesson-oriented folder layout. Isolation prevents this project's dlt, dbt, Snowflake connector, pandas, and Streamlit versions from interfering with other projects.

## Create the repository and environment

From the new repository root:

```bash
git init
python -m venv .venv
source .venv/bin/activate                 # Windows PowerShell: .venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install dlt[snowflake] requests pandas dbt-core dbt-snowflake \
  python-dotenv streamlit snowflake-connector-python
```

These dependencies are inferred from the actual imports in:

- `10_dbt_modeling/dlt_code/load_job_ads.py` (`dlt`, `requests`);
- `10_dbt_modeling/dbt_code/` (`dbt-core`, Snowflake adapter);
- `12_dashboard_streamlit/connect_data_warehouse.py` (`python-dotenv`, connector, pandas);
- `12_dashboard_streamlit/dashboard.py` (`streamlit`).

The learning notes use `uv pip install`, so using an existing uv environment is also valid:

```bash
uv pip install 'dlt[snowflake]' requests pandas dbt-core dbt-snowflake \
  python-dotenv streamlit snowflake-connector-python
```

There is no committed root `requirements.txt` or `pyproject.toml`; record tested versions in your new repository rather than assuming reproducibility from this repository alone.

## Copy the meaningful structure

For a clean rebuild, preserve at least:

```text
10_dbt_modeling/
  dlt_code/load_job_ads.py
  dbt_code/{dbt_project.yml,packages.yml,package-lock.yml,macros/,models/}
  sql/
11_dbt_testing/dbt_code/models/schema.yml
12_dashboard_streamlit/{connect_data_warehouse.py,dashboard.py,run_dashboard.py,streamlit_sql/}
documentation/
```

The numbered folders are lesson snapshots, not a set of independent production services. Do not run every version of the dlt/dbt project; use `10_dbt_modeling/` and then add the tests/dashboard described later.

## Secrets and generated files

The root `.gitignore` already excludes `.venv/`, `.env`, `.env.*`, `**/.dlt/`, `.streamlit/secrets.toml`, `target/`, `logs/`, and `dbt_packages/`. Preserve these rules. Also keep private RSA keys, passwords, `~/.dbt/profiles.yml`, and local dlt state out of Git.

Important distinction:

- commit `packages.yml` and `package-lock.yml` (instructions and resolved versions);
- do not commit `dbt_packages/` (downloaded dependencies);
- do not commit `target/` (compiled SQL/docs) or `logs/`;
- do not commit `.dlt/secrets.toml`, `.env`, or private keys.

**Security warning:** `12_dashboard_streamlit/streamlit_sql/01_setup_user_reporter.sql` currently contains a literal example password. Treat it as compromised, rotate it if it was ever used, and replace it with a placeholder in a clean rebuild. The service-account alternative in `03_setup_reporter_service_acc.sql` contains only a public-key placeholder, but its corresponding private key must remain local.

## Verify before continuing

```bash
git status --short
python --version
python -c "import dlt, requests, dbt, streamlit, snowflake.connector, pandas"
git check-ignore .venv .env 10_dbt_modeling/dlt_code/.dlt/secrets.toml \
  10_dbt_modeling/dbt_code/target 10_dbt_modeling/dbt_code/dbt_packages
```

The import command should exit without an exception. `git check-ignore` should print every sensitive/generated path. Next, create the Snowflake objects on which both dlt and dbt depend.
