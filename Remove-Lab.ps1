. .\Variables.ps1
$ResourceGroupScope = Get-AzureRmResourceGroup -Name $Lab
Remove-AzureRmPolicyAssignment -Name $PolicyAssignmentName -Scope $ResourceGroupScope.ResourceId
Remove-AzureRmPolicyDefinition -Name $PolicyDefinitionName -Force
Remove-AzureRmRoleAssignment -SignInName $User -ResourceGroupName $Lab -RoleDefinitionName $RoleDefinitionName
Remove-AzureRmRoleDefinition -Name $RoleDefinitionName -Scope $ResourceGroupScope.ResourceId -Force
Remove-AzureADUser -ObjectId $User
Remove-AzureRmResourceGroup -Name $Lab -Force