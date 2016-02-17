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
