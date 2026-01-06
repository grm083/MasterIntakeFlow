@isTest
public with sharing class OperatorExpressionTest {
    @isTest static void eval_test() {
        System.assert(OperatorExpression.evaluate('test', 'equals', 'test', 'String'));
        System.assert(OperatorExpression.evaluate('test', 'not equals', 'test1', 'String'));
        System.assert(OperatorExpression.evaluate('test', 'starts with', 't', 'String'));
        System.assert(OperatorExpression.evaluate('test', 'ends with', 't', 'String'));
        System.assert(OperatorExpression.evaluate('test', 'contains', 't', 'String'));
        System.assert(OperatorExpression.evaluate(5, 'equals', 5, 'Double'));
        System.assert(OperatorExpression.evaluate(5, 'not equals', 6, 'Double'));
        System.assert(OperatorExpression.evaluate(5, 'less than', 6, 'Double'));
        System.assert(OperatorExpression.evaluate(5, 'less or equals', 6, 'Double'));
        System.assert(OperatorExpression.evaluate(6, 'greater than', 5, 'Double'));
        System.assert(OperatorExpression.evaluate(6, 'greater or equals', 5, 'Double'));
        System.assert(OperatorExpression.evaluate(true, 'equals', true, 'Boolean'));
        System.assert(OperatorExpression.evaluate(false, 'not equals', true, 'Boolean'));
        System.assert(OperatorExpression.evaluate('2022-10-10 00:00:00', 'equals', '2022-10-10 00:00:00', 'DateTime'));
        System.assert(OperatorExpression.evaluate('2022-10-10 00:00:00', 'not equals', '2022-10-11 00:00:00', 'DateTime'));
        System.assert(OperatorExpression.evaluate('2022-10-10 00:00:00', 'less than', '2022-10-12 00:00:00', 'DateTime'));
        System.assert(OperatorExpression.evaluate('2022-10-10 00:00:00', 'less or equals', '2022-10-12 00:00:00', 'DateTime'));
        System.assert(OperatorExpression.evaluate('2022-10-11 00:00:00', 'greater than', '2022-10-10 00:00:00', 'DateTime'));
        System.assert(OperatorExpression.evaluate('2022-10-11 00:00:00', 'greater or equals', '2022-10-10 00:00:00', 'DateTime'));

    }
}