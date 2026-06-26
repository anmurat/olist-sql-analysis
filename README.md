# Olist E-Commerce SQL Analysis

SQL analysis on the Olist Brazilian E-Commerce dataset using PostgreSQL.

## Analyses

### Cohort & Retention Analysis
Grouped customers by their first order month and tracked how many returned in subsequent months.

### Funnel Analysis
Tracked order status transitions from created to delivered, measuring drop-off and conversion rates at each step.

### RFM Analysis
Segmented customers based on Recency, Frequency, and Monetary value using NTILE scoring.

## Tools
- PostgreSQL
- DBeaver

## Dataset
[Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Notes
Olist assigns a new customer_id for each order, which limits retention and frequency metrics.
For accurate repeat-purchase analysis, customer_unique_id should be used instead.
