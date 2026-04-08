@IsTest
private class DemoMathServiceTest {

    @IsTest
    static void testAdd_Passing() {
        Integer result = DemoMathService.add(2, 3);
        Assert.areEqual(5, result, '2 + 3 should be 5');
    }

    @IsTest
    static void testAdd_Failing_Assertion() {
        Integer result = DemoMathService.add(2, 3);
        Assert.areEqual(10, result, 'This assertion is intentionally wrong to force a failure');
    }

    @IsTest
    static void testDivide_Passing() {
        Decimal result = DemoMathService.divide(10, 2);
        Assert.areEqual(5, result, '10 / 2 should be 5');
    }

    @IsTest
    static void testDivide_Failing_Exception() {
        // This will throw an IllegalArgumentException from DemoMathService
        // and the test will appear as Failed due to the unhandled exception.
        DemoMathService.divide(10, 0);
    }
}