@isTest
public class BooleanExpressionTest {
    @isTest static void eval_test() {
        System.assert(BooleanExpression.evaluate('TRUE'));
        System.assert(BooleanExpression.evaluate('TRUE OR FALSE'));
        System.assert(BooleanExpression.evaluate('TRUE OR TRUE'));
        System.assert(BooleanExpression.evaluate('TRUE OR (TRUE AND FALSE)'));
        System.assert(BooleanExpression.evaluate('TRUE OR (TRUE AND FALSE AND TRUE OR TRUE)'));
        System.assert(BooleanExpression.evaluate('TRUE OR (TRUE AND FALSE AND (TRUE OR FALSE))'));
        System.assert(BooleanExpression.evaluate('TRUE OR (TRUE OR (FALSE AND (TRUE OR FALSE)))'));
        System.assert(BooleanExpression.evaluate('(FALSE OR ((TRUE OR FALSE) AND (TRUE OR FALSE)))'));
        
        System.assert(!BooleanExpression.evaluate('FALSE'));
        System.assert(!BooleanExpression.evaluate('TRUE AND FALSE'));
        System.assert(!BooleanExpression.evaluate('FALSE AND FALSE'));
        System.assert(!BooleanExpression.evaluate('TRUE AND (TRUE AND FALSE)'));
        System.assert(!BooleanExpression.evaluate('FALSE AND (TRUE AND FALSE AND TRUE OR TRUE)'));
        System.assert(!BooleanExpression.evaluate('TRUE AND (TRUE AND FALSE AND (TRUE OR FALSE))'));
        System.assert(!BooleanExpression.evaluate('TRUE AND (TRUE AND (FALSE AND (TRUE OR FALSE)))'));
        System.assert(!BooleanExpression.evaluate('(FALSE AND ((TRUE OR FALSE) AND (TRUE OR FALSE)))'));
    }
}