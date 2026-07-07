# Retail Store Inventory Analytics using Hadoop, Hive & R

An end-to-end **Big Data Analytics** project that processes over **500,000 retail transactions** using **Hadoop HDFS**, **Apache Hive**, and **R** to generate actionable business insights for inventory management and sales analysis.

This project demonstrates scalable data preprocessing, feature engineering, business analytics, forecasting, and visualization using distributed computing technologies.

---

## Project Overview

Retail businesses generate massive volumes of transactional data every day. This project builds a complete analytics pipeline that stores, cleans, processes, and analyzes large-scale retail data to answer important business questions such as:

- Which product categories generate the highest revenue?
- Which countries contribute the most sales?
- What seasonal purchasing patterns exist?
- How does pricing influence sales?
- Which products should be restocked or discontinued?
- What are the future sales trends?

---

## Architecture

```
Online Retail Dataset
          │
          ▼
   Hadoop HDFS Storage
          │
          ▼
 Apache Hive Processing
(Data Cleaning & Feature Engineering)
          │
          ▼
 Aggregation & Analytics
          │
          ▼
      R Programming
          │
          ▼
 Visualization & Forecasting
          │
          ▼
 Business Insights
```

---

## Technologies Used

| Technology | Purpose |
|------------|---------|
| Hadoop HDFS | Distributed Data Storage |
| Apache Hive | Data Cleaning & SQL Analytics |
| R | Data Visualization & Forecasting |
| ggplot2 | Charts & Graphs |
| dplyr | Data Manipulation |
| forecast | Time Series Forecasting |
| corrplot | Correlation Analysis |

---

## Project Structure

```
retail-store-inventory-analytics
│
├── dataset/
│   └── dataset_info.md
│
├── hive/
│   └── retail_analytics.sql
│
├── r/
│   └── retail_analytics.R
│
├── screenshots/
│
├── output/
│
├── docs/
│   └── Retail_Store_Inventory_Analysis.pdf
│
├── README.md
├── LICENSE
└── .gitignore
```

---

## Key Features

- Data ingestion using Hadoop HDFS
- Data cleaning and preprocessing using Hive
- Feature engineering for business analytics
- Category-wise sales analysis
- Country-wise revenue analysis
- Top-selling product analysis
- Seasonal sales analysis
- Weekly sales trend analysis
- Price vs Sales relationship analysis
- Correlation analysis
- Sales forecasting using ARIMA
- Identification of low-moving inventory
- Brand performance analysis
- Basket size analysis

---

## Business Insights

The analysis revealed several valuable insights:

- Home décor and gifting products generated the highest revenue.
- The United Kingdom contributed the majority of total sales.
- Customer demand showed strong seasonal trends, especially during festival months.
- Lower-priced products accounted for the highest sales volume.
- Revenue was more strongly influenced by quantity sold than product price.
- A small number of products contributed disproportionately to overall revenue.

---

## Sample Visualizations

> Add the generated plots inside the `screenshots/` folder and replace the placeholders below.

### Category-wise Sales

![Category Sales](screenshots/category_sales.png)

---

### Monthly Sales Trend

![Monthly Sales](screenshots/monthly_sales.png)

---

### Top Selling Products

![Top Products](screenshots/top_products.png)

---

### Seasonal Sales Analysis

![Seasonal Sales](screenshots/seasonal_sales.png)

---

### Sales Forecast

![Forecast](screenshots/sales_forecast.png)

---

## Dataset

**Dataset:** Online Retail Dataset

The dataset contains more than **500,000 retail transactions** including:

- Invoice Number
- Product Code
- Product Description
- Quantity
- Unit Price
- Invoice Date
- Customer ID
- Country

The dataset is not included in this repository due to licensing restrictions.

Dataset Source:
https://archive.ics.uci.edu/ml/datasets/online+retail

---

## Future Enhancements

- Apache Spark implementation
- Interactive Power BI dashboard
- Machine Learning-based demand forecasting
- Real-time analytics using Kafka and Spark Streaming
- Automated ETL pipeline using Apache Airflow

---

## Author

**Sujitha Madda**

- GitHub: https://github.com/sujitha-madda
- LinkedIn: https://www.linkedin.com/in/sujitha-madda/

---

## ⭐ If you found this project useful, consider giving it a star!
