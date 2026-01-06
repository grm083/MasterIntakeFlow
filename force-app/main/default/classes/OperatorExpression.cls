/*
Module: Asset Management -CPQ
Dev: Rishi
FC: Anmoal Bharti
Description: OperatorExpression class is being used to evaluate the String which has operators like equals,not equals,contains,starts with,ends with etc.
             To use the class evaluate() method is exposed.
             BOperatorExpressionTest is the test coverage of the class.
[Update] 16-Mar-2022: Currently the class is being used in ProductRulesExecutor.
*/
public with sharing class OperatorExpression {
    public static Boolean evaluate(Object leftObj, String operatorStr, Object rightObj, String type){
        if(operatorStr == 'equals'){
            if(type == 'String'){
                return leftObj == rightObj ? true : false;
            }else if(type == 'DateTime'){
                DateTime leftDateTime = OperatorExpression.formatDateTime((String)leftObj);
                DateTime rightDateTime = OperatorExpression.formatDateTime((String)rightObj);
                return leftDateTime == rightDateTime ? true : false;
            }else if(type == 'Double'){
                Double leftDbl = (Double)leftObj;
                Double rightDbl = (Double)rightObj;
                return leftDbl == rightDbl ? true : false;
            }else if(type == 'Boolean'){
                Boolean leftDbl = (Boolean)leftObj;
                Boolean rightDbl = (Boolean)rightObj;
                return leftDbl == rightDbl ? true : false;
            }
        }else if(operatorStr == 'not equals'){
            if(type == 'String'){
                return leftObj != rightObj ? true : false;
            }else if(type == 'DateTime'){
                DateTime leftDateTime = OperatorExpression.formatDateTime((String)leftObj);
                DateTime rightDateTime = OperatorExpression.formatDateTime((String)rightObj);
                return leftDateTime != rightDateTime ? true : false;
            }else if(type == 'Double'){
                Double leftDbl = (Double)leftObj;
                Double rightDbl = (Double)rightObj;
                return leftDbl != rightDbl ? true : false;
            }else if(type == 'Boolean'){
                Boolean leftDbl = (Boolean)leftObj;
                Boolean rightDbl = (Boolean)rightObj;
                return leftDbl != rightDbl ? true : false;
            }
        }else if(operatorStr == 'less than'){
            if(type == 'DateTime'){
                DateTime leftDateTime = OperatorExpression.formatDateTime((String)leftObj);
                DateTime rightDateTime = OperatorExpression.formatDateTime((String)rightObj);
                return leftDateTime < rightDateTime ? true : false;
            }else if(type == 'Double'){
                Double leftDbl = (Double)leftObj;
                Double rightDbl = (Double)rightObj;
                return leftDbl < rightDbl ? true : false;
            }
        }else if(operatorStr == 'greater than'){
            if(type == 'DateTime'){
                DateTime leftDateTime = OperatorExpression.formatDateTime((String)leftObj);
                DateTime rightDateTime = OperatorExpression.formatDateTime((String)rightObj);
                return leftDateTime > rightDateTime ? true : false;
            }else if(type == 'Double'){
                Double leftDbl = (Double)leftObj;
                Double rightDbl = (Double)rightObj;
                return leftDbl > rightDbl ? true : false;
            }
        }else if(operatorStr == 'less or equals'){
            if(type == 'DateTime'){
                DateTime leftDateTime = OperatorExpression.formatDateTime((String)leftObj);
                DateTime rightDateTime = OperatorExpression.formatDateTime((String)rightObj);
                return leftDateTime <= rightDateTime ? true : false;
            }else if(type == 'Double'){
                Double leftDbl = (Double)leftObj;
                Double rightDbl = (Double)rightObj;
                return leftDbl <= rightDbl ? true : false;
            }
        }else if(operatorStr == 'greater or equals'){
            if(type == 'DateTime'){
                DateTime leftDateTime = OperatorExpression.formatDateTime((String)leftObj);
                DateTime rightDateTime = OperatorExpression.formatDateTime((String)rightObj);
                return leftDateTime >= rightDateTime ? true : false;
            }else if(type == 'Double'){
                Double leftDbl = (Double)leftObj;
                Double rightDbl = (Double)rightObj;
                return leftDbl >= rightDbl ? true : false;
            }
        }else if(operatorStr == 'starts with'){
            if(type == 'String'){
                try{
                    String leftStr = (String)leftObj;
                    String rightStr = (String)rightObj;
                    return leftStr.startsWithIgnoreCase(rightStr) ? true : false;
                }catch(Exception e){
                    return false;
                }
            }
        }else if(operatorStr == 'ends with'){
            if(type == 'String'){
                try{
                    String leftStr = (String)leftObj;
                    String rightStr = (String)rightObj;
                    return leftStr.endsWithIgnoreCase(rightStr) ? true : false;
                }catch(Exception e){
                    return false;
                }
            }
        }else if(operatorStr == 'contains'){
            if(type == 'String'){
                try{
                    String leftStr = (String)leftObj;
                    String rightStr = (String)rightObj;
                    return leftStr.containsIgnoreCase(rightStr) ? true : false;
                }catch(Exception e){
                    return false;
                }
            }
        }
        return false;
    }

    public static DateTime formatDateTime(String str){
        List<String> strList = str.split(' ');
        List<String> dateList = strList[0].split('-');
        List<String> timeList = strList[1].split(':');
        DateTime DT = DateTime.newInstance(Integer.valueOf(dateList[0]), Integer.valueOf(dateList[1]), Integer.valueOf(dateList[2]),Integer.valueOf(timeList[0]),Integer.valueOf(timeList[1]),Integer.valueOf(timeList[2]));
        return DT;
    }
}