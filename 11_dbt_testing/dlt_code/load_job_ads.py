#========================================#
#                                        #
#    This script loads job ads for       #
#    "Yrken med teknisk inriktning"      #
#                                        #
#========================================#

"""

    JobTech API
        ↓
    dlt script
        ↓
    Snowflake
        ↓
    job_ads.staging
"""

import dlt
import requests
import json
from pathlib import Path
import os


def _get_ads(url_for_search, params):
    """
    Send a request to the JobTech API and return the response as Python data.

    Args:
        url_for_search: The API endpoint used to search for job ads.
        params: Search filters sent to the API, such as occupation field and limit.

    Returns:
        The API response converted from JSON into a Python dictionary.
    """

    # Tell the API that we expect the response in JSON format.
    headers = {"accept": "application/json"}

    # Send a GET request to the API with the search parameters.
    response = requests.get(
        url_for_search,
        headers=headers,
        params=params
    )

    # Stop the program if the API returns an HTTP error.
    response.raise_for_status()

    # Convert the JSON response into a Python dictionary.
    return json.loads(response.content.decode("utf8"))


@dlt.resource(write_disposition="replace")
def jobads_resource(params):
    """
    Get job ads from the JobTech API and yield them one at a time to dlt.

    The resource uses write_disposition="replace", which means the existing
    destination table is replaced when the pipeline runs again.
    """

    # Base URL for the JobTech API.
    url = "https://jobsearch.api.jobtechdev.se"

    # Full endpoint used for searching job ads.
    url_for_search = f"{url}/search"

    # "hits" contains the list of job ads returned by the API.
    # Yield sends one job ad at a time to the dlt pipeline.
    for ad in _get_ads(url_for_search, params)["hits"]:
        yield ad


def run_pipeline(table_name):
    """
    Create and run the dlt pipeline that loads job ads into Snowflake.

    Args:
        table_name: Name of the Snowflake table where the job ads will be loaded.
    """

    # Configure the dlt pipeline.
    pipeline = dlt.pipeline(
        pipeline_name="jobsearch",
        destination="snowflake",
        dataset_name="staging",
    )

    # Search settings for the JobTech API.
    # limit = maximum number of job ads returned.
    # occupation-field = code for "Yrken med teknisk inriktning".
    params = {
        "limit": 100,
        "occupation-field": "6Hq3_tKo_V57"
    }

    # Run the pipeline:
    # API -> dlt resource -> Snowflake staging table.
    load_info = pipeline.run(
        jobads_resource(params=params),
        table_name=table_name
    )

    # Print information about the pipeline run.
    print(load_info)


if __name__ == "__main__":
    # Find the folder where this Python file is located.
    working_directory = Path(__file__).parent

    # Change the current working directory to that folder.
    # This helps dlt find local configuration files such as .dlt/secrets.toml.
    os.chdir(working_directory)

    # Start the pipeline and load the data into this Snowflake table.
    run_pipeline(table_name="technical_field_job_ads")