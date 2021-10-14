# MS SQL Server

## Development using Docker
### Getting Started

```bash
$ docker pull mcr.microsoft.com/mssql/server:2017-latest
$ docker run \
  --name sqlenterprise \
  --hostname sqlenterprise \
  --publish 1433:1433 \
  --env 'ACCEPT_EULA=Y' \
  --env 'SA_PASSWORD=<YourStrong!Passw0rd>' \
  --env 'MSSQL_PID=Enterprise' \
  --detach mcr.microsoft.com/mssql/server:2017-latest
```

```bash
$ docker exec \
  --interactive \
  --tty \
  sqlenterprise \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P '<YourStrong!Passw0rd>'
```

Querying for Tables within a Database

```sql
> USE [<DATABASE_NAME>];
> SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE';
```

Exporting Tables from a Database

From the PowerShell within the server environment:
```powershell
> Invoke-Sqlcmd -Query "SELECT * FROM [Sandbox].[dbo].[Customer]" -ServerInstance ".\SQL2019" | Export-DbaDbTableData -FilePath '.\export.sql'
```

By invoking `Get-DbaDbTable`:
```powershell
> Get-DbaDbTable -SqlInstance sqlenterprise\SQL2019 -Database Enterprise -Table 'dbo.Table1', 'dbo.Table2' |  Export-DbaDbTableData -FilePath .\Combined.sql -Append
```

### Exporting from the Database Server

Within the Windows Server environment, one may find the configuration file for the Symplectic Elements installation using the Internet Information Services (IIS):
```powershell
> type D:\Symplectic\Elements\Website\web.config
```

One then finds the following:

#### Developer
```xml
<dataSources>
  <dataSource database="publications" connectionString="Data Source=CISDR300W;Initial Catalog=elements;Integrated Security=False;User ID=Sympsql_Dev;Password=$PASSWORD" />
  <dataSource database="reporting" connectionString="Data Source=CISDR300W;Initial Catalog=elements-reporting;Integrated Security=False;User ID=Sympsql_Dev;Password=$PASSWORD" />
</dataSources>
```

#### Production
```xml
<dataSources>
  <dataSource database="publications" connectionString="Data Source=cisdr200w.princeton.edu;Initial Catalog=elements;Integrated Security=False;User ID=sympsql;Password=$PASSWORD" />
  <dataSource database="reporting" connectionString="Data Source=cisdr200w.princeton.edu;Initial Catalog=elements-reporting;Integrated Security=False;User ID=sympsql;Password=$PASSWORD" />
</dataSources>
```

One can then export the database tables by invoking `Get-DbaDbTable`:
```powershell
> Get-DbaDbTable -SqlInstance sqlenterprise\SQL2019 -Database Enterprise -Table 'dbo.Table1', 'dbo.Table2' | Export-DbaDbTableData -FilePath .\Combined.sql -Append
> Get-DbaDbTable -SqlInstance sqlenterprise\SQL2019 -Database Enterprise -Table 'dbo.Table1', 'dbo.Table2' | Export-DbaDbTableData -FilePath .\Combined.sql -Append
```
