import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import processGoogleDriveFolder from '@salesforce/apex/AccountGoogleDriveFolderController.processGoogleDriveFolderRequest';
export default class AccountGoogleDriveFolderQuickAction extends LightningElement {
  @api recordId;

  @api async invoke() {
    if (!this.recordId) {
      this.recordId = this._recordId;
    }
    try {
      await processGoogleDriveFolder({ accountId: this.recordId });
      this.showToast(
        'Success',
        'Google Drive folder created successfully',
        'success'
      );
      setTimeout(() => {
        this.refreshFullPage();
      }, 8000);
    } catch (error) {
      console.log(error);
      this.showToast(
        'Error creating Google Drive folder',
        error.body.message,
        'error'
      );
    }
  }
  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
      })
    );
  }
  refreshFullPage() {
    // Refresh the entire page
    window.location.reload();
  }
}