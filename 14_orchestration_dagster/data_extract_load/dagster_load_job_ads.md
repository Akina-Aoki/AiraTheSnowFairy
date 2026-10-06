# Understanding the dlt + Dagster Job Ads Ingestion Flow

This file defines the **dlt source** that Dagster will later orchestrate.

The main idea is:

```text
Dagster decides WHEN to run
        ↓
dlt decides HOW to extract and load
        ↓
this Python code defines WHAT data to extract
```

The overall flow is:

```text
Dagster
   ↓
jobads_source()
   ↓
jobads_resource(params)
   ↓
_get_ads(...)
   ↓
JobTech API
   ↓
JSON response
   ↓
response["hits"]
   ↓
yield one job ad at a time
   ↓
dlt
   ↓
normalize + infer schema
   ↓
Snowflake
   ↓
job_ads table
```

> Important: this file itself does **not** create the Dagster DAG.  
> It prepares a `dlt` source that another Dagster file can register as a Dagster asset.

---

## 1. Imports

```python
import dlt
import requests
import json
```

Each library has a different responsibility:

```text
requests
    ↓
communicates with JobTech API

json
    ↓
turns JSON response into Python objects

dlt
    ↓
handles data ingestion:
extract → normalize → load
```

Dagster is not imported here because the Dagster-specific orchestration code is handled elsewhere.

---

## 2. Temporary dlt staging cleanup

```python
dlt.config["load.truncate_staging_dataset"] = True
```

This tells dlt to clean up its temporary staging dataset after using it during load operations such as `replace`.

It does **not** mean:

```text
Delete my Snowflake staging schema.
```

Conceptually:

```text
dlt temporary work area
        ↓
staging_staging
        ↓
load / replace
        ↓
staging
        ↓
job_ads
```

After the load finishes, dlt cleans the temporary work area.

---

## 3. API parameters

```python
params = {
    "limit": 100,
    "occupation-field": "6Hq3_tKo_V57"
}
```

These parameters control what data is requested from JobTech.

### `limit`

```python
"limit": 100
```

Requests up to 100 job ads.

### `occupation-field`

```python
"occupation-field": "6Hq3_tKo_V57"
```

Filters the API results to the occupation field used in this project:

```text
Yrken med teknisk inriktning
```

So conceptually:

```text
params
  │
  ├── how many? → 100
  │
  └── which occupation field? → technical occupations
```

This script therefore does **not** load every job advertisement in JobTech.

---

# 4. `_get_ads()`

```python
def _get_ads(url_for_search, params):
```

This helper function is responsible for communicating with the API.

It receives:

```text
url_for_search
params
```

For example:

```text
url_for_search
↓
https://jobsearch.api.jobtechdev.se/search
```

---

## 5. Send the HTTP request

```python
response = requests.get(url_for_search, params=params)
```

This sends an HTTP GET request to JobTech.

Conceptually:

```text
GET
https://jobsearch.api.jobtechdev.se/search
    ?limit=100
    &occupation-field=6Hq3_tKo_V57
```

This is the moment the Python application asks JobTech for data.

The response from the server is stored in:

```python
response
```

---

## 6. Check for HTTP errors

```python
response.raise_for_status()
```

This checks whether the request succeeded.

For example:

```text
200 OK
    ↓
continue
```

But if JobTech returns something like:

```text
404
500
503
```

Python raises an exception.

This is useful in an orchestrated pipeline because Dagster can clearly show that the run failed instead of silently continuing with invalid data.

---

## 7. Convert JSON into Python

```python
return json.loads(response.content.decode("utf8"))
```

The API sends JSON data.

Conceptually:

```text
HTTP response
     ↓
bytes
     ↓
decode UTF-8
     ↓
JSON text
     ↓
json.loads()
     ↓
Python dictionary
```

The returned Python object may look conceptually like:

```python
{
    "total": 2345,
    "hits": [
        {
            "id": "123",
            "headline": "Data Engineer"
        },
        {
            "id": "456",
            "headline": "Software Engineer"
        }
    ]
}
```

So `_get_ads()` returns a normal Python dictionary.

---

# 8. Define the dlt resource

```python
@dlt.resource(
    table_name="job_ads",
    write_disposition="replace"
)
```

This decorator tells dlt that the function below represents data that should be extracted and loaded.

Without `@dlt.resource`, the function would just be a normal Python generator.

With it:

```text
Python generator
      ↓
dlt resource
      ↓
data that dlt knows how to load
```

---

## 9. `table_name="job_ads"`

```python
table_name="job_ads"
```

This tells dlt that the resource should be loaded into a table called:

```text
job_ads
```

Conceptually:

```text
jobads_resource
      ↓
     dlt
      ↓
Snowflake
      ↓
job_ads
```

The database and schema are configured elsewhere in the dlt pipeline configuration.

For example:

```python
dlt.pipeline(
    destination="snowflake",
    dataset_name="staging"
)
```

could conceptually produce:

```text
Snowflake

JOB_ADS database
    ↓
STAGING schema
    ↓
JOB_ADS table
```

---

# 10. `write_disposition="replace"`

```python
write_disposition="replace"
```

This means the resource behaves like a refreshed snapshot.

Instead of continuously appending more rows:

```text
APPEND

Monday:      100 rows
Tuesday:    +100 rows
Wednesday:  +100 rows

Total: 300 rows
```

`replace` behaves conceptually like:

```text
REPLACE

Monday:
100 rows

Tuesday:
old data replaced
100 current rows

Wednesday:
old data replaced
100 current rows
```

So the table represents the latest dataset returned by the API query.

---

# 11. `jobads_resource()`

```python
def jobads_resource(params):
```

This function defines how the job ads are extracted.

It receives:

```python
{
    "limit": 100,
    "occupation-field": "6Hq3_tKo_V57"
}
```

Then it defines the API base URL:

```python
url = "https://jobsearch.api.jobtechdev.se"
```

and creates the search endpoint:

```python
url_for_search = f"{url}/search"
```

Result:

```text
https://jobsearch.api.jobtechdev.se/search
```

---

# 12. Call the API and get `"hits"`

```python
for ad in _get_ads(url_for_search, params)["hits"]:
```

Break this down from the inside out.

First:

```python
_get_ads(url_for_search, params)
```

returns something like:

```python
{
    "total": ...,
    "hits": [
        {...},
        {...},
        {...}
    ]
}
```

Then:

```python
["hits"]
```

extracts only the actual advertisements:

```python
[
    {...},
    {...},
    {...}
]
```

Then:

```python
for ad in ...:
```

loops through each advertisement.

---

# 13. `yield ad`

```python
yield ad
```

Instead of returning all ads at once, the generator yields them one at a time.

Example:

```text
yield ad #1
   ↓
dlt receives it

yield ad #2
   ↓
dlt receives it

yield ad #3
   ↓
dlt receives it
```

So the flow becomes:

```text
API
 ↓
Ad 1 ──→ dlt
Ad 2 ──→ dlt
Ad 3 ──→ dlt
Ad 4 ──→ dlt
...
```

dlt then handles normalization, schema inference, and loading.

---

# 14. Resource vs Source

You already have a resource:

```python
@dlt.resource
def jobads_resource(params):
```

Think of a **resource** as one stream or table of data.

```text
resource
   ↓
job_ads
```

Then you create a source:

```python
@dlt.source
def jobads_source():
    return jobads_resource(params)
```

Think of a **source** as a container for one or more resources.

For example:

```text
JobTech Source
│
├── job_ads resource
├── occupations resource
├── employers resource
└── municipalities resource
```

In this project the source currently contains only:

```text
JobTech Source
      │
      └── job_ads resource
```

---

# 15. Why create `jobads_source()`?

```python
@dlt.source
def jobads_source():
    return jobads_resource(params)
```

The Dagster + dlt integration works with a dlt source.

So:

```text
jobads_resource
     ↓
DltResource
```

gets wrapped as:

```text
jobads_source()
     ↓
DltSource
     ↓
contains
     ↓
jobads_resource
```

That `DltSource` can then be passed into Dagster.

---

# 16. When does the API actually run?

This is an important distinction.

When Python imports this file, it mainly creates definitions:

```text
_get_ads()
jobads_resource()
jobads_source()
```

It does **not** immediately download the job ads.

The API request happens later when dlt actually executes and iterates through the resource.

Conceptually:

```text
Start Dagster
     ↓
load Python definitions
     ↓
Dagster knows about jobads_source
     ↓
Dagster materializes the asset
     ↓
dlt starts running the source
     ↓
resource starts iterating
     ↓
_get_ads() executes
     ↓
HTTP request happens
```

So:

```text
importing the file
≠
calling the API
```

---

# 17. Where Dagster fits

Another Dagster-specific file will use the dlt source and pipeline.

Conceptually it may look similar to:

```python
@dlt_assets(
    dlt_source=jobads_source(),
    dlt_pipeline=some_pipeline
)
def job_ads_assets(...):
    yield from dlt.run(...)
```

Dagster then orchestrates the execution.

The architecture becomes:

```text
                  DAGSTER
                     │
             "Run job ads asset"
                     │
                     ▼
              jobads_source()
                     │
                     ▼
            jobads_resource()
                     │
                     ▼
                _get_ads()
                     │
                     ▼
                JobTech API
                     │
                 JSON response
                     │
                     ▼
               response["hits"]
                     │
                 yield ads
                     │
                     ▼
                    dlt
               ┌─────┴─────┐
               │           │
            normalize     load
               │           │
               └─────┬─────┘
                     ▼
                  Snowflake
                     │
                     ▼
                  STAGING
                     │
                     ▼
                  JOB_ADS
```

---

# 18. Full modern data stack

This ingestion layer is only the first part of the architecture.

```text
JobTech API
     ↓
dlt
     ↓
Snowflake STAGING
     ↓
dbt
     ↓
Snowflake WAREHOUSE
     ↓
dbt
     ↓
MARTS
     ↓
Streamlit
```

Dagster sits above the workflow and orchestrates when different parts should run:

```text
                DAGSTER
                   │
        orchestrates the workflow
                   │
     ┌─────────────┼─────────────┐
     ▼             ▼             ▼
    dlt           dbt        other assets
     │             │
     ▼             ▼
 STAGING      WAREHOUSE/MARTS
```

---

# 19. Responsibility of Each Function

The easiest way to remember this code is:

```text
_get_ads()
    = How do I communicate with the API?

jobads_resource()
    = What records/table should dlt ingest?

jobads_source()
    = What group of dlt resources should be exposed?

dlt.pipeline(...)
    = Where should dlt load the data?

Dagster
    = When, in what order, and under what orchestration should everything run?
```

---

# 20. Simple Explanation for Speaking Practice

A concise way to explain the script out loud:

> This file defines the dlt source that Dagster will later orchestrate.
>
> First, I configure dlt to clean its temporary staging dataset. Then I define the JobTech API parameters, requesting up to 100 ads for the technical occupation field.
>
> `_get_ads()` is my helper function responsible for making the HTTP request, checking whether the request succeeded, and converting the JSON response into Python data.
>
> Next, I define a dlt resource called `jobads_resource`. This represents the stream of job advertisement records. I tell dlt to load those records into a table called `job_ads` using the `replace` write disposition.
>
> Inside the resource, I call the JobTech API, select the `hits` array, loop through the advertisements, and yield each advertisement to dlt.
>
> Finally, I wrap that resource inside `jobads_source`. The source acts as a container for dlt resources and gives Dagster the dlt source object it needs for orchestration.
>
> Dagster will later decide when this ingestion process should run, while dlt handles the extraction, normalization, and loading into Snowflake.

---

# Key Mental Model

```text
Dagster
   = orchestration

dlt source
   = collection of resources

dlt resource
   = stream/table of data

requests
   = API communication

JobTech
   = source system

Snowflake
   = destination

dbt
   = downstream transformation
```
