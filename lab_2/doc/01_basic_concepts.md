# 01_basic_concepts

## Basic

- OLAP VS OLTP
	- BE system VS analytics system
	- 線上分析處理 (OLAP)
	-	 線上分析處理 (OLAP): 分析用, 數據倉儲
	- 線上交易處理 (OLTP) 
		- 後端用, 為了業務處理而設(e.g. 交易, 下單...)
	是資料處理系統，可協助您儲存和分析業務資料。您可從多個來源 (例如網站、應用程式、智慧型電錶和內部系統) 收集和儲存資料。OLAP 會合併和分組資料，以便您可以從不同的角度對其進行分析。而 OLTP 則是可靠且高效地大量儲存和更新交易資料。OLTP 資料庫可以是 OLAP 系統的數個資料來源之一
	- https://aws.amazon.com/tw/compare/the-difference-between-olap-and-oltp/#:~:text=%E5%A4%A7%E7%9A%84%E5%8D%80%E5%88%A5%E3%80%82-,OLAP%20%E8%88%87OLTP%20%E7%9A%84%E4%B8%BB%E8%A6%81%E5%8D%80%E5%88%A5,%E5%BA%AB%E5%AD%98%E5%92%8C%E7%AE%A1%E7%90%86%E5%AE%A2%E6%88%B6%E5%B8%B3%E6%88%B6%E3%80%82
- data cube
	- https://learn.microsoft.com/zh-tw/analysis-services/multidimensional-models/olap-logical/logical-architecture-overview-analysis-services-multidimensional-data?view=asallproducts-allversions
	- https://blog.csdn.net/Forlogen/article/details/88634117

<p align="center"><img src ="../pic/data_cube.png" ></p>

- data granularity
	- 資料顆粒度
	- sales table
		- time=20250101-10-01-01, product=phone, sales=1
		- time=20250101, product=phone, sales=1
		- time=202501, product=phone, sales=1
- Normalization VS Denormalization
- DB basics
	- Index
	- PK
	- SQL vs NoSQL
	- ...

## Code

- [01_basic_concepts.sql](../01_basic_concepts.sql)

## Ref
