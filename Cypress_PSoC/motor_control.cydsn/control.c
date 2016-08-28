/* ========================================
 * Filename: control.h
 * Author: Ricardo L. Stephen
 * Github: RicardoStephen
 * ========================================
*/

#include "control.h"

void control_drive_1A(const uint8 pwm) {
    Control_Reg_1_Write((Control_Reg_1_Read()&CONTROL_MASK_1)|CONTROL_DRIVE_1A);
    PWM_1_WriteCompare(pwm);
}

void control_drive_1B(const uint8 pwm) {
    Control_Reg_1_Write((Control_Reg_1_Read()&CONTROL_MASK_1)|CONTROL_DRIVE_1B);
    PWM_1_WriteCompare(pwm); 
}

void control_stop_1() {
    Control_Reg_1_Write((Control_Reg_1_Read()&CONTROL_MASK_1)|CONTROL_STOP_1);
    PWM_1_WriteCompare(MIN_PWM);
}

void control_drive_2A(const uint8 pwm) {
    Control_Reg_1_Write((Control_Reg_1_Read()&CONTROL_MASK_2)|CONTROL_DRIVE_2A);
    PWM_2_WriteCompare(pwm);
}

void control_drive_2B(const uint8 pwm) {
    Control_Reg_1_Write((Control_Reg_1_Read()&CONTROL_MASK_2)|CONTROL_DRIVE_2B);
    PWM_2_WriteCompare(pwm);
}
    
void control_stop_2() {
    Control_Reg_1_Write((Control_Reg_1_Read()&CONTROL_MASK_2)|CONTROL_STOP_2);
    PWM_2_WriteCompare(MIN_PWM);
}

void control_init() {
    PWM_1_Start();
    PWM_2_Start(); 
}

void control_stop() {control_stop_1(); control_stop_2();}
void control_update(uint8* navigation) {
    if (navigation[0] == 0) {
        control_stop();
    } else {
        if (navigation[1]) {
            control_drive_1A(navigation[2]);
        } else {
            control_drive_1B(navigation[2]);
        }
        if (navigation[3]) {
            control_drive_2A(navigation[4]);
        } else {
            control_drive_2B(navigation[4]);
        }
    }
}
