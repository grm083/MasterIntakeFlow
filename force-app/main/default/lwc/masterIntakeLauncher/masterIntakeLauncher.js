import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import MasterIntakeFormModal from 'c/masterIntakeForm';

/**
 * Master Intake Launcher - Button component to open intake modal
 *
 * This component should be placed on the Case record page.
 * It displays a button that opens the Master Intake Flow modal dialog.
 */
export default class MasterIntakeLauncher extends LightningElement {
    @api recordId; // Case ID from record page
    @track showFloatingButton = false;

    connectedCallback() {
        // Check if there's a minimized form waiting to be restored
        this.checkFloatingButtonState();
    }

    checkFloatingButtonState() {
        this.showFloatingButton = MasterIntakeFormModal.isFloatingButtonVisible();
        console.log('[MasterIntakeLauncher] Floating button visible:', this.showFloatingButton);
    }

    async handleOpenIntake() {
        console.log('[MasterIntakeLauncher] Opening Master Intake Flow modal');
        console.log('[MasterIntakeLauncher] Case ID:', this.recordId);

        try {
            const result = await MasterIntakeFormModal.open({
                size: 'large', // small, medium, large
                description: 'Master Intake Flow',
                recordId: this.recordId
            });

            console.log('[MasterIntakeLauncher] Modal closed with result:', result);

            // Check floating button state after modal closes
            this.checkFloatingButtonState();

            // If intake was completed successfully, refresh the page
            if (result === 'success') {
                console.log('[MasterIntakeLauncher] Intake completed successfully');

                // Show success toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Master Intake completed successfully',
                        variant: 'success'
                    })
                );

                // Refresh the page to show updated case
                setTimeout(() => {
                    console.log('[MasterIntakeLauncher] Refreshing page...');
                    eval("$A.get('e.force:refreshView').fire();");
                }, 500);
            }

            // If minimized, show floating button
            if (result === 'minimized') {
                console.log('[MasterIntakeLauncher] Modal minimized, showing floating button');
                this.showFloatingButton = true;
            }

        } catch (error) {
            console.error('[MasterIntakeLauncher] Error opening modal:', error);

            // Show error toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to open Master Intake Flow',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
    }

    async handleRestoreFromFloating() {
        console.log('[MasterIntakeLauncher] Restoring from floating button');

        // Hide floating button
        this.showFloatingButton = false;
        MasterIntakeFormModal.clearFloatingButton();

        // Re-open the modal (it will auto-load the draft)
        await this.handleOpenIntake();
    }
}
