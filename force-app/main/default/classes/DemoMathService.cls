public with sharing class DemoMathService {

    public static Integer add(Integer a, Integer b) {
        if (a == null || b == null) {
            throw new IllegalArgumentException('Both parameters are required.');
        }
        return a + b;
    }

    public static Decimal divide(Integer numerator, Integer denominator) {
        if (numerator == null || denominator == null) {
            throw new IllegalArgumentException('Both parameters are required.');
        }
        if (denominator == 0) {
            throw new IllegalArgumentException('Division by zero is not allowed.');
        }
        return Decimal.valueOf(numerator) / Decimal.valueOf(denominator);
    }
}