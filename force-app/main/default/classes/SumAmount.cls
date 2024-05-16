public class SumAmount implements Database.Batchable<SObject>, Database.Stateful{
    public Map<Id, Map<String, Decimal>> accountSummaryMap = new Map<Id, Map<String, Decimal>>();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT AccountId, StageName, Amount FROM Opportunity]);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> subList) {
        for (Opportunity opp : subList) {
            if (opp.AccountId != null) {
                if (!accountSummaryMap.containsKey(opp.AccountId)) {
                    accountSummaryMap.put(opp.AccountId, new Map<String, Decimal>{
                        'Closed Won' => 0,
                            'Open' => 0,
                            'Closed Lost' => 0
                            });
                }
                Map<String, Decimal> stageSummary = accountSummaryMap.get(opp.AccountId);
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
    
    public void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Contact ctt : [SELECT AccountId, Email, Account.Name FROM Contact WHERE Is_Primary_Contact__c = true]) {
            if (ctt != null && accountSummaryMap.containsKey(ctt.AccountId)) {
                Map<String, Decimal> summary = accountSummaryMap.get(ctt.AccountId);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String accName = ctt.Account.Name;
                
                // Format amounts to currency
                String closedWonAmount = summary.get('Closed Won').format();
                String openAmount = summary.get('Open').format();
                String closedLostAmount = summary.get('Closed Lost').format();
                
                email.setToAddresses(new String[] { ctt.Email });
                email.setSubject('Opportunity Summary for ' + accName);
                email.setHtmlBody(
                    'Below is a table of opportunities related to the account: ' + accName + '<br><br>' +
                    '<table border="0">' +
                    '<tr style="background-color: gray; color: white; border: none;">' +
                    '<th>Account</th><th>Stage</th><th>Amount</th></tr>' +
                    '<tr><td>' + accName + '</td><td>Closed Won</td><td>' + 'R$ ' +  closedWonAmount + '</td></tr>' +
                    '<tr><td>' + accName + '</td><td>Open</td><td>' + 'R$ ' + openAmount + '</td></tr>' +
                    '<tr><td>' + accName + '</td><td>Closed Lost</td><td>' + 'R$ ' + closedLostAmount + '</td></tr>' +
                    '</table><br><br>Best Regards'
                );
                emails.add(email);
            }
        }
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}