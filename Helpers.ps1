function New-LabUser {
    param (
        [String]$User, [String]$Password
    )
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $Password
    $PasswordProfile.EnforceChangePasswordPolicy = $false
    $PasswordProfile.ForceChangePasswordNextLogin = $true
    New-AzureADUser -DisplayName $User.Split('@')[0] -PasswordProfile $PasswordProfile -UserPrincipalName $User -AccountEnabled $true -MailNickName "Labuser"
}

function Get-LabPolicyComponents {
    param (
        $file
    ) 
    $text = [IO.File]::ReadAllText($file)
    $parser = New-Object Web.Script.Serialization.JavaScriptSerializer
    $parser.MaxJsonLength = $text.length
    $policy = $parser.Deserialize($text, @{}.GetType())
    return @{
        Policy      = $parser.Serialize($policy['policyRule'])
        Permissions = $parser.Serialize($policy['permissions'])
        Parameters  = $parser.Serialize($policy['parameters'])
        Values      = $parser.Serialize($policy['parameters_values'])
    }
}

function Add-CustomRoleField {
    param (
        $RoleDefinitionName,
        $PolicyComponents,
        $ResourceGroupScope
    )
    $parser = New-Object Web.Script.Serialization.JavaScriptSerializer
    $parser.MaxJsonLength = $PolicyComponents['Permissions'].length+1024
    $role = $parser.Deserialize($PolicyComponents['Permissions'], @().GetType())[0]
    $role['Name'] = $RoleDefinitionName
    $role['Description'] = 'Lab Role'
    $role['AssignableScopes'] = @($ResourceGroupScope.ResourceId)
    $PolicyComponents['Role'] = $parser.Serialize($role)
}

function Write-TempCustomRole {
    param (
        $Permissions
    )
    $CustomRoleFile = [System.IO.Path]::GetTempFileName()
    $stream = [System.IO.StreamWriter] $CustomRoleFile
    $stream.WriteLine($Permissions)
    $stream.close()
    $CustomRoleFile
}