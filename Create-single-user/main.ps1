#CREATE A SINGLE USER

$Firstname = Read-Host -Prompt 'Enter Firstname'
$Surname = Read-Host -Prompt 'Enter Surname'
$Username = Read-Host -Prompt 'Enter Username'
$UPN = Read-Host -Prompt 'Enter UPN'
$Password = Read-Host -Prompt 'Enter Password'

New-AzADUser `
  -DisplayName $Firstname `
  -Surname $Surname `
  -MailNickname $Username `
  -UserPrincipalName $UPN `
  -Password ( ConvertTo-SecureString $Password -AsPlainText -Force)`
 
