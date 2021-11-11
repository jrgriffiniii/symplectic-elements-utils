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
  <dataSource database="publications" connectionString="Data Source=CISDR300W;Initial Catalog=elements;Integrated Security=False;User ID=Sympsql_Dev;Password=$DbPassword" />
  <dataSource database="reporting" connectionString="Data Source=CISDR300W;Initial Catalog=elements-reporting;Integrated Security=False;User ID=Sympsql_Dev;Password=$DbPassword" />
</dataSources>
```

#### Production
```xml
<dataSources>
  <dataSource database="publications" connectionString="Data Source=cisdr200w.princeton.edu;Initial Catalog=elements;Integrated Security=False;User ID=sympsql;Password=$DbPassword" />
  <dataSource database="reporting" connectionString="Data Source=cisdr200w.princeton.edu;Initial Catalog=elements-reporting;Integrated Security=False;User ID=sympsql;Password=$DbPassword" />
</dataSources>
```

### Connecting to the Server Database

#### Testing the connection

```powershell
> $DbUser = 'Sympsql_Dev'
> $DbServer = 'CISDR300W'
> sqlcmd -U $DbUser -P $DbPassword -S $DbServer -Q "SELECT @@VERSION"
```

#### Listing the databases

```powershell
> sqlcmd -U $DbUser -P $DbPassword -S $DbServer -Q "SELECT NAME FROM sys.databases"
```

#### Listing the database tables

```powershell
> New-Item .\select_table_names.sql -ItemType File
> Add-Content .\select_table_names.sql '-- Select all table names for the elements database'
```

Then, please copy the contents of `sql/select_table_names.sql`:
```tsql
SELECT QUOTENAME(DB_NAME())
  + '.' + QUOTENAME(SCHEMA_NAME(SCHEMA_ID))
  + '.' + QUOTENAME(name)
  FROM sys.tables;

GO
```

### Generating the Database Table XML Format Files (`bulk copy program (bcp)`)

From within the server environment, please execute the following:

```powershell
> New-Item .\exports -ItemType directory
> Set-Location .\exports
> function Export-Table {
    process {
      $TableName = $_.Trim()

      if (($TableName.IndexOf("rows affected") -eq -1) -and ($TableName.length -gt 0))
      {
        $SchemaFilePath = $TableName.Replace("[", "").Replace("]", "").Replace(".", "_") + '_schema.xml'
        Write-Host "Exporting $TableName schema to $SchemaFilePath..."
        bcp $TableName format nul -x -f $SchemaFilePath -U $DbUser -P $DbPassword -S $DbServer -w

        $ExportFilePath = $TableName.Replace("[", "").Replace("]", "").Replace(".", "_") + '.bcp'
        Write-Host "Exporting $TableName rows to $ExportFilePath..."
        bcp $TableName out $ExportFilePath -U $DbUser -P $DbPassword -S $DbServer -w
      }
    }
  }
> .\exportTables.ps1
> sqlcmd -U $DbUser -P $DbPassword -S $DbServer -d elements -h -1 -i ..\select_table_names.sql | Export-Table

```

In order to transfer these files to a local development environment, one must mount the CIFS file share hosted for one's user account using the path `\\files.princeton.edu\$NetID`. For the purposes of this example, I am mounting this to the drive `F:\`.

Then, please copy the files from the Windows Server environment with the following:

```powershell
> Set-Location ..
> Copy-Item -Path .\exports -Destination F:\exports -Recurse
```

From within the local development environment, please connect to the same CIFS file share, and then please copy these files:

```bash
$ cp -r /Volumes/$NET_ID/exports/*bcp ./exports/
$ cp -r /Volumes/$NET_ID/exports/*bcp ./exports/
```

#### Importing the Database Tables

From within the local development environment, one can then load the tables from `exports` by invoking:

```bash
$ bin/import.sh exports/
```

### Generating Database Backups (BACKUP Strategy)

Then, please copy the contents of `sql/select_table_names.sql`:
```tsql
USE elements;
GO
BACKUP DATABASE elements
TO DISK = 'c:\tmp\elements.bak' WITH FORMAT,
  MEDIANAME = 'ElementsBackups',
  NAME = 'Full Backup of elements';
GO
```

## Generating Database Backups (T-SQL Strategy)

Please copy the contents of `sql/backup.sql`:
```tsql
USE elements;
GO

DECLARE @TableCursor CURSOR;
DECLARE @TableName varchar(255);

BEGIN
  SET @TableCursor = CURSOR FOR
    SELECT table_name FROM elements.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

  OPEN @TableCursor;
  FETCH NEXT FROM @TableCursor INTO @TableName;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC sp_help @TableName;
    FETCH NEXT FROM @TableCursor INTO @TableName;
  END;

  CLOSE @TableCursor;
  DEALLOCATE @TableCursor;
END;

GO
```

Then invoke:

```powershell
> sqlcmd -U $DbUser -P $DbPassword -S $DbServer -h -1 -d elements -i .\sql\backup.sql
```

## Checking the Databases

```bash
$ bin/sqlcmd.sh
```

```mssql
1> SELECT database_id,name FROM sys.databases;
2> GO
```

## Checking the Tables

```mssql
1> SELECT table_name FROM elements.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
2> GO
```
