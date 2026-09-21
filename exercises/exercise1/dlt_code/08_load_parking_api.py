"""
3. Load parking API to snowflake

url + params
    ↓
requests.get()
    ↓
Stockholm Parking API
    ↓
JSON response
    ↓
Python dictionary

"""

import requests
import dlt

# API endpoint for all permitted parking regulations.
# asks for permitted-parking regulations.
url = "https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten/all"


# Read the API key securely from .dlt/secrets.toml.
# reads your key without hardcoding it.
api_key = dlt.secrets["sources.parking.api_key"]


# Parameters sent with the API request.
# gives us JSON instead of the default XML.
# limits the first test to 100 records while we inspect the response structure. The API officially supports this parameter.
params = {
    "apiKey": api_key,
    "outputFormat": "json",
    "maxFeatures": 100,
}



def get_parking_data():
    """
    Send a request to Stockholm's parking API
    and return the JSON response as a Python object.

    Returns:
        dict: The decoded JSON response from the API.
    """

    # Send a GET request using the URL and parameters above.
    response = requests.get(url, params=params)

    # Raise an error if the API request failed.
    response.raise_for_status()

    # Convert the JSON response into Python data.
    return response.json()




@dlt.resource(write_disposition="replace")
def parking_resource():
    """
    Get parking data from the Stockholm Parking API
    and yield one parking feature at a time.

    dlt will use each yielded feature as one record
    to load into Snowflake.

    Yields:
        dict: One parking feature from the API.


    Stockholm Parking API
            ↓
    get_parking_data()
            ↓
    parking_resource()
            ↓
    dlt pipeline
            ↓
    Snowflake staging
    """

    # Call the helper function to get the API response.
    parking_data = get_parking_data()

    # "features" contains the actual parking records.
    features = parking_data["features"]

    # Send one parking record at a time to dlt.
    for feature in features:
        yield feature


# Create the dlt pipeline.
# This tells dlt to load the parking data into Snowflake
# and place the table inside the staging schema.
pipeline = dlt.pipeline(
    pipeline_name="parking_api",
    destination="snowflake",
    dataset_name="staging",
)


if __name__ == "__main__":
    """
    Run the parking resource through the dlt pipeline
    and load the data into Snowflake.
    """

    # Load the parking records into a Snowflake table.
    load_info = pipeline.run(
        parking_resource(),
        table_name="parking_regulations",
    )

    # Print information about the load so we can verify
    # whether the pipeline completed successfully.
    print(load_info)