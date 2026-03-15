# Entra Access Review Reporting

PowerShell script for exporting Microsoft Entra access review decisions to CSV using Microsoft Graph PowerShell.

## Features
- Connects to Microsoft Graph
- Enumerates access review definitions and instances
- Filters decisions by start date
- Resolves reviewed users
- Resolves target groups
- Exports results to CSV

## Requirements
- PowerShell 7 recommended
- Microsoft Graph PowerShell SDK

## Install Modules
```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
