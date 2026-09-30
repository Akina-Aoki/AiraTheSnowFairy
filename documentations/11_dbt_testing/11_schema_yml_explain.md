The most important thing to understand is that this file is not changing your data. It is defining rules that your data should satisfy.

Flow
```
fct_job_ads
     ↓
schema.yml
     ↓
"Here are the rules this data should follow"
     ↓
dbt test
     ↓
dbt checks Snowflake
     ↓
PASS / WARN / FAIL
```




```yaml
# This file describes dbt models and defines tests for their columns.

models:

  # This section is for the model called fct_job_ads
  - name: fct_job_ads

    # These are the columns inside fct_job_ads that we want to test
    columns:

      # ---------------------------------------------
      # TEST 1: occupation_id
      # ---------------------------------------------
      - name: occupation_id

        # data_tests tells dbt:
        # "Run these tests on this column"
        data_tests:

          # relationships is a built-in dbt test.
          # It checks that every occupation_id in fct_job_ads
          # also exists in dim_occupation.
          #
          # This is basically checking the relationship between:
          #
          # fct_job_ads.occupation_id
          #          ↓
          # dim_occupation.occupation_id
          #
          # Think of this like checking a foreign key.
          - relationships:

              # ref('dim_occupation') tells dbt:
              # "Use the dim_occupation model"
              to: ref('dim_occupation')

              # Match against the occupation_id column
              # inside dim_occupation
              field: occupation_id


      # ---------------------------------------------
      # TEST 2: relevance
      # ---------------------------------------------
      - name: relevance

        data_tests:

          # This test comes from the dbt_expectations package.
          #
          # It checks every value in the relevance column
          # and makes sure it is between 0 and 1.
          #
          # Good examples:
          # 0
          # 0.4
          # 0.75
          # 1
          #
          # Bad examples:
          # -1
          # 1.5
          # 100
          - dbt_expectations.expect_column_values_to_be_between:

              # Lowest allowed value
              min_value: 0

              # Highest allowed value
              max_value: 1


          # This checks the DATA TYPE of the relevance column.
          #
          # It expects Snowflake/dbt to see this column
          # as a float.
          #
          # Example:
          # 0.75 -> float
          # 1.0  -> float
          - dbt_expectations.expect_column_values_to_be_of_type:

              column_type: float


      # ---------------------------------------------
      # TEST 3: vacancies
      # ---------------------------------------------
      - name: vacancies

        data_tests:

          # This test looks at the 99th percentile
          # of the vacancies column.
          #
          # quantile: .99 means:
          # "Look at the value where 99% of the data
          # is at or below this point."
          #
          # Example:
          #
          # vacancies:
          # 1, 1, 2, 2, 3, 3, 4, 5, 10, 15
          #
          # The .99 quantile will be close to
          # the highest values in the dataset.
          #
          # Here we expect that 99th percentile value
          # to be somewhere between 1 and 20.
          - dbt_expectations.expect_column_quantile_values_to_be_between:

              # 0.99 = 99th percentile
              quantile: .99

              # Expected minimum for the 99th percentile
              min_value: 1

              # Expected maximum for the 99th percentile
              max_value: 20


          # This test checks the absolute MAXIMUM value
          # in the vacancies column.
          #
          # We expect the highest number of vacancies
          # to be between 1 and 20.
          - dbt_expectations.expect_column_max_to_be_between:

              min_value: 1
              max_value: 20

              # Normally, when a dbt test fails,
              # dbt marks it as an ERROR.
              #
              # severity: warn changes that behavior.
              #
              # Instead of:
              # FAIL / ERROR
              #
              # dbt will show:
              # WARN
              #
              # This is useful when something looks suspicious
              # but we don't want it to stop the whole pipeline.
              config:
                severity: warn


          # This checks the data type of vacancies.
          #
          # We expect vacancies to contain numbers.
          - dbt_expectations.expect_column_values_to_be_of_type:

              column_type: number

```

- Run `dbt test` to run the test.

Bascially means:
```
occupation_id
→ must exist in dim_occupation

relevance
→ must be between 0 and 1
→ must be a float

vacancies
→ 99th percentile should be between 1 and 20
→ maximum should be between 1 and 20
→ should be numeric
```

  - name: dim_employer
    columns:
      - name: workplace_city
        data_tests:
          - not_null
  - name: dim_job_details
    columns:
      - name: job_details_id
        data_tests:
          - not_null
          - unique
      - name: headline
        data_tests:
          - not_null