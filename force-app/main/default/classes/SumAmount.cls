public class SumAmount implements Database.Batchable<SObject>, Database.Stateful {
    // This map stores the summary of opportunities for each account, categorized by stage.
    public Map<Id, Map<String, Decimal>> accountSummaryMap = new Map<Id, Map<String, Decimal>>();

    // This method is called at the beginning of the batch job. It returns the query to fetch the data.
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT AccountId, StageName, Amount FROM Opportunity
        ]);
    }
    
    // This method is called for each batch of records fetched by the start method.
    public void execute(Database.BatchableContext bc, List<Opportunity> subList) {
        // Iterate through each Opportunity record in the current batch
        for (Opportunity opp : subList) {
            if (opp.AccountId != null) {
                // Initialize the account summary map if it doesn't already exist for this AccountId
                if (!accountSummaryMap.containsKey(opp.AccountId)) {
                    accountSummaryMap.put(opp.AccountId, new Map<String, Decimal>{
                        'Closed Won' => 0,
                        'Open' => 0,
                        'Closed Lost' => 0
                    });
                }
                // Get the current summary for the account
                Map<String, Decimal> stageSummary = accountSummaryMap.get(opp.AccountId);
                // Update the amount based on the stage of the opportunity
                if (opp.StageName == 'Closed Won') {
                    stageSummary.put('Closed Won', stageSummary.get('Closed Won') + opp.Amount);
                } else if (opp.StageName == 'Open') {
                    stageSummary.put('Open', stageSummary.get('Open') + opp.Amount);
                } else if (opp.StageName == 'Closed Lost') {
                    stageSummary.put('Closed Lost', stageSummary.get('Closed Lost') + opp.Amount);
                }
            }
        }
    }
    
    // This method is called after all batches are processed.
    public void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        // Fetch primary contacts for each account to send summary emails
        for (Contact ctt : [SELECT AccountId, Email, Account.Name FROM Contact WHERE Is_Primary_Contact__c = true]) {
            if (ctt != null && accountSummaryMap.containsKey(ctt.AccountId)) {
                // Get the opportunity summary for the account
                Map<String, Decimal> summary = accountSummaryMap.get(ctt.AccountId);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String accName = ctt.Account.Name;
                
                // Format amounts to currency for better readability
                String closedWonAmount = summary.get('Closed Won').format();
                String openAmount = summary.get('Open').format();
                String closedLostAmount = summary.get('Closed Lost').format();
                
                // Set email properties
                email.setToAddresses(new String[] { ctt.Email });
                email.setSubject('Opportunity Summary for ' + accName);
                email.setHtmlBody(
                    'Below is a table of opportunities related to the account: ' + accName + '<br><br>' +
                    '<table border="0">' +
                    '<tr style="background-color: gray; color: white; border: none;">' +
                    '<th>Account</th><th>Stage</th><th>Amount</th></tr>' +
                    '<tr><td>' + accName + '</td><td>Closed Won</td><td>' + 'R$ ' + closedWonAmount + '</td></tr>' +
                    '<tr><td>' + accName + '</td><td>Open</td><td>' + 'R$ ' + openAmount + '</td></tr>' +
                    '<tr><td>' + accName + '</td><td>Closed Lost</td><td>' + 'R$ ' + closedLostAmount + '</td></tr>' +
                    '</table><br><br>Best Regards'
                );
                // Add the email to the list to be sent
                emails.add(email);
            }
        }
        // Send all emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}
