# 02 — Scenario A: Load a CSV into Snowflake with dlt

Use this path when your source is a local CSV file.

Course reference: `06_extract_load_csv_dlt`

---

## Goal

```text
CSV file
   |
   v
Python + dlt
   |
   v
Snowflake
PROJECT_DB.staging.<table>
```

Before starting, complete `01_snowflake_foundation.md`.

---

# Part 1 — Set up the Python environment

From the root of your repository:

```bash
pip install uv
```

Install `uv` globally when no virtual environment is active.

Create the virtual environment:

```bash
uv venv
```

Activate it.

### Windows Git Bash

```bash
source .venv/Scripts/activate
```

### macOS/Linux

```bash
source .venv/bin/activate
```

Install packages:

```bash
uv pip install "dlt[snowflake]" pandas ipykernel "dlt[parquet]"
```

Verify:

```bash
dlt --version
pip list
```

---

# Part 2 — Create the CSV pipeline folder

Recommended structure:

```text
dlt_code/
├── .dlt/
│   └── secrets.toml
├── data/
│   └── source.csv
└── load_csv.py
```

Create the folders:

```bash
mkdir -p dlt_code/.dlt
mkdir -p dlt_code/data
```

Put the CSV inside `dlt_code/data/`.

---

# Part 3 — Add Snowflake credentials

Create:

```text
dlt_code/.dlt/secrets.toml
```

```toml
[destination.snowflake.credentials]
database = "PROJECT_DB"
username = "extract_loader"
password = "<YOUR_PASSWORD>"
host = "<YOUR_SNOWFLAKE_ACCOUNT_IDENTIFIER>"
warehouse = "dev_wh"
role = "project_dlt_role"
```

Example:

```toml
[destination.snowflake.credentials]
database = "movies"
username = "extract_loader"
password = "<PASSWORD>"
host = "<ACCOUNT_IDENTIFIER>"
warehouse = "dev_wh"
role = "movies_dlt_role"
```

---

# Part 4 — Protect the secrets

Your root `.gitignore` must include:

```gitignore
.dlt/
**/.dlt/
**/secrets.toml
```

Before committing:

```bash
git status
```

Make sure `secrets.toml` is not shown as a file to commit.

---

# Part 5 — Create the CSV loader

Create:

```text
dlt_code/load_csv.py
```

Reusable template:

```python
from pathlib import Path
import os

import dlt
import pandas as pd


@dlt.resource(write_disposition="replace")
def csv_resource(file_path: Path, **read_csv_kwargs):
    """Read a CSV file and expose it as a dlt resource."""
    dataframe = pd.read_csv(file_path, **read_csv_kwargs)
    yield dataframe


def run_pipeline():
    working_directory = Path(__file__).parent
    os.chdir(working_directory)

    csv_path = working_directory / "data" / "source.csv"

    pipeline = dlt.pipeline(
        pipeline_name="project_pipeline",
        destination="snowflake",
        dataset_name="staging",
    )

    load_info = pipeline.run(
        csv_resource(csv_path),
        table_name="source_data",
    )

    print(load_info)


if __name__ == "__main__":
    run_pipeline()
```

Change:

```text
source.csv
project_pipeline
source_data
```

to names that fit your project.

---

# Part 6 — If the CSV uses another encoding

Example:

```python
csv_resource(csv_path, encoding="latin1")
```

You can pass normal `pandas.read_csv()` arguments:

```python
csv_resource(
    csv_path,
    encoding="latin1",
    sep=",",
)
```

---

# Part 7 — Understand `write_disposition`

The course starts with:

```python
write_disposition="replace"
```

The three important dlt dispositions are:

| Disposition | Meaning |
|---|---|
| `replace` | Replace the destination data on each load |
| `append` | Add new rows |
| `merge` | Insert/update rows using a key |

For learning and small full-refresh datasets, `replace` is easy to reason about.

For production pipelines, choose the disposition based on how the source changes.

---

# Part 8 — Run the pipeline

Make sure the virtual environment is active.

From the repository root:

```bash
python dlt_code/load_csv.py
```

Or:

```bash
cd dlt_code
python load_csv.py
```

A successful run should print load information showing that a load package reached Snowflake.

---

# Part 9 — Verify in Snowflake

```sql
USE WAREHOUSE dev_wh;
USE DATABASE PROJECT_DB;
USE SCHEMA staging;

SHOW TABLES;

SELECT *
FROM source_data
LIMIT 10;
```

Check row count:

```sql
SELECT COUNT(*)
FROM source_data;
```

---

# Part 10 — Common problems

## `ModuleNotFoundError: No module named 'dlt'`

You are probably using the wrong Python environment.

Check:

```bash
which python
```

Reactivate on Windows Git Bash:

```bash
source .venv/Scripts/activate
```

---

## dlt cannot find Snowflake credentials

Check:

```text
dlt_code/
├── .dlt/
│   └── secrets.toml
└── load_csv.py
```

The script changes the working directory to the same folder containing `.dlt`.

---

## Snowflake says the role cannot create a table

Verify:

```sql
SHOW GRANTS TO ROLE project_dlt_role;
```

The role needs:

```text
USAGE on warehouse
USAGE on database
USAGE on staging schema
CREATE TABLE on staging schema
DML privileges on staging tables
```

---

## The file exists but pandas cannot read it

Print:

```python
print(csv_path.resolve())
```

Confirm the file really exists there.

---

# Final checklist

- [ ] virtual environment created
- [ ] correct virtual environment activated
- [ ] dlt Snowflake package installed
- [ ] CSV placed in `dlt_code/data`
- [ ] `.dlt/secrets.toml` created
- [ ] secrets ignored by Git
- [ ] loader script created
- [ ] pipeline run succeeds
- [ ] table appears in `PROJECT_DB.staging`
- [ ] row count checked in Snowflake
