# Upgrading Symplectic Elements

## Database Backups
Database backups are available from the Princeton Office of Information Technology

## File Backups
Copy the binaries from the path `D:\Symplectic\Elements\Website\bin` with the following:

```powershell
> $HostName = "cisdr301w"
> $ElementsVersion = "5.12.0"
> $SourcePattern = "D:\Symplectic\Elements\Website\bin\*"
> $DestPath = "F:\backups\symplectic_elements\$HostName\$ElementsVersion"
```
...where this assumes that one is undertaking backups for the host `cisdr301w` for the release `5.12.0`.

## Download the Upgrade Pack

Please then select the release for the upgrade with
https://support.symplectic.co.uk/support/discussions/forums/6000214743. Download
the ZIP-compressed archive into the server environment, and decompress this into
the following:

```
> $ElementsUpgradeUri = "https://$SymplecticHost/elements-5.21.0.3075-x86.zip"
> $ElementsUpgradePath = "C:\Users\libwinvijrg5\downloads\elements-5.21.0.3075-x86.zip"
> Invoke-WebRequest -Uri $ElementsUpgradeUri -OutFile $ElementsUpgradePath
> $LatestBuildFolder = "F:\downloads\symplectic_elements\5.21.0"
> New-Item $LatestBuildFolder -ItemType Directory
> Expand-Archive -LiteralPath $ElementsUpgradePath -DestinationPath $LatestBuildFolder
```

## Enter Maintenance Mode

Uncomment the "notice" flag in the file `D:\Symplectic\Elements\Website\web.config`. In other words, replace:

```xml
<!--add key="notice" value="Site under maintenance. Please come back shortly."/-->
```

with:

```xml
<add key="notice" value="Site under maintenance. Please come back shortly."/>
```

using `psEdit D:\Symplectic\Elements\Website\web.config`, and then please save the file.

## Execute the Setup Utility

```powershell
> Start-Process -FilePath "$LatestBuildFolder\Setup\Setup.exe"
```

