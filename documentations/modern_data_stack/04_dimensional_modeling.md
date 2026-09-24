# 04 — Dimensional Modeling Guide

Use this after raw/source-shaped data is available in Snowflake `staging`.

Course reference: `08_dimensional_modeling`

---

## Goal

Design the **blueprint** that dbt will later build.

You are moving from:

```text
staging
source-shaped data
```

to:

```text
warehouse
facts + dimensions
```

and finally:

```text
marts
business-facing datasets
```

---

# Part 1 — Do not start with SQL

First ask:

```text
What business process am I modeling?
What questions should the data answer?
What is one row in my fact table?
```

The third question defines the **grain**.

Example:

```text
One row in fct_job_ads = one job advertisement
```

The grain should be clear before you choose dimensions or measures.

---

# Part 2 — Identify the fact table

A fact table usually represents an event or measurable business process.

Examples:

```text
fct_job_ads
fct_sales
fct_orders
fct_transactions
```

A fact table often contains:

```text
foreign keys to dimensions
numeric measures
dates/timestamps
business-event identifiers
```

Example:

```text
fct_job_ads
---------------------------------
job_details_id
employer_id
auxiliary_attributes_id
number_vacancies
relevance
application_deadline
```

---

# Part 3 — Identify dimensions

Dimensions describe the business context around facts.

Examples:

```text
dim_employer
dim_job_details
dim_customer
dim_product
dim_location
dim_date
```

Think:

```text
Fact = what happened?
Dimension = who / what / where / how?
```

Example:

```text
fct_job_ads
    |
    +--> dim_employer
    |
    +--> dim_job_details
    |
    +--> dim_auxiliary_attributes
```

---

# Part 4 — Understand a star schema

```text
                +------------------+
                |   dim_employer   |
                +---------+--------+
                          |
                          |
+------------------+      |      +----------------------+
| dim_job_details  +------v------+ dim_aux_attributes   |
+------------------+  fct_job_ads +----------------------+
                   +-------------+
```

The fact table sits in the center.

Dimensions connect directly to it.

---

# Part 5 — Choose keys

## Surrogate key

A warehouse-generated identifier.

Example:

```text
employer_id
job_details_id
```

## Natural/business key

An identifier from the source system.

Example:

```text
organization_number
job_ad_id
customer_number
```

A dimension may keep both.

---

# Part 6 — Separate measures from descriptive attributes

Measures are values that can often be aggregated.

Examples:

```text
number_vacancies
sales_amount
quantity
revenue
```

Descriptive attributes belong in dimensions.

Examples:

```text
employer_name
city
employment_type
product_category
```

---

# Part 7 — Consider a junk/auxiliary dimension

Several small flags can sometimes be grouped into one dimension.

For job ads:

```text
experience_required
driver_license
access_to_own_car
```

These can be modeled as:

```text
dim_auxiliary_attributes
```

This is often called a **junk dimension**.

---

# Part 8 — Create the model in dbdiagram

Workflow:

1. create a dbdiagram account;
2. create a DBML diagram;
3. define tables;
4. add relationships;
5. inspect the star schema;
6. review the design before implementing dbt.

Recommended file:

```text
modeling/dimensional_model.dbml
```

---

# Part 9 — Generic DBML template

```dbml
Table fct_event {
  event_id integer [pk]
  customer_id integer [ref: > dim_customer.customer_id]
  product_id integer [ref: > dim_product.product_id]

  quantity integer
  event_timestamp datetime
}

Table dim_customer {
  customer_id integer [pk]
  customer_name varchar
  city varchar
  country varchar
}

Table dim_product {
  product_id integer [pk]
  product_name varchar
  category varchar
}
```

The diagram is a **design artifact**.

dbt will later implement the transformations that produce these tables.

---

# Part 10 — Think in layers

## Staging

Purpose:

```text
land and lightly standardize source data
```

Examples:

```text
stg_job_ads
stg_customers
stg_orders
```

## Warehouse

Purpose:

```text
store reusable facts and dimensions
```

Examples:

```text
fct_job_ads
dim_employer
dim_job_details
```

## Marts

Purpose:

```text
serve a specific business or analytical use case
```

Examples:

```text
mart_technical_jobs
mart_marketing_performance
mart_sales_summary
```

---

# Part 11 — Modeling workflow

```text
1. Understand the source
        |
        v
2. Define business process
        |
        v
3. Declare fact-table grain
        |
        v
4. Identify dimensions
        |
        v
5. Identify measures
        |
        v
6. Choose keys
        |
        v
7. Draw DBML star schema
        |
        v
8. Validate with business questions
        |
        v
9. Implement with dbt
```

---

# Part 12 — Questions before finalizing the model

### Grain

Can I finish:

```text
One row represents __________________.
```

### Duplicates

What makes one fact uniquely identifiable?

### Dimensions

Can descriptive attributes be reused by multiple facts?

### History

If a dimension changes, do I need the old value too?

This leads to **slowly changing dimension (SCD)** decisions later.

### Null values

Which attributes are genuinely required?

### Downstream use

Which columns do analysts actually need?

A model should serve business questions rather than merely reproduce the API structure.

---

# Final checklist

Before dbt implementation:

- [ ] business process defined
- [ ] fact-table grain written in one sentence
- [ ] fact table identified
- [ ] dimensions identified
- [ ] measures identified
- [ ] key strategy considered
- [ ] relationships drawn
- [ ] staging/warehouse/marts responsibilities are clear
- [ ] DBML file saved in Git
