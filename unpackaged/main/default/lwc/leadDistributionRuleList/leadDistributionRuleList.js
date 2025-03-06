import { LightningElement, wire } from 'lwc';
import getLeadDistributionRules from '@salesforce/apex/LeadDistributionRuleController.getLeadDistributionRules';
import deleteRule from '@salesforce/apex/LeadDistributionRuleController.deleteRule';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';

export default class leadDistributionRuleList extends LightningElement {
    columns = [
        { label: 'Priority', fieldName: 'Priority__c', type: 'number', fixedWidth: 100},
        { label: 'Name', fieldName: 'Name', type: 'text' },
        { label: 'From Object', fieldName: 'From_Object__c', type: 'text' },
        { label: 'Return Object', fieldName: 'Return_Object__c', type: 'text' },
        { label: 'Is Active', fieldName: 'IsActive__c', type: 'boolean' },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Edit', name: 'edit' },
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];
    rules = [];
    isModalOpen = false;
    selectedRuleId = null;
    isEditMode = false;

    @wire(getLeadDistributionRules)
    wiredRules({ data, error }) {
        if (data) {
            this.rules = data;
        } else if (error) {
            console.error('Error fetching rules:', error);
        }
    }

    handleNewClick() {
        this.selectedRuleId = null;
        this.isEditMode = false;
        this.isModalOpen = true;
    }

    handleEditClick(event) {
        this.selectedRuleId = event.detail.row.Id;
        console.log('event detail', event.detail.row.Id);
        console.log('this.selectedRuleId', this.selectedRuleId);
        this.isEditMode = true;
        this.isModalOpen = true;
    }

    handleDeleteClick(event) {
        const ruleId = event.detail.row.Id;
        this.handleDelete(ruleId);
    }

    async handleDelete(ruleId){
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to delete this rule?',
            variant: 'headerless',
            label: 'this is the aria-label value'
        });

        if (result) {
            deleteRule({ ruleId })
                .then(() => {
                    this.showToast('Success', 'Rule deleted successfully.', 'success');
                    this.refreshRules();
                })
                .catch(error => {
                    console.error('Error deleting rule:', error);
                    this.showToast('Error', 'Failed to delete the rule.', 'error');
                });
        }
    }

    handleModalClose(event) {
        console.log('CLose event recived');
        console.log('event.detail', event.detail);
        const reloadPage = event.detail.reloadPage;
        this.isModalOpen = false;
        if(reloadPage){
            this.refreshRules();
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;

        if (actionName == 'edit') {
            this.handleEditClick(event);
        }
        else if (actionName == 'delete') {
            this.handleDeleteClick(event);
        }
    }

    refreshRules() {
        window.location.reload();
        // return getLeadDistributionRules()
        //     .then(data => {
        //         this.rules = data;
        //     })
        //     .catch(error => {
        //         console.error('Error refreshing rules:', error);
        //     });
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
}