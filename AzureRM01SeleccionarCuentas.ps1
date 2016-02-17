#para seleccionar la cuenta de Azure con la que quieres trabajar utilizando powershell
Login-AzureRmAccount
$subscriptionId = 
    ( Get-AzurermSubscription |
        Out-GridView `
          -Title "Selecciona cuenta ..." `
          -PassThru
    ).SubscriptionId

Select-AzurermSubscription -SubscriptionId $subscriptionId

#Comprobación
Get-AzurermSubscription
