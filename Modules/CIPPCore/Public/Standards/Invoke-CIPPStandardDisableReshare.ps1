function Invoke-CIPPStandardDisableReshare {
    <#
    .FUNCTIONALITY
    Internal
    #>
    param($Tenant, $Settings)
    $CurrentInfo = New-GraphGetRequest -Uri 'https://graph.microsoft.com/beta/admin/sharepoint/settings' -tenantid $Tenant -AsApp $true
    
    If ($Settings.remediate) {


        if ($CurrentInfo.isResharingByExternalUsersEnabled) {
            try {
                $body = '{"isResharingByExternalUsersEnabled": "False"}'
                $null = New-GraphPostRequest -tenantid $tenant -Uri 'https://graph.microsoft.com/beta/admin/sharepoint/settings' -AsApp $true -Type patch -Body $body -ContentType 'application/json'
                Write-LogMessage -API 'Standards' -tenant $tenant -message 'Disabled guests from resharing files' -sev Info
            } catch {
                Write-LogMessage -API 'Standards' -tenant $tenant -message "Failed to disable guests from resharing files: $($_.exception.message)" -sev Error
            }
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Guests are already disabled from resharing files' -sev Info
        }
    }
    if ($Settings.alert) {

        if ($CurrentInfo.isResharingByExternalUsersEnabled -eq $false) {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Guests are not allowed to reshare files' -sev Info
        } else {
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Guests are allowed to reshare files' -sev Alert
        }
    }
    
    if ($Settings.report) {
        Add-CIPPBPAField -FieldName 'DisableReshare' -FieldValue [bool]$CurrentInfo.isResharingByExternalUsersEnabled -StoreAs bool -Tenant $tenant
    }
}
