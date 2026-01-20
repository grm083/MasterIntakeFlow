# PROJECT CHARTER
## Master Intake Flow Redesign Initiative

**Project Code:** MIF-REDESIGN-2025
**Date:** January 2026
**Status:** COMPLETED
**Prepared By:** Development Team
**Sponsor:** Operations Leadership

---

## EXECUTIVE SUMMARY

The Master Intake Flow Redesign project transformed the case intake process from a Flow-based system to a modern, high-performance Apex and Lightning Web Component (LWC) architecture. This redesign addresses critical performance bottlenecks, improves user experience, and provides a scalable foundation for future enhancements.

**Key Deliverables:**
- IntakeProcessController (Apex) - Backend orchestration and business logic
- masterIntakeLauncher (LWC) - Primary intake interface component
- Child Components - questionItem, answerSummary, caseDetailsPanel
- Draft Management System - Session-based draft persistence
- Enhanced Edit Capabilities - Post-submission answer editing

---

## PROJECT PURPOSE & JUSTIFICATION

### Problem Statement

The legacy Master Intake Flow, built on Salesforce Flow technology, suffered from several critical limitations:

1. **Performance Issues**
   - Sequential question loading (1 server call per question)
   - Average intake time: 4-6 minutes per case
   - Timeout issues on complex cases
   - Poor performance on mobile devices

2. **User Experience Challenges**
   - No ability to edit answers after submission
   - No draft save capability (lost work on browser close)
   - Limited context visibility (users had to close intake to view case details)
   - Rigid, form-based interface with limited customization

3. **Technical Debt**
   - Flow maintenance complexity (visual programming limitations)
   - Difficult to extend or modify
   - Limited error handling and recovery options
   - Poor integration with other system components

4. **Scalability Concerns**
   - Flow governor limits at risk with growing question complexity
   - Difficult to implement conditional logic
   - Limited ability to add new features

### Strategic Alignment

This project aligns with organizational objectives to:
- Improve operational efficiency through technology modernization
- Reduce case processing time and increase throughput
- Enhance user satisfaction and reduce training time
- Build scalable technical foundation for future automation

---

## FINANCIAL BENEFITS ANALYSIS

### Cost Assumptions
- **Offshore Developer/Administrator Rate:** $20/hour
- **Onshore Platform User Cost:** $50,000/year (fully loaded)
- **Average Cases Processed:** 50,000/year
- **Users Performing Intake:** 200 onshore staff

### Quantifiable Benefits

#### 1. Time Savings (Primary Benefit)

**Before Redesign:**
- Average intake completion time: 5 minutes
- Total annual time: 50,000 cases × 5 min = 250,000 minutes (4,167 hours)
- Cost: 4,167 hours × ($50,000/2080 hours) = **$100,048/year**

**After Redesign:**
- Average intake completion time: 2 minutes (60% reduction)
- Total annual time: 50,000 cases × 2 min = 100,000 minutes (1,667 hours)
- Cost: 1,667 hours × ($50,000/2080 hours) = **$40,019/year**

**Annual Savings: $60,029**

#### 2. Error Reduction & Rework Elimination

**Before Redesign:**
- Estimated error rate: 5% (incomplete/incorrect intakes)
- Errors requiring rework: 2,500 cases/year
- Rework time per case: 10 minutes
- Annual rework cost: (2,500 × 10 min) ÷ 60 = 417 hours
- Cost: 417 hours × ($50,000/2080 hours) = **$10,019/year**

**After Redesign:**
- Error rate: 1% (draft save, edit capability, better validation)
- Errors requiring rework: 500 cases/year
- Annual rework cost: (500 × 10 min) ÷ 60 = 83 hours
- Cost: 83 hours × ($50,000/2080 hours) = **$1,995/year**

**Annual Savings: $8,024**

#### 3. Training & Support Cost Reduction

**Before Redesign:**
- New user training time: 2 hours
- Annual new users/refresher training: 50 sessions
- Training delivery cost: 100 hours × ($50,000/2080) = **$2,404/year**
- Help desk tickets related to intake issues: 500/year
- Resolution time: 15 minutes average
- Help desk cost: (500 × 15 min) ÷ 60 = 125 hours × $20/hour = **$2,500/year**
- **Total: $4,904/year**

**After Redesign:**
- New user training time: 0.5 hours (75% reduction due to intuitive UI)
- Training cost: 25 hours × ($50,000/2080) = **$601/year**
- Help desk tickets: 150/year (70% reduction)
- Help desk cost: (150 × 15 min) ÷ 60 = 38 hours × $20/hour = **$760/year**
- **Total: $1,361/year**

**Annual Savings: $3,543**

#### 4. Avoided Downtime & Lost Productivity

**Before Redesign:**
- Browser crashes/timeouts: 2% of intakes
- Lost work: 1,000 cases/year × 5 min average progress
- Recovery cost: (1,000 × 5 min) ÷ 60 = 83 hours
- Cost: 83 hours × ($50,000/2080 hours) = **$1,995/year**

**After Redesign:**
- Draft auto-save feature eliminates lost work
- **Annual Savings: $1,995**

#### 5. Maintenance Cost Reduction

**Before Redesign (Flow-based):**
- Monthly maintenance/updates: 8 hours × $20/hour = $160/month
- Annual: **$1,920**

**After Redesign (Apex/LWC):**
- Monthly maintenance: 2 hours × $20/hour = $40/month
- Annual: **$480**

**Annual Savings: $1,440**

### Total Financial Benefits

| Benefit Category | Annual Savings |
|-----------------|----------------|
| Time Savings (Faster Intake) | $60,029 |
| Error Reduction & Rework | $8,024 |
| Training & Support Reduction | $3,543 |
| Avoided Downtime/Lost Work | $1,995 |
| Maintenance Cost Reduction | $1,440 |
| **TOTAL ANNUAL SAVINGS** | **$75,031** |

### ROI Calculation

**Project Cost:** $19,200 (see cost breakdown below)
**Annual Benefit:** $75,031
**Payback Period:** 3.1 months
**3-Year ROI:** (($75,031 × 3) - $19,200) ÷ $19,200 = **1,071%**

---

## PROJECT SCOPE

### In Scope

1. **Backend Development (IntakeProcessController)**
   - Question hierarchy traversal logic
   - Batch question fetching and caching
   - Outcome action execution (Case updates, Task creation, Assignments)
   - Case context aggregation
   - Draft persistence APIs

2. **Frontend Development (LWC Components)**
   - masterIntakeLauncher - Main orchestrator component
   - questionItem - Individual question display with validation
   - answerSummary - Completion summary and submission
   - caseDetailsPanel - Contextual Asset/Location/Contact information
   - Draft management UI (save, resume, discard)
   - Edit capability for completed questions

3. **User Experience Enhancements**
   - Side panel with case context (no need to minimize intake)
   - Visual progress indicators
   - Responsive design (desktop and mobile)
   - Inline validation and error handling
   - Session-based draft auto-save

4. **Technical Improvements**
   - Performance optimization (batch fetching, caching)
   - Error handling and recovery
   - Code documentation and maintainability
   - Test coverage (85%+ Apex, 80%+ LWC)

### Out of Scope

- AI-powered features (classification, entity extraction, answer suggestions)
- Integration with external systems
- Reporting and analytics dashboard
- Mobile-specific native application
- Automated question generation
- Multi-language support

---

## PROJECT PHASES

If this project had been planned from inception, it would have followed these phases:

### Phase 1: Discovery & Requirements (2 weeks)

**Objectives:**
- Document current state Flow architecture
- Identify pain points through user interviews
- Define success criteria and KPIs
- Create technical requirements document

**Deliverables:**
- Current state analysis document
- User persona and journey maps
- Requirements specification
- Success metrics definition

**Effort:** 80 hours offshore development time

### Phase 2: Technical Design (2 weeks)

**Objectives:**
- Design Apex controller architecture
- Define LWC component hierarchy
- Create data model for draft persistence
- Design API contracts between components
- Define caching strategy

**Deliverables:**
- Technical design document
- Component architecture diagram
- API specifications
- Database schema (if custom objects needed)
- Performance benchmarks and targets

**Effort:** 80 hours offshore development time

### Phase 3: Backend Development (3 weeks)

**Objectives:**
- Implement IntakeProcessController class
- Build question traversal logic
- Implement batch fetching and caching
- Create outcome action handlers
- Develop draft persistence layer
- Write comprehensive unit tests

**Deliverables:**
- IntakeProcessController.cls (complete)
- Test classes with 85%+ coverage
- API documentation
- Performance test results

**Effort:** 120 hours offshore development time

### Phase 4: Frontend Development (4 weeks)

**Objectives:**
- Build masterIntakeLauncher component
- Develop questionItem component with all input types
- Create answerSummary component
- Build caseDetailsPanel with Asset/Location/Contact sections
- Implement draft management UI
- Create edit functionality
- Develop responsive layouts

**Deliverables:**
- All LWC components (complete)
- Jest test suites (80%+ coverage)
- Component documentation
- Style guide compliance

**Effort:** 160 hours offshore development time

### Phase 5: Integration & Testing (2 weeks)

**Objectives:**
- Integration testing across all components
- User acceptance testing (UAT)
- Performance testing and optimization
- Security review
- Accessibility compliance testing

**Deliverables:**
- Test execution reports
- Bug fixes and refinements
- Performance benchmarks
- Security review sign-off

**Effort:** 80 hours offshore development time

### Phase 6: Deployment & Training (1 week)

**Objectives:**
- Production deployment
- User training sessions
- Documentation creation
- Knowledge transfer to support team

**Deliverables:**
- Production deployment
- User training materials
- Administrator guide
- Support runbook

**Effort:** 40 hours offshore development time

### Phase 7: Post-Launch Support (2 weeks)

**Objectives:**
- Monitor system performance
- Address user feedback
- Bug fixes and minor enhancements
- Optimize based on usage patterns

**Deliverables:**
- Performance monitoring reports
- User feedback analysis
- Bug fix releases
- Optimization recommendations

**Effort:** 80 hours offshore development time

### Phase Timeline Summary

| Phase | Duration | Effort (Hours) |
|-------|----------|----------------|
| 1. Discovery & Requirements | 2 weeks | 80 |
| 2. Technical Design | 2 weeks | 80 |
| 3. Backend Development | 3 weeks | 120 |
| 4. Frontend Development | 4 weeks | 160 |
| 5. Integration & Testing | 2 weeks | 80 |
| 6. Deployment & Training | 1 week | 40 |
| 7. Post-Launch Support | 2 weeks | 80 |
| **TOTAL** | **16 weeks** | **640 hours** |

---

## PROJECT COST BREAKDOWN

### Development Costs (Offshore @ $20/hour)

| Category | Hours | Cost |
|----------|-------|------|
| Requirements & Design | 160 | $3,200 |
| Backend Development (Apex) | 120 | $2,400 |
| Frontend Development (LWC) | 160 | $3,200 |
| Integration & Testing | 80 | $1,600 |
| Deployment | 40 | $800 |
| Post-Launch Support | 80 | $1,600 |
| **Subtotal** | **640** | **$12,800** |

### Project Management & Overhead

| Category | Hours | Cost |
|----------|-------|------|
| Project Management (20% of dev effort) | 128 | $2,560 |
| Architecture Review | 20 | $400 |
| Security Review | 16 | $320 |
| Documentation | 40 | $800 |
| **Subtotal** | **204** | **$4,080** |

### Training & Change Management

| Category | Hours | Cost |
|----------|-------|------|
| Training Material Development | 40 | $800 |
| Train-the-Trainer Sessions | 20 | $400 |
| User Training Delivery (5 sessions × 4 hours) | 20 | $400 |
| Change Management Communications | 20 | $400 |
| **Subtotal** | **100** | **$2,000** |

### Infrastructure & Tools

| Category | Cost |
|----------|------|
| Sandbox Environments | $0 (existing) |
| Testing Tools | $320 (4 months) |
| Documentation Tools | $0 (existing) |
| **Subtotal** | **$320** |

### Total Project Cost

| Category | Cost |
|----------|------|
| Development Costs | $12,800 |
| Project Management & Overhead | $4,080 |
| Training & Change Management | $2,000 |
| Infrastructure & Tools | $320 |
| **TOTAL PROJECT COST** | **$19,200** |

---

## RISKS, CONSTRAINTS, AND ASSUMPTIONS

### Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| **User Adoption Resistance** | Medium | High | Phased rollout with champions; extensive training; clear communication of benefits |
| **Data Migration Issues** | Low | High | Comprehensive testing in sandbox; parallel run period; rollback plan ready |
| **Performance Degradation** | Low | High | Performance testing at each phase; caching strategy; batch processing optimization |
| **Integration Breakage** | Medium | Medium | Thorough integration testing; maintain API contracts; version compatibility checks |
| **Scope Creep** | High | Medium | Strict change control process; document all requests for Phase 2; executive approval required |
| **Resource Availability** | Medium | Medium | Cross-train team members; buffer time in schedule; backup resources identified |
| **Technical Complexity** | Low | Medium | Spike solutions for complex areas; peer code reviews; architecture reviews |
| **Security Vulnerabilities** | Low | High | Security review at design stage; OWASP compliance; penetration testing |

### Constraints

1. **Technical Constraints**
   - Must maintain backward compatibility with existing Intake_Process__c data model
   - Must integrate with existing Case, Asset, and Location objects without schema changes
   - Must work within Salesforce governor limits (heap size, SOQL queries, DML operations)
   - Must support all existing question types and outcome actions

2. **Resource Constraints**
   - Limited to offshore development resources at $20/hour
   - Development team availability: 2 developers maximum
   - Testing resources: Shared QA environment
   - No budget for third-party tools beyond existing licenses

3. **Timeline Constraints**
   - Must complete within 16-week timeline
   - Cannot disrupt existing business operations during deployment
   - Training must be scheduled around peak business periods
   - Production deployment limited to off-peak hours

4. **Organizational Constraints**
   - Must follow existing change management processes
   - Requires approval from Operations Leadership for production deployment
   - Must maintain existing security model and permissions
   - Must comply with company coding standards and documentation requirements

5. **Business Constraints**
   - Cannot reduce functionality from existing Flow implementation
   - Must support 200 concurrent users
   - Must maintain 99.5% uptime SLA
   - Cannot introduce new licensing costs

### Assumptions

1. **Technical Assumptions**
   - Salesforce platform will remain stable during development period
   - Current Intake_Process__c configuration is accurate and complete
   - No major Salesforce platform upgrades during project timeline
   - Existing test data in sandbox is representative of production data
   - Browser compatibility: Chrome, Firefox, Safari, Edge (latest 2 versions)

2. **Resource Assumptions**
   - Offshore developers have Salesforce Platform Developer II certification or equivalent
   - Developers are proficient in Apex, LWC, and JavaScript
   - Subject matter experts are available 4 hours/week for requirements clarification
   - QA resources available for testing during Phase 5
   - Production deployment support available during deployment window

3. **Business Assumptions**
   - Current intake process workflows will not change significantly during development
   - Users have basic Salesforce navigation skills
   - Training can be completed within 2-week window
   - Champions identified in each department to support rollout
   - Business stakeholders available for UAT within 2-week testing window

4. **Data Assumptions**
   - Intake_Process__c records are properly configured and tested
   - Case, Asset, and Location data quality is acceptable
   - No data cleanup required before migration
   - Existing draft data (if any) can be discarded during migration

5. **Support Assumptions**
   - Help desk trained on new system before launch
   - Support documentation available at launch
   - Escalation path defined for critical issues
   - Development team available for 2 weeks post-launch for critical fixes

---

## SUCCESS CRITERIA

### Quantitative Metrics

| Metric | Baseline | Target | Measurement Method |
|--------|----------|--------|-------------------|
| Average Intake Completion Time | 5 minutes | ≤ 2.5 minutes | System logs analysis |
| Intake Error Rate | 5% | ≤ 2% | Case rework tracking |
| User Satisfaction Score | 6.2/10 | ≥ 8.5/10 | Post-implementation survey |
| System Availability | 99.2% | ≥ 99.5% | Platform monitoring |
| Page Load Time | 3-4 seconds | ≤ 1.5 seconds | Performance monitoring |
| Help Desk Tickets | 500/year | ≤ 200/year | Support ticket tracking |
| Training Time per User | 2 hours | ≤ 0.5 hours | Training logs |
| Draft Save Success Rate | N/A | ≥ 99% | Application logs |

### Qualitative Metrics

- Users report improved experience and ease of use
- Reduced frustration with system timeouts and lost work
- Positive feedback on contextual information availability
- Support team reports fewer escalations
- Management visibility into intake process improved

### Technical Metrics

| Metric | Target |
|--------|--------|
| Apex Test Coverage | ≥ 85% |
| LWC Test Coverage | ≥ 80% |
| Code Quality (SonarQube) | A Rating |
| Performance (Time to Interactive) | ≤ 1.5 seconds |
| Mobile Performance | ≤ 2.5 seconds |
| WCAG 2.1 Compliance | Level AA |

---

## STAKEHOLDERS

### Executive Sponsor
- **Role:** VP of Operations
- **Responsibility:** Project approval, budget allocation, final decision authority

### Project Manager
- **Role:** Technical Project Manager
- **Responsibility:** Day-to-day project management, resource coordination, risk management

### Development Team
- **Role:** Offshore Salesforce Developers (2)
- **Responsibility:** Technical implementation, testing, documentation

### Business Analysts
- **Role:** Requirements gathering and validation
- **Responsibility:** User story creation, UAT coordination

### End Users
- **Role:** Case Management Team (200 users)
- **Responsibility:** UAT participation, feedback provision, training completion

### Support Team
- **Role:** Help Desk / IT Support
- **Responsibility:** Post-launch support, user assistance, issue escalation

### Quality Assurance
- **Role:** QA Team
- **Responsibility:** Test plan creation, test execution, defect tracking

---

## DEPENDENCIES

### Technical Dependencies
- Salesforce platform stability and availability
- Intake_Process__c metadata configuration
- Case, Asset, Location object schema
- User permissions and security model

### Resource Dependencies
- Offshore developer availability
- Subject matter expert availability for requirements
- QA resources for testing phase
- Production deployment window

### Business Dependencies
- Stakeholder approval for design decisions
- User availability for UAT
- Training schedule coordination
- Change management communication timeline

---

## CHANGE CONTROL

All scope changes must follow this process:

1. **Request Submission:** Change request documented with business justification
2. **Impact Analysis:** Technical team assesses effort, cost, risk, and timeline impact
3. **Prioritization:** Project Manager and Sponsor review and prioritize
4. **Approval:** Changes requiring >40 hours require Executive Sponsor approval
5. **Implementation:** Approved changes incorporated into project plan
6. **Communication:** All stakeholders notified of approved changes

Minor changes (<8 hours effort) may be approved by Project Manager alone.

---

## PROJECT GOVERNANCE

### Steering Committee
- Meets bi-weekly
- Reviews project status, risks, and issues
- Makes decisions on scope changes and escalated issues
- Members: VP Operations, IT Director, Project Manager, Business Owner

### Project Team
- Meets weekly
- Reviews progress, resolves technical issues, coordinates activities
- Members: Project Manager, Lead Developer, Business Analyst, QA Lead

### Communication Plan

| Stakeholder Group | Communication Type | Frequency | Medium |
|-------------------|-------------------|-----------|--------|
| Executive Sponsor | Status Report | Bi-weekly | Email |
| Steering Committee | Status Meeting | Bi-weekly | Video Call |
| Project Team | Stand-up | Daily | Chat |
| End Users | Newsletter | Monthly | Email |
| All Stakeholders | Milestone Updates | At milestone | Email |

---

## DELIVERABLES SUMMARY

### Technical Deliverables
- [ ] IntakeProcessController.cls with full documentation
- [ ] masterIntakeLauncher LWC component
- [ ] questionItem LWC component
- [ ] answerSummary LWC component
- [ ] caseDetailsPanel LWC component
- [ ] Test classes with 85%+ coverage
- [ ] Jest test suites with 80%+ coverage
- [ ] Technical documentation

### Documentation Deliverables
- [ ] User Guide
- [ ] Administrator Guide
- [ ] Technical Architecture Document
- [ ] API Documentation
- [ ] Training Materials
- [ ] Support Runbook

### Project Management Deliverables
- [ ] Project Plan with timeline
- [ ] Risk Register
- [ ] Test Plan and Results
- [ ] UAT Sign-off
- [ ] Deployment Plan
- [ ] Lessons Learned Report

---

## APPROVAL

### Project Charter Approval

| Name | Title | Signature | Date |
|------|-------|-----------|------|
| [Executive Sponsor] | VP of Operations | _______________ | ___/___/___ |
| [Project Manager] | Technical PM | _______________ | ___/___/___ |
| [IT Director] | IT Director | _______________ | ___/___/___ |
| [Business Owner] | Business Operations Lead | _______________ | ___/___/___ |

---

## APPENDICES

### Appendix A: Technical Architecture Overview

The Master Intake Flow redesign follows a three-tier architecture:

1. **Presentation Layer (LWC Components)**
   - masterIntakeLauncher: Orchestrates the intake flow
   - questionItem: Renders individual questions with validation
   - answerSummary: Displays completion summary
   - caseDetailsPanel: Provides contextual case information

2. **Business Logic Layer (Apex Controllers)**
   - IntakeProcessController: Manages question flow and outcomes
   - Batch fetching and caching for performance
   - Draft persistence and retrieval
   - Outcome action execution

3. **Data Layer**
   - Intake_Process__c custom object (existing)
   - Case, Asset, Location standard objects
   - SessionStorage for draft management (browser-side)

### Appendix B: Performance Benchmarks

Target performance metrics:

| Metric | Target | Measurement |
|--------|--------|-------------|
| Initial Load Time | ≤ 1.5 sec | Time to Interactive |
| Question Transition | ≤ 0.3 sec | Click to render |
| Draft Save | ≤ 0.5 sec | API response time |
| Batch Fetch | ≤ 1.0 sec | Server round trip |
| Submit & Process | ≤ 2.0 sec | Complete submission |

### Appendix C: Browser Compatibility Matrix

| Browser | Minimum Version | Status |
|---------|----------------|--------|
| Chrome | Latest - 2 | Supported |
| Firefox | Latest - 2 | Supported |
| Safari | Latest - 2 | Supported |
| Edge | Latest - 2 | Supported |
| IE 11 | N/A | Not Supported |

### Appendix D: Security Considerations

- Object-level security enforced via Salesforce sharing model
- Field-level security respected in all queries
- CRUD permissions validated before DML operations
- Input validation and sanitization on all user inputs
- XSS prevention via Lightning Security
- CSRF protection via Salesforce platform

---

**Document Version:** 1.0
**Last Updated:** January 2026
**Next Review Date:** Post-Project Completion

