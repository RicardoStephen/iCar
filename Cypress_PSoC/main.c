/* ========================================
 * Filename: control.h
 * Author: Ricardo L. Stephen
 * Github: RicardoStephen
 * ========================================
*/

#include <stdio.h>
#include "control.h"
#include "project.h"


void StackEventHandler(uint32 event, void* eventParam) {
    CYBLE_GATTS_WRITE_REQ_PARAM_T *wr_req_param;
    
    switch(event) {
        // Handle requests to write to the GATT server
        
        case CYBLE_EVT_GATTS_WRITE_REQ: 
            wr_req_param = (CYBLE_GATTS_WRITE_REQ_PARAM_T *)eventParam;
                  
            // write to gatt database
            CyBle_GattsWriteAttributeValue(&(wr_req_param->handleValPair),
                0, &(wr_req_param->connHandle), 0);
            // update the controls
            if (wr_req_param->handleValPair.attrHandle == CYBLE_NAVIGATION_NAVIGATION_CHAR_HANDLE) {
                control_update(wr_req_param->handleValPair.value.val);
            }
            // send success notification
            CyBle_GattsWriteRsp(wr_req_param->connHandle);
            break;
            
        case CYBLE_EVT_STACK_ON:
        case CYBLE_EVT_GAP_DEVICE_DISCONNECTED:
            /* Start the BLE fast advertisement. */
            CyBle_GappStartAdvertisement(CYBLE_ADVERTISING_FAST);
            break;
    }
}

int main()
{   
    // Enable global interrupts (required for pwm and ble)
    CyGlobalIntEnable; 
    
    // Start the BLE component and register StackEventHandler function
    CyBle_Start(StackEventHandler);    

    // Initialize motor control
    control_init();
    
    // Handle ble events
    while(1) {CyBle_ProcessEvents();}
}


/* [] END OF FILE */
