@isTest
private class ApplicationContextTest {

    @isTest
    private static void positive_scan() {
        Map<Id, ApexClass> classes = new Map<Id, ApexClass>([
            SELECT Id
            FROM ApexClass
        ]);

        Test.setFixedSearchResults(new List<Id>(classes.keySet()));

        ApplicationContext ctxt = ApplicationContext.start();

        Class2 foundInstance = (Class2) ctxt.getInstance(Class2.class);

        System.assertNotEquals(foundInstance, null);
        System.assertNotEquals(foundInstance.testInstance, null);
    }

    @isTest
    private static void negative_scan_ClassWithAnavailableComponentInConstructor() {
        Map<Id, ApexClass> classes = new Map<Id, ApexClass>([
            SELECT Id
            FROM ApexClass
        ]);

        Test.setFixedSearchResults(new List<Id>(classes.keySet()));

        ApplicationContext ctxt = ApplicationContext.start();

        Class3 foundInstance = (Class3) ctxt.getInstance(Class3.class);

        System.assertEquals(foundInstance, null);
    }
}
