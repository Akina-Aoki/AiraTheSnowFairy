# Exercise 0:
0. Google queries
Go into marketplace under data products in snowsight. Search and get the following dataset Google Keywords search dataset - discover all searches on Google.

Now create a worksheet on your local repository and start querying this data through vscode.

  ## a) Use this database and find out the underlying schemas, tables and views to get an overview of its logical structure.

| Result column   |      value        | meaning                                                       |
| --------------- | ----------------- | ------------------------------------------------------------- |
| `database_name` | `GOOGLE_KEYWORDS` | The database containing the table                             |
| `schema_name`   | `DATAFEEDS`       | The schema containing the table                               |
| `name`          | `GOOGLE_KEYWORDS` | The table’s name                                              |
| `kind`          | `TABLE`           | This object is a table                                        |
| `created_on`    | `2026-09-06…`     | When the table was created—not when the first search happened |


  ## b) Find out the columns and its data types in the table GOOGLE_KEYWORDS.
  `DESCRIBE TABLE GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS;`


We will now do some exploratory data analysis (EDA) of this dataset.

  ## c) Find out number of rows in the dataset. 35046855
    ``` 
    SELECT COUNT(*) AS total_rows
    FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS;
    ```

  ## d) When is the first search and when is the latest search in the dataset?

  ```
    SELECT
        MIN (DATE) AS first_search,
        MAX (DATE) AS lastest_search
    FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS;
  ```

  22-06-06 - FIRST SEARCH
  22-06-30 - LAST SEARCH

  ## e) Which are the 10 most popular keywords?

  ```
    SELECT
        keyword,
        COUNT (*) AS number_of_searches
    FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS
    GROUP BY keyword
    ORDER BY number_of_searches
    LIMIT 10;
  ```

  ## f) How many unique keywords are there? - 7263686
  ```
    SELECT COUNT(DISTINCT keyword) AS unique_keywords
    FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS;
  ```

  ## g) Check what type of platforms are used and how many users per platform - 111473

  ```
    SELECT 
        platform,
        COUNT (DISTINCT calibrated_users) AS number_of_users
    FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS
    GROUP BY platform
    ORDER BY number_of_users DESC;
  ```

  ## h) Let's dive into what swedish people are searching. Go into worldbanks country codes to find out the country code for Sweden. Find the 20 most popular keywords and the number of searches of that keyword.

    ```
    SELECT 
        keyword,
        COUNT (*) AS number_of_searches
    FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS
    WHERE country = 752
    GROUP BY keyword
    ORDER BY number_of_searches DESC
    LIMIT 20;
    ```
  ## i) Lets see how popular spotify is around the world. List the top 10 number countries and the number of searches for spotify.

  ```
    SELECT
        country,
        COUNT (*) AS number_of_searches
    FROM GOOGLE_KEYWORDS.DATAFEEDS.GOOGLE_KEYWORDS
    WHERE keyword = 'spotify'
    GROUP BY country
    ORDER BY number_of_searches DESC
    LIMIT 10;
  ```

| Country code | Country        |
| ------------ | -------------- |
| 840          | United States  |
| 356          | India          |
| 276          | Germany        |
| 124          | Canada         |
| 392          | Japan          |
| 826          | United Kingdom |
| 250          | France         |
| 36           | Australia      |
| 76           | Brazil         |
| 56           | Belgium        |


# Exercise 1: 1. How much does it cost?
For these exercises, look up the credit cost for your snowflake edition, cloud provider and region for your snowflake account.

  a) You have a simple workload that runs daily in Snowflake. The workload uses 0.5 credits per day. Calculate the total credit usage and cost for a 30-day month.

  b) Your workload varies throughout the month. For the first 10 days, you use 2 credits per day. For the next 10 days, you use 1.5 credits per day, and for the last 10 days, you use 1 credit per day. Calculate the total credit usage and cost for a 30-day month.

  c) You have three different warehouses running workloads simultaneously. Warehouse A is of size XS, Warehouse B is of size S, and Warehouse C is of size M. Warehouse A is used for 10h/day, B is used for 2h/day and C is used for 1h/day. Calculate the total monthly cost assuming each warehouse runs for the full 30-day month.

  d) Your Snowflake warehouse uses auto-scaling. For the first 10 days, it operates on 2 clusters for 10 hours per day. For the next 10 days, it scales up to 3 clusters for 10 hours per day. For the last 10 days, it scales up to 4 clusters for 10 hours per day. Calculate the total monthly budget. Assume the warehouse consumes 1 credit per hour per cluster.


For Standard Edition on Microsoft Azure, Sweden Central, the on-demand rate is US$2.40 per credit. Snowflake pricing table
Monthly cost = total credits × $2.40

| Exercise                | How to calculate the credits                                                    | Monthly credits | Monthly cost (USD) |
| ----------------------- | ------------------------------------------------------------------------------- | --------------: | -----------------: |
| **a) Daily workload**   | 0.5 × 30 days                                                                   |          **15** |            **$36** |
| **b) Varying workload** | (2 × 10 days) + (1.5 × 10 days) + (1 × 10 days)                                 |          **45** |           **$108** |
| **c) Three warehouses** | A: 1 × 10 hours × 30 = 300; B: 2 × 2 hours × 30 = 120; C: 4 × 1 hour × 30 = 120 |         **540** |         **$1,296** |
| **d) Scaling clusters** | (2 clusters × 10 hours × 10 days) + (3 × 10 × 10) + (4 × 10 × 10)               |         **900** |        **$2,160*** |

For c, this uses Gen1 warehouse rates: XS = 1, S = 2, M = 4 credits/hour.

*For d, $2,160 is the exercise’s hypothetical calculation using your Standard rate. Actual multi-cluster warehouses require Enterprise Edition or higher. At your region’s Enterprise rate of $3.60/credit, that workload would cost $3,240. Edition features

Your $400 trial balance would cover either a or b for the month, but not c or d. These figures cover the specified compute usage only, before applying the trial balance.

# Exercise 2: Theory Questions

| Question                                                                                              | Beginner-friendly answer                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ----------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **a) What are the main components of Snowflake’s architecture?**                                      | Snowflake has **three layers: storage, compute, and cloud services**. Storage keeps the data, compute processes it, and cloud services coordinates how everything works. [Source](https://docs.snowflake.com/en/user-guide/intro-key-concepts)                                                                                                                                                                                                                                                                                                                                                                        |
| **b) What is the role of the storage layer?**                                                         | It **stores your data in the cloud**. Snowflake automatically organizes, compresses, and encrypts it. Storage is separate from compute, so your data remains available even when your virtual warehouse is stopped. [Source](https://docs.snowflake.com/en/user-guide/intro-key-concepts)                                                                                                                                                                                                                                                                                                                             |
| **c) What is the purpose of the compute layer?**                                                      | It provides the **processing power to run queries, load data, and transform data**. For example, when you count searches by country, a virtual warehouse performs that work. [Source](https://docs.snowflake.com/en/user-guide/warehouses)                                                                                                                                                                                                                                                                                                                                                                            |
| **d) How does the cloud services layer help Snowflake work?**                                         | It **coordinates tasks behind the scenes**, including checking logins and permissions, tracking information about tables, and planning how SQL queries should run efficiently. [Source](https://docs.snowflake.com/en/user-guide/intro-key-concepts)                                                                                                                                                                                                                                                                                                                                                                  |
| **e) What is a virtual warehouse, and how is it different from a traditional data warehouse?**        | A **virtual warehouse is a group of compute resources** used to process data. It does not permanently store your tables. A traditional data warehouse usually refers to the whole system, including storage and processing. Snowflake separates these, letting you resize or stop compute without moving your stored data. [Source](https://docs.snowflake.com/en/user-guide/warehouses)                                                                                                                                                                                                                              |
| **f) When should you scale up versus scale out?**                                                     | **Scale up** means making a warehouse larger, such as XS → M. Use it when a demanding query needs more processing power. **Scale out** means adding clusters to handle more queries at the same time. Use it when many users or jobs cause queries to queue. Multi-cluster warehouses require Enterprise Edition or higher. [Source](https://docs.snowflake.com/en/user-guide/warehouses-considerations)                                                                                                                                                                                                              |
| **g) How does Snowflake pricing differ from traditional on-premise data warehousing?**                | With **Snowflake**, you pay for resources consumed, including compute and storage separately. You can stop warehouses to stop their compute consumption. With **on-premise systems**, you usually buy hardware and licenses upfront and pay for maintenance, electricity, and staff—even when the hardware is idle. [Snowflake cost model](https://docs.snowflake.com/en/user-guide/cost-understanding-overall)                                                                                                                                                                                                       |
| **h) What is the difference between pay-as-you-go and upfront storage? When should you choose each?** | **Pay-as-you-go (On Demand)** means paying for usage without a long-term commitment. It suits learning, small projects, or uncertain demand. **Upfront commitment (Capacity)** means committing to spending in advance for discounted pricing. It suits organizations with predictable, ongoing usage. In both cases, storage charges depend on how much data you actually store; Capacity is a purchasing agreement, not a fixed disk you buy. [Source](https://docs.snowflake.com/en/user-guide/intro-editions)                                                                                                     |
| **i) What are Time Travel and Fail-safe, and when are they useful?**                                  | **Time Travel** lets you query earlier versions of data and recover from mistakes, such as accidental updates or dropped tables, within the retention period. Your Standard Edition supports **up to 1 day**. **Fail-safe** provides an additional **7-day recovery period for permanent tables** after Time Travel ends. Snowflake handles this recovery as a last resort; you cannot query Fail-safe data yourself. Temporary and transient tables have no Fail-safe. [Time Travel](https://docs.snowflake.com/en/user-guide/data-time-travel), [Fail-safe](https://docs.snowflake.com/en/user-guide/data-failsafe) |

# Exercise 3: Glossary

| **Terminology**       | **Explanation**                                                                                                                                         |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **downstream**        | A later step in a data pipeline. For example, a dashboard is downstream from the tables it reads.                                                       |
| **upstream**          | An earlier step that supplies data to later steps. For example, a source API is upstream from the database receiving its data.                          |
| **data warehouse**    | A system that brings together data for analysis and reporting, often including historical data from multiple sources.                                   |
| **cloud computing**   | Using computing resources, such as storage and processing power, over the internet instead of running your own physical servers.                        |
| **OLAP**              | **Online Analytical Processing.** Analyzing large amounts of data to answer questions, such as “What were our sales per country last year?”             |
| **OLTP**              | **Online Transaction Processing.** Handling everyday transactions quickly, such as placing an order or updating an account balance.                     |
| **virtual warehouse** | Snowflake’s compute resources for running queries, loading data, and transforming data. Your tables remain stored separately when it stops.             |
| **external stage**    | A Snowflake object that points to files in external cloud storage, such as Azure Blob Storage or Amazon S3. It is used to load or unload data.          |
| **data consumer**     | A person, application, or team that uses data. For example, an analyst reading a table to create a report.                                              |
| **scaling out**       | Adding more compute clusters to handle more work at the same time, such as many users running queries simultaneously.                                   |
| **scaling up**        | Increasing the size of a compute cluster to give it more resources, such as changing a Snowflake warehouse from XS to M.                                |
| **snowflake credit**  | A unit used to measure compute consumption. Its dollar price depends on your edition, cloud provider, region, and pricing agreement.                    |
| **securable object**  | Something in Snowflake that you can control access to using permissions, such as a database, schema, table, or warehouse.                               |
| **schema**            | A named container inside a database that organizes tables, views, and other objects. Your `DATAFEEDS` schema is an example.                             |
| **permanent table**   | The default Snowflake table type. It stays until explicitly dropped and supports both Time Travel and Fail-safe protection.                             |
| **transient table**   | A table that stays until explicitly dropped but has **no Fail-safe** and at most one day of Time Travel. Useful for intermediate data you can recreate. |
| **temporary table**   | A table available only within the session that created it. Snowflake removes it when that session ends. Useful for short-term processing.               |
| **time-travel**       | Accessing earlier versions of data within a retention period. Useful for checking previous values or recovering from accidental changes.                |
| **fail-safe**         | An additional seven-day recovery period for permanent table data after Time Travel ends. Snowflake manages this last-resort recovery.                   |
| **view**              | A saved query that you can query like a table. A regular view stores the query definition rather than its own separate copy of the results.             |
| **table**             | An object that stores data in rows and columns. Columns describe fields, and rows contain individual records.                                           |
| **DML**               | **Data Manipulation Language.** Commands that change table data, such as `INSERT`, `UPDATE`, `DELETE`, and `MERGE`.                                     |
| **DDL**               | **Data Definition Language.** Commands that create or change database objects, such as `CREATE`, `ALTER`, and `DROP`.                                   |
| **DQL**               | **Data Query Language.** A common term for commands that retrieve data, mainly `SELECT`. Some SQL classifications include querying under DML.           |
| **DCL**               | **Data Control Language.** Commands that control permissions, such as `GRANT` to give access and `REVOKE` to remove access.                             |
