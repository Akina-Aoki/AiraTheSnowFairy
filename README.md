# AiraTheSnowFairy
Modern Data Stack Lectture Repo: dlt, dbt, dagster, snowflake, python, azure, streamlit
- **Setting up the dlt password is in the lecture video 4:15**

| Package                      | Used for                          |
| ---------------------------- | --------------------------------- |
| `dlt`                        | Running the data pipeline         |
| `snowflake-connector-python` | Connecting to Snowflake           |
| `ipykernel`                  | Running Jupyter notebooks         |
| `pandas`                     | Reading and working with CSV data |
| `pyarrow`                    | Working with Parquet data         |


## Activate your existing virtual environment.If not exists, create one.
`source .venv/Scripts/activate`

## Show the packages installed in that environment.
`uv pip list`

## Install dlt and the packages needed for this lecture.
`uv pip install "dlt[snowflake,parquet]" ipykernel pandas`

## Display the installed packages.
`uv pip list`

## Confirm that dlt is installed.
`dlt --version`
