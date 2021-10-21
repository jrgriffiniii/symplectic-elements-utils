# MS SQL Server

## Development using Docker
### Getting Started

```bash
$ bash bin/start.sh
```

### Accessing the terminal for the sqlcmd

```bash
$ bash bin/sqlcmd.sh
```

## Exporting the Elements Databases

### Locating the Credentials

Within the Windows Server environment, one may find the configuration file for the Symplectic Elements installation using the Internet Information Services (IIS):
```powershell
> type D:\Symplectic\Elements\Website\web.config
```

One then finds the following:

#### Development
```xml
<dataSources>
  <dataSource database="publications" connectionString="Data Source=CISDR300W;Initial Catalog=elements;Integrated Security=False;User ID=Sympsql_Dev;Password=$Password" />
  <dataSource database="reporting" connectionString="Data Source=CISDR300W;Initial Catalog=elements-reporting;Integrated Security=False;User ID=Sympsql_Dev;Password=$Password" />
</dataSources>
```

#### Production
```xml
<dataSources>
  <dataSource database="publications" connectionString="Data Source=cisdr200w.princeton.edu;Initial Catalog=elements;Integrated Security=False;User ID=sympsql;Password=$Password" />
  <dataSource database="reporting" connectionString="Data Source=cisdr200w.princeton.edu;Initial Catalog=elements-reporting;Integrated Security=False;User ID=sympsql;Password=$Password" />
</dataSources>
```

### Connecting to the Server Database

#### Testing the connection

```powershell
> sqlcmd -U Sympsql_Dev -P $Password -S CISDR300W -Q "SELECT @@VERSION"
```

#### Listing the databases

```powershell
> sqlcmd -U Sympsql_Dev -P $Password -S CISDR300W -Q "SELECT NAME FROM sys.databases"
```

#### Listing the database tables

```powershell
> sqlcmd -U Sympsql_Dev -P $Password -S CISDR300W -d elements -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'"
```

The database tables usually follow a structure similar to the following:

```mssql
table_name
--------------------------------------------------------------------------------------------------------------------------------
#Publication Record (Field Display Names)___________________________________________________________________________000000002107
#Publication Record_________________________________________________________________________________________________000000002108
```

### Exporting the Database Tables

*This is being drafted.*
