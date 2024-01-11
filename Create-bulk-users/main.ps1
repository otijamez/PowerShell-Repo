#CREATE BULK USERS WITH CSV FILE

$password = ConvertTo-SecureString 'yourpassword' -AsPlainText -Force

Import-Csv -Path "input file path" | `
foreach { New-AzADUser `
-DisplayName $_.DisplayName `
-MailNickname $_.MailNickname `
-UserPrincipalName $_.UserprincipalName `
-Password $Password }
