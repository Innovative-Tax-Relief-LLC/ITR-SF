import { LightningElement, api } from 'lwc';
import getLastPriority from '@salesforce/apex/LeadDistributionRuleController.getLastPriority';
import saveRule from '@salesforce/apex/LeadDistributionRuleController.saveRule';
import getFields from '@salesforce/apex/FieldSelectorModalController.getFields';
import getRuleDetails from '@salesforce/apex/LeadDistributionRuleController.getRuleDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadDistributionRuleCreator extends LightningElement {
    @api isEditMode = false;
    @api recordId ='';
    ruleName = 'New Rule';
    isActive = true;
    returnObject = 'Account';
    criteriaRows = [];
    logic = '';
    isModalOpen = false;
    modalRowId = null;
    criteriaObject = null;
    priority;
    sortByOptions;
    sortingDirectionOptions = [
        { label: 'Ascending', value: 'ASC' },
        { label: 'Descending', value: 'DESC' }
    ];
    sortBy = 'LastModifiedDate';
    sortingDirection = 'ASC';

    returnObjectOptions = [
        { label: 'Account', value: 'Account' },
        { label: 'Lead', value: 'Lead' }
    ];

    operatorOptions = [
        { label: 'Equal To', value: '=' },
        { label: 'Not Equal To', value: '!=' },
        { label: 'Less than', value: '<' },
        { label: 'Less than or equal to', value: '<=' },
        { label: 'Greater than', value: '>' },
        { label: 'Greater than or equal to', value: '>=' },
        { label: 'Contains', value: 'LIKE' },
        { label: 'In', value: 'In' },
        { label: 'Not In', value: 'Not In' }
    ];

    get isAddDisabled() {
        return !this.returnObject && this.criteriaRows.length === 0;
    }

    get showLogic() {
        return this.criteriaRows.length > 1;
    }

    connectedCallback() {
        console.log('recordId : ', this.recordId);
        if(this.recordId){
            console.log('recordId loaded: ', this.recordId);
            this.loadRuleDetails(this.recordId);
        }
        this.loadFields(this.returnObject);
        if(!this.isEditMode){
            this.loadPriority();
        }
    }

    loadRuleDetails(ruleId) {
        getRuleDetails({ ruleId })
            .then(ruleData => {
                this.ruleName = ruleData.ruleName;
                this.priority = ruleData.priority;
                this.isActive = ruleData.isActive;
                this.returnObject = ruleData.returnObject;
                this.criteriaObject = ruleData.fromObject;
                this.criteriaRows = ruleData.criteriaRows || [];
                this.logic = ruleData.logic;
                this.sortBy = ruleData.sortBy || 'LastModifiedDate';
                this.sortingDirection = ruleData.sortingDirection || 'ASC';
                this.returnField = ruleData.returnField;

                console.log('ruleData : ', ruleData);

                this.recalculateOrderValues();
            })
            .catch(error => {
                console.error('Error loading rule details:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error loading rule details.',
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            });
    }


    handleRuleNameChange(event) {
        this.ruleName = event.target.value;
    }

    handleIsActiveChange(event) {
        this.isActive = event.detail.checked;
        console.log('this.isActive : ', this.isActive);
    }

    handlePriorityChange(event) {
        this.priority = event.target.value;
    }

    handleReturnObjectChange(event) {
        this.returnObject = event.target.value;
        this.criteriaRows = [];
        this.logic = '';
        this.loadFields(this.returnObject);
    }

    handleSortByChange(event) {
        this.sortBy = event.target.value;
    }

    handleSortingDirectionChange(event) {
        this.sortingDirection = event.target.value;
    }

    handleAddRow() {
        const newRow = {
            id: this.criteriaRows.length + 1,
            fieldApiName: '',
            operator: '',
            value: ''
        };
        this.criteriaRows = [...this.criteriaRows, newRow];
        this.updateLogic();
    }

    handleSelectField(event) {
        this.modalRowId = event.target.dataset.id;
        this.isModalOpen = true;
    }

    handleFieldSelect(event) {
        const { fieldApiName, objectApiName } = event.detail;
        console.log('fieldApiName : ', fieldApiName);
        console.log('objectApiName : ', objectApiName);
        
        if(objectApiName){
            this.criteriaObject = objectApiName;
        }
        const updatedRows = this.criteriaRows.map(row => {
            if (row.id == this.modalRowId) {
                row.objectAndFieldApiName = objectApiName ? `${objectApiName}.${fieldApiName}`: `${this.returnObject}.${fieldApiName}`;
                row.fieldApiName = objectApiName ? `${objectApiName}.${fieldApiName}`: fieldApiName;
            }
            return row;
        });
        this.criteriaRows = [...updatedRows];

        this.isModalOpen = false;
    }

    handleOperatorChange(event) {
        const rowId = event.target.dataset.id;
        const updatedRows = this.criteriaRows.map(row => {
            if (row.id == rowId) {
                row.operator = event.detail.value;
            }
            return row;
        });
        this.criteriaRows = [...updatedRows];
        this.updateLogic();
    }

    handleValueChange(event) {
        const rowId = event.target.dataset.id;
        const updatedRows = this.criteriaRows.map(row => {
            if (row.id == rowId) {
                row.value = event.detail.value;
            }
            return row;
        });
        this.criteriaRows = [...updatedRows];
    }

    handleCriteriaDeleteClick(event) {
        const rowId = event.target.dataset.id;
        const index = this.criteriaRows.findIndex(row => row.id == rowId);

        if (this.criteriaRows.length === 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'A rule needs at least one criteria.',
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
            return;
        }

        if (index != -1){
            this.criteriaRows.splice(index, 1);

            // Recalculate Order values for the remaining rows
            this.recalculateOrderValues();

            this.updateLogic();
        }
    }

    handleCloseClick(){
        this.dispatchClose(false);
    }
   
    recalculateOrderValues() {
        let indexCounter = 0
            const updatedRows = this.criteriaRows.map(row => {
                row.id = indexCounter + 1;
                indexCounter++;
                return row;
            });
        this.criteriaRows = [...updatedRows];
    }

    loadPriority(){
        getLastPriority()
            .then(data => {
                this.priority = this.convertToInteger(data) + 1;
            })
            .catch(error => {
                console.error('Error loading priority:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error loading priority.',
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            });
    }

    loadFields(objectApiName) {
            getFields({ baseObject: objectApiName })
                .then(data => {
                    this.sortByOptions = data.map(fieldApiName => {
                        return {
                            label: fieldApiName,
                            value: fieldApiName 
                        };
                    });
                    this.sortBy = 'LastModifiedDate';
                })
                .catch(error => {
                    console.error('Error loading fields:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error loading Sorting fields.',
                            variant: 'error',
                            mode: 'dismissable'
                        })
                    );
                });
        }

    convertToInteger(value) {
        return value * 1;
    }


    updateLogic() {
        this.logic = this.criteriaRows.map((row, index) => `{${index + 1}}`).join(' AND ');
    }

    handleSave() {
        if (!this.ruleName || !this.returnObject || this.criteriaRows.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please populate all required fields.',
                    variant: 'warning',
                    mode: 'dismissable'
                })
            );
            return;
        }

        let fromObject;
        let returnField;
        if(this.criteriaObject ){
            fromObject = this.criteriaObject;
            returnField = this.returnObject+'.Id';
        }else{
            fromObject = this.returnObject;
            returnField = 'Id';
        }
        const ruleData = {
            ruleId: this.recordId,
            ruleName: this.ruleName,
            priority : this.priority,
            isActive: this.isActive,
            fromObject: fromObject,
            returnObject: this.returnObject,
            criteria: this.criteriaRows,
            returnField: returnField,
            orderBy: this.sortBy,
            sortingDirection: this.sortingDirection,
            logic: this.logic
        };

        saveRule({ ruleData })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Rule saved successfully!',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
                this.dispatchClose(true);
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error saving rule.',
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            });
    }

    resetForm() {
        this.ruleName = '';
        this.isActive = false;
        this.returnObject = '';
        this.criteriaRows = [];
        this.logic = '';
    }

    dispatchClose(realodPage) {
        console.log('dispatchClose');
        this.dispatchEvent(new CustomEvent('close', { detail: {reloadPage: realodPage} }));
        console.log('dispatchedClose');
    }

    handleFieldModalClose(event) {
        this.isModalOpen = false;
    }
}