# Exercise 1 - Extracting and loading

In this exercise, you get to familiarize yourself with snowflake roles, extracting and loading to snowflake using dlt.

> [!NOTE]
> These exercises covers lectures 05-07.

## 1. Which role to use?

Use the correct role and do the following

> [!NOTE]
> Correct role refers to the system defined role and custom role that is most suitable for the task, i.e. don't use a top-level role such as ACCOUNTADMIN to do everything.
> Follow the principle of least privilege (PoLP) - only provide necessary access for roles to perform their duties.
```

01_setup_warehouse.sql
        ↓
Create compute

02_setup_database.sql
        ↓
Create database + staging schema

03_setup_user.sql
        ↓
Create extract_loader

04_setup_role.sql
        ↓
Create marketing_dlt_role + privileges

05_grant_role.sql
        ↓
Connect role to user

Python files
        ↓
Actually load the data
```

&nbsp; a) Create a marketing virtual warehouse called marketing_wh with size xs, 1 min suspend time, it should autoresume, suspend initially and give it a suitable comment.

&nbsp; b) Now create a database called ifood, and add a staging layer by creating a schema called staging.

&nbsp; c) Create a user called extract_loader and setup its credentials.

&nbsp; d) Create a role marketing_dlt_role and grant it access to staging.

&nbsp; e) Assign marketing_dlt_role to extract_loader user.

## 2. Load csv marketing data to snowflake

Load this [marketing data](https://www.kaggle.com/datasets/fayez7/ifood-marketing-campaigns) into the staging layer using dlt.

## 3. Load parking API to snowflake

In this exercise, you will explore the use of API data requiring an API key. Use the ```secrets.toml``` to store your API key and make sure that you don't track this file with git.

&nbsp; a) Start by asking for an API key in [open stockholm `Trafikkontorets trafik- och vägdata som öppna data`](https://openstreetgs.stockholm.se/home/). 

&nbsp; b) Then go into [parkering - API](https://openstreetgs.stockholm.se/Home/Parking), read the documentation and try to load some data you find interesting into snowflake. Remember to use an appropriate user and role for this loading task. 

## 4. Theory questions

| Question                                                                             | Answer                                                                                                                                                                                                  | Example / key idea                                                                                                             |
| ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| **a) Why is the principle of least privilege important in a company?**               | The **Principle of Least Privilege (PoLP)** means users and applications should only get the permissions they need to do their job. This reduces security risks and prevents accidental changes.        | Our `marketing_dlt_role` only needs access to `marketing_wh` and `ifood.staging`, not the whole Snowflake account.             |
| **b) Explain the role of dlt in managing data pipelines.**                           | **dlt** helps extract data from sources, organize it, infer schemas, and load it into destinations such as Snowflake. It also manages things like pipeline state, table creation, and loading behavior. | We used dlt to move data from `iFood.csv` and the Stockholm Parking API into Snowflake.                                        |
| **c) What is a data connector and why is it important in data integration?**         | A **data connector** connects a data source to another system so data can be extracted and transferred. It simplifies integration between systems.                                                      | A connector could connect an API, PostgreSQL database, or file storage to Snowflake.                                           |
| **d) What are the three different write dispositions in dlt?**                       | **append** adds new rows, **replace** replaces existing table data, and **merge** updates existing records and inserts new ones based on keys.                                                          | We used `write_disposition="replace"` in our exercises.                                                                        |
| **e) What is ELT and how does it differ from ETL?**                                  | **ELT = Extract, Load, Transform.** Data is first extracted, then loaded into the warehouse, and transformed there. **ETL = Extract, Transform, Load**, where transformation happens before loading.    | Snowflake projects commonly use ELT because Snowflake can perform transformations after the raw data is loaded.                |
| **f) What are the advantages of performing transformations after loading the data?** | Raw data is preserved, transformations can be changed later, and Snowflake's compute can be used for processing. Different teams can also create different transformations from the same raw data.      | Load API data into `staging` first, then clean and transform it later.                                                         |
| **g) What is the purpose of roles in Snowflake?**                                    | Roles are collections of privileges. Instead of granting permissions individually to every user, permissions are granted to roles and roles are assigned to users.                                      | `marketing_dlt_role` gets privileges; then the role is granted to `extract_loader` and your human Snowflake user.              |
| **h) Explain the difference between USAGE and OWNERSHIP privileges.**                | **USAGE** allows a role to access/use an object such as a warehouse, database, or schema. **OWNERSHIP** gives control over an object and includes the ability to manage it and its grants.              | `USAGE ON DATABASE ifood` lets the role access the database. The role that creates `marketing_campaigns` can become its owner. |
| **i) What information is required to create a user in Snowflake?**                   | A Snowflake user needs a **user name**. Other properties such as authentication/password, default warehouse, default role, and comments can be configured depending on how the user will be used.       | Our `extract_loader` service user had a username, password, and `DEFAULT_WAREHOUSE = marketing_wh`.                            |


## Glossary
| Terminology             | Easy explanation                                                                                                         | Example / context                                                                    |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| **SYSADMIN**            | System role mainly used to create and manage Snowflake objects such as warehouses, databases, schemas, and tables.       | We used it to create `marketing_wh` and `ifood`.                                     |
| **USERADMIN**           | System role responsible for creating and managing users and roles.                                                       | `CREATE USER extract_loader` and `CREATE ROLE marketing_dlt_role`.                   |
| **ORGADMIN**            | Organization-level administrative role used to manage Snowflake accounts across an organization.                         | Relevant when a company has multiple Snowflake accounts.                             |
| **SECURITYADMIN**       | System role responsible for managing privileges, grants, and access control.                                             | We used it for `GRANT USAGE`, CRUD privileges, and assigning roles.                  |
| **ACCOUNTADMIN**        | Highest account-level administrative role. It has very powerful permissions and should be used sparingly.                | Used for account-wide administration, not normal pipeline work.                      |
| **role inheritance**    | A role can inherit permissions from another role below it in the role hierarchy.                                         | A higher-level role can gain privileges from roles granted to it.                    |
| **PUBLIC role**         | A built-in role automatically available to every Snowflake user.                                                         | Privileges granted to `PUBLIC` are effectively available to all users.               |
| **public schema**       | A default schema normally created automatically inside a new database.                                                   | `ice_cream_db.public`. This is different from the `PUBLIC` role.                     |
| **API**                 | Application Programming Interface. A way for programs to communicate and request data from another system.               | Stockholm Parking API.                                                               |
| **ETL**                 | **Extract → Transform → Load.** Transform data before putting it into the destination.                                   | Clean data in Python first, then load it.                                            |
| **ELT**                 | **Extract → Load → Transform.** Load data first and transform it inside the warehouse.                                   | Load raw data to Snowflake staging, then transform it later.                         |
| **data ingestion**      | The process of bringing data from source systems into a destination.                                                     | Loading CSV or API data into Snowflake.                                              |
| **batch ingestion**     | Loading a group of records at intervals instead of continuously.                                                         | Loading a CSV file once per day.                                                     |
| **streaming ingestion** | Continuously loading data as it is produced.                                                                             | Sensor or IoT events arriving continuously.                                          |
| **incremental load**    | Loading only new or changed data instead of reloading everything.                                                        | Load today's new records instead of replacing the whole table.                       |
| **dlt connectors**      | Prebuilt integrations that help dlt connect to sources or destinations.                                                  | Connecting dlt to Snowflake or another data system.                                  |
| **snowflake user**      | An identity that can authenticate/login to Snowflake. It can represent a human or an application.                        | `AIRATHESNOWFAIRY` is a human user; `extract_loader` is a service user.              |
| **staging layer**       | An area where extracted data is loaded before further transformation.                                                    | `ifood.staging`.                                                                     |
| **granted to**          | Shows **who receives** a privilege or role.                                                                              | `GRANT SELECT ... TO ROLE marketing_dlt_role`.                                       |
| **granted on**          | Shows **which object** the privilege applies to.                                                                         | `SELECT` granted **on** `ifood.staging.marketing_campaigns`.                         |
| **granted by**          | Shows **which role gave** the privilege.                                                                                 | A grant may have been made by `SECURITYADMIN`.                                       |
| **secrets.toml**        | A dlt configuration file used to safely store credentials and secrets outside the Python code.                           | Snowflake password and Parking API key. It should be in `.gitignore`.                |
| **RBAC**                | **Role-Based Access Control.** Users receive permissions through roles rather than being given every privilege directly. | User → `marketing_dlt_role` → Snowflake privileges.                                  |
| **CRUD operations**     | Basic data operations: **Create, Read, Update, Delete**.                                                                 | `INSERT`, `SELECT`, `UPDATE`, `DELETE`.                                              |
| **resource dlt**        | A dlt resource represents data that dlt can extract/load. It usually yields individual records.                          | `@dlt.resource` on `parking_resource()`.                                             |
| **source dlt**          | A dlt source groups one or more related resources into a larger data source.                                             | One API source could contain separate resources for customers, orders, and products. |
| **yield Python**        | `yield` returns one item at a time from a generator instead of returning everything at once.                             | `for row in reader: yield row` sends each CSV row to dlt one at a time.              |

