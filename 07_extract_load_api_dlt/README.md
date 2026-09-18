# Extract and load API to snowflake with dlt 

Video on dlt theory to extract and load from API to snowflake :point_down:

[Video: dlt to extract and load from api to snowflake](https://www.youtube.com/watch?v=5fur2ZTonDQ)



Read [dlthub documentation for loading data from API](https://dlthub.com/devel/tutorial/load-data-from-an-api). 

> [!NOTE]
> We won't use API which requires a secret in the lecture, but there will be an exercise on it.


## Set up in snowflake
### Database
Via Snowsight or Snowflake VSC extension, run the worksheet *setup_database.sql*

### Users and roles
Via Snowsight or Snowflake VSC extension, run the worksheet *setup_user_role.sql*

## Extract data with dlt

### Arbetsförmedlingen API data

We will be using jobtech API to get ads published in arbetsförmedlingen/platsbanken. Go into [this code examples repository](https://gitlab.com/arbetsformedlingen/job-ads/getting-started-code-examples/code-examples-start-here) to read documentation. 

### dlt's connection to snowflake
Create a folder *.dlt* and a file *secrets.toml*. The entire *.dlt* folder should be ignored by git. Populate the toml file:

```toml
[destination.snowflake.credentials]
database = "job_ads" 
username = "extract_loader" 
password = "<password for extract_loader>" # please set me up!
host = "<account_identifier>" # please set me up!  
warehouse = "dev_wh" 
role = "job_ads_dlt_role" 
```
### dlt load
Run the script *load_job_ads.py* and control that the data has been loaded to snowflake. 



## Read more :eyeglasses:

- [Create a pipeline - dlthub docs](https://dlthub.com/docs/walkthroughs/create-a-pipeline)
- [How to add credentials - dlthub docs](https://dlthub.com/docs/walkthroughs/add_credentials)
- [Add a verified source - dlthub docs](https://dlthub.com/docs/walkthroughs/add-a-verified-source)
- [Run a pipeline - dlthub docs](https://dlthub.com/docs/walkthroughs/run-a-pipeline)
- [Adjust a schema - dlthub docs](https://dlthub.com/docs/walkthroughs/adjust-a-schema)