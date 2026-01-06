/*************************************************************
@Name: ExceptionHandlingScheduler 
@Author: WM
@CreateDate: 01/03/2021
@Description: Scheduler class for sending Exception log email.
@UsedBy: 
**************************************************************/
global class ExceptionHandlingScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ExceptionLogEmailSend.generateCount();
    }
}