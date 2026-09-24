"""
JobTech API
    ↓
search: "data engineer"
    ↓
dlt
    ↓
JOB_ADS.STAGING.DATA_FIELD_JOB_ADS
    ↓
original_headline.sql
    ↓
updated_headline.sql
    ↓
updated_headline_macro.sql

"""

#========================================#
#                                        #
#   Load "data engineer" job ads from    #
#   JobTech API into Snowflake staging   #
#                                        #
#========================================#

import dlt
import requests
import json
from pathlib import Path
import os


def _get_ads(url_for_search, params):
    """
    Send a request to the JobTech API and return the JSON response
    as a Python dictionary.
    """

    headers = {"accept": "application/json"}

    response = requests.get(
        url_for_search,
        headers=headers,
        params=params
    )

    response.raise_for_status()

    return json.loads(response.content.decode("utf8"))


@dlt.resource(write_disposition="replace")
def jobads_resource(params):
    """
    Get job ads from the JobTech API and send them
    one at a time to the dlt pipeline.
    """

    url = "https://jobsearch.api.jobtechdev.se"
    url_for_search = f"{url}/search"

    for ad in _get_ads(url_for_search, params)["hits"]:
        yield ad


def run_pipeline(table_name):
    """
    Load job ads into Snowflake.

    Destination:
        job_ads.staging.data_field_job_ads
    """

    pipeline = dlt.pipeline(
        pipeline_name="jobsearch",
        destination="snowflake",
        dataset_name="staging",
    )

    # Search JobTech for Data Engineer job ads
    params = {
        "q": "data engineer",
        "limit": 100
    }

    load_info = pipeline.run(
        jobads_resource(params=params),
        table_name=table_name
    )

    print(load_info)


if __name__ == "__main__":

    # Make sure dlt can find .dlt/secrets.toml
    working_directory = Path(__file__).parent
    os.chdir(working_directory)

    # Load into:
    # job_ads.staging.data_field_job_ads
    run_pipeline(table_name="data_field_job_ads")