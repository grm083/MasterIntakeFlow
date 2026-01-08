import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFlowVisualizationData from '@salesforce/apex/IntakeAdminController.getFlowVisualizationData';
import getQuestionFlowPath from '@salesforce/apex/IntakeAdminController.getQuestionFlowPath';
import validateQuestionPath from '@salesforce/apex/IntakeAdminController.validateQuestionPath';

export default class IntakeFlowVisualizer extends NavigationMixin(LightningElement) {
    // Public API - can receive filters from parent component
    @api filters;

    // Data
    @track flowData = null;
    @track selectedNode = null;
    @track validationResults = null;
    @track selectedTerminalOutcome = null;

    // UI State
    @track isLoading = false;
    @track error = null;
    @track viewMode = 'full'; // 'full' or 'path'
    @track selectedQuestionId = null;

    // Internal filters (used if no filters passed from parent)
    @track internalFilters = {
        caseType: '',
        caseSubType: '',
        limit: 1000
    };

    // Visualization state
    @track zoomLevel = 1;
    @track showLabels = true;
    @track showOrphaned = true;
    @track highlightIssues = true;

    // Stats
    @track stats = {
        totalNodes: 0,
        totalEdges: 0,
        orphanedNodes: 0,
        startNodes: 0,
        deadEnds: 0
    };

    // ========== LIFECYCLE ==========

    connectedCallback() {
        this.loadFlowData();
    }

    renderedCallback() {
        if (this.flowData && !this.isVisualizationRendered) {
            this.renderVisualization();
            this.isVisualizationRendered = true;
        }
    }

    // ========== DATA LOADING ==========

    async loadFlowData() {
        try {
            this.isLoading = true;
            this.error = null;

            // Use filters from parent if provided, otherwise use internal filters
            const filtersToUse = this.filters || this.internalFilters;
            const filterJson = typeof filtersToUse === 'string' ? filtersToUse : JSON.stringify(filtersToUse);
            const data = await getFlowVisualizationData({ filters: filterJson });

            this.flowData = data;
            this.calculateStats(data);
            this.isVisualizationRendered = false; // Trigger re-render

            this.showToast('Success', `Loaded ${data.nodeCount} questions and ${data.edgeCount} connections`, 'success');
            this.isLoading = false;

        } catch (error) {
            console.error('Error loading flow data:', error);
            this.error = error.body?.message || error.message;
            this.isLoading = false;
            this.showToast('Error', this.error, 'error');
        }
    }

    async loadQuestionPath(questionId) {
        try {
            this.isLoading = true;
            this.selectedQuestionId = questionId;

            const data = await getQuestionFlowPath({
                questionId: questionId,
                maxDepth: 50
            });

            this.flowData = data;
            this.viewMode = 'path';
            this.calculateStats(data);
            this.isVisualizationRendered = false;

            this.showToast('Info', `Showing path from question (depth: ${data.depthReached})`, 'info');
            this.isLoading = false;

        } catch (error) {
            console.error('Error loading question path:', error);
            this.error = error.body?.message || error.message;
            this.isLoading = false;
            this.showToast('Error', this.error, 'error');
        }
    }

    async validateNode(questionId) {
        try {
            const results = await validateQuestionPath({ questionId: questionId });
            this.validationResults = results;

            if (!results.isValid) {
                this.showToast('Validation Issues', `Found ${results.issues.length} issues`, 'warning');
            } else {
                this.showToast('Validation Passed', 'No issues found', 'success');
            }

        } catch (error) {
            console.error('Error validating question:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
        }
    }

    // ========== VISUALIZATION ==========

    renderVisualization() {
        const canvas = this.template.querySelector('.flow-canvas');
        if (!canvas || !this.flowData) {
            return;
        }

        // Clear existing content
        canvas.innerHTML = '';

        // Create SVG with larger dimensions for hierarchical layout
        const width = canvas.clientWidth || 1600;
        const height = canvas.clientHeight || 1200;

        const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('width', '100%');
        svg.setAttribute('height', height);
        svg.setAttribute('viewBox', `0 0 ${width} ${height}`);
        svg.setAttribute('class', 'flow-svg');

        // Create groups for edges and nodes
        const edgeGroup = document.createElementNS('http://www.w3.org/2000/svg', 'g');
        edgeGroup.setAttribute('class', 'edges');
        svg.appendChild(edgeGroup);

        const nodeGroup = document.createElementNS('http://www.w3.org/2000/svg', 'g');
        nodeGroup.setAttribute('class', 'nodes');
        svg.appendChild(nodeGroup);

        // Calculate hierarchical layout
        const layoutData = this.calculateHierarchicalLayout(this.flowData, width, height);
        const nodes = layoutData.nodes;
        const nodeMap = new Map(nodes.map(n => [n.id, n]));

        // Separate terminal and regular edges
        const terminalEdges = this.flowData.edges.filter(e => e.isTerminal);
        const regularEdges = this.flowData.edges.filter(e => !e.isTerminal);

        // Render regular edges with curved paths and labels
        regularEdges.forEach(edge => {
            const source = nodeMap.get(edge.source);
            const target = nodeMap.get(edge.target);

            if (source && target) {
                // Use curved path for better visibility
                const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');

                // Calculate control point for smooth curve
                const midY = (source.y + target.y) / 2;
                const pathData = `M ${source.x} ${source.y}
                                  C ${source.x} ${midY}, ${target.x} ${midY}, ${target.x} ${target.y}`;

                path.setAttribute('d', pathData);
                path.setAttribute('stroke', '#cbd5e0');
                path.setAttribute('stroke-width', '2');
                path.setAttribute('fill', 'none');
                path.setAttribute('marker-end', 'url(#arrowhead)');
                path.setAttribute('data-edge-id', edge.id);
                edgeGroup.appendChild(path);

                // Add outcome label if present
                if (edge.label && this.showLabels) {
                    const labelX = source.x;
                    const labelY = (source.y + target.y) / 2;

                    const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                    text.setAttribute('x', labelX + 15);
                    text.setAttribute('y', labelY);
                    text.setAttribute('font-size', '12'); // Larger font for edge labels
                    text.setAttribute('font-style', 'italic');
                    text.setAttribute('font-weight', '500');
                    text.setAttribute('fill', '#4a5568');
                    text.setAttribute('class', 'edge-label');
                    text.textContent = edge.label;
                    edgeGroup.appendChild(text);
                }
            }
        });

        // Render terminal outcomes as special end nodes
        const terminalNodesBySource = new Map();
        terminalEdges.forEach(edge => {
            if (!terminalNodesBySource.has(edge.source)) {
                terminalNodesBySource.set(edge.source, []);
            }
            terminalNodesBySource.get(edge.source).push(edge);
        });

        terminalNodesBySource.forEach((terminals, sourceId) => {
            const source = nodeMap.get(sourceId);
            if (!source) return;

            terminals.forEach((edge, index) => {
                // Calculate position below source node
                const terminalY = source.y + 100;
                const offset = (index - (terminals.length - 1) / 2) * 150;
                const terminalX = source.x + offset;

                // Draw connection line to terminal outcome
                const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
                const midY = (source.y + terminalY) / 2;
                const pathData = `M ${source.x} ${source.y}
                                  C ${source.x} ${midY}, ${terminalX} ${midY}, ${terminalX} ${terminalY}`;
                path.setAttribute('d', pathData);
                path.setAttribute('stroke', '#48bb78');
                path.setAttribute('stroke-width', '2');
                path.setAttribute('fill', 'none');
                path.setAttribute('stroke-dasharray', '5,5');
                edgeGroup.appendChild(path);

                // Add outcome label on the path
                if (edge.label && this.showLabels) {
                    const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                    text.setAttribute('x', source.x + 15);
                    text.setAttribute('y', (source.y + terminalY) / 2);
                    text.setAttribute('font-size', '12'); // Larger font for terminal labels
                    text.setAttribute('font-weight', 'bold');
                    text.setAttribute('fill', '#2f855a');
                    text.textContent = edge.label;
                    edgeGroup.appendChild(text);
                }

                // Render terminal outcome box
                this.renderTerminalOutcome(nodeGroup, terminalX, terminalY, edge);
            });
        });

        // Render nodes with improved sizing and spacing
        nodes.forEach(node => {
            const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
            circle.setAttribute('cx', node.x);
            circle.setAttribute('cy', node.y);
            circle.setAttribute('r', node.isStart ? '18' : '14'); // Larger circles for visibility
            circle.setAttribute('data-node-id', node.id);

            // Color based on status
            let fill = '#4bca81'; // Active/normal (green)
            if (node.isOrphaned) {
                fill = '#ea001e'; // Orphaned (red)
            } else if (node.outcomeCount === 0) {
                fill = '#fe9339'; // No outcomes (orange)
            } else if (node.isStart) {
                fill = '#0176d3'; // Start node (blue)
            }

            circle.setAttribute('fill', fill);
            circle.setAttribute('stroke', '#fff');
            circle.setAttribute('stroke-width', '3');
            circle.style.cursor = 'pointer';

            // Click handler
            circle.addEventListener('click', () => {
                this.handleNodeClick(node);
            });

            nodeGroup.appendChild(circle);

            // Add label if enabled
            if (this.showLabels) {
                const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                text.setAttribute('x', node.x);
                text.setAttribute('y', node.y - 28); // More space above node
                text.setAttribute('text-anchor', 'middle');
                text.setAttribute('font-size', '13'); // Larger font
                text.setAttribute('font-weight', node.isStart ? 'bold' : 'normal');
                text.setAttribute('fill', '#2d3748');
                text.textContent = node.name;
                nodeGroup.appendChild(text);
            }

            // Add tier label for debugging/clarity
            if (this.showLabels && node.tier !== undefined) {
                const tierText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
                tierText.setAttribute('x', node.x);
                tierText.setAttribute('y', node.y + 32); // More space below node
                tierText.setAttribute('text-anchor', 'middle');
                tierText.setAttribute('font-size', '10'); // Slightly larger tier labels
                tierText.setAttribute('fill', '#718096');
                tierText.textContent = `Tier ${node.tier}`;
                nodeGroup.appendChild(tierText);
            }
        });

        // Add arrowhead marker definition
        const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
        const marker = document.createElementNS('http://www.w3.org/2000/svg', 'marker');
        marker.setAttribute('id', 'arrowhead');
        marker.setAttribute('markerWidth', '10');
        marker.setAttribute('markerHeight', '10');
        marker.setAttribute('refX', '9');
        marker.setAttribute('refY', '3');
        marker.setAttribute('orient', 'auto');

        const polygon = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
        polygon.setAttribute('points', '0 0, 10 3, 0 6');
        polygon.setAttribute('fill', '#cbd5e0');
        marker.appendChild(polygon);
        defs.appendChild(marker);
        svg.insertBefore(defs, svg.firstChild);

        canvas.appendChild(svg);
    }

    /**
     * Render a terminal outcome as a visual box with statement and actions
     */
    renderTerminalOutcome(parentGroup, x, y, edge) {
        const boxWidth = 140;
        const boxHeight = 80;

        // Create rounded rectangle for terminal outcome
        const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
        rect.setAttribute('x', x - boxWidth / 2);
        rect.setAttribute('y', y - boxHeight / 2);
        rect.setAttribute('width', boxWidth);
        rect.setAttribute('height', boxHeight);
        rect.setAttribute('rx', '8');
        rect.setAttribute('fill', '#f0fff4');
        rect.setAttribute('stroke', '#48bb78');
        rect.setAttribute('stroke-width', '2');
        parentGroup.appendChild(rect);

        // Add "END" indicator
        const endLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        endLabel.setAttribute('x', x);
        endLabel.setAttribute('y', y - boxHeight / 2 + 15);
        endLabel.setAttribute('text-anchor', 'middle');
        endLabel.setAttribute('font-size', '9');
        endLabel.setAttribute('font-weight', 'bold');
        endLabel.setAttribute('fill', '#2f855a');
        endLabel.textContent = 'END';
        parentGroup.appendChild(endLabel);

        // Add outcome statement if present
        if (edge.outcomeStatement) {
            const statement = this.truncateText(edge.outcomeStatement, 20);
            const statementText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
            statementText.setAttribute('x', x);
            statementText.setAttribute('y', y - 5);
            statementText.setAttribute('text-anchor', 'middle');
            statementText.setAttribute('font-size', '9');
            statementText.setAttribute('fill', '#2d3748');
            statementText.textContent = statement;
            parentGroup.appendChild(statementText);
        }

        // Add action indicators
        const actionIcons = this.getActionIcons(edge.actions);
        if (actionIcons.length > 0) {
            const iconsText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
            iconsText.setAttribute('x', x);
            iconsText.setAttribute('y', y + 15);
            iconsText.setAttribute('text-anchor', 'middle');
            iconsText.setAttribute('font-size', '8');
            iconsText.setAttribute('fill', '#718096');
            iconsText.textContent = actionIcons.join(' • ');
            parentGroup.appendChild(iconsText);
        }

        // Make it clickable for more details
        rect.style.cursor = 'pointer';
        rect.addEventListener('click', () => {
            this.handleTerminalOutcomeClick(edge);
        });
    }

    /**
     * Get action icons/labels for terminal outcome
     */
    getActionIcons(actions) {
        if (!actions) return [];

        const icons = [];
        if (actions.updateCaseStatus) icons.push('📊 Status');
        if (actions.updateCaseType) icons.push('📁 Type');
        if (actions.updateCaseSubType) icons.push('📋 SubType');
        if (actions.updateCaseReason) icons.push('🔍 Reason');
        if (actions.createTask) icons.push('✓ Task');
        if (actions.queueAssigned) icons.push('👥 Queue');
        if (actions.assignToCurrentUser) icons.push('👤 User');

        return icons;
    }

    /**
     * Truncate text to specified length
     */
    truncateText(text, maxLength) {
        if (!text) return '';
        return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
    }

    /**
     * Handle click on terminal outcome
     */
    handleTerminalOutcomeClick(edge) {
        // Store terminal outcome details for display
        this.selectedTerminalOutcome = edge;

        // Show toast with summary
        const actionCount = this.getActionIcons(edge.actions).length;
        const message = edge.outcomeStatement
            ? `${edge.outcomeStatement} (${actionCount} actions)`
            : `Terminal outcome with ${actionCount} actions`;

        this.showToast('Terminal Outcome', message, 'info');
    }

    /**
     * Calculate hierarchical tree layout positions for nodes
     */
    calculateHierarchicalLayout(flowData, width, height) {
        // Build adjacency map for easy traversal
        const adjacency = new Map();
        const incomingCount = new Map();

        flowData.nodes.forEach(node => {
            adjacency.set(node.id, []);
            incomingCount.set(node.id, 0);
        });

        flowData.edges.forEach(edge => {
            if (adjacency.has(edge.source)) {
                adjacency.get(edge.source).push(edge.target);
            }
            incomingCount.set(edge.target, (incomingCount.get(edge.target) || 0) + 1);
        });

        // Find start nodes (Presentation_Order = 1 or no incoming edges)
        const startNodes = flowData.nodes.filter(n =>
            n.isStart || incomingCount.get(n.id) === 0
        );

        // Assign tiers using BFS
        const tierMap = new Map();
        const visited = new Set();
        const queue = [];

        // Initialize start nodes at tier 0
        startNodes.forEach(node => {
            tierMap.set(node.id, 0);
            queue.push({ id: node.id, tier: 0 });
            visited.add(node.id);
        });

        // BFS to assign tiers
        let maxTier = 0;
        while (queue.length > 0) {
            const current = queue.shift();
            const children = adjacency.get(current.id) || [];

            children.forEach(childId => {
                if (!visited.has(childId)) {
                    const childTier = current.tier + 1;
                    tierMap.set(childId, childTier);
                    maxTier = Math.max(maxTier, childTier);
                    queue.push({ id: childId, tier: childTier });
                    visited.add(childId);
                }
            });
        }

        // Handle orphaned nodes (not visited) - put them at the end
        flowData.nodes.forEach(node => {
            if (!tierMap.has(node.id)) {
                tierMap.set(node.id, maxTier + 1);
            }
        });

        maxTier = Math.max(maxTier, maxTier + 1);

        // Group nodes by tier
        const tierGroups = new Map();
        for (let i = 0; i <= maxTier; i++) {
            tierGroups.set(i, []);
        }

        flowData.nodes.forEach(node => {
            const tier = tierMap.get(node.id);
            tierGroups.get(tier).push(node);
        });

        // Calculate positions with increased spacing for better readability
        const padding = 80;
        const minVerticalSpacing = 150; // Minimum vertical space between tiers
        const minHorizontalSpacing = 200; // Minimum horizontal space between nodes

        // Use larger of calculated or minimum spacing
        const verticalSpacing = Math.max(minVerticalSpacing, height / (maxTier + 2));
        const nodes = [];

        tierGroups.forEach((nodesInTier, tier) => {
            const nodeCount = nodesInTier.length;

            // Calculate horizontal spacing with minimum spacing enforced
            let horizontalSpacing;
            if (nodeCount === 1) {
                horizontalSpacing = 0;
            } else {
                const calculatedSpacing = (width - 2 * padding) / (nodeCount - 1);
                horizontalSpacing = Math.max(minHorizontalSpacing, calculatedSpacing);
            }

            nodesInTier.forEach((node, index) => {
                const x = nodeCount === 1
                    ? width / 2
                    : padding + (index * horizontalSpacing);
                const y = padding + (tier * verticalSpacing);

                nodes.push({
                    ...node,
                    x: x,
                    y: y,
                    tier: tier
                });
            });
        });

        return { nodes, maxTier };
    }

    handleNodeClick(node) {
        this.selectedNode = node;
        this.validateNode(node.id);
    }

    // ========== EVENT HANDLERS ==========

    handleRefresh() {
        this.loadFlowData();
    }

    handleViewFullFlow() {
        this.viewMode = 'full';
        this.selectedQuestionId = null;
        this.loadFlowData();
    }

    handleShowLabelsChange(event) {
        this.showLabels = event.target.checked;
        this.isVisualizationRendered = false;
    }

    handleShowOrphanedChange(event) {
        this.showOrphaned = event.target.checked;
        // Re-render with filter
    }

    handleHighlightIssuesChange(event) {
        this.highlightIssues = event.target.checked;
        this.isVisualizationRendered = false;
    }

    handleZoomIn() {
        this.zoomLevel = Math.min(this.zoomLevel + 0.2, 3);
        this.applyZoom();
    }

    handleZoomOut() {
        this.zoomLevel = Math.max(this.zoomLevel - 0.2, 0.5);
        this.applyZoom();
    }

    handleResetZoom() {
        this.zoomLevel = 1;
        this.applyZoom();
    }

    applyZoom() {
        const svg = this.template.querySelector('.flow-svg');
        if (svg) {
            svg.style.transform = `scale(${this.zoomLevel})`;
            svg.style.transformOrigin = 'center center';
        }
    }

    handleNavigateToQuestion() {
        if (this.selectedNode) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.selectedNode.id,
                    objectApiName: 'Intake_Process__c',
                    actionName: 'view'
                }
            });
        }
    }

    handleViewQuestionPath() {
        if (this.selectedNode) {
            this.loadQuestionPath(this.selectedNode.id);
        }
    }

    handleCloseDetails() {
        this.selectedNode = null;
        this.validationResults = null;
    }

    // ========== HELPERS ==========

    calculateStats(data) {
        this.stats = {
            totalNodes: data.nodeCount || data.nodes.length,
            totalEdges: data.edgeCount || data.edges.length,
            orphanedNodes: data.nodes.filter(n => n.isOrphaned).length,
            startNodes: data.nodes.filter(n => n.isStart).length,
            deadEnds: data.nodes.filter(n => n.outcomeCount === 0).length
        };
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    // ========== GETTERS ==========

    get hasFlowData() {
        return this.flowData && this.flowData.nodes && this.flowData.nodes.length > 0;
    }

    get hasSelectedNode() {
        return this.selectedNode !== null;
    }

    get hasValidationResults() {
        return this.validationResults !== null;
    }

    get validationIssuesClass() {
        if (!this.validationResults) return '';
        return this.validationResults.isValid ? 'validation-success' : 'validation-error';
    }

    get isFullViewMode() {
        return this.viewMode === 'full';
    }

    get isPathViewMode() {
        return this.viewMode === 'path';
    }
}
