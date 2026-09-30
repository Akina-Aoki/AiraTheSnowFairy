# 7. Add dbt data tests

## Where testing appears

The canonical `10_dbt_modeling/` snapshot has no configured model tests. The later snapshot `11_dbt_testing/` copies the pipeline and adds:

- `11_dbt_testing/dbt_code/models/schema.yml`;
- `calogica/dbt_expectations` `0.10.3` in `packages.yml`;
- resolved transitive `dbt_date` `0.10.1` in `package-lock.yml`.

For a single clean project, copy/adapt `schema.yml` and the extra package declaration into the canonical dbt project rather than running two separate copies. Then run `dbt deps`.

## Actual tests

File: `11_dbt_testing/dbt_code/models/schema.yml`.

On `fct_job_ads.occupation_id`:

- built-in generic `relationships` requires every non-null fact occupation key to exist as `dim_occupation.occupation_id`. It is a data-quality foreign-key check, not a Snowflake constraint.

On `fct_job_ads.relevance`:

- `expect_column_values_to_be_between` requires values in `[0, 1]`;
- `expect_column_values_to_be_of_type` expects Snowflake type `float`.

On `fct_job_ads.vacancies`:

- the 0.99 quantile must be between 1 and 20;
- maximum must be between 1 and 20, configured `severity: warn`;
- type must be `number`.

These are **generic column tests**: parameterized test macros attached to a model column in YAML. There are no singular SQL tests under `tests/`. Despite beginner examples often mentioning them, the repository does **not** currently declare `not_null`, `unique`, or `accepted_values`. Recommended additions—only after confirming business rules—are `not_null` and `unique` on `dim_occupation.occupation_id`, plus `not_null` on the fact foreign key. Do not claim they already run.

## Run tests in the later snapshot

```bash
cd 11_dbt_testing/dbt_code
dbt deps
dbt run
dbt test
```

Or after merging the YAML/package declaration into the canonical project:

```bash
cd 10_dbt_modeling/dbt_code
dbt deps
dbt build
```

`dbt build` runs models and tests in DAG order; `dbt test` assumes referenced models already exist.

## Interpret results

- **PASS:** the test query returned zero failing rows (or the expectation was satisfied).
- **WARN:** a test failed with warning severity; dbt continues and reports it. The maximum-vacancies test is explicitly configured this way.
- **FAIL:** data violates an error-severity assertion; investigate before serving the mart.
- **ERROR:** dbt could not compile or execute the test—often a missing package/relation, permission issue, invalid type name, or bad `ref()`—rather than a mere bad row.

`ref('dim_occupation')` in the relationship test must name an existing dbt model. A reference to a nonexistent model fails during parsing/compilation; it is not a failed data assertion.

## Learning limitations and compatibility

`11_dbt_testing/README.md` explicitly says the suite is incomplete. The project pins the older `calogica/dbt_expectations` package, so check compatibility with the dbt version installed on a future computer. The comments in `schema.yml` also point to a misspelled/nonexistent explanation filename; this guide supersedes that pointer.

## Verify before continuing

```bash
dbt deps
dbt parse
dbt test --select fct_job_ads
```

Record failures rather than weakening thresholds without understanding the source. Confirm a relationship PASS before exposing the mart to Streamlit.
