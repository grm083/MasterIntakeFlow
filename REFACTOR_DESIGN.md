# Master Intake Flow - LWC Refactor Design Document

## Overview
This document outlines the architecture and implementation strategy for refactoring the Master Intake Flow from Aura components to Lightning Web Components (LWC), with significant UX improvements.

## Design Goals

### Primary Objectives
1. **Eliminate "Next" button friction** - Questions appear automatically as users answer
2. **Enable answer editing** - Users can go back and modify previous answers
3. **Improve performance** - Batch fetch questions to reduce Apex calls
4. **Better visual feedback** - Smooth animations and clear progress indication
5. **Preview outcomes** - Show what will happen before completing intake

### User Experience Principles
- **Progressive Disclosure**: Only show next question when previous is answered
- **Instant Feedback**: Auto-advance on answer selection (blur for text inputs)
- **Forgiving**: Easy to edit previous answers and change path
- **Transparent**: Clear preview of actions before execution

## Architecture

### Component Structure

```
force-app/main/default/lwc/
├── masterIntakeForm/              # Main container component
│   ├── masterIntakeForm.js
│   ├── masterIntakeForm.html
│   ├── masterIntakeForm.css
│   └── masterIntakeForm.js-meta.xml
│
├── questionItem/                  # Individual question renderer
│   ├── questionItem.js
│   ├── questionItem.html
│   ├── questionItem.css
│   └── questionItem.js-meta.xml
│
├── outcomePreview/                # Shows final actions preview
│   ├── outcomePreview.js
│   ├── outcomePreview.html
│   ├── outcomePreview.css
│   └── outcomePreview.js-meta.xml
│
└── answerSummary/                 # Final review screen
    ├── answerSummary.js
    ├── answerSummary.html
    ├── answerSummary.css
    └── answerSummary.js-meta.xml
```

### Apex Controller Structure

```
force-app/main/default/classes/
├── IntakeProcessController.cls         # New optimized controller
├── IntakeProcessController.cls-meta.xml
├── IntakeProcessControllerTest.cls     # Comprehensive tests
└── IntakeProcessControllerTest.cls-meta.xml
```

## Data Model

### Client-Side State Management

The LWC will maintain a reactive state object:

```javascript
// Main state object in masterIntakeForm.js
@track state = {
  // CPQ status
  cpqEligible: false,
  cpqCheckComplete: false,

  // Case context
  caseId: null,
  caseType: null,
  caseSubType: null,
  caseReason: null,

  // Question flow
  questionHistory: [],      // Array of answered questions
  currentQuestionId: null,  // ID of active question
  nextQuestionCache: {},    // Prefetched next questions

  // Completion
  allQuestionsAnswered: false,
  finalOutcome: null,
  showSummary: false,

  // UI state
  isLoading: false,
  error: null
};

// Question object structure
questionHistory = [
  {
    // Question metadata
    questionId: 'a1x...',
    questionText: 'Who reported this issue?',
    inputType: 'Picklist',
    presentationOrder: 1,

    // Answer data
    selectedOutcomeId: 'a1y...',
    selectedOutcomeText: 'Hauler reported during service',
    answerValue: 'Hauler reported during service', // User's actual input

    // Navigation
    nextQuestionId: 'a1z...',
    isComplete: true,
    isEditable: true,

    // Outcomes for this question
    outcomes: [
      {
        outcomeId: 'a1y...',
        outcomeText: 'Hauler reported during service',
        nextQuestionId: 'a1z...',
        hasNextQuestion: true,
        isTerminal: false,
        outcomeStatement: null,

        // Actions this outcome will trigger
        actions: {
          updateCaseType: false,
          updateCaseStatus: true,
          newCaseStatus: 'Open',
          createTask: true,
          taskType: 'Obtain Internal Response',
          assignToQueue: 'CS Resolution',
          teamName: 'Service Resolution Team'
        }
      }
      // ... more outcomes
    ]
  }
  // ... more questions
]
```

### Apex Wrapper Classes

```apex
public class IntakeProcessController {

  // Wrapper for initial data load (CPQ + first question + batch)
  public class InitialDataWrapper {
    @AuraEnabled public Boolean cpqEligible { get; set; }
    @AuraEnabled public QuestionWrapper firstQuestion { get; set; }
    @AuraEnabled public Map<String, QuestionWrapper> nextQuestionsCache { get; set; }
    @AuraEnabled public CaseContextWrapper caseContext { get; set; }
  }

  // Case context
  public class CaseContextWrapper {
    @AuraEnabled public String caseType { get; set; }
    @AuraEnabled public String caseSubType { get; set; }
    @AuraEnabled public String caseReason { get; set; }
    @AuraEnabled public String caseNumber { get; set; }
  }

  // Question with all outcomes
  public class QuestionWrapper {
    @AuraEnabled public String questionId { get; set; }
    @AuraEnabled public String questionText { get; set; }
    @AuraEnabled public String inputType { get; set; }
    @AuraEnabled public Integer presentationOrder { get; set; }
    @AuraEnabled public List<OutcomeWrapper> outcomes { get; set; }
  }

  // Outcome with action metadata
  public class OutcomeWrapper {
    @AuraEnabled public String outcomeId { get; set; }
    @AuraEnabled public String outcomeText { get; set; }
    @AuraEnabled public String nextQuestionId { get; set; }
    @AuraEnabled public Boolean hasNextQuestion { get; set; }
    @AuraEnabled public Boolean isTerminal { get; set; }
    @AuraEnabled public String outcomeStatement { get; set; }
    @AuraEnabled public ActionWrapper actions { get; set; }
  }

  // Actions that will be taken
  public class ActionWrapper {
    @AuraEnabled public Boolean updateCaseRecordType { get; set; }
    @AuraEnabled public String caseRecordType { get; set; }
    @AuraEnabled public Boolean updateCaseType { get; set; }
    @AuraEnabled public String caseType { get; set; }
    @AuraEnabled public Boolean updateCaseSubType { get; set; }
    @AuraEnabled public String caseSubType { get; set; }
    @AuraEnabled public Boolean updateCaseReason { get; set; }
    @AuraEnabled public String caseReason { get; set; }
    @AuraEnabled public Boolean updateCaseStatus { get; set; }
    @AuraEnabled public String caseStatus { get; set; }
    @AuraEnabled public String teamName { get; set; }
    @AuraEnabled public String queueAssigned { get; set; }
    @AuraEnabled public Boolean assignToCurrentUser { get; set; }
    @AuraEnabled public Boolean createTask { get; set; }
    @AuraEnabled public String taskType { get; set; }
    @AuraEnabled public String taskProcess { get; set; }
  }

  // Completion result
  public class CompletionWrapper {
    @AuraEnabled public Boolean success { get; set; }
    @AuraEnabled public String caseStatus { get; set; }
    @AuraEnabled public String commentId { get; set; }
    @AuraEnabled public String taskId { get; set; }
    @AuraEnabled public String errorMessage { get; set; }
  }
}
```

## Apex Controller Methods

### Method 1: Initialize Intake (Batch Fetch)

```apex
@AuraEnabled
public static InitialDataWrapper initializeIntake(Id caseId) {
  InitialDataWrapper result = new InitialDataWrapper();

  // 1. Get case context
  Case c = [SELECT Id, Case_Type__c, Case_Sub_Type__c, Case_Reason__c,
            CaseNumber, Client__c, Location__c, Asset.Project_Code__c,
            Master_Intake_Complete__c
            FROM Case WHERE Id = :caseId LIMIT 1];

  result.caseContext = new CaseContextWrapper();
  result.caseContext.caseType = c.Case_Type__c;
  result.caseContext.caseSubType = c.Case_Sub_Type__c;
  result.caseContext.caseReason = c.Case_Reason__c;
  result.caseContext.caseNumber = c.CaseNumber;

  // 2. Check CPQ eligibility FIRST
  result.cpqEligible = checkCPQEligibility(c);

  if (result.cpqEligible) {
    return result; // Exit early if CPQ eligible
  }

  // 3. Get first question
  Intake_Process__c firstQuestion = getFirstQuestionRecord(c);

  if (firstQuestion == null) {
    return result; // No questions configured
  }

  result.firstQuestion = buildQuestionWrapper(firstQuestion);

  // 4. BATCH FETCH: Get all possible next questions from first question's outcomes
  result.nextQuestionsCache = batchFetchNextQuestions(result.firstQuestion.outcomes);

  return result;
}

// Helper: Build question wrapper with all outcomes
private static QuestionWrapper buildQuestionWrapper(Intake_Process__c question) {
  QuestionWrapper wrapper = new QuestionWrapper();
  wrapper.questionId = question.Id;
  wrapper.questionText = question.Question__c;
  wrapper.inputType = question.Input_Type__c;
  wrapper.presentationOrder = Integer.valueOf(question.Presentation_Order__c);

  // Get all outcomes for this question
  List<Intake_Process__c> outcomes = [
    SELECT Id, Outcome__c, Any_Value__c, Next_Question__c, Outcome_Statement__c,
           Update_Case_Record_Type__c, Case_Record_Type__c,
           Update_Case_Type__c, Case_Type__c,
           Update_Case_Sub_Type__c, Case_Sub_Type__c,
           Update_Case_Reason__c, Case_Reason__c,
           Update_Case_Status__c, Case_Status__c,
           Team_Name__c, Queue_Assigned__c, Assign_to_Current_User__c,
           Create_Task__c, Task_Type__c, Task_Process__c
    FROM Intake_Process__c
    WHERE RecordType.Name = 'Intake Outcomes'
    AND Intake_Question__c = :question.Id
  ];

  wrapper.outcomes = new List<OutcomeWrapper>();
  for (Intake_Process__c outcome : outcomes) {
    wrapper.outcomes.add(buildOutcomeWrapper(outcome));
  }

  return wrapper;
}

// Helper: Build outcome wrapper with action metadata
private static OutcomeWrapper buildOutcomeWrapper(Intake_Process__c outcome) {
  OutcomeWrapper wrapper = new OutcomeWrapper();
  wrapper.outcomeId = outcome.Id;
  wrapper.outcomeText = outcome.Outcome__c;
  wrapper.nextQuestionId = outcome.Next_Question__c;
  wrapper.hasNextQuestion = outcome.Next_Question__c != null;
  wrapper.isTerminal = outcome.Next_Question__c == null;
  wrapper.outcomeStatement = outcome.Outcome_Statement__c;

  // Build action metadata
  wrapper.actions = new ActionWrapper();
  wrapper.actions.updateCaseRecordType = outcome.Update_Case_Record_Type__c;
  wrapper.actions.caseRecordType = outcome.Case_Record_Type__c;
  wrapper.actions.updateCaseType = outcome.Update_Case_Type__c;
  wrapper.actions.caseType = outcome.Case_Type__c;
  wrapper.actions.updateCaseSubType = outcome.Update_Case_Sub_Type__c;
  wrapper.actions.caseSubType = outcome.Case_Sub_Type__c;
  wrapper.actions.updateCaseReason = outcome.Update_Case_Reason__c;
  wrapper.actions.caseReason = outcome.Case_Reason__c;
  wrapper.actions.updateCaseStatus = outcome.Update_Case_Status__c;
  wrapper.actions.caseStatus = outcome.Case_Status__c;
  wrapper.actions.teamName = outcome.Team_Name__c;
  wrapper.actions.queueAssigned = outcome.Queue_Assigned__c;
  wrapper.actions.assignToCurrentUser = outcome.Assign_to_Current_User__c;
  wrapper.actions.createTask = outcome.Create_Task__c;
  wrapper.actions.taskType = outcome.Task_Type__c;
  wrapper.actions.taskProcess = outcome.Task_Process__c;

  return wrapper;
}

// Helper: Batch fetch all next questions
private static Map<String, QuestionWrapper> batchFetchNextQuestions(
  List<OutcomeWrapper> outcomes
) {
  Map<String, QuestionWrapper> cache = new Map<String, QuestionWrapper>();

  // Collect all unique next question IDs
  Set<Id> nextQuestionIds = new Set<Id>();
  for (OutcomeWrapper outcome : outcomes) {
    if (outcome.nextQuestionId != null) {
      nextQuestionIds.add(outcome.nextQuestionId);
    }
  }

  if (nextQuestionIds.isEmpty()) {
    return cache;
  }

  // Fetch all next questions in one query
  Map<Id, Intake_Process__c> questionsById = new Map<Id, Intake_Process__c>([
    SELECT Id, Question__c, Input_Type__c, Presentation_Order__c,
           Case_Type__c, Case_Sub_Type__c, Case_Reason__c
    FROM Intake_Process__c
    WHERE Id IN :nextQuestionIds
  ]);

  // Build wrappers for each
  for (Id questionId : questionsById.keySet()) {
    cache.put(questionId, buildQuestionWrapper(questionsById.get(questionId)));
  }

  return cache;
}
```

### Method 2: Get Next Question (with recursive batch fetch)

```apex
@AuraEnabled
public static Map<String, QuestionWrapper> getNextQuestionBatch(String outcomeId) {
  Map<String, QuestionWrapper> cache = new Map<String, QuestionWrapper>();

  // Get the outcome record
  Intake_Process__c outcome = [
    SELECT Next_Question__c
    FROM Intake_Process__c
    WHERE Id = :outcomeId
    LIMIT 1
  ];

  if (outcome.Next_Question__c == null) {
    return cache; // Terminal outcome
  }

  // Get the next question
  Intake_Process__c nextQuestion = [
    SELECT Id, Question__c, Input_Type__c, Presentation_Order__c
    FROM Intake_Process__c
    WHERE Id = :outcome.Next_Question__c
    LIMIT 1
  ];

  QuestionWrapper wrapper = buildQuestionWrapper(nextQuestion);
  cache.put(nextQuestion.Id, wrapper);

  // Batch fetch the questions after this one
  Map<String, QuestionWrapper> deepCache = batchFetchNextQuestions(wrapper.outcomes);
  cache.putAll(deepCache);

  return cache;
}
```

### Method 3: Complete Intake

```apex
@AuraEnabled
public static CompletionWrapper completeIntake(
  Id caseId,
  String answersJSON,
  Id finalOutcomeId
) {
  CompletionWrapper result = new CompletionWrapper();

  try {
    // Parse answers
    List<Object> answers = (List<Object>) JSON.deserializeUntyped(answersJSON);

    // Build comment text
    String commentText = buildCommentFromAnswers(answers);

    // Create comment
    String commentId = createIntakeComment(caseId, commentText);
    result.commentId = commentId;

    // Execute case updates
    String taskId = executeCaseUpdates(caseId, finalOutcomeId);
    result.taskId = taskId;

    // Get final case status
    Case c = [SELECT Status FROM Case WHERE Id = :caseId LIMIT 1];
    result.caseStatus = c.Status;

    result.success = true;

  } catch (Exception e) {
    result.success = false;
    result.errorMessage = e.getMessage();
  }

  return result;
}
```

## LWC Implementation

### masterIntakeForm.js

```javascript
import { LightningElement, api, track, wire } from 'lwc';
import initializeIntake from '@salesforce/apex/IntakeProcessController.initializeIntake';
import getNextQuestionBatch from '@salesforce/apex/IntakeProcessController.getNextQuestionBatch';
import completeIntake from '@salesforce/apex/IntakeProcessController.completeIntake';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MasterIntakeForm extends LightningElement {
  @api recordId; // Case ID from record page

  @track state = {
    cpqEligible: false,
    cpqCheckComplete: false,
    caseContext: null,
    questionHistory: [],
    currentQuestionId: null,
    nextQuestionCache: new Map(),
    allQuestionsAnswered: false,
    finalOutcome: null,
    showSummary: false,
    isLoading: true,
    error: null
  };

  connectedCallback() {
    this.loadIntakeData();
  }

  // ========== INITIALIZATION ==========

  async loadIntakeData() {
    try {
      this.state.isLoading = true;

      const data = await initializeIntake({ caseId: this.recordId });

      // Store case context
      this.state.caseContext = data.caseContext;
      this.state.cpqCheckComplete = true;

      // Check CPQ eligibility
      if (data.cpqEligible) {
        this.state.cpqEligible = true;
        this.state.isLoading = false;
        return;
      }

      // Check if there are questions
      if (!data.firstQuestion) {
        this.state.error = 'No intake questions configured for this case type.';
        this.state.isLoading = false;
        return;
      }

      // Store first question in history
      const firstQuestion = {
        ...data.firstQuestion,
        isComplete: false,
        isEditable: false,
        selectedOutcomeId: null,
        selectedOutcomeText: null,
        answerValue: null
      };
      this.state.questionHistory = [firstQuestion];
      this.state.currentQuestionId = firstQuestion.questionId;

      // Cache next questions
      if (data.nextQuestionsCache) {
        Object.keys(data.nextQuestionsCache).forEach(key => {
          this.state.nextQuestionCache.set(key, data.nextQuestionsCache[key]);
        });
      }

      this.state.isLoading = false;

    } catch (error) {
      this.state.error = error.body?.message || 'Error loading intake data';
      this.state.isLoading = false;
      this.showErrorToast('Error', this.state.error);
    }
  }

  // ========== ANSWER HANDLING ==========

  handleAnswerSelected(event) {
    const { questionId, outcomeId, outcomeText, answerValue } = event.detail;

    // Find question in history
    const questionIndex = this.state.questionHistory.findIndex(
      q => q.questionId === questionId
    );

    if (questionIndex === -1) return;

    // Update question with answer
    const question = this.state.questionHistory[questionIndex];
    question.selectedOutcomeId = outcomeId;
    question.selectedOutcomeText = outcomeText;
    question.answerValue = answerValue;
    question.isComplete = true;
    question.isEditable = true;

    // Find the selected outcome
    const outcome = question.outcomes.find(o => o.outcomeId === outcomeId);

    if (!outcome) {
      console.error('Outcome not found:', outcomeId);
      return;
    }

    // Check if this is the end
    if (outcome.isTerminal) {
      this.handleIntakeComplete(outcome);
      return;
    }

    // Load next question
    this.loadNextQuestion(outcome.nextQuestionId, questionIndex);
  }

  async loadNextQuestion(nextQuestionId, afterIndex) {
    // Remove any questions after this point (in case of edit)
    this.state.questionHistory = this.state.questionHistory.slice(0, afterIndex + 1);

    // Check cache first
    let nextQuestion = this.state.nextQuestionCache.get(nextQuestionId);

    if (!nextQuestion) {
      // Not in cache, fetch it
      try {
        this.state.isLoading = true;
        const batchData = await getNextQuestionBatch({
          outcomeId: this.state.questionHistory[afterIndex].selectedOutcomeId
        });

        // Add to cache
        Object.keys(batchData).forEach(key => {
          this.state.nextQuestionCache.set(key, batchData[key]);
        });

        nextQuestion = this.state.nextQuestionCache.get(nextQuestionId);
        this.state.isLoading = false;

      } catch (error) {
        this.state.isLoading = false;
        this.showErrorToast('Error', 'Failed to load next question');
        return;
      }
    }

    // Add to history
    const newQuestion = {
      ...nextQuestion,
      isComplete: false,
      isEditable: false,
      selectedOutcomeId: null,
      selectedOutcomeText: null,
      answerValue: null
    };

    this.state.questionHistory.push(newQuestion);
    this.state.currentQuestionId = nextQuestionId;

    // Scroll to new question
    this.scrollToBottom();
  }

  // ========== EDIT HANDLING ==========

  handleEditQuestion(event) {
    const { questionId } = event.detail;

    // Find question index
    const questionIndex = this.state.questionHistory.findIndex(
      q => q.questionId === questionId
    );

    if (questionIndex === -1) return;

    // Remove all questions after this one
    this.state.questionHistory = this.state.questionHistory.slice(0, questionIndex + 1);

    // Clear the answer on this question
    const question = this.state.questionHistory[questionIndex];
    question.selectedOutcomeId = null;
    question.selectedOutcomeText = null;
    question.answerValue = null;
    question.isComplete = false;
    question.isEditable = false;

    this.state.currentQuestionId = questionId;
    this.state.allQuestionsAnswered = false;
  }

  // ========== COMPLETION ==========

  handleIntakeComplete(finalOutcome) {
    this.state.allQuestionsAnswered = true;
    this.state.finalOutcome = finalOutcome;
    this.state.currentQuestionId = null;

    // Show summary screen
    this.state.showSummary = true;
  }

  handleBackFromSummary() {
    this.state.showSummary = false;
    this.state.allQuestionsAnswered = false;
  }

  async handleFinalSubmit() {
    try {
      this.state.isLoading = true;

      // Build answers JSON
      const answers = this.state.questionHistory.map(q => ({
        question: q.questionText,
        answer: q.answerValue || q.selectedOutcomeText
      }));

      const result = await completeIntake({
        caseId: this.recordId,
        answersJSON: JSON.stringify(answers),
        finalOutcomeId: this.state.finalOutcome.outcomeId
      });

      if (result.success) {
        this.showSuccessToast('Success', 'Intake completed successfully');

        // Refresh the page to hide component
        eval("$A.get('e.force:refreshView').fire();");

      } else {
        throw new Error(result.errorMessage);
      }

    } catch (error) {
      this.state.isLoading = false;
      this.showErrorToast('Error', error.body?.message || 'Failed to complete intake');
    }
  }

  // ========== UTILITIES ==========

  scrollToBottom() {
    setTimeout(() => {
      const container = this.template.querySelector('.question-stack');
      if (container) {
        container.scrollTop = container.scrollHeight;
      }
    }, 100);
  }

  showSuccessToast(title, message) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant: 'success' }));
  }

  showErrorToast(title, message) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant: 'error' }));
  }

  // ========== GETTERS ==========

  get showCPQScreen() {
    return this.state.cpqCheckComplete && this.state.cpqEligible;
  }

  get showQuestions() {
    return !this.state.cpqEligible &&
           this.state.questionHistory.length > 0 &&
           !this.state.showSummary;
  }

  get completedQuestions() {
    return this.state.questionHistory.filter(q => q.isComplete);
  }

  get activeQuestion() {
    return this.state.questionHistory.find(q => !q.isComplete);
  }
}
```

### masterIntakeForm.html

```html
<template>
  <!-- Loading Spinner -->
  <template if:true={state.isLoading}>
    <lightning-spinner alternative-text="Loading" size="medium"></lightning-spinner>
  </template>

  <!-- CPQ Eligible Screen -->
  <template if:true={showCPQScreen}>
    <lightning-card title="Quote Eligible" icon-name="standard:quotes">
      <div class="slds-p-around_medium cpq-notice">
        <lightning-icon
          icon-name="utility:announcement"
          size="large"
          class="slds-m-right_small">
        </lightning-icon>
        <div>
          <p class="slds-text-heading_medium slds-m-bottom_small">
            This case is eligible for CPQ
          </p>
          <p class="slds-text-body_regular">
            Please use the "Add Quote" button at the top of the screen to configure
            the customer's requested change.
          </p>
        </div>
      </div>
    </lightning-card>
  </template>

  <!-- Main Intake Form -->
  <template if:true={showQuestions}>
    <lightning-card title="Master Intake Flow" icon-name="custom:custom63">

      <!-- Case Context Header -->
      <div slot="title" class="case-context">
        <div class="slds-text-heading_small">Master Intake</div>
        <div class="slds-text-body_small slds-text-color_weak">
          {state.caseContext.caseType}
          <template if:true={state.caseContext.caseSubType}>
            → {state.caseContext.caseSubType}
          </template>
          <template if:true={state.caseContext.caseReason}>
            → {state.caseContext.caseReason}
          </template>
        </div>
      </div>

      <!-- Question Stack -->
      <div class="slds-card__body slds-card__body_inner">
        <div class="question-stack">
          <template for:each={state.questionHistory} for:item="question">
            <c-question-item
              key={question.questionId}
              question={question}
              is-active={question.questionId === state.currentQuestionId}
              onanswerselected={handleAnswerSelected}
              oneditquestion={handleEditQuestion}>
            </c-question-item>
          </template>
        </div>
      </div>

    </lightning-card>
  </template>

  <!-- Answer Summary Screen -->
  <template if:true={state.showSummary}>
    <c-answer-summary
      questions={state.questionHistory}
      final-outcome={state.finalOutcome}
      onback={handleBackFromSummary}
      onsubmit={handleFinalSubmit}
      is-loading={state.isLoading}>
    </c-answer-summary>
  </template>

  <!-- Error State -->
  <template if:true={state.error}>
    <lightning-card>
      <div class="slds-p-around_medium">
        <div class="slds-text-color_error">
          <lightning-icon icon-name="utility:error" size="small"></lightning-icon>
          {state.error}
        </div>
      </div>
    </lightning-card>
  </template>

</template>
```

### masterIntakeForm.css

```css
.question-stack {
  max-height: 600px;
  overflow-y: auto;
  padding: 1rem;
}

.cpq-notice {
  display: flex;
  align-items: center;
  background-color: #e3f2fd;
  border-left: 4px solid #1976d2;
  padding: 1rem;
}

.case-context {
  display: flex;
  flex-direction: column;
}

/* Smooth scrolling */
.question-stack {
  scroll-behavior: smooth;
}
```

## Next Steps

1. **Review CSV data** - Once uploaded, analyze question patterns
2. **Build questionItem component** - Individual question renderer with auto-advance
3. **Build answerSummary component** - Final review screen
4. **Build outcomePreview component** - Show actions before submission
5. **Write tests** - Apex and Jest tests for all components
6. **Migration plan** - Strategy for replacing Aura with LWC

## Performance Optimizations

- Batch fetch reduces Apex calls from N to 2-3 for most flows
- Client-side caching eliminates duplicate server calls
- Lazy rendering of questions (only active + completed shown)
- Debounced text input validation

## Accessibility Considerations

- Keyboard navigation (Tab, Enter, Escape)
- ARIA labels on all interactive elements
- Focus management when questions appear
- Screen reader announcements for new questions
- High contrast mode support
