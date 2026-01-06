# Master Intake Flow System - Technical Overview

## Executive Summary

The Master Intake Flow is a Salesforce-based dynamic case management system that guides customer service representatives through context-aware questionnaires when processing cases. The system intelligently presents questions and routing decisions based on case type, customer, location, and user role, ensuring consistent case handling and proper work distribution across the organization.

## System Purpose

This system serves as a "guided intake process" for customer service representatives, similar to a call center script or decision tree. When a case is created or being worked, the system:

1. **Determines Appropriate Questions**: Identifies which questions to ask based on case context (type, sub-type, reason) and organizational context (customer account, location, user role)
2. **Guides User Through Workflow**: Presents questions in a logical sequence, with each answer determining the next question or final outcome
3. **Automates Case Configuration**: Updates case fields, creates tasks, assigns to queues, and documents the interaction automatically based on user responses
4. **Ensures Consistency**: Provides standardized handling for similar case scenarios across different users and teams

---

## Core Components

### 1. Intake_Process__c Custom Object

**Purpose**: Stores the configuration data that drives the dynamic questionnaire system.

**Record Types**:
- **Intake Questions**: Defines the questions that will be presented to users
- **Intake Outcomes**: Defines the possible answers/outcomes for each question and what actions to take

**Key Fields**:

#### Question Configuration Fields
- **Question__c**: The actual question text displayed to the user
- **Input_Type__c**: Type of response expected (Text, Picklist, Checkbox, Date, Email, Phone, Number, URL, File, Instruction)
- **Presentation_Order__c**: Determines the sequence when multiple questions exist for the same context
- **Case_Type__c, Case_Sub_Type__c, Case_Reason__c**: Criteria that determine when this question applies
- **Customer_Account__c**: Links question to specific customer account (highest priority)
- **Customer_Location__c**: Links question to specific location
- **Customer_Project__c**: Links question to specific project (future feature - currently disabled)
- **User_Role__c**: Links question to specific user roles for role-based scripting

#### Outcome Configuration Fields
- **Intake_Question__c**: Lookup to the parent question this outcome belongs to
- **Outcome__c**: The answer/response value
- **Next_Question__c**: Lookup to the next question to display (if answer leads to more questions)
- **Outcome_Statement__c**: Final message displayed when questioning is complete
- **Any_Value__c**: Boolean indicating if any user input is acceptable for this outcome

#### Action Fields (What happens when this outcome is selected)
- **Update_Case_Record_Type__c**: Boolean - should case record type be changed?
- **Case_Record_Type__c**: Target record type name
- **Update_Case_Type__c**: Boolean - should case type be updated?
- **Case_Type__c**: New case type value
- **Update_Case_Sub_Type__c**: Boolean - should case sub-type be updated?
- **Case_Sub_Type__c**: New case sub-type value
- **Update_Case_Reason__c**: Boolean - should case reason be updated?
- **Case_Reason__c**: New case reason value
- **Update_Case_Status__c**: Boolean - should case status be updated?
- **Case_Status__c**: New status value
- **Team_Name__c**: Team to assign case to
- **Queue_Assigned__c**: Queue to route case to
- **Assign_to_Current_User__c**: Boolean - assign case to current user
- **Create_Task__c**: Boolean - should a task be created?
- **Task_Type__c**: Type of task to create
- **Task_Process__c**: Process associated with the task
- **Update_Service_Date__c**: Boolean - update the service date

**Data Model**: This object contains pre-configured questions and outcomes loaded by administrators. For example:
- A "Service Not Performed" case might have questions about who reported it (hauler vs customer)
- Based on the answer, different outcomes route to different teams or create specific tasks

---

### 2. IntakeProcessAuraHandler Apex Class

**Location**: `/force-app/main/default/classes/IntakeProcessAuraHandler.cls`

**Purpose**: Server-side controller that handles all business logic for the intake process.

**Key Methods**:

#### `getFirstQuestion(Id CaseId)` - Line 141
**Purpose**: Determines the first question to show based on case context

**Logic Flow**:
1. Retrieves case details (Client, Location, Project, Case Type/Sub-Type/Reason)
2. Searches for applicable questions in priority order:
   - **Account-level scripting** (highest priority) - via `getAccountQs()`
   - **Project-level scripting** (commented out for future release)
   - **Location-level scripting** - via `getLocationQs()`
   - **Role-level scripting** - via `getRoleQs()`
   - **General scripting** (lowest priority/fallback) - via `getGeneralQs()`
3. Returns the first matching question with `Presentation_Order__c = 1`

**Why This Matters**: This prioritization allows for highly customized experiences. A VIP customer can have special questions, a specific location can have location-specific handling, or a user role can determine different workflows.

#### `getNextQuestion(Id QuestionId)` - Line 205
**Purpose**: Retrieves the next question details based on an outcome selection

**Returns**: The Intake_Process__c record representing the next question

#### `getOutcomes(Id Question)` - Line 225
**Purpose**: Retrieves all possible outcomes (answers) for a given question

**Returns**: List of Intake_Process__c records with RecordType = 'Intake Outcomes' that are associated with the question

**Usage**: Generates the picklist values or response options shown to the user

#### `doCaseUpdates(Id CaseId, Id OutcomeId)` - Line 28
**Purpose**: Executes all actions defined in an outcome when user selects an answer

**Actions Performed**:
1. Updates case record type (if `Update_Case_Record_Type__c = true`)
2. Updates team and queue assignments (if `Queue_Assigned__c` is populated)
3. Assigns case to current user (if `Assign_to_Current_User__c = true`)
4. Creates a task (if `Create_Task__c = true`) with:
   - Subject from `Task_Type__c`
   - Process = 'Master Intake'
   - Description from `Outcome_Statement__c`
   - Assigned to current user
5. Updates Case Type/Sub-Type/Reason (if respective update flags are true)
6. Updates case status with special handling:
   - If Case Sub-Type = 'Service Not Performed' AND Status = 'Open': Sets Case Sub-Status to 'Pending Service Issue Resolution'
   - If Case Sub-Type = 'Bale(s)' AND Status = 'Pending': Sets Case Sub-Status to 'Pending Request Approval'

**Returns**: The final case status as a string

#### `createComment(Id CaseId, String Comment)` - Line 102
**Purpose**: Creates a comment record documenting the intake process responses

**Actions**:
1. Creates a Comment__c record with:
   - Type = 'Case'
   - Communication Log Type = 'Internal'
   - RecordType = 'Acorn Ticket Comment'
   - Comment text (with "Additional Comments" replaced with "Additional Comments/Instructions for Other Teams")
2. Updates case fields:
   - `Master_Intake_Complete__c = true`
   - `Case_Comments__c = 'Salesforce Generated Case'`

**Why This Matters**: This creates an audit trail of what questions were asked and what answers were given during the intake process.

#### `getCaseDetails(Id CaseId, Boolean updateFlow)` - Line 8
**Purpose**: Retrieves case details and optionally marks the flow as complete

**Parameters**:
- `CaseId`: The case being processed
- `updateFlow`: If true, sets `Master_Intake_Complete__c = true`

**Returns**: Case record with `Master_Intake_Complete__c` field

---

### 3. MasterIntakeShell Aura Component

**Location**: `/force-app/main/default/aura/MasterIntakeShell/`

**Purpose**: Lightning component wrapper that embeds the Master Intake Flow and controls when it displays.

**Component Structure** (`MasterIntakeShell.cmp`):
```xml
<aura:component implements="flexipage:availableForAllPageTypes,force:hasRecordId"
                controller="IntakeProcessAuraHandler">

    <aura:attribute name="Question" type="Intake_Process__c" />
    <aura:handler name="init" value="{!this}" action="{!c.init}" />
    <aura:handler event="force:refreshView" action="{!c.init}" />

    <lightning:card>
        <aura:if isTrue="{!not(empty(v.Question))}">
            <lightning:flow aura:id="MasterIntake" />
        </aura:if>
    </lightning:card>

</aura:component>
```

**Key Features**:
- Can be placed on any page type (`flexipage:availableForAllPageTypes`)
- Has access to current record ID (`force:hasRecordId`)
- Only displays the flow if there are questions to show (SDT-14129 requirement)
- Refreshes when the view is refreshed

**Controller Logic** (`MasterIntakeShellController.js`):

**init Function** (Line 2):
1. Gets the current case ID from `recordId` attribute
2. Calls `getCaseDetails` to check if `Master_Intake_Complete__c` is true
3. If intake is NOT complete:
   - Calls `getFirstQuestion` to retrieve the first question
   - If a question exists:
     - Launches the 'Master_Intake_Flow' flow
     - Passes the case ID as a flow input variable
4. If intake IS complete:
   - Refreshes the view to hide the component

**Why This Approach**:
- The component dynamically hides itself when not needed
- Flow is embedded within the component rather than placed directly on the page
- Allows better control over when the intake process shows/hides based on case state

---

### 4. Master_Intake_Flow Flow

**Location**: `/force-app/main/default/flows/Master_Intake_Flow.flow-meta.xml`

**Purpose**: Screen flow that presents the dynamic questions to users and processes their responses.

**Flow Variables**:
- `recordId` (Input): The case ID being processed
- `currentCase` (SObject): Case record details
- `CaseCommentConcatenation` (String): Accumulates question/answer pairs for final comment
- `nextQuestionId` (String): Tracks which question to show next
- `boolEnd` (Boolean): Indicates if questioning is complete
- `EndStatement` (String): Final message to display
- `QuoteEligibleFlag` (Boolean): Whether case is eligible for CPQ
- `FinalOutcomeId` (String): ID of the selected final outcome

**Key Screens**:

#### 1. **Case Incomplete Warning** (Line 475)
- Checks if required fields are populated (Case Type, Sub-Type, Client, Location)
- If any are missing, displays message and loops back to start
- Prevents intake process from running on incomplete cases

#### 2. **Help With Flow Screen** (Line 638)
- Transition screen explaining the Case Template Tool is starting
- Allows user to make last-minute changes to Case Type/Sub-Type/Reason before proceeding

#### 3. **RequestedEffectiveDateScreen** (Line 716)
**Triggered When**: Case is eligible for CPQ (Configure Price Quote) based on metadata lookup
**Purpose**: Captures the requested service effective date
**Key Features**:
- Shows SLA Override Reason and Comment fields if requested date is earlier than current service date
- Validates that both override reason AND comment are provided if date is being moved up
- Defaulted to current case service date

#### 4. **First Dynamic Questions** (Line 577)
**Purpose**: Displays the first question from the `getFirstQuestion` call
**Component**: Uses custom Lightning component `c:DynamicQuestions`
**Outputs**:
- `nextQuestionId`: ID of next question to show
- `QuestionAnswer`: The user's response (formatted as "Question: Answer")
- `boolEnd`: Whether this was the final question

#### 5. **Next Dynamic Question** (Line 657)
**Purpose**: Displays subsequent questions in a loop
**Same Logic**: Uses `c:DynamicQuestions` component
**Loop Behavior**: Continues showing questions until `boolEnd = true`

#### 6. **End Statement Display** (Line 495)
**Purpose**: Shows final summary and next steps
**Displays**:
- Concatenated summary of all questions and answers
- Outcome statement from the final selected outcome
- Additional comments field via custom component `c:flowFalseFinish`

**Flow Logic**:

1. **Start**: Gets case details and validates completeness
2. **CPQ Eligibility Check**:
   - Queries `AC_Scope_Controller__mdt` metadata for matching Case Type/Sub-Type/Reason
   - If match found AND user has `Update_Asset_Active_User__c = true`: Case is CPQ eligible
3. **If CPQ Eligible**:
   - Shows RequestedEffectiveDateScreen
   - Validates SLA override if needed
   - Updates case service date
   - Runs subflow: `Validation_Add_Change_Scope_Evaluation`
   - Shows "Case Eligible for Quote" screen
4. **If Not CPQ Eligible** (or after CPQ path):
   - Shows first dynamic question
   - Loops through subsequent questions
   - Accumulates answers in `CaseCommentConcatenation`
5. **Completion**:
   - Shows end statement with summary
   - Creates comment via `c:flowFalseFinish` component
   - Calls `doCaseUpdates` to execute outcome actions

**Special Handling**:
- **Looping Logic**: Uses decision elements `End_of_Statement` and `End_of_Statement_0` to determine if more questions exist
- **Comment Building**: Each answer is concatenated with a newline to build a complete transcript
- **Error Handling**: Has fault connector on `Get_Case_Details` that shows error screen

---

## How It All Works Together

### Scenario: Customer Service Rep Opens a "Service Not Performed" Case

1. **Case Created**:
   - Case Type: "Status"
   - Case Sub-Type: "Service Not Performed"
   - Case Reason: "Hauler Reported"
   - Client: Acme Corporation
   - Location: Acme Store #123

2. **MasterIntakeShell Component Loads**:
   - Component is embedded on Case page layout
   - Controller `init` method fires
   - Calls `getCaseDetails` - returns `Master_Intake_Complete__c = false`
   - Calls `getFirstQuestion` with case ID

3. **IntakeProcessAuraHandler.getFirstQuestion Executes**:
   - Queries case: gets Client, Location, Case Type/Sub-Type/Reason
   - Searches for questions in priority order:
     - **Account Level**: Searches for Intake Question with `Customer_Account__c = 'Acme Corporation'`, matching case types, `Presentation_Order__c = 1`
     - If not found, searches **Location Level**
     - If not found, searches **User Role** Level based on current user's role
     - Falls back to **General** scripting if no specific match
   - Returns the matching Intake_Process__c question record

4. **Flow Launches**:
   - MasterIntakeShell starts 'Master_Intake_Flow' with case ID
   - Flow validates case completeness
   - Checks CPQ eligibility (not eligible for Status cases)
   - Displays First Dynamic Questions screen

5. **First Question Displays**:
   - Question: "Who reported this service issue?"
   - Component calls `getOutcomes` to get possible answers:
     - Outcome 1: "Customer reported directly"
     - Outcome 2: "Hauler reported during service"
     - Outcome 3: "Discovered during inspection"

6. **User Selects Answer**: "Hauler reported during service"
   - Answer is appended to `CaseCommentConcatenation`: "Who reported: Hauler reported during service\n"
   - Outcome record has `Next_Question__c` pointing to next question

7. **Next Question Displays**:
   - Question: "Was the hauler able to provide details?"
   - User selects: "Yes - detailed notes available"
   - Outcome has `Next_Question__c = null` and `Outcome_Statement__c` populated (indicates end of questions)
   - Sets `boolEnd = true`

8. **End Statement Screen**:
   - Shows concatenated summary of Q&A
   - Shows outcome statement: "Your case has been routed to the Service Resolution Team. Please attach hauler notes to the case."
   - User can add additional comments
   - Custom component `c:flowFalseFinish` calls `createComment` to save the transcript
   - Calls `doCaseUpdates` with the final outcome ID

9. **Case Updates Execute**:
   - Based on outcome configuration:
     - Changes Case Record Type to "Status Case"
     - Sets Team Name = "Service Resolution Team"
     - Sets Queue = "CS Resolution"
     - Sets Case Status = "Open"
     - Sets Case Sub-Status = "Pending Service Issue Resolution" (special logic)
     - Creates Task:
       - Subject: "Obtain Internal Response"
       - Process: "Master Intake"
       - Owner: Current User

10. **Completion**:
    - Sets `Master_Intake_Complete__c = true` on case
    - Component refreshes and hides itself
    - Case is now properly configured and routed

---

## Configuration Hierarchy & Priority

The system uses a **hierarchical matching** system to determine which questions to show:

### Priority Order (Highest to Lowest):

1. **Account-Specific** (`Customer_Account__c` populated)
   - Most specific - for VIP customers or special handling scenarios
   - Example: Walmart gets custom questions about their specific processes

2. **Project-Specific** (`Customer_Project__c` populated)
   - *Currently disabled/commented out - future feature*
   - Would allow project-based workflows

3. **Location-Specific** (`Customer_Location__c` populated)
   - For locations with unique requirements
   - Example: A high-security facility might have additional verification questions

4. **Role-Specific** (`User_Role__c` populated)
   - Different questions for different user roles
   - Example: Project Managers see different questions than Customer Service Reps

5. **General** (All context fields null)
   - Fallback for standard case handling
   - Used when no specific scripting exists

### Matching Logic:
Within each priority level, the system matches:
- Case Type (e.g., "Status", "Billing", "Pickup")
- Case Sub-Type (e.g., "Service Not Performed", "Equipment")
- Case Reason (e.g., "Hauler Reported", "Customer Reported") - if populated on case
- Presentation Order = 1 (for the first question)

---

## Data Structure Example

### Sample Question Record (Intake Questions Record Type):
```
Name: INT-000123
RecordType: Intake Questions
Case_Type__c: Status
Case_Sub_Type__c: Service Not Performed
Case_Reason__c: Hauler Reported
Customer_Account__c: [Acme Corp ID]
Question__c: "Please describe the service issue reported by the hauler"
Input_Type__c: Text
Presentation_Order__c: 1
```

### Sample Outcome Records (Intake Outcomes Record Type):
```
Name: INT-000124
RecordType: Intake Outcomes
Intake_Question__c: INT-000123
Outcome__c: "Equipment failure prevented service"
Next_Question__c: INT-000125
Update_Case_Type__c: true
Case_Type__c: Status
Team_Name__c: Service Resolution Team
Queue_Assigned__c: CS Resolution

---

Name: INT-000126
RecordType: Intake Outcomes
Intake_Question__c: INT-000123
Outcome__c: "Location was inaccessible"
Next_Question__c: INT-000127
Update_Case_Status__c: true
Case_Status__c: Pending
Create_Task__c: true
Task_Type__c: Obtain Customer info
```

---

## Business Value

### For Customer Service Representatives:
- **Guided Process**: No need to memorize complex routing rules
- **Consistency**: Same scenarios handled the same way every time
- **Reduced Errors**: Automated field updates eliminate manual mistakes
- **Training**: New reps can handle cases effectively with built-in guidance

### For Management:
- **Standardization**: Enforce business processes across all users
- **Flexibility**: Update workflows without code changes (configuration-driven)
- **Visibility**: Comments provide audit trail of decision-making
- **Scalability**: Handle complex routing scenarios for different customers, locations, and roles

### For The Organization:
- **Work Distribution**: Cases automatically route to correct teams/queues
- **SLA Compliance**: Proper urgency and status settings from the start
- **Customer Experience**: Faster, more accurate case handling
- **Customization**: VIP customers can have tailored workflows

---

## Technical Architecture

### Technology Stack:
- **Salesforce Lightning Aura Framework**: UI layer
- **Apex**: Server-side business logic
- **Flow Builder**: Declarative process orchestration
- **Custom Objects**: Configuration data storage
- **Lightning Components**: Reusable UI components

### Design Patterns:
- **Strategy Pattern**: Different question resolution strategies (Account, Location, Role, General)
- **Chain of Responsibility**: Question flows linked via Next_Question__c
- **Command Pattern**: Outcomes encapsulate actions to perform
- **Template Method**: Standard flow with customizable question content

### Integration Points:
- **CPQ Integration**: Validates quote eligibility via `AC_Scope_Controller__mdt` metadata
- **Case Management**: Updates case fields, creates tasks, assigns ownership
- **Comment System**: Creates audit trail in `Comment__c` object
- **User Context**: Leverages user role and permissions

---

## Configuration & Maintenance

### Adding New Questions:
1. Create Intake_Process__c record with RecordType = "Intake Questions"
2. Set Case Type/Sub-Type/Reason criteria
3. Optionally set Customer Account, Location, or User Role for specific scenarios
4. Set Presentation Order (1 for first question)
5. Define Question text and Input Type

### Adding Outcomes:
1. Create Intake_Process__c record with RecordType = "Intake Outcomes"
2. Link to parent question via Intake_Question__c
3. Define Outcome text (the answer choice)
4. Either:
   - Set Next_Question__c to continue questioning, OR
   - Set Outcome_Statement__c for final message
5. Configure actions: update flags, team/queue assignments, task creation

### Modifying Workflows:
- **No Code Changes Required**: All configuration is data-driven
- **Testing**: Use test cases with specific types to validate question flow
- **Version Control**: Intake_Process__c records support history tracking

---

## Future Enhancements (Documented in Code)

### Project-Level Scripting:
- Currently commented out in `getFirstQuestion` (lines 174-197)
- Would query on `Customer_Project__c` field
- Intended for project-specific workflows
- Code structure already in place, ready to enable

### Any Value Handling:
- `Any_Value__c` field exists on outcomes but not currently utilized
- Could allow free-text responses with validation logic

---

## Testing & Quality

### Test Coverage:
- `IntakeProcessAuraHandlerTest.cls` provides comprehensive unit tests
- Tests all priority levels: Account, Location, Role, General
- Tests outcome processing and case updates
- Tests comment creation
- Tests null handling for Case Reason

### Test Scenarios Covered:
1. Account-specific questions
2. Location-specific questions
3. Role-specific questions
4. General fallback questions
5. Case updates with all outcome options
6. Task creation
7. Comment creation with special character handling

---

## Key Terminology

- **Intake Process**: The overall system for guided case handling
- **Intake Question**: A question presented to the user (Intake Questions record type)
- **Intake Outcome**: A possible answer/result for a question (Intake Outcomes record type)
- **Presentation Order**: Sequence number for questions (allows multiple questions per scenario)
- **Master Intake Complete**: Flag on Case indicating intake process has finished
- **Outcome Statement**: Final message shown when questioning ends
- **Next Question**: Link from one outcome to the next question in the chain
- **CPQ Eligible**: Case qualifies for Configure-Price-Quote functionality
- **Hierarchical Matching**: Priority-based system for question selection

---

## System Dependencies

### Salesforce Objects:
- **Case**: Primary object being processed
- **Comment__c**: Custom comment object for audit trail
- **Task**: Standard Salesforce task object
- **User**: For role-based scripting
- **RecordType**: For Case record type updates
- **AC_Scope_Controller__mdt**: Metadata for CPQ eligibility

### Flows:
- **Master_Intake_Flow**: Main flow (this system)
- **Validation_Add_Change_Scope_Evaluation**: Subflow for CPQ validation

### Custom Components:
- **c:DynamicQuestions**: Lightning component for rendering questions
- **c:flowFalseFinish**: Component for final comment capture

---

## Summary

The Master Intake Flow system is a sophisticated, configuration-driven case management solution that provides:

1. **Intelligence**: Context-aware question selection based on case, customer, location, and user
2. **Automation**: Automatic case updates, task creation, and work routing
3. **Flexibility**: Easy to modify workflows without code changes
4. **Scalability**: Supports complex enterprise scenarios with hierarchical matching
5. **Auditability**: Complete transcript of questions and answers
6. **User Experience**: Guided, consistent process for all users

It transforms case intake from a manual, error-prone process into a streamlined, intelligent workflow that ensures cases are handled correctly from the very beginning.
