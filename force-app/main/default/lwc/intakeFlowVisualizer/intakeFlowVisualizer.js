import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFlowVisualizationData from '@salesforce/apex/IntakeAdminController.getFlowVisualizationData';
import getQuestionFlowPath from '@salesforce/apex/IntakeAdminController.getQuestionFlowPath';
import validateQuestionPath from '@salesforce/apex/IntakeAdminController.validateQuestionPath';

export default class IntakeFlowVisualizer extends NavigationMixin(LightningElement) {
    // Data
    @track flowData = null;
    @track selectedNode = null;
    @track validationResults = null;

    // UI State
    @track isLoading = false;
    @track error = null;
    @track viewMode = 'full'; // 'full' or 'path'
    @track selectedQuestionId = null;

    // Filters
    @track filters = {
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

            const filterJson = JSON.stringify(this.filters);
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

        // Create SVG
        const width = canvas.clientWidth || 800;
        const height = canvas.clientHeight || 600;

        const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('width', width);
        svg.setAttribute('height', height);
        svg.setAttribute('class', 'flow-svg');

        // Create groups for edges and nodes
        const edgeGroup = document.createElementNS('http://www.w3.org/2000/svg', 'g');
        edgeGroup.setAttribute('class', 'edges');
        svg.appendChild(edgeGroup);

        const nodeGroup = document.createElementNS('http://www.w3.org/2000/svg', 'g');
        nodeGroup.setAttribute('class', 'nodes');
        svg.appendChild(nodeGroup);

        // Simple force-directed layout (simplified version)
        const nodes = this.flowData.nodes.map(n => ({
            ...n,
            x: Math.random() * width,
            y: Math.random() * height,
            vx: 0,
            vy: 0
        }));

        const nodeMap = new Map(nodes.map(n => [n.id, n]));

        // Render edges
        this.flowData.edges.forEach(edge => {
            const source = nodeMap.get(edge.source);
            const target = nodeMap.get(edge.target);

            if (source && target) {
                const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
                line.setAttribute('x1', source.x);
                line.setAttribute('y1', source.y);
                line.setAttribute('x2', target.x);
                line.setAttribute('y2', target.y);
                line.setAttribute('stroke', '#999');
                line.setAttribute('stroke-width', '1');
                line.setAttribute('marker-end', 'url(#arrowhead)');
                line.setAttribute('data-edge-id', edge.id);
                edgeGroup.appendChild(line);
            }
        });

        // Render nodes
        nodes.forEach(node => {
            const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
            circle.setAttribute('cx', node.x);
            circle.setAttribute('cy', node.y);
            circle.setAttribute('r', node.isStart ? '12' : '8');
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
            circle.setAttribute('stroke-width', '2');
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
                text.setAttribute('y', node.y - 15);
                text.setAttribute('text-anchor', 'middle');
                text.setAttribute('font-size', '10');
                text.setAttribute('fill', '#333');
                text.textContent = node.name;
                nodeGroup.appendChild(text);
            }
        });

        // Add arrowhead marker definition
        const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
        const marker = document.createElementNS('http://www.w3.org/2000/svg', 'marker');
        marker.setAttribute('id', 'arrowhead');
        marker.setAttribute('markerWidth', '10');
        marker.setAttribute('markerHeight', '10');
        marker.setAttribute('refX', '8');
        marker.setAttribute('refY', '3');
        marker.setAttribute('orient', 'auto');

        const polygon = document.createElementNS('http://www.w3.org/2000/svg', 'polygon');
        polygon.setAttribute('points', '0 0, 10 3, 0 6');
        polygon.setAttribute('fill', '#999');
        marker.appendChild(polygon);
        defs.appendChild(marker);
        svg.insertBefore(defs, svg.firstChild);

        canvas.appendChild(svg);
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
