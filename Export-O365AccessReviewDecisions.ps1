<#
.SYNOPSIS
Exports Microsoft Entra access review decisions to CSV.

.DESCRIPTION
Connects to Microsoft Graph, retrieves access review definitions, instances,
and decision records, filters decisions by a user-provided start date, resolves
reviewed users and target groups where possible, and exports the results to CSV.

.REQUIREMENTS
- Microsoft.Graph.Identity.Governance
- Microsoft.Graph.Users
- Microsoft.Graph.Groups

.REQUIRED PERMISSIONS
- AccessReview.Read.All
- User.Read.All
- Group.Read.All

.OUTPUTS
O365AccessReviewDecisions.csv
#>

Import-Module Microsoft.Graph.Identity.Governance
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups

try {
    Connect-MgGraph -Scopes "AccessReview.Read.All", "User.Read.All", "Group.Read.All" -NoWelcome
} catch {
    Write-Error "Failed to connect to Microsoft Graph. $_"
    exit 1
}

$inputDate = Read-Host "Enter a start date (MMddyyyy, e.g., 04252024)"
try {
    $startDate = [DateTime]::ParseExact($inputDate, "MMddyyyy", $null)
} catch {
    Write-Host "Invalid date format. Please enter the date in MMddyyyy format." -ForegroundColor Red
    exit 1
}

$allDecisions = @()
$definitions = Get-MgIdentityGovernanceAccessReviewDefinition

foreach ($def in $definitions) {
    Write-Host "Processing review: $($def.DisplayName)" -ForegroundColor Cyan

    $instances = Get-MgIdentityGovernanceAccessReviewDefinitionInstance `
        -AccessReviewScheduleDefinitionId $def.Id

    foreach ($instance in $instances) {
        Write-Host "  Processing instance: $($instance.Id)"

        $decisions = Get-MgIdentityGovernanceAccessReviewDefinitionInstanceDecision `
            -AccessReviewScheduleDefinitionId $def.Id `
            -AccessReviewInstanceId $instance.Id

        foreach ($decision in $decisions) {
            if (-not $decision.ReviewedDateTime -or $decision.ReviewedDateTime -lt $startDate) {
                continue
            }

            $userDisplayName = "N/A"
            $userPrincipalName = "N/A"
            $reviewedByDisplayName = "N/A"
            $groupName = "N/A"

            if ($decision.PrincipalLink -match "https://graph.microsoft.com/v1.0/users/(.*)") {
                $userId = $Matches[1]
                try {
                    $user = Get-MgUser -UserId $userId
                    $userDisplayName = $user.DisplayName
                    $userPrincipalName = $user.UserPrincipalName
                } catch {
                    Write-Host "  Error fetching user: $userId" -ForegroundColor Red
                }
            }

            if ($decision.ResourceLink -match "https://graph.microsoft.com/v1.0/groups/(.*)") {
                $groupId = $Matches[1]
                try {
                    $group = Get-MgGroup -GroupId $groupId
                    $groupName = $group.DisplayName
                } catch {
                    Write-Host "  Could not retrieve group name for ID $groupId" -ForegroundColor Yellow
                }
            }

            if ($decision.ReviewedBy -and $decision.ReviewedBy.DisplayName) {
                $reviewedByDisplayName = $decision.ReviewedBy.DisplayName
            } elseif ($decision.AppliedBy -and $decision.AppliedBy.DisplayName) {
                $reviewedByDisplayName = $decision.AppliedBy.DisplayName
            }

            $allDecisions += [PSCustomObject]@{
                "Group Name"                    = $groupName
                "Review Decision"             = $decision.Decision
                "User Display Name"           = $userDisplayName
                "User Principal Name"         = $userPrincipalName
                "Reviewed Date/Time"          = $decision.ReviewedDateTime
                "Reviewed By"                 = $reviewedByDisplayName
                "Microsoft Recommendation"    = $decision.Recommendation
                "Reviewer Justification"      = $decision.Justification
            }
        }
    }
}

$csvPath = ".\O365AccessReviewDecisions.csv"

$allDecisions |
    Sort-Object "Reviewed Date/Time", "Group Name", "User Display Name" |
    Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Export complete: $csvPath" -ForegroundColor Green