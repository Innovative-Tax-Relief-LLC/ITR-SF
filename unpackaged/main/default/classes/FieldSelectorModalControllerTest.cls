@isTest
public class FieldSelectorModalControllerTest {

    @isTest
    static void testGetObjects() {
        List<String> result = FieldSelectorModalController.getObjects('Account', '');
        System.assertEquals(4, result.size(), 'Expected 4 objects when secondObject is blank');
        System.assert(result.contains('Account'), 'Expected baseObject to be in the list');
        System.assert(result.contains('Opportunity'), 'Expected Opportunity to be in the list');
        System.assert(result.contains('Case'), 'Expected Case to be in the list');
        System.assert(result.contains('Contact'), 'Expected Contact to be in the list');

        result = FieldSelectorModalController.getObjects('Account', 'Account');
        System.assertEquals(4, result.size(), 'Expected 4 objects when baseObject equals secondObject');
        System.assert(result.contains('Account'), 'Expected baseObject to be in the list');
        System.assert(result.contains('Opportunity'), 'Expected Opportunity to be in the list');
        System.assert(result.contains('Case'), 'Expected Case to be in the list');
        System.assert(result.contains('Contact'), 'Expected Contact to be in the list');

        result = FieldSelectorModalController.getObjects('Account', 'Lead');
        System.assertEquals(2, result.size(), 'Expected 2 objects when secondObject is a valid and different value');
        System.assert(result.contains('Account'), 'Expected baseObject to be in the list');
        System.assert(result.contains('Lead'), 'Expected secondObject to be in the list');
    }

    @isTest
    static void testGetFields() {
        List<String> result = FieldSelectorModalController.getFields('Account');
        System.assert(!result.isEmpty(), 'Expected non-empty list of fields for Account');
        System.assert(result.contains('Name'), 'Expected Name field to be in the list for Account');
    }
}