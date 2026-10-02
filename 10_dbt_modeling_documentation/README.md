# Data transformation with dbt - a more realistic example

In this lecture, we will transform data with dbt according to a dimensional model which is usually provided to the data engineer team as the blueprint of coding dbt models.

Video on dbt modeling :point_down:

- [Dbt Modelling Video](https://youtu.be/aYGcrrFshrs)


## Scenario

Imagine you are a data engineer for a HR agency. Here's an overview of the business model of this agency: <br>

Talent acquisition specialists work with different occupation fields. According to the opening job ads on Arbetsförmedlingen, they will:

- search and contact potential candidates from LinkedIn
- contact and market those potential candidates to corresponding employers <BR>

Therefore, they constantly analyze job ads in order to understand which types of candidates they should approach. Currently, every begining of the week, they manually browse the homepage of Arbetsförmedlingen and download a list of opening job ads to guide their work over the week. However, they are not able to draw insights from these job ads as:

- the information are messy
- they have spent too much time to manually collect and clean data so that they do not have much time to analyze the data, which is important to improve the efficiency of their work <BR>

Now, you are given a task to create a data pipeline for the team of talent acquisition specialists to:

- automate the data extraction from Jobtech API of Arbetsförmedlingen
- transform and structure data according to a dimensional model
- design a dashboard for talent acquisition specialists to analyse numbers of vacancies by city, by occupation and by employment types etc, for each of the occupation fields

## Data model

Based on our previous dimensional models on the job ads we'll transform the data from staging layer to the warehouse layer. This will be our source of truth, that later will serve the data marts layer, which then in turn serves BI dashboards. We will base our modeling on the ER diagram of a star schema created in `dimension_modeling` lecture.

> [!NOTE]
> I haven't implemented the full dimensional model. The rest is intended for you to implement, so I have intentionally left it out.

## Setup

### dlt

The script, _load_job_ads.py_ loads job ads with a specific occupation field to a Snowflake database. Note that this script only loads job ads for ONE occupation field

### dbt utils

Then run `dbt deps` to install the dependencies specified in packages.yml

### dbt models

Now you can run all dbt models and check if the resulting data in Snowflake. *Note that only an extract of models are provided in this repo.*

In *fct_job_ads* model, you can use the codes below to generate the surrogate keys for joining the fact model with dimension models:

```sql
{{ dbt_utils.generate_surrogate_key(['occupation__label']) }} as occupation_id,

{{ dbt_utils.generate_surrogate_key(['employer__workplace', 'workplace_address__municipality']) }}
as employer_id,

{{ dbt_utils.generate_surrogate_key(['id']) }} as job_details_id,

{{ dbt_utils.generate_surrogate_key(['id']) }} as auxilliary_attributes_id,
```

## Tests done in class
- Dbt test 1- Generic data tests provided by dbt by default. [https://docs.getdbt.com/docs/build/data-tests?version=2]
- Dbt test 2 - Generic data tests provide by a dbt package, i.e. dbt expectations[https://github.com/calogica/dbt-expectations/tree/main].
- Dbt test 3 - Singular data tests written by yourself and put under the `tests` subfolder.

## Other videos :video_camera:

From Kahan data solutions:

- [Tips to improve your dbt projects](https://www.youtube.com/watch?v=qOx8l_QFz9I&list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT&index=2)
- [Add raw sources to your dbt project](https://www.youtube.com/watch?v=Y03CsVDK69Y&list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT&index=3)
- [Deploy to custom schemas & override dbt defaults](https://www.youtube.com/watch?v=AvrVQr5FHwk&list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT&index=5)
- [Change the materialization (aka how dbt models deploy)](https://www.youtube.com/watch?v=zpACZu31154&list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT&index=7)

## Read more :eyeglasses:

dbt from dbt docs

- [dbt models](https://docs.getdbt.com/docs/build/models)
- [dbt seeds](https://docs.getdbt.com/docs/build/seeds)
- [Jinja and macros](https://docs.getdbt.com/docs/build/jinja-macros)
- [sources](https://docs.getdbt.com/docs/build/sources)
- [project variables](https://docs.getdbt.com/docs/build/project-variables)



# dbt documentation

[![dbt documentation](https://github.com/kokchun/assets/blob/main/data_warehouse/dbt_docs_video.png?raw=true)](https://www.youtube.com/watch?v=0tws8vOwKKQ)


dbt can generate comprehensive documentation for your data models, which can be incredibly useful for both development and communication within data teams. It has 
- auto-generated documentation 
- markdown support 
- data lineage
- browser based interface

## Document column description
Add description for a column in *schema.yml* under *models* directory:

```yml
models:

  - name: dim_occupation
    description: "The dimension is a collection of unique occupation"

  - name: fct_job_ads
    description: "The facts are relevance and vacancies."
```

## Generate documentation

Generate the documentation with 

```bash
dbt docs generate
```

then serve it to a local webserver with 

```bash
dbt docs serve
```


## Other videos :video_camera:
From Kahan data solutions

- [View your dbt documentation as a website](https://www.youtube.com/watch?v=sfKXR612p_I&list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT&index=9)


## Read more :eyeglasses:

From dbt docs

- [About dbt docs command](https://docs.getdbt.com/reference/commands/cmd-docs)
- [Documentation](https://docs.getdbt.com/docs/build/documentation)