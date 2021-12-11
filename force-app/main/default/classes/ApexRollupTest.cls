@isTest
public class ApexRollupTest {
    @TestSetup
    public static void setup(){
        upsert new RollupSettings__c(IsEnabled__c = true);
    }
    
    @isTest
    public static void shouldRollUpChildAmountToGrandparent(){
        
    	Grandparent__c gp = new Grandparent__c(
            AmountfromChildren__c = 0
        );
        insert gp;
        
        Parent__c p = new Parent__c(
        	Grandparent__c = gp.Id
        );
        insert p;
        
        Child__c c = new Child__c(
            Parent__c = p.Id
        );
        insert c;
        
        test.startTest();
            c.Amount__c = 5;
            update c;
        test.stopTest();

        gp = [SELECT AmountfromChildren__c FROM GrandParent__c WHERE Id = :gp.Id];

        system.assertEquals(c.Amount__c, gp.AmountfromChildren__c);
        
    }

    @isTest
    public static void shouldRecalcRollupToGrandparentWhenChildIsReparented(){

        Grandparent__c gp1 = new Grandparent__c(
            AmountfromChildren__c = 0
        );
        insert gp1;

        Grandparent__c gp2 = new Grandparent__c(
            AmountfromChildren__c = 0
        );
        insert gp2;
        
        Parent__c p1 = new Parent__c(
        	Grandparent__c = gp1.Id
        );
        insert p1;

        Parent__c p2 = new Parent__c(
        	Grandparent__c = gp2.Id
        );
        insert p2;
        
        Child__c c = new Child__c(
            Parent__c = p1.Id,
            Amount__c = 5.00
        );
        insert c;

        test.startTest();
            c.Parent__c = p2.Id;
            update c;
        test.stopTest();

        c = [SELECT Amount__c, Parent__r.Grandparent__c FROM Child__c WHERE Id = :c.Id];
        system.assertEquals(gp2.Id, c.Parent__r.Grandparent__c); // PASSES
        system.debug(c);

        gp1 = [SELECT AmountfromChildren__c FROM GrandParent__c WHERE Id = :gp1.Id];
        system.assertEquals(0, gp1.AmountfromChildren__c); // FAILS
        system.debug('Grandparent 1 Amt frm Child - '+gp1.AmountfromChildren__c); // 5.00

        gp2 = [SELECT AmountfromChildren__c FROM GrandParent__c WHERE Id = :gp2.Id];
        system.assertEquals(c.Amount__c, gp2.AmountfromChildren__c); // FAILS
        system.debug('Grandparent 2 Amt frm Child - '+gp2.AmountfromChildren__c); // 0.00

    }
}
