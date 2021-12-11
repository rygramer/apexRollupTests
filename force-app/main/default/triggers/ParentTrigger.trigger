trigger ParentTrigger on Parent__c (after insert, after update, before delete, after delete, after undelete) {
    Rollup.runFromTrigger();
}