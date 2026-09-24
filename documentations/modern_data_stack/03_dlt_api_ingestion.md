# 03 — Scenario B: Load API Data into Snowflake with dlt

Use this path when your source is a REST API.

Course reference: `07_extract_load_api_dlt`

---

## Goal

```text
REST API
   |
   v
requests
   |
   v
dlt resource
   |
   v
Snowflake
PROJECT_DB.staging.<table>
```

Before starting, complete `01_snowflake_foundation.md`.

---

# Part 1 — Set up the Python environment

If you already created the project's `.venv`, reuse it.

Activate it.

### Windows Git Bash

```bash
source .venv/Scripts/activate
```

### macOS/Linux

```bash
source .venv/bin/activate
```

Install:

```bash
uv pip install "dlt[snowflake]" requests ipykernel
```

---

# Part 2 — Recommended folder structure

```text
dlt_code/
├── .dlt/
│   └── secrets.toml
├── api_eda.ipynb
└── load_api.py
```

Use the notebook for exploration.

Use the `.py` script for the repeatable pipeline.

---

# Part 3 — Configure Snowflake for dlt

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

Protect it:

```gitignore
.dlt/
**/.dlt/
**/secrets.toml
```

---

# Part 4 — Explore the API before building the pipeline

Do not start by loading everything.

First learn the API response.

```python
import requests

url = "https://example.com/search"

params = {
    "q": "data engineer",
    "limit": 10,
}

response = requests.get(url, params=params, timeout=30)
response.raise_for_status()

json_response = response.json()

print(json_response.keys())
```

Then inspect the collection containing the records.

For the JobTech-style response used in the course:

```python
hits = json_response.get("hits", [])

print("Number returned:", len(hits))

if hits:
    print(hits[0])
```

### Important lesson about `limit`

If:

```python
"limit": 0
```

the API may return metadata such as `total` but no records in `hits`.

If you want actual records, use a positive limit.

---

# Part 5 — Create a reusable API helper

```python
import requests


def _get_json(url: str, params: dict) -> dict:
    """Send a GET request and return decoded JSON."""
    response = requests.get(
        url,
        params=params,
        headers={"accept": "application/json"},
        timeout=30,
    )
    response.raise_for_status()
    return response.json()
```

The leading underscore in `_get_json` is a Python convention meaning "internal helper".

---

# Part 6 — Turn API records into a dlt resource

Example for an API whose records are under `"hits"`:

```python
import dlt


@dlt.resource(write_disposition="replace")
def api_resource(url: str, params: dict):
    payload = _get_json(url, params)

    for record in payload.get("hits", []):
        yield record
```

`yield` sends one record at a time to dlt.

---

# Part 7 — Create the complete API pipeline

Create:

```text
dlt_code/load_api.py
```

```python
from pathlib import Path
import os

import dlt
import requests


def _get_json(url: str, params: dict) -> dict:
    response = requests.get(
        url,
        params=params,
        headers={"accept": "application/json"},
        timeout=30,
    )
    response.raise_for_status()
    return response.json()


@dlt.resource(write_disposition="replace")
def api_resource(url: str, params: dict):
    payload = _get_json(url, params)

    for record in payload.get("hits", []):
        yield record


def run_pipeline(query: str, table_name: str):
    pipeline = dlt.pipeline(
        pipeline_name="project_api_pipeline",
        destination="snowflake",
        dataset_name="staging",
    )

    url = "https://example.com/search"

    params = {
        "q": query,
        "limit": 100,
    }

    load_info = pipeline.run(
        api_resource(url=url, params=params),
        table_name=table_name,
    )

    print(load_info)


if __name__ == "__main__":
    working_directory = Path(__file__).parent
    os.chdir(working_directory)

    run_pipeline(
        query="data engineer",
        table_name="data_field_job_ads",
    )
```

Replace the URL and response structure with your actual API.

---

# Part 8 — API keys

If the API requires a key, do **not** hard-code it in `load_api.py`.

Store sensitive values in:

```text
.dlt/secrets.toml
environment variables
a managed secret store
```

Also keep the key out of:

```text
Git history
screenshots
committed notebooks
README files
public issues
```

---

# Part 9 — Pagination

Many APIs return only one page at a time.

Common patterns:

```text
page + page_size
offset + limit
next URL
cursor
```

Before calling the pipeline complete, ask:

```text
Am I loading all records, or only the first page?
```

---

# Part 10 — Run the pipeline

```bash
python dlt_code/load_api.py
```

---

# Part 11 — Verify in Snowflake

```sql
USE WAREHOUSE dev_wh;
USE DATABASE PROJECT_DB;
USE SCHEMA staging;

SHOW TABLES;

SELECT *
FROM data_field_job_ads
LIMIT 10;
```

Row count:

```sql
SELECT COUNT(*)
FROM data_field_job_ads;
```

---

# Part 12 — Schema inference warnings

dlt infers Snowflake columns from observed values.

If a field contains only `NULL` values in the sample, dlt may not know which type to assign.

Possible responses:

1. load more representative source data;
2. provide explicit dlt column hints;
3. omit unneeded fields;
4. investigate whether the API field is always empty.

Repeated schema warnings should be investigated rather than ignored.

---

# Part 13 — Common API mistakes

## `IndexError: list index out of range`

Example:

```python
params = {"limit": 1}
hits[1]
```

With one returned record, only:

```python
hits[0]
```

exists.

---

## Getting the “latest” result incorrectly

Do not assume:

```python
hits[-1]
```

is the newest record.

That is only valid if the API guarantees that ordering.

Check for:

```text
published date
created date
sort parameter
ordering documentation
```

---

## HTTP errors

Always use:

```python
response.raise_for_status()
```

This prevents HTTP failures from being treated as normal source data.

---

# Final checklist

- [ ] correct `.venv` activated
- [ ] `requests` and dlt installed
- [ ] API explored before loading
- [ ] response keys understood
- [ ] record list identified
- [ ] pagination checked
- [ ] API key protected if required
- [ ] dlt resource created
- [ ] pipeline loads to `staging`
- [ ] Snowflake row count checked
- [ ] schema inference warnings reviewed
