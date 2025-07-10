public with sharing class PaymentScheduleGenQueuable implements Queueable, Database.AllowsCallouts {
    public InputParameters params;

    public PaymentScheduleGenQueuable(InputParameters params) {
        this.params = params;
    }
    
    @InvocableMethod(label='Create Payment Schedule' description='Creates Payment Schedules')
    public static void createPaymentSchedule(List<InputParameters> parameters) {
        if (!parameters.isEmpty()) {
            System.enqueueJob(new PaymentScheduleGenQueuable(parameters[0]));
        }
    }
    
    public void execute(QueueableContext context){
        
        try {
            bt_stripe__Payment_Schedule__c paymentSchedule = new bt_stripe__Payment_Schedule__c();
            //Information
            paymentSchedule.bt_stripe__Preset__c = params.ezPreset;
            paymentSchedule.bt_stripe__Recurrence_Method__c = params.recurrenceMethod;
            paymentSchedule.bt_stripe__Start_Date__c = params.startDate;
            paymentSchedule.bt_stripe__End_Date__c = params.endDate;
            paymentSchedule.bt_stripe__Count__c = params.count;
            paymentSchedule.Opportunity__c = params.opportunityId;
            paymentSchedule.bt_stripe__Initial_Amount__c = params.initialAmount;
            paymentSchedule.bt_stripe__Each_Amount__c = params.eachAmount;
            paymentSchedule.bt_stripe__Total_Amount__c = params.totalAmount;
            paymentSchedule.bt_stripe__Currency__c = params.currencyITR;
            paymentSchedule.bt_stripe__Description__c = params.description;
            //Related To
            paymentSchedule.bt_stripe__Payment_Gateway__c = params.paymentGateway;
            paymentSchedule.bt_stripe__Account__c = params.accountPs;
            paymentSchedule.bt_stripe__Contact__c = params.contactPs;
            paymentSchedule.bt_stripe__Payment_Method__c = params.paymentMethodPs;
            //Status
            paymentSchedule.bt_stripe__Payment_Status__c = params.paymentStatus;
            paymentSchedule.bt_stripe__Status__c = params.scheduleStatus;
            paymentSchedule.bt_stripe__Balance_Paid__c = params.balancePaid;
            paymentSchedule.bt_stripe__Balance_Due__c = params.balanceDue;
            paymentSchedule.bt_stripe__Next_Payment_Date__c =params.nextPaymentDate;

            //Schedule Details
            paymentSchedule.bt_stripe__Repeats__c = params.repeats;
            paymentSchedule.bt_stripe__Frequency__c = params.frequency;
            paymentSchedule.bt_stripe__Day_of_Month__c = params.dayOfTheMonth;
            paymentSchedule.bt_stripe__Month_of_Year__c = params.monthOfYear;
            paymentSchedule.bt_stripe__Day_of_Week__c = params.dayOfTheWeek;
            paymentSchedule.bt_stripe__On_The__c = params.onThe;

            //CRON Expression
            paymentSchedule.bt_stripe__CRON__c = params.cron;

            //Logic
            paymentSchedule.bt_stripe__Capture_First__c = params.captureFirst;
            paymentSchedule.bt_stripe__Auto_Capture__c = params.autoCapture;

            insert paymentSchedule;        
        } catch (Exception e) {
            System.debug('Error while creating Payment Schedule: ' + e.getMessage());
        }
    }

    public class InputParameters {

        @InvocableVariable(label='EZ Preset' required=true)
        public String ezPreset;
        
        @InvocableVariable(label='Recurrence Method')
        public String recurrenceMethod;

        @InvocableVariable(label='Start Date' required=true)
        public Date startDate;

        @InvocableVariable(label='End Date')
        public Date endDate;

        @InvocableVariable(label='Count')
        public Integer count;

        @InvocableVariable(label='Opportunity ID')
        public Id opportunityId;

        @InvocableVariable(label='Initial Amount')
        public Decimal initialAmount;

        @InvocableVariable(label='Each Amount')
        public Decimal eachAmount;

        @InvocableVariable(label='Total Amount')
        public Decimal totalAmount;

        @InvocableVariable(label='Currency')
        public String currencyITR;

        @InvocableVariable(label='Description')
        public String description;

        @InvocableVariable(label='Payment Gateway')
        public Id paymentGateway;

        @InvocableVariable(label='Account Related to Payment Schedule')
        public Id accountPs;
        
        @InvocableVariable(label='Contact Related to Payment Schedule')
        public Id contactPs;

        @InvocableVariable(label='Payment Method Related to Payment Schedule')
        public Id paymentMethodPs;

        @InvocableVariable(label='Payment Status')
        public String paymentStatus;

        @InvocableVariable(label='Schedule Status' required=true)
        public String scheduleStatus;

        @InvocableVariable(label='Balance Paid')
        public Decimal balancePaid;

        @InvocableVariable(label='Balance Due')
        public Decimal balanceDue;

        @InvocableVariable(label='Next Payment Date')
        public Date nextPaymentDate;

        @InvocableVariable(label='Repeats')
        public String repeats;
        
        @InvocableVariable(label='Frequency')
        public Integer frequency;

        @InvocableVariable(label='Day of Month')
        public String dayOfTheMonth;

        @InvocableVariable(label='Month of Year')
        public String monthOfYear;

        @InvocableVariable(label='Day of Week')
        public String dayOfTheWeek;

        @InvocableVariable(label='On The')
        public String onThe;

        @InvocableVariable(label='CRON')
        public String cron;

        @InvocableVariable(label='Capture First')
        public Boolean captureFirst;

        @InvocableVariable(label='Auto Capture')
        public Boolean autoCapture;
    }

}