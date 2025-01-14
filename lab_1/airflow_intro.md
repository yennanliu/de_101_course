# Airflow Intro

Apache Airflow 是一個功能強大且彈性極高的開源工具，用於設計、排程和監控工作流程（Workflows）。它最適合處理需要多步驟執行且高度可視化的資料管道或自動化任務，並能有效整合多種工具與服務。

- core: https://airflow.apache.org/docs/apache-airflow/stable/tutorial/index.html
- arch: https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/overview.html


## 核心概念
- 1.	DAG（Directed Acyclic Graph）有向無環圖
 - Airflow 的工作流程是由 DAG 定義的。
 - DAG 是一組有依賴關係的任務，每個任務都以有向無環的形式串聯執行，確保任務不會形成循環。
- 2.	Operator（運算子）
  - Airflow 提供多種運算子，用於定義各種任務，如 Python、Bash、SQL、HTTP 請求等。
  - 運算子可以用來呼叫外部系統或執行程式。
- 3. Scheduler（排程器）
  - Scheduler 根據 DAG 的定義和排程時間表，負責觸發任務執行。
  - 它會根據依賴關係來決定任務的執行順序。
- 4. Web UI
  - 提供直觀的網頁介面，用於檢視 DAG 的運行狀態、手動觸發任務，以及查看執行紀錄。


## 配置

- airflow.cfg

```
[core]
# DAG 檔案存放目錄
dags_folder = /opt/airflow/dags

# 任務執行器類型：SequentialExecutor、LocalExecutor、CeleryExecutor、KubernetesExecutor
executor = LocalExecutor

# Airflow 元數據資料庫的連接字串
sql_alchemy_conn = sqlite:////opt/airflow/airflow.db

# 是否加載範例 DAG
load_examples = False

# 預設的任務日誌格式
default_task_retries = 1

[webserver]
# Web UI 的基礎 URL
base_url = http://localhost:8080

# Web UI 伺服器埠號
web_server_port = 8080

# 用於加密 session cookie 的密鑰
secret_key = temporary_key

# 是否啟用 csrf token 驗證
enable_xsrf_protection = True

[scheduler]
# 排程器的心跳週期（秒）
scheduler_heartbeat_sec = 5

# 排程器掃描 DAG 檔案夾的最小間隔（秒）
min_file_process_interval = 30

# 每個 DAG 的最大併發任務數
dag_concurrency = 16

# 每個 DAG 的最大活動運行數
max_active_runs_per_dag = 16

[database]
# 資料庫連接字串，用於存儲 Airflow 的元數據
sql_alchemy_conn = sqlite:////opt/airflow/airflow.db

[logging]
# 儲存日誌的目錄
base_log_folder = /opt/airflow/logs

# 是否啟用遠端日誌
remote_logging = False

# 日誌層級（DEBUG, INFO, WARNING, ERROR）
log_level = INFO

[celery]
# Celery 的任務隊列（Broker）URL，例如 Redis 或 RabbitMQ
broker_url = redis://localhost:6379/0

# 儲存 Celery 任務結果的後端
result_backend = redis://localhost:6379/0

# 每個 Worker 的最大併發數
worker_concurrency = 16

[kubernetes]
# 當使用 KubernetesExecutor 時，指定 namespace
namespace = default

# 配置 Pod 的啟動模式：標準或自定義
worker_pod_template = /opt/airflow/pod_templates/pod_template.yaml
```