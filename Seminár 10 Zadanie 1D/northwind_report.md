# Northwind DBT – reporting

SQL dotazy spúšťajte v pgAdmin (Query Tool / Query Builder) nad databázou `northwind_dbt`.
Pri každom grafe vložte obrázok a doplňte interpretáciu podľa skutočných výsledkov.

## 1. Tržby podľa mesiaca (čiarový graf)

```sql
SELECT year, month, month_name, total_sales
FROM reporting.rpt_sales_by_month
ORDER BY year, month;
```

Graf: X = `month_name` (resp. rok-mesiac), Y = `total_sales`.

![Tržby podľa mesiaca](graf1.png)

Interpretácia: *(1–2 vety – ktorý mesiac mal najvyššie tržby, je viditeľný trend?)*

## 2. Tržby podľa kategórie produktov (stĺpcový graf)

```sql
SELECT category_name, total_sales
FROM reporting.rpt_sales_by_category
ORDER BY total_sales DESC;
```

Graf: X = `category_name`, Y = `total_sales`.

![Tržby podľa kategórie](graf2.png)

Interpretácia: *(1–2 vety – ktorá kategória predáva najviac a ktorá najmenej?)*

## 3. Top 10 krajín podľa tržieb (stĺpcový graf)

```sql
SELECT country_name, total_sales
FROM reporting.rpt_sales_by_country
ORDER BY total_sales DESC
LIMIT 10;
```

Graf: X = `country_name`, Y = `total_sales`.

![Top 10 krajín](graf3.png)

Interpretácia: *(1–2 vety – ktoré krajiny dominujú, sú tržby sústredené v pár krajinách?)*
