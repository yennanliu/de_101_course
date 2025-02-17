# 03_datamart_warehouse_tutorial

<p align="center"><img src ="../pic/dw_layers.png" ></p>


## Concept

- Data lake VS data warehouse VS data mart

| Stage          | Purpose                   | Technology                  | Example Table                                       |
|---------------|---------------------------|-----------------------------|-----------------------------------------------------|
| **Data Lake**  | Stores raw data           | AWS S3, Hadoop              | `raw_game_events`, `raw_ad_campaigns`, `raw_transactions` |
| **Data Warehouse** | Cleans & structures data | Redshift, Snowflake, BigQuery | `dw_game_events`, `dw_ad_campaigns`, `dw_transactions` |
| **Data Mart**  | Optimized for analytics   | Redshift, BI tools          | `dm_player_sessions`, `dm_campaign_performance`, `dm_revenue_summary` |


- ELT VS ETL
	- 擷取、載入和轉換 (ELT) VS 擷取、轉換和載入 (ETL)
	- https://aws.amazon.com/tw/compare/the-difference-between-etl-and-elt/#:~:text=ETL%20%E6%9C%80%E9%81%A9%E5%90%88%E6%96%BC%E6%82%A8,%E7%AD%89%E9%9D%9E%E7%B5%90%E6%A7%8B%E5%8C%96%E8%B3%87%E6%96%99%E3%80%82

## Ref
- https://ithelp.ithome.com.tw/articles/10357605 - 3 layer of DW
	- Data lake -> data warehouse -> data mart