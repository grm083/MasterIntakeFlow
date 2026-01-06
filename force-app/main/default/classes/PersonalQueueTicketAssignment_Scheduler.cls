global class PersonalQueueTicketAssignment_Scheduler implements schedulable
{
    global void execute(SchedulableContext sc)
    {
        PersonalQueueTicketAssignmentTaskBatch pq = new PersonalQueueTicketAssignmentTaskBatch();
        Database.executeBatch(pq, 200);
    }
}