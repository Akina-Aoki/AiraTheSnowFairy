"""Load job advertisements from the JobTech API into a DLT/Dagster pipeline.

This script fetches job ads for the category "Yrken med teknisk inriktning"
and exposes them as a DLT source/resource so Dagster can ingest them.

A beginner-friendly way to think about it:
- requests.get(...) downloads data from an API
- _get_ads(...) turns the raw response into Python objects
- jobads_resource(...) yields one job ad at a time
- jobads_source(...) wraps the resource so Dagster can work with it
"""

import json

import dlt
import requests

# In DLT, this tells the loader to clear the temporary staging dataset before
# each load. This helps keep the pipeline predictable during development.
dlt.config["load.truncate_staging_dataset"] = True

# Search parameters for the JobTech API.
# "limit" controls how many ads we ask for, and the occupation field filters the
# job ads to the technical occupations category used in this project.
params = {"limit": 100, "occupation-field": "6Hq3_tKo_V57"}


def _get_ads(url_for_search, params):
    """Call the JobTech search API and return the list of hits as Python data.

    Args:
        url_for_search: The URL to the JobTech search endpoint.
        params: Query parameters such as limit and occupation filters.

    Returns:
        A dictionary containing the API response, usually with a "hits" key.
    """
    response = requests.get(url_for_search, params=params)
    response.raise_for_status()  # Stop with an error if the HTTP request fails.
    return json.loads(response.content.decode("utf8"))


@dlt.resource(table_name="job_ads", write_disposition="replace")
def jobads_resource(params):
    """Yield each job ad from the JobTech search results.

    This is the actual data-producing function. DLT will turn each yielded item
    into a row in the target table called "job_ads".
    """
    url = "https://jobsearch.api.jobtechdev.se"
    url_for_search = f"{url}/search"

    for ad in _get_ads(url_for_search, params)["hits"]:
        yield ad


# Dagster expects a DLT source object, not a raw DLT resource.
# This wrapper lets Dagster and DLT work together.
@dlt.source
def jobads_source():
    """Expose the job ads resource as a DLT source for Dagster."""
    return jobads_resource(params)