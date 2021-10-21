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
> Add-Item \.select_table_names.sql
> Add-Content \.select_table_names.sql '-- Select all table names for the elements database'
```

Then, please copy the contents of `sql/select_table_names.sql`:
```tsql
SELECT QUOTENAME(DB_NAME())
  + '.' + QUOTENAME(SCHEMA_NAME(SCHEMA_ID))
  + '.' + QUOTENAME(name)
  FROM sys.tables;

GO
```

### Exporting the Database Tables

```powershell
> New-Item .\exports -ItemType directory
> function Export-Table {
    process {
      $TableName = $_.Trim()

      if ( ($TableName.IndexOf("rows affected") -eq -1) -and ($TableName.length -gt 0) )
      {
        $ExportFilePath = '.\exports\' + $TableName.Replace("[", "").Replace("]", "").Replace(".", "_") + '.bcp'

        Write-Host "Exporting $TableName to $ExportFilePath..."
        bcp $TableName out $ExportFilePath -U Sympsql_Dev -P $Password -S CISDR300W -w
      }
    }
  }
> sqlcmd -U Sympsql_Dev -P $Password -S CISDR300W -d elements -h -1 -i .\select_table_names.sql | Export-Table
```
