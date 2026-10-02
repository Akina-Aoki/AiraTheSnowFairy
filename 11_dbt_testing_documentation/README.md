# dbt testing

Video on dbt testing (coding) :point_down:

[dbt testing code](https://youtu.be/GRGPnSTCTFI)

There will be errors along the data pipeline somewhere and sometimes. It can be due to strange input data, some outliers, or something that went wrong in some part in the pipeline. It is thus important for the data team to be the first to capture this error and don't let it propagate to downstream use cases that might base decisions on this data. It could be harmful for the business and the data team might lose its credibility if this happens. 

One way to mitigate this is through testing the data before serving it to downstream. By using dbt we can test the data in various ways.

<!-- TODO: specify some tests here -->

> [!NOTE]
> I haven't made a complete test suite intentionally as it is your job to do it in order to learn how to properly test your models. 


## Setup

Install [dbt_expectation](https://hub.getdbt.com/calogica/dbt_expectations/latest/), which has a lot of test macros that can be used to test the data. The documentation of [dbt-expectations are found here](https://github.com/calogica/dbt-expectations/tree/0.10.3/?tab=readme-ov-file). Start by adding the following to `packages.yml`

```yml
packages:
  - package: calogica/dbt_expectations
    version: 0.10.3
```

- Now run `dbt deps` to install the dependencies.
- Create `schema.yml` with the tests.

## Tests done in class
- Dbt test 1- Generic data tests provided by dbt by default. [https://docs.getdbt.com/docs/build/data-tests?version=2]
- Dbt test 2 - Generic data tests provide by a dbt package, i.e. dbt expectations[https://github.com/calogica/dbt-expectations/tree/main].
- Dbt test 3 - Singular data tests written by yourself and put under the `tests` subfolder.

### Generic data tests

Generic data tests are built-in tests in dbt. With the package `dbt_expectation`, there are more choices of built-in tests for use. An alternative is to write your own singular data tests (.sql files) under *test* directory. For generic data tests, add a file called *schema.yml* under the *models* directory as below:

```yml
models:

  - name: fct_job_ads
    columns:
      - name: occupation_id
        data_tests:
          - relationships:
              to: ref('dim_occupation')
              field: occupation_id
```

Check out the *schema.yml* file for more examples of tests. Run the tests with 

```
dbt test
```

## Other videos :video_camera:

from Kahan data solutions 

- [How to test and debug your dbt models](https://www.youtube.com/watch?v=aCZUiCzoJt4&list=PLy4OcwImJzBLJzLYxpxaPUmCWp8j1esvT&index=6)

## Read more :eyeglasses:

from dbt docs
- [Add data tests to your DAG](https://docs.getdbt.com/docs/build/data-tests)
- [About data tests property](https://docs.getdbt.com/reference/resource-properties/data-tests)
- [About dbt test command](https://docs.getdbt.com/reference/commands/test)
- [Unit tests](https://docs.getdbt.com/docs/build/unit-tests)






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