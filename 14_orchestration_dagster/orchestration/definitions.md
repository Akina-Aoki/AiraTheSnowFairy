# Dagster `definitions.py` — Flow and Code Guide

This file is the **orchestration layer** of the project. It connects the dlt ingestion pipeline and the dbt transformation project, then tells Dagster what can run, what should trigger what, and what should be registered in the Dagster application.

The overall flow is:

```text
JobTech API
    ↓
dlt
    ↓
Snowflake STAGING
    ↓
Dagster sensor
    ↓
dbt
    ↓
Snowflake WAREHOUSE / MARTS
```

Dagster does not replace dlt or dbt.

```text
dlt      = ingestion
dbt      = transformation
Dagster  = orchestration
```

---

## 1. Imports

```python
from pathlib import Path
import dlt
import dagster as dg
from dagster_dlt import DagsterDltResource, dlt_assets
from dagster_dbt import DbtCliResource, DbtProject, dbt_assets
```

### `Path`

Used to build file paths safely.

Later:

```python
Path(__file__).parents[1] / "data_transformation"
```

helps Dagster locate the dbt project.

### `dlt`

Used for the ingestion pipeline:

```text
API → extract → normalize → load → Snowflake
```

### `dagster as dg`

Used for orchestration objects such as:

- assets
- jobs
- schedules
- sensors
- definitions

### `DagsterDltResource` and `dlt_assets`

These connect Dagster with dlt.

```text
dlt source
    ↓
dlt_assets
    ↓
Dagster asset
```

### `DbtCliResource`, `DbtProject`, `dbt_assets`

These connect Dagster with dbt.

```text
dbt project
    ↓
manifest.json
    ↓
dbt_assets
    ↓
Dagster assets
```

---

# 2. Import the dlt source from another folder

```python
import sys
sys.path.insert(0, '../data_extract_load')
from load_job_ads import jobads_source
```

The project structure is conceptually:

```text
project/
│
├── orchestration/
│   └── definitions.py
│
├── data_extract_load/
│   └── load_job_ads.py
│
└── data_transformation/
    ├── dbt_project.yml
    ├── models/
    └── ...
```

Python normally searches only known module paths.

This line:

```python
sys.path.insert(0, '../data_extract_load')
```

adds the `data_extract_load` folder to Python's import path.

That makes this possible:

```python
from load_job_ads import jobads_source
```

So `definitions.py` can reuse the dlt source defined in `load_job_ads.py`.

The responsibility split is:

```text
load_job_ads.py
    = extraction logic

definitions.py
    = orchestration logic
```

---

# 3. Create the Dagster dlt resource

```python
dlt_resource = DagsterDltResource()
```

A Dagster resource is a **tool an asset needs in order to do its work**.

This resource gives Dagster the ability to execute dlt.

```text
dlt_load asset
      │
      │ needs
      ▼
DagsterDltResource
      │
      ▼
runs dlt
```

---

# 4. Create the dlt asset

```python
@dlt_assets(
    dlt_source=jobads_source(),
    dlt_pipeline=dlt.pipeline(
        pipeline_name="jobsearch",
        dataset_name="staging",
        destination="snowflake",
    ),
)
```

This combines two things:

```text
dlt source
+
dlt pipeline configuration
```

and exposes the result as Dagster assets.

## `dlt_source`

```python
dlt_source=jobads_source()
```

This tells Dagster which dlt source to orchestrate.

The hierarchy is:

```text
jobads_source
    ↓
jobads_resource
    ↓
JobTech API
```

## `dlt_pipeline`

```python
dlt.pipeline(
    pipeline_name="jobsearch",
    dataset_name="staging",
    destination="snowflake",
)
```

This tells dlt where to load the data.

```text
pipeline_name = jobsearch
dataset_name  = staging
destination   = snowflake
```

Conceptually:

```text
jobads_source()
      ↓
jobsearch pipeline
      ↓
Snowflake
      ↓
STAGING
      ↓
job_ads
```

---

# 5. The `dlt_load` function

```python
def dlt_load(
    context: dg.AssetExecutionContext,
    dlt: DagsterDltResource
):
    yield from dlt.run(context=context)
```

This is the function Dagster executes when the dlt asset is materialized.

It receives two dependencies.

## `context`

```python
context: dg.AssetExecutionContext
```

Dagster creates this automatically.

It contains information about the current run, such as execution context, logging, metadata, and run state.

## `dlt`

```python
dlt: DagsterDltResource
```

Dagster also injects this automatically.

This is called **dependency injection**.

Instead of manually creating the dependency inside the function, Dagster supplies it.

```text
Dagster
  │
  ├── creates context
  │
  └── provides DagsterDltResource
             │
             ▼
         dlt_load()
```

## Run the dlt pipeline

```python
yield from dlt.run(context=context)
```

This starts the dlt ingestion.

```text
Dagster materializes dlt asset
        ↓
dlt_load()
        ↓
dlt.run()
        ↓
jobads_source()
        ↓
jobads_resource()
        ↓
JobTech API
        ↓
normalize
        ↓
Snowflake STAGING
```

`yield from` also forwards dlt execution events back to Dagster so they can appear in the Dagster UI.

---

# 6. Locate the dbt project

```python
dbt_project_directory = Path(__file__).parents[1] / "data_transformation"
```

`__file__` means the current Python file:

```text
definitions.py
```

`parents[1]` moves upward in the folder structure.

Then:

```python
/ "data_transformation"
```

points to the dbt project.

Conceptually:

```text
project/
├── orchestration/
│   └── definitions.py
└── data_transformation/
```

---

# 7. Locate `profiles.yml`

```python
profiles_dir = Path.home() / ".dbt"
```

dbt normally stores its profile configuration here:

```text
~/.dbt/profiles.yml
```

On Windows this is commonly something like:

```text
C:\Users\<username>\.dbt\profiles.yml
```

This profile contains the connection settings that dbt needs.

---

# 8. Create the `DbtProject`

```python
dbt_project = DbtProject(
    project_dir=dbt_project_directory,
    profiles_dir=profiles_dir
)
```

This tells Dagster:

```text
Here is my dbt project.
Here is my dbt profile directory.
```

The dbt project may contain:

```text
dbt_project.yml
models/
macros/
schema.yml
packages.yml
target/
```

---

# 9. Create the dbt CLI resource

```python
dbt_resource = DbtCliResource(
    project_dir=dbt_project
)
```

This gives Dagster the ability to execute dbt CLI commands.

The difference is:

```text
DbtProject
    = describes where the dbt project is

DbtCliResource
    = gives Dagster the ability to run dbt
```

---

# 10. Prepare the dbt manifest

```python
dbt_project.prepare_if_dev()
```

This prepares the dbt project during local development.

One important artifact is:

```text
target/manifest.json
```

The manifest contains metadata about:

```text
models
sources
dependencies
tests
relationships
lineage
```

Dagster reads this metadata so it can understand how the dbt models depend on each other.

Conceptually:

```text
dbt code
   ↓
manifest.json
   ↓
Dagster reads manifest
   ↓
Dagster understands dbt lineage
```

---

# 11. Create dbt assets

```python
@dbt_assets(
    manifest=dbt_project.manifest_path,
)
```

This tells Dagster:

> Read the dbt manifest and represent the dbt models as Dagster assets.

For example:

```text
STAGING
   ↓
dim_occupation
   ↓
fct_job_ads
   ↓
MARTS
```

Dagster can now visualize those relationships.

---

# 12. Run dbt

```python
def dbt_models(
    context: dg.AssetExecutionContext,
    dbt: DbtCliResource
):
    yield from dbt.cli(
        ["build"],
        context=context
    ).stream()
```

Dagster again uses dependency injection.

It provides:

```text
AssetExecutionContext
+
DbtCliResource
```

The command:

```python
dbt.cli(["build"])
```

is conceptually equivalent to:

```bash
dbt build
```

The flow is:

```text
Snowflake STAGING
      ↓
dbt build
      ↓
WAREHOUSE models
      ↓
MARTS models
      ↓
tests
```

## `.stream()`

```python
.stream()
```

streams the dbt CLI output back to Dagster in real time.

This lets you see progress in the Dagster UI, such as:

```text
START dim_occupation
SUCCESS dim_occupation
START fct_job_ads
SUCCESS fct_job_ads
```

---

# 13. Assets vs Jobs

This distinction is important.

## Asset

An asset represents data that is produced.

Examples:

```text
job_ads
dim_occupation
fct_job_ads
mart tables
```

Think:

```text
ASSET = what data is produced?
```

## Job

A job tells Dagster which assets should be executed together.

Think:

```text
JOB = what group of assets should run?
```

---

# 14. Create the dlt job

```python
job_dlt = dg.define_asset_job(
    "job_dlt",
    selection=dg.AssetSelection.keys(
        "dlt_jobads_source_jobads_resource"
    )
)
```

This creates a Dagster job called:

```text
job_dlt
```

It selects the dlt asset:

```text
dlt_jobads_source_jobads_resource
```

Conceptually:

```text
job_dlt
   ↓
dlt asset
   ↓
JobTech ingestion
```

The long key identifies the asset generated from the dlt source and resource.

---

# 15. Create the dbt job

```python
job_dbt = dg.define_asset_job(
    "job_dbt",
    selection=dg.AssetSelection.key_prefixes(
        "warehouse",
        "marts"
    )
)
```

This creates:

```text
job_dbt
```

and selects assets whose keys start with:

```text
warehouse
marts
```

Conceptually:

```text
job_dbt
  │
  ├── warehouse assets
  └── marts assets
```

---

# 16. Why two jobs?

The pipeline separates ingestion from transformation.

```text
job_dlt
    = ingestion

job_dbt
    = transformation
```

This allows them to be triggered independently and connected through events.

---

# 17. Create the schedule

```python
schedule_dlt = dg.ScheduleDefinition(
    job=job_dlt,
    cron_schedule="15 13 * * *"
)
```

This schedules the dlt job.

The cron expression:

```text
15 13 * * *
```

means:

```text
13:15 UTC every day
```

So:

```text
Clock
  ↓
13:15 UTC
  ↓
schedule_dlt
  ↓
job_dlt
  ↓
dlt ingestion
```

---

# 18. Why dbt does not need its own schedule

Instead of saying:

```text
13:15 → dlt
13:20 → dbt
```

the pipeline uses a sensor.

Why?

Because dlt may occasionally take longer.

A fixed dbt time could start transformation before the new data is ready.

Instead:

```text
dlt actually finishes
        ↓
asset materialized
        ↓
sensor reacts
        ↓
dbt starts
```

This is event-driven orchestration.

---

# 19. Create the asset sensor

```python
@dg.asset_sensor(
    asset_key=dg.AssetKey(
        "dlt_jobads_source_jobads_resource"
    ),
    job_name="job_dbt"
)
def dlt_load_sensor():
    yield dg.RunRequest()
```

The sensor watches this asset:

```text
dlt_jobads_source_jobads_resource
```

When that asset materializes, Dagster requests a run of:

```text
job_dbt
```

The flow is:

```text
dlt asset materialized
        ↓
dlt_load_sensor
        ↓
RunRequest
        ↓
job_dbt
```

In plain English:

> When fresh JobTech data has successfully arrived in staging, start the dbt transformation job.

---

# 20. `RunRequest`

```python
yield dg.RunRequest()
```

This tells Dagster:

> Start a run for the job connected to this sensor.

Because the sensor declares:

```python
job_name="job_dbt"
```

the requested job is:

```text
job_dbt
```

---

# 21. The final `Definitions` object

```python
defs = dg.Definitions(
    assets=[dlt_load, dbt_models],
    resources={
        "dlt": dlt_resource,
        "dbt": dbt_resource
    },
    jobs=[job_dlt, job_dbt],
    schedules=[schedule_dlt],
    sensors=[dlt_load_sensor],
)
```

This is the final registration point.

Dagster needs to know:

```text
What assets exist?
What resources exist?
What jobs exist?
What schedules exist?
What sensors exist?
```

`dg.Definitions` bundles everything together.

The structure is:

```text
Definitions
│
├── Assets
│   ├── dlt_load
│   └── dbt_models
│
├── Resources
│   ├── dlt_resource
│   └── dbt_resource
│
├── Jobs
│   ├── job_dlt
│   └── job_dbt
│
├── Schedule
│   └── schedule_dlt
│
└── Sensor
    └── dlt_load_sensor
```

---

# 22. Complete Runtime Flow

This is the most important diagram to remember:

```text
                    DAGSTER
                       │
                 13:15 UTC daily
                       │
                       ▼
                 schedule_dlt
                       │
                       ▼
                    job_dlt
                       │
                       ▼
                    dlt_load
                       │
                       ▼
              DagsterDltResource
                       │
                       ▼
                    dlt.run()
                       │
                       ▼
                jobads_source()
                       │
                       ▼
               jobads_resource()
                       │
                       ▼
                 JobTech API
                       │
                       ▼
               Snowflake STAGING
                       │
                       ▼
            dlt asset materialized
                       │
                       ▼
                dlt_load_sensor
                       │
                       ▼
                   RunRequest
                       │
                       ▼
                    job_dbt
                       │
                       ▼
                  dbt_models
                       │
                       ▼
                  dbt build
                       │
             ┌─────────┴─────────┐
             ▼                   ▼
         WAREHOUSE             MARTS
```

---

# 23. Definition Time vs Execution Time

This distinction is very important.

When Dagster first imports `definitions.py`, the data pipeline does **not** immediately run.

Dagster first reads the definitions.

```text
Dagster starts
    ↓
imports definitions.py
    ↓
discovers assets
    ↓
discovers resources
    ↓
discovers jobs
    ↓
discovers schedules
    ↓
discovers sensors
```

This is **definition time**.

Later, when a job starts, schedule fires, sensor triggers, or you manually materialize an asset, Dagster performs the actual work.

This is **execution time**.

So:

```text
definitions.py imported
≠
pipeline runs immediately
```

---

# 24. Responsibility Map

## `jobads_source()`

Defined in `load_job_ads.py`.

```text
What data should dlt extract?
```

## `dlt_resource`

```python
DagsterDltResource()
```

```text
Give Dagster the ability to run dlt.
```

## `dlt_load`

```text
Execute the dlt ingestion.
```

## `dbt_project`

```text
Tell Dagster where the dbt project and profile are.
```

## `dbt_resource`

```text
Give Dagster the ability to run dbt CLI commands.
```

## `dbt_models`

```text
Run dbt build.
```

## `job_dlt`

```text
Group the ingestion asset into an executable job.
```

## `job_dbt`

```text
Group warehouse and marts assets into an executable job.
```

## `schedule_dlt`

```text
Start the dlt job automatically at the configured time.
```

## `dlt_load_sensor`

```text
Start dbt after the dlt asset successfully materializes.
```

## `defs`

```text
Register the complete Dagster application.
```

---

# 25. Dagster Concept Cheat Sheet

```text
Asset
= data that is produced

Resource
= tool needed to produce the data

Job
= group of assets to execute

Schedule
= run something at a specific time

Sensor
= react when something happens

Definitions
= register everything with Dagster
```

---

# 26. Full Code with Short Annotations

```python
from pathlib import Path

import dlt
import dagster as dg

from dagster_dlt import DagsterDltResource, dlt_assets
from dagster_dbt import DbtCliResource, DbtProject, dbt_assets


# Import dlt source from another folder
import sys

sys.path.insert(0, "../data_extract_load")

from load_job_ads import jobads_source


# ---------------------------------
# dlt
# ---------------------------------

# Tool Dagster uses to execute dlt
dlt_resource = DagsterDltResource()


# Convert dlt source + pipeline into Dagster assets
@dlt_assets(
    dlt_source=jobads_source(),
    dlt_pipeline=dlt.pipeline(
        pipeline_name="jobsearch",
        dataset_name="staging",
        destination="snowflake",
    ),
)
def dlt_load(
    context: dg.AssetExecutionContext,
    dlt: DagsterDltResource,
):
    yield from dlt.run(context=context)


# ---------------------------------
# dbt
# ---------------------------------

# Locate dbt project
dbt_project_directory = (
    Path(__file__).parents[1]
    / "data_transformation"
)

# Locate ~/.dbt/profiles.yml
profiles_dir = Path.home() / ".dbt"


# Describe dbt project to Dagster
dbt_project = DbtProject(
    project_dir=dbt_project_directory,
    profiles_dir=profiles_dir,
)


# Tool Dagster uses to execute dbt CLI
dbt_resource = DbtCliResource(
    project_dir=dbt_project
)


# Prepare manifest in development
dbt_project.prepare_if_dev()


# Convert dbt models into Dagster assets
@dbt_assets(
    manifest=dbt_project.manifest_path,
)
def dbt_models(
    context: dg.AssetExecutionContext,
    dbt: DbtCliResource,
):
    yield from dbt.cli(
        ["build"],
        context=context,
    ).stream()


# ---------------------------------
# Jobs
# ---------------------------------

job_dlt = dg.define_asset_job(
    "job_dlt",
    selection=dg.AssetSelection.keys(
        "dlt_jobads_source_jobads_resource"
    ),
)

job_dbt = dg.define_asset_job(
    "job_dbt",
    selection=dg.AssetSelection.key_prefixes(
        "warehouse",
        "marts",
    ),
)


# ---------------------------------
# Schedule
# ---------------------------------

schedule_dlt = dg.ScheduleDefinition(
    job=job_dlt,
    cron_schedule="15 13 * * *",
)


# ---------------------------------
# Sensor
# ---------------------------------

@dg.asset_sensor(
    asset_key=dg.AssetKey(
        "dlt_jobads_source_jobads_resource"
    ),
    job_name="job_dbt",
)
def dlt_load_sensor():
    yield dg.RunRequest()


# ---------------------------------
# Definitions
# ---------------------------------

defs = dg.Definitions(
    assets=[
        dlt_load,
        dbt_models,
    ],
    resources={
        "dlt": dlt_resource,
        "dbt": dbt_resource,
    },
    jobs=[
        job_dlt,
        job_dbt,
    ],
    schedules=[
        schedule_dlt,
    ],
    sensors=[
        dlt_load_sensor,
    ],
)
```

---

# 27. Final Mental Model

The entire project can be remembered as:

```text
load_job_ads.py
    ↓
defines extraction

dbt project
    ↓
defines transformation

definitions.py
    ↓
defines orchestration
```

And inside Dagster:

```text
Schedule
   ↓
job_dlt
   ↓
dlt
   ↓
Snowflake STAGING
   ↓
Sensor
   ↓
job_dbt
   ↓
dbt
   ↓
WAREHOUSE / MARTS
```

The most important idea is that `definitions.py` is not the place where the detailed extraction or transformation logic lives.

It is the place where you tell Dagster:

> **These are my data assets, these are the tools they need, these are my jobs, and this is how the workflow should be automated.**
