# Set working directory to exported Hive CSV folder
setwd("C:/Users/msuji/Downloads/exports")

# Install required libraries (run only once)
install.packages(c("ggplot2", "dplyr", "forecast", "corrplot", "stringr"))

# Load libraries
library(ggplot2)
library(dplyr)
library(forecast)
library(corrplot)
library(stringr)

# Create folder to store plots
if (!dir.exists("plots")) dir.create("plots")

# Function to detect file inside subfolder
find_file <- function(subfolder) {
  files <- list.files(subfolder, full.names = TRUE)
  csvs <- files[grepl("\\.csv$", files, ignore.case = TRUE)]
  if (length(csvs) > 0) return(csvs[1])
  return(files[1])
}

# Function to load CSV and assign column names
load_and_clean <- function(path, cols, numeric_cols = NULL) {
  df <- read.csv(path, header = FALSE, stringsAsFactors = FALSE)
  names(df) <- cols[seq_len(ncol(df))]
  
  if (!is.null(numeric_cols)) {
    for (col in numeric_cols) {
      if (col %in% names(df)) {
        df[[col]] <- as.numeric(gsub(",", "", trimws(df[[col]])))
      }
    }
  }
  return(df)
}

# Load category sales table
category <- load_and_clean(
  find_file("category_sales"),
  c("Category", "TotalSales", "TotalQuantity"),
  c("TotalSales", "TotalQuantity")
)

# Category-wise sales plot
p1 <- ggplot(category, aes(x = reorder(Category, -TotalSales), y = TotalSales)) +
  geom_col(fill = "skyblue") +
  coord_flip() +
  theme_minimal(base_size = 12) +
  ggtitle("Category-wise Sales Distribution")
ggsave("plots/category_sales.png", p1, width = 10, height = 8)

# Load store performance table
store <- load_and_clean(
  find_file("store_performance"),
  c("Country", "NumOrders", "TotalSales", "AvgOrderValue"),
  c("NumOrders", "TotalSales", "AvgOrderValue")
)

# Top 10 countries by sales
store10 <- head(store[order(-store$TotalSales), ], 10)
p2 <- ggplot(store10, aes(x = reorder(Country, -TotalSales), y = TotalSales)) +
  geom_col(fill = "tomato") +
  coord_flip() +
  theme_minimal() +
  ggtitle("Top 10 Countries by Sales")
ggsave("plots/store_performance.png", p2, width = 10, height = 8)

# Load monthly sales
monthly <- load_and_clean(
  find_file("monthly_sales"),
  c("Year", "Month", "TotalSales", "TotalUnits"),
  c("Year", "Month", "TotalSales", "TotalUnits")
)
monthly$Date <- as.Date(paste(monthly$Year, monthly$Month, 1, sep = "-"))

# Monthly sales trend plot
p3 <- ggplot(monthly, aes(Date, TotalSales)) +
  geom_line(linewidth = 1.2, color = "blue") +
  theme_minimal(base_size = 14) +
  ggtitle("Monthly Sales Trend")
ggsave("plots/monthly_sales.png", p3, width = 10, height = 6)

# Load daily sales
daily <- load_and_clean(
  find_file("daily_sales"),
  c("Year", "Month", "Day", "TotalSales", "TotalUnits"),
  c("Year", "Month", "Day", "TotalSales", "TotalUnits")
)
daily$Date <- as.Date(paste(daily$Year, daily$Month, daily$Day, sep = "-"))

# Daily sales trend plot
p4 <- ggplot(daily, aes(Date, TotalSales)) +
  geom_line(linewidth = 0.8, color = "darkgreen") +
  theme_minimal() +
  ggtitle("Daily Sales Trend")
ggsave("plots/daily_sales.png", p4, width = 10, height = 6)

# Load top products
top <- load_and_clean(
  find_file("top_products"),
  c("StockCode", "Description", "TotalUnits", "TotalSales"),
  c("TotalUnits", "TotalSales")
)
top10 <- head(top[order(-top$TotalSales), ], 10)

# Top 10 products plot
p5 <- ggplot(top10, aes(x = reorder(Description, TotalSales), y = TotalSales)) +
  geom_col(fill = "orange") +
  coord_flip() +
  theme_minimal() +
  ggtitle("Top 10 Selling Products")
ggsave("plots/top_products.png", p5, width = 12, height = 7)

# Sales forecasting with ARIMA
ts_sales <- ts(monthly$TotalSales, frequency = 12,
               start = c(min(monthly$Year), min(monthly$Month)))
model <- auto.arima(ts_sales)
fc <- forecast(model, h = 6)

png("plots/sales_forecast.png", width = 900, height = 600)
plot(fc, main = "6-Month Sales Forecast")
dev.off()

# Load price vs sales
ps <- load_and_clean(
  find_file("price_sales"),
  c("StockCode", "Description", "AvgPrice", "TotalSales", "TotalUnits"),
  c("AvgPrice", "TotalSales", "TotalUnits")
)

# Price vs sales scatter plot
p6 <- ggplot(ps, aes(AvgPrice, TotalSales)) +
  geom_point(alpha = 0.5, color = "purple") +
  theme_minimal() +
  ggtitle("Price vs Sales Relationship")
ggsave("plots/price_vs_sales.png", p6, width = 10, height = 6)

# Load seasonal sales
season <- load_and_clean(
  find_file("seasonal_sales"),
  c("Year", "Month", "Season", "TotalSales"),
  c("Year", "Month", "TotalSales")
)

# Seasonal sales plot
p7 <- ggplot(season, aes(factor(Month), TotalSales, fill = Season)) +
  geom_col() +
  theme_minimal() +
  ggtitle("Seasonal Sales Analysis")
ggsave("plots/seasonal_sales.png", p7, width = 10, height = 6)

# Load weekly pattern
weekly <- load_and_clean(
  find_file("weekly_pattern"),
  c("DayOfWeek", "Hour", "AvgSales", "TotalUnits"),
  c("DayOfWeek", "Hour", "AvgSales", "TotalUnits")
)

# Weekly pattern plot
p8 <- ggplot(weekly, aes(Hour, AvgSales, color = factor(DayOfWeek))) +
  geom_line(linewidth = 1) +
  theme_minimal() +
  ggtitle("Weekly Sales Pattern")
ggsave("plots/weekly_pattern.png", p8, width = 10, height = 6)

# Load brand performance
brand <- load_and_clean(
  find_file("brand_performance"),
  c("Brand", "BrandSales", "BrandUnits"),
  c("BrandSales", "BrandUnits")
)
brand10 <- head(brand[order(-brand$BrandSales), ], 10)

# Brand performance plot
p9 <- ggplot(brand10, aes(x = reorder(Brand, -BrandSales), y = BrandSales)) +
  geom_col(fill = "brown") +
  coord_flip() +
  theme_minimal() +
  ggtitle("Top 10 Performing Brands")
ggsave("plots/brand_performance.png", p9, width = 10, height = 6)

# Load correlation data
corr <- load_and_clean(
  find_file("corr_ready"),
  c("Sales", "Quantity", "UnitPrice"),
  c("Sales", "Quantity", "UnitPrice")
)

png("plots/correlation.png", width = 800, height = 700)
corrplot(cor(corr, use = "complete.obs"), method = "circle")
dev.off()

# Save low-moving products as CSV
low <- load_and_clean(
  find_file("low_moving_products"),
  c("StockCode", "Description", "TotalUnits"),
  c("TotalUnits")
)
write.csv(low, "plots/low_moving_products.csv", row.names = FALSE)

# Save top profit items
margin <- load_and_clean(
  find_file("margin_analysis"),
  c("StockCode", "Description", "TotalSales", "Profit"),
  c("TotalSales", "Profit")
)
write.csv(head(margin[order(-margin$Profit), ], 20),
          "plots/top_profit_items.csv", row.names = FALSE)

cat("All plots saved in:", file.path(getwd(), "plots"), "\n")
