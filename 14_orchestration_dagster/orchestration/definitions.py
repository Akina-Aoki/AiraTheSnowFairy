"""Describe the data pipeline and tell Dagster how to run it.

An *asset* is a piece of data produced by a pipeline step. Dagster tracks when
each asset is updated and which other assets depend on it.

End-to-end flow:
1. The DLT asset uses ``jobads_source`` to fetch job ads and load them into the
   ``staging`` dataset in Snowflake.
2. Dagster records the DLT asset as materialized (successfully updated).
3. The asset sensor notices that update and requests the dbt job.
4. dbt builds the selected models, transforming the staged data into
   downstream warehouse and mart models.

The DLT job is also scheduled to run daily at 13:15 UTC. Dagster's sensor and
scheduler need to be running for those automatic triggers to be evaluated.
"""

from pathlib import Path
import dlt
# Dagster provides the objects used below to define assets, jobs, and automation.
import dagster as dg 
from dagster_dlt import DagsterDltResource, dlt_assets
from dagster_dbt import DbtCliResource, DbtProject, dbt_assets

# Make the sibling data_extract_load folder importable, then reuse its DLT
# source here. This relative path is interpreted from the process's working
# directory when Dagster starts.
import sys
sys.path.insert(0, '../data_extract_load')
from load_job_ads import jobads_source

 
# ==================== #
#                      #
#       DLT Asset      #
#                      #
# ==================== #
# DLT uses the Snowflake credentials configured in the local secrets.toml file.
# Keep credentials out of this script; the pipeline reads them from DLT config.

# A Dagster resource is a configured helper that an asset can use while running.
# Dagster supplies this object to dlt_load through its ``dlt`` parameter.
dlt_resource = DagsterDltResource() 

# This decorator turns the DLT source into Dagster asset(s). It also connects
# the source to a DLT pipeline, which controls the pipeline name, destination
# dataset (schema), and where the data is loaded.
@dlt_assets(
    # The source contains the code that fetches job ads from the API.
    dlt_source = jobads_source(),
    dlt_pipeline = dlt.pipeline(
        pipeline_name="jobsearch",
        dataset_name="staging",
        destination="snowflake",
    ),
)
def dlt_load(context: dg.AssetExecutionContext, dlt: DagsterDltResource):
    """Run DLT and report its results to Dagster.

    ``context`` contains information about this Dagster run. ``dlt`` is the
    injected DLT resource. Yielding the run results lets Dagster record the
    produced asset and display the load events in its UI.
    """
    yield from dlt.run(context=context) 


# ==================== #
#                      #
#       dbt Assets     #
#                      #
# ==================== #
# dbt transforms data already loaded into the warehouse; it does not fetch the
# source ads itself. Install the dbt project's required packages before running
# this code (for example, with ``dbt deps``).

# Find the dbt project relative to this file. The profile directory is in the
# current user's home folder and usually contains connection settings.
dbt_project_directory = Path(__file__).parents[1] / "data_transformation"
profiles_dir = Path.home() / ".dbt"  

# This object tells the Dagster dbt integration where the project and profiles
# are located, and provides access to project metadata such as the manifest.
dbt_project = DbtProject(project_dir=dbt_project_directory,
                         profiles_dir=profiles_dir)

# The CLI resource is Dagster's configured way to invoke dbt commands.
# Dagster injects it into dbt_models through the ``dbt`` parameter.
dbt_resource = DbtCliResource(project_dir=dbt_project)

# Prepare the dbt manifest when developing locally. The manifest lists models
# and their relationships so Dagster can represent them as assets and order
# dependent work correctly.
dbt_project.prepare_if_dev()



# Turn the models in the manifest into Dagster assets. This lets Dagster track
# model updates and dependencies alongside the DLT-produced asset.
@dbt_assets(manifest=dbt_project.manifest_path,) # path to the dbt manifest.json
def dbt_models(context: dg.AssetExecutionContext, dbt: DbtCliResource):
    """Run ``dbt build`` and stream command events back to Dagster.

    ``dbt build`` builds and tests the selected dbt resources. Streaming the
    events allows Dagster to show progress and the final results in its UI.
    """
    yield from dbt.cli(["build"], context=context).stream()


# ==================== #
#                      #
#         Jobs         #
#                      #
# ==================== #

"""
Define a Dagster job named ``job_dlt``. Defining the job does not run it;
it tells Dagster what to execute when the job is launched by a user or trigger.

``AssetSelection.keys(...)`` selects only the asset with this exact key.
That key is created for the DLT job-ads source/resource and represents the step
that fetches the ads and loads them into Snowflake. The schedule below uses this job, 
so each scheduled run executes that selected asset.
"""
job_dlt = dg.define_asset_job("job_dlt", selection=dg.AssetSelection.keys("dlt_jobads_source_jobads_resource"))



"""
Define a Dagster job named ``job_dbt``. It runs the selected dbt assets when started by Dagster; 
# defining it here does not run the models immediately.
``key_prefixes`` selects every asset whose key starts with either ``warehouse`` or ``marts``. 
These prefixes identify the downstream dbt models to build,
rather than the DLT asset that loads the raw job ads. 
The sensor below starts this job after Dagster observes that the DLT asset has been updated.
"""
job_dbt = dg.define_asset_job("job_dbt", selection=dg.AssetSelection.key_prefixes("warehouse", "marts"))

# ==================== #
#                      #
#       Schedule       #
#                      #
# ==================== #

# The cron expression is minute hour day-of-month month day-of-week. 
# This one runs job_dlt every day at 13:15 UTC; it does not directly schedule the dbt job.
# UTC time is the default to work with internally by developers. 
# Timestamp usually isn't shown in the marts layer.
schedule_dlt = dg.ScheduleDefinition(
    job=job_dlt,
    cron_schedule="15 13 * * *" #UTC
)

# ==================== #
#                      #
#    Asset Sensor      #
#                      #
# ==================== #

# Watch for successful updates to the DLT asset. When Dagster observes one,
# it requests the downstream dbt job. The asset key must match the key produced
# by the DLT integration (source name plus resource name).
@dg.asset_sensor(asset_key=dg.AssetKey("dlt_jobads_source_jobads_resource"),
                 job_name="job_dbt")
def dlt_load_sensor():
    """Return a run request that tells Dagster to start ``job_dbt``."""
    yield dg.RunRequest()

# ==================== #
#                      #
#     Definitions      #
#                      #
# ==================== #

# Bundle the definitions Dagster needs to load this pipeline:
# - assets describe the DLT load and dbt transformations;
# - resources provide the DLT and dbt integrations those assets use;
# - jobs define runnable asset selections;
# - the schedule and sensor define automatic triggers.
# Dagster loads this object as the entry point for this code location.
defs = dg.Definitions(
                    assets=[dlt_load, dbt_models], 
                    resources={"dlt": dlt_resource,
                               "dbt": dbt_resource},
                    jobs=[job_dlt, job_dbt],
                    schedules=[schedule_dlt],
                    sensors=[dlt_load_sensor],
                    )
