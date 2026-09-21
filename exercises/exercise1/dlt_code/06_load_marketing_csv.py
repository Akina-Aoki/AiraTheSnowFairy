
"""
Flow:

iFood.csv
    ↓
marketing_resource()
    ↓
pipeline.run()
    ↓
Snowflake
    ↓
IFOOD.STAGING.MARKETING_CAMPAIGNS
"""

# Python reads the CSV
import csv

# build the path 
from pathlib import Path

# loads data into Sbowflake
import dlt 



csv_path = Path(__file__).parent/"data"/"iFood.csv"


@dlt.resource(write_disposition = "replace")
def marketing_resource():
    """
    Read the iFood marketing CSV file and yield one row at a time.

    dlt will use each yielded row as one record to load into Snowflake.

    Returns:
        dict: One row from the CSV file.
    """

    # Open the CSV file.
    # utf-8-sig also handles CSV files that contain a UTF-8 BOM.
    with csv_path.open("r", encoding = "utf-8-sig", newline = "") as file:

        # read each row as a dict
        # Sample: {"Income": "58138", "Kidhome": "0", ...}
        reader = csv.DictReader(file)

        # Send one row at a time to dlt
        for row in reader:
            yield row



"""
Create the dlt pipeline. pipeline → Snowflake → staging schema

Pipeline_name identifies this pipeline inside dlt.
Destination="snowflake" tells dlt where to load the data.
Dataset_name="staging" means the table will be created in the staging schema.
"""
pipeline = dlt.pipeline(
    pipeline_name = "ifood_marketing",
    destination = "snowflake",
    dataset_name = "staging",
)


# Only run the pipeline when this Python file is executed directly.
if __name__ == "__main__":

    """
    Run the marketing resource and load the rows
    into a Snowflake table called marketing_campaigns.
    """

    load_info = pipeline.run(
        marketing_resource(),
        table_name = "marketing_campaigns",
    )

    """
    Print info about the load to verify if pipeline is successful
    """
    print(load_info)


