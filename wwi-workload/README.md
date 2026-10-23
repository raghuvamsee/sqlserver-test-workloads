# wwi-workload

DDL for Microsoft's **WideWorldImportersDW** sample data warehouse (schema only, no data).

Source backup: [`WideWorldImportersDW-Full.bak`](https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImportersDW-Full.bak)
(release `wide-world-importers-v1.0`, SHA-256 `e2f4a37c2db3aa494ca8f7bee2f52372b3d2cceac2ec7e3aa3b140bd1e77bee5`).

## Contents

| Path | What it is |
| --- | --- |
| `WideWorldImportersDW.sql` | Single SQLCMD-mode script that creates the whole database (filegroups, partitioning, schemas, tables, indexes, sequences, procedures, functions, permissions). |
| `schema/<Schema>/<ObjectType>/<Object>.sql` | The same DDL split into one file per object, for browsing and diffing. |
| `schema/Security/` | Schemas and database-level permissions. |
| `schema/Storage/` | Filegroups (`USERDATA`, memory-optimized `WWIDW_InMemory_Data`) and the `PF_Date` / `PS_Date` partition function and scheme. |

Object counts: 29 tables, 74 indexes, 29 primary keys, 29 foreign keys, 8 default constraints, 8 sequences, 24 stored procedures, 1 inline table-valued function.

## Deploying

The full script uses SQLCMD variables and Linux data paths (`/var/opt/mssql/data/`), so it runs as-is against the official SQL Server 2022 container:

```bash
docker run -d --name wwi-sql -e ACCEPT_EULA=Y -e 'MSSQL_SA_PASSWORD=<password>' \
  -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest

docker cp wwi-workload/WideWorldImportersDW.sql wwi-sql:/tmp/
docker exec wwi-sql /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P '<password>' \
  -b -i /tmp/WideWorldImportersDW.sql
```

To use a different database name or data path, edit the `:setvar` lines at the top of the script.
The per-object files reference `$(DatabaseName)` in `schema/Storage/` and are not ordered for direct execution; use the full script to deploy.

## How it was generated

1. Restored the `.bak` into `mcr.microsoft.com/mssql/server:2022-latest`.
2. `sqlpackage /Action:Extract /p:ExtractTarget=SchemaObjectType` for `schema/`.
3. `sqlpackage /Action:Extract` to a `.dacpac`, then `sqlpackage /Action:Script` against a new database for `WideWorldImportersDW.sql`.
4. Verified by running `WideWorldImportersDW.sql` into an empty database and comparing object and index counts with the restored original (all match).
