# Admin Dashboard Query Investigation

## Analysis Results

### CSV Data Analysis:
- **Total Questions in CSV**: 13,331
- **Total Outcomes in CSV**: 22,493
- **Questions with Presentation_Order__c = 1**: 807
- **Questions with Presentation_Order__c = 0**: 12,522

### RecordType Distribution in CSV:
- Questions RecordTypeId: `0123u000000uAS0AAM` (13,331 records)
- Outcomes RecordTypeId: `0123u000000uARzAAM` (22,532 records)

### Dashboard Showing:
- **Total Questions**: 1,135 (should be 13,331)
- **Missing Questions**: ~12,196

## Root Cause

The admin dashboard query filters by:
```apex
WHERE RecordType.Name = 'Intake Questions'
```

This filter is too restrictive. The issue is one of the following:

1. **RecordType Mismatch**: The CSV contains RecordTypeIds from a different Salesforce org. When data was imported into the target org, the RecordTypeId values didn't transfer correctly because RecordTypeIds are org-specific.

2. **Incomplete Import**: Only 1,135 out of 13,331 questions were imported with the correct "Intake Questions" RecordType set.

3. **Missing RecordType Assignment**: The bulk of the records (12,196) were imported but don't have a RecordType assigned, or have the wrong RecordType.

## Diagnostic Queries

Run these queries in Developer Console or Workbench to diagnose:

### Query 1: Count all Intake_Process__c records
```sql
SELECT COUNT()
FROM Intake_Process__c
```

### Query 2: Count by RecordType
```sql
SELECT RecordType.Name, COUNT(Id)
FROM Intake_Process__c
GROUP BY RecordType.Name
```

### Query 3: Count questions without RecordType
```sql
SELECT COUNT()
FROM Intake_Process__c
WHERE RecordTypeId = null
AND Question__c != null
```

### Query 4: Count questions with any RecordType
```sql
SELECT COUNT()
FROM Intake_Process__c
WHERE Question__c != null
AND Intake_Question__c = null
```

### Query 5: Identify questions not showing in dashboard
```sql
SELECT Id, Name, Question__c, RecordType.Name
FROM Intake_Process__c
WHERE Question__c != null
AND Intake_Question__c = null
AND RecordType.Name != 'Intake Questions'
LIMIT 10
```

## Recommended Fixes

### Option 1: Update Query to Include All Questions (Quick Fix)
Modify the query to identify questions by field structure rather than RecordType:
```apex
WHERE Question__c != null
AND Intake_Question__c = null
```

### Option 2: Fix RecordType Assignment (Proper Fix)
Use Data Loader or Apex to update all question records with the correct RecordType:
```apex
List<Intake_Process__c> questionsToUpdate = [
    SELECT Id
    FROM Intake_Process__c
    WHERE Question__c != null
    AND Intake_Question__c = null
    AND (RecordTypeId = null OR RecordType.Name != 'Intake Questions')
];

Id questionRecordTypeId = Schema.SObjectType.Intake_Process__c
    .getRecordTypeInfosByName()
    .get('Intake Questions').getRecordTypeId();

for (Intake_Process__c q : questionsToUpdate) {
    q.RecordTypeId = questionRecordTypeId;
}

Database.update(questionsToUpdate, false);
```

### Option 3: Make Query More Flexible
Add a setting/parameter to toggle between strict RecordType filtering and flexible filtering.
