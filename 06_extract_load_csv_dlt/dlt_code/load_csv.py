import dlt  # Moves data from a source into a destination, such as Snowflake.
import pandas as pd  # Reads the CSV file into a DataFrame (a table in Python).
from pathlib import Path  # Builds file and folder paths.
import os  # Lets us change the current working directory.


# Tell dlt that this function provides data to load.
# "replace" means each run replaces the existing data in the destination table.
@dlt.resource(write_disposition="replace")
def load_csv_resource(file_path: str, **kwargs):
    """
    Read a CSV file and provide its data to dlt.

    Args:
        file_path: Location of the CSV file.
        **kwargs: Extra options passed to pandas.read_csv(),
            such as encoding="latin1".

    Yields:
        A pandas DataFrame containing the CSV data.
    """
    # Read the CSV into a DataFrame.
    # **kwargs forwards any extra options to read_csv().
    df = pd.read_csv(file_path, **kwargs)

    # Give the DataFrame to dlt when the resource is processed.
    # Unlike return, yield makes this function a generator.
    yield df


# Run this section only when this file is executed directly.
# It will not run if another Python file imports this script.
if __name__ == "__main__":

    # __file__ is the path to this Python script.
    # .parent gives us the folder containing the script.
    # .resolve() makes this an absolute path
    # points to: 06_extract_load_csv_dlt/dlt_code
    working_directory = Path(__file__).resolve().parent


    # Set that folder as the current working directory.
    # This helps dlt find the project's .dlt configuration folder
    # when VS Code starts the script from a different directory.
    # This assumes .dlt is inside the same folder as this script.
    os.chdir(working_directory)


    # Build the path to the CSV inside the data folder.
    # points to: 06_extract_load_csv_dlt/data/NetflixOriginals.csv
    csv_path = working_directory.parent / "data" / "NetflixOriginals.csv"


    # Create a dlt resource for the CSV.
    # "latin1" tells pandas how to interpret the file's text characters.
    # The CSV is read later, when the pipeline processes this resource.
    data = load_csv_resource(csv_path, encoding="latin1")

    # Print information about the resource, not the CSV's rows.
    print(data)

    # Create the pipeline that will load data into Snowflake.
    pipeline = dlt.pipeline(
        pipeline_name="movies",  # Name used by dlt to identify this pipeline.
        destination="snowflake",  # The system where the data will be loaded.
        dataset_name="staging",  # The target schema in Snowflake.
    )


    # Read the resource and load its data into the netflix table.
    # dlt uses the configured Snowflake connection and credentials.
    load_info = pipeline.run(data, table_name="netflix")

    # Print a summary of the load, including its status.
    print(load_info)