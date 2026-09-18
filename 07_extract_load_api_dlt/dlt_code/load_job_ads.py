# ========================================
# Load job ads matching "data engineer"
# from the JobTech API into Snowflake.
#
# Data flow:
# JobTech API → Python → dlt → Snowflake
# ========================================

import dlt                  # Organizes and loads data into a destination.
import requests             # Sends HTTP requests to the API.
import json                 # Converts JSON text into Python objects.
from pathlib import Path    # Helps work with file and folder paths.
import os                   # Allows us to change the working directory.


def _get_ads(url_for_search, params):
    """
    Request one page of search results from the JobTech API.

    Args:
        url_for_search: The API address used to search for job ads.
        params: A dictionary containing search settings, such as
            the search text and the maximum number of results.

    Returns:
        A Python dictionary containing the API response.
        The job ads are inside its "hits" key.

    Raises:
        requests.exceptions.HTTPError: If the API returns an HTTP
            error status, such as 404 or 500.
    """

    # The leading underscore in _get_ads is a naming convention:
    # it tells other developers this is an internal helper function.

    # Tell the API we want the response in JSON format.
    headers = {"accept": "application/json"}

    # Send a GET request to retrieve data.
    # requests adds params to the URL as query parameters.
    response = requests.get(url_for_search, headers=headers, params=params)

    # Raise an exception for HTTP errors.
    # Unless handled elsewhere, the exception stops this script.
    response.raise_for_status()

    # response.content contains bytes.
    # decode("utf8") converts those bytes into text.
    # json.loads() converts the JSON text into Python objects.
    return json.loads(response.content.decode("utf8"))


# A decorator adds behavior to the function below it.
# This decorator makes the function a dlt data resource.
#
# "replace" means the new load replaces existing data in the
# destination tables for this resource. It does not keep a history.
@dlt.resource(write_disposition="replace")
def jobads_resource(params):
    """
    Provide job ads to dlt, one ad at a time.

    Args:
        params: Search settings passed to the JobTech API.

    Yields:
        A dictionary representing one job advertisement.
    """

    # Base address of the API.
    url = "https://jobsearch.api.jobtechdev.se"

    # Build the address of the search endpoint.
    # An f-string inserts the value of url into the string.
    url_for_search = f"{url}/search"

    # Fetch the response and access its "hits" list.
    # Each item in that list represents one job advertisement.
    for ad in _get_ads(url_for_search, params)["hits"]:

        # Give one ad to dlt, then pause this function.
        # When dlt asks for the next item, the loop continues.
        #
        # Unlike return, yield does not end the function here.
        # The API response has already been downloaded in full.
        yield ad


def run_pipeline(query, table_name):
    """
    Extract job ads, organize them into tables, and load Snowflake.

    Args:
        query: The text to search for, such as "data engineer".
        table_name: The name of the main destination table.

    Returns:
        None. The function prints the load information instead.
    """

    # Configure the pipeline.
    # Snowflake connection details come from dlt configuration,
    # such as .dlt/secrets.toml or environment variables.
    pipeline = dlt.pipeline(
        pipeline_name="jobsearch",   # Identifies this dlt pipeline.
        destination="snowflake",    # Where the data will be loaded.
        dataset_name="staging",      # Destination schema in Snowflake.
    )

    # Set the API search parameters:
    # "q" contains the search text.
    # "limit" requests up to 100 results.
    #
    # This script makes one search request.
    # It does not fetch additional pages of results.
    params = {"q": query, "limit": 100}

    # Run the pipeline:
    # 1. Extract: Get job ads from the resource.
    # 2. Normalize: Organize the data into tables and columns.
    # 3. Load: Write the data into Snowflake.
    #
    # table_name sets the main table's name.
    # Nested data can also produce related child tables.
    load_info = pipeline.run(jobads_resource(params=params), table_name=table_name)

    # Print information about the load, rather than the job ads.
    print(load_info)


# Run this block only when this file is executed directly.
# Importing this file from another script will not run this block.
if __name__ == "__main__":

    # __file__ refers to this Python file.
    # .parent gives the folder containing it.
    working_directory = Path(__file__).parent

    # Make that folder the current working directory.
    # Relative paths will now start from this folder.
    os.chdir(working_directory)

    # Choose the search text.
    query = "data engineer"

    # Choose the main destination table's name.
    # The Snowflake database comes from your connection configuration.
    table_name = "data_field_job_ads"

    # Start the extraction and loading process.
    run_pipeline(query, table_name)