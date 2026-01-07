import { LightningElement, api } from 'lwc';
import MasterIntakeFormModal from 'c/masterIntakeForm';

/**
 * Master Intake Launcher - Button component to open intake modal
 *
 * This component should be placed on the Case record page.
 * It displays a button that opens the Master Intake Flow modal dialog.
 */
export default class MasterIntakeLauncher extends LightningElement {
    @api recordId; // Case ID from record page

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

            // If intake was completed successfully, refresh the page
            if (result === 'success') {
                console.log('[MasterIntakeLauncher] Intake completed, refreshing page...');
                // Use force:refreshView or navigate to refresh
                eval("$A.get('e.force:refreshView').fire();");
            }

        } catch (error) {
            console.error('[MasterIntakeLauncher] Error opening modal:', error);
        }
    }
}
