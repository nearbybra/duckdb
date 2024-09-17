
# Guia Passo a Passo: Configuração do DuckDB e dbt para Dados de Táxi de NYC

Este guia vai te guiar pela configuração do **DuckDB** e **dbt** para trabalhar com um grande conjunto de dados de corridas de táxi de Nova York. Ao final desta configuração, você terá ingerido mais de 1 milhão de linhas em menos de 35 segundos e gerado insights utilizando o dbt.

## 1. Instalar DuckDB e dbt

Primeiro, certifique-se de que você tem tanto o **DuckDB** quanto o **dbt** instalados na sua máquina.

### Instalação do DuckDB:
```bash
pip install duckdb
```

### Instalação do dbt:
```bash
pip install dbt-core dbt-duckdb
```

## 2. Configurar o Projeto dbt

Crie um novo projeto dbt para analisar os dados de Táxi de NYC.

```bash
mkdir taxi_project
cd taxi_project
dbt init taxi_project
```

Isso vai inicializar um projeto dbt com as pastas e arquivos necessários.

## 3. Configurar o Profile do dbt

Para conectar o dbt com o DuckDB, configure seu arquivo `profiles.yml`. Esse arquivo geralmente está localizado em `~/.dbt/` (ou crie se ele não existir).

Adicione a seguinte configuração:

```yaml
taxi_project:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: data/my_duckdb_database.duckdb
      schema: analytics
```

## 4. Preparar o Conjunto de Dados

Baixe o grande conjunto de dados de Táxi de NYC ou use um arquivo CSV com mais de 1 milhão de linhas. Coloque-o na pasta `data/` dentro do diretório do seu projeto.

Por exemplo:

```bash
mv caminho_para_o_dataset/nyc_taxi_data_massive.csv data/
```

## 5. Criar Modelos dbt

Crie um novo modelo SQL para ingerir os dados. Na sua pasta `models/`, crie um arquivo chamado `nyc_taxi_tb.sql` com o seguinte conteúdo:

```sql
WITH raw_data AS (
  SELECT * FROM read_csv_auto('data/nyc_taxi_data_massive.csv')
)

SELECT
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  fare_amount,
  total_amount,
  payment_type
FROM raw_data;
```

Agora, crie outro arquivo `nyc_taxi_analysis.sql` para gerar insights dos dados:

```sql
WITH payment_data AS (
    SELECT
        payment_type,
        SUM(total_amount) AS total_revenue,
        COUNT(*) AS total_trips,
        AVG(total_amount) AS avg_fare
    FROM {{ ref('nyc_taxi_tb') }}
    GROUP BY payment_type
)

SELECT
    payment_type,
    total_revenue,
    total_trips,
    avg_fare
FROM payment_data
ORDER BY total_revenue DESC;
```

## 6. Executar os Modelos dbt

Agora, execute os modelos dbt para ingerir o conjunto de dados e gerar os insights.

```bash
dbt run
```

- A **ingestão dos dados** com mais de 1 milhão de linhas levará menos de 35 segundos.
- A **análise** para gerar insights dos dados levará outros 34 segundos.

## 7. Consultar os Dados

Uma vez que os modelos tenham sido executados, você pode consultar o banco de dados DuckDB para verificar os resultados. Abra o DuckDB via CLI ou use Python:

```bash
duckdb data/my_duckdb_database.duckdb
```

Ou use Python:

```python
import duckdb

con = duckdb.connect("data/my_duckdb_database.duckdb")
result = con.execute("SELECT * FROM analytics.nyc_taxi_analysis LIMIT 10").fetchall()

for row in result:
    print(row)
```
