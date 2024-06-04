/*
*********************************************************
Apex Class Name    : SummaryBatchHandler
Created Date       : June 3, 2024
@description       : This class processes opportunities to generate a summary 
                     of their amounts categorized by stage for each account. 
                     It also handles sending summary emails to primary contacts.
@author            : Lucas Silva de Oliveira
Modification Log:
Ver   Date         Author          Modification
1.0   06-03-2024   Lucas Silva     Initial Version
*********************************************************
*/
public class SummaryBatchHandler {
  // This map stores the summary of opportunities for each account, categorized by stage.
  public Map<Id, Map<String, Decimal>> accountSummaryMap = new Map<Id, Map<String, Decimal>>();

    /*
    *********************************************************
    @Method Name    : processOpportunity
    @description    : Processes a list of opportunities to update the summary map 
                      with the total amounts for each stage (Closed Won, Open, Closed Lost).
    @param          : List<Opportunity> subList - List of opportunities to process
    @return         : Map<Id, Map<String, Decimal>> - Updated account summary map
    *********************************************************
    */
    public Map<Id, Map<String, Decimal>> processOpportunity(List<Opportunity> subList){        
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
                }  else if (opp.StageName == 'Closed Lost') {
                    stageSummary.put('Closed Lost', stageSummary.get('Closed Lost') + opp.Amount);
                }else {
                    stageSummary.put('Open', stageSummary.get('Open') + opp.Amount);
                }
            }
        }
        return accountSummaryMap;
    }

    /*
    *********************************************************
    @Method Name    : sendSumary
    @description    : Sends summary emails to the primary contacts of accounts 
                      with updated opportunity summaries. The email contains 
                      a summary table of opportunity amounts categorized by stage.
    @param          : Map<Id, Map<String, Decimal>> accSum - Summary map of account opportunity amounts
    @return         : void
    *********************************************************
    */
    public void sendSumary(Map<Id, Map<String, Decimal>> accSum){
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Contact ctt : [SELECT AccountId, Email, Account.Name FROM Contact WHERE Is_Primary_Contact__c = true]) {
            if (ctt != null && accSum.containsKey(ctt.AccountId)) {
                // Get the opportunity summary for the account
                Map<String, Decimal> summary = accSum.get(ctt.AccountId);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String accName = ctt.Account.Name;
                                
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
                    '<tr><td>' + accName + '</td><td>Closed Won</td><td>' + 'R$ ' + closedWonAmount + '</td></tr>' +
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