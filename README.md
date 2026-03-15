# Entra Access Review Reporting

PowerShell script for exporting Microsoft Entra access review decisions to CSV using Microsoft Graph PowerShell.

## Overview

This script connects to Microsoft Graph and retrieves access review definitions, instances, and decision records.
It allows filtering decisions based on a specified start date and resolves associated users and target groups where possible.
The results are exported to a structured CSV file for reporting, auditing, or governance review.

## Features

- Connects to Microsoft Graph using delegated permissions
- Enumerates access review definitions and instances
- Filters decision records by start date
- Resolves reviewed users from Graph
- Resolves target group names
- Captures reviewer identity
- Exports structured results to CSV
- Designed for enterprise Entra ID environments

## Requirements

- PowerShell 7 (recommended)
- Microsoft Graph PowerShell SDK
- Appropriate Microsoft Graph permissions

## Required Graph Permissions

- AccessReview.Read.All
- User.Read.All
- Group.Read.All

## Install Microsoft Graph PowerShell

Install-Module Microsoft.Graph -Scope CurrentUser

## Usage

Run the script:

.\Export-O365AccessReviewDecisions.ps1

When prompted, enter a start date in the following format:

MMddyyyy

Example:

04252024

## Output

The script generates the following file in the working directory:

O365AccessReviewDecisions.csv

The exported report includes:

- Group Name
- Review Decision
- User Display Name
- User Principal Name
- Reviewed Date/Time
- Reviewed By
- Microsoft Recommendation
- Reviewer Justification

## Purpose

This script is intended to support:

- Identity governance reporting
- Access review auditing
- Security posture assessments
- Compliance validation activities
- Operational reporting for Entra administrators

## Notes

- Requires appropriate Microsoft Graph permissions
- Designed for delegated authentication scenarios
- Handles missing user or group resolution gracefully
- Suitable for enterprise Microsoft 365 environments
