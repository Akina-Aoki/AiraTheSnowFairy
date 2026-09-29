import os  # Used to access environment variables from the operating system

from dotenv import load_dotenv  # Loads variables stored in a .env file
import snowflake.connector  # Lets Python connect to Snowflake
import pandas as pd  # Used to work with tabular data as DataFrames


def query_job_listings(query="SELECT * FROM mart_technical_jobs"):
    """
    Connect to Snowflake, run a SQL query, and return the result as a Pandas DataFrame.

    Args:
        query (str):
            SQL query to execute in Snowflake.

            By default, it selects all rows and columns from
            the `mart_technical_jobs` table.

    Returns:
        pandas.DataFrame:
            A DataFrame containing the result of the SQL query.
    """

    # Load the variables from the .env file into the environment.
    # Example:
    # SNOWFLAKE_USER=...
    # SNOWFLAKE_PASSWORD=...
    # SNOWFLAKE_ACCOUNT=...
    load_dotenv(override=True)

    # Open a connection to Snowflake.
    #
    # os.getenv() reads the corresponding value from the environment.
    # This prevents credentials from being hard-coded directly in Python.
    #
    # "with" automatically closes the Snowflake connection
    # when this block of code finishes.
    with snowflake.connector.connect(
        user=os.getenv("SNOWFLAKE_USER"),

        # Alternative authentication method using a private RSA key.
        # Currently not used because we are authenticating with a password.
        # private_key_file=os.getenv("SNOWFLAKE_RSA_KEY"),

        password=os.getenv("SNOWFLAKE_PASSWORD"),
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema=os.getenv("SNOWFLAKE_SCHEMA"),
        role=os.getenv("SNOWFLAKE_ROLE"),
    ) as conn:

        # Send the SQL query to Snowflake.
        #
        # pd.read_sql() executes the SQL query using the Snowflake connection
        # and converts the returned rows into a Pandas DataFrame.
        df = pd.read_sql(query, conn)

        # Give the DataFrame back to whatever code called this function.
        # For example:
        # jobs_df = query_job_listings()
        return df

if __name__ == "__main__":
    df = query_job_listings()
    print(df.head())