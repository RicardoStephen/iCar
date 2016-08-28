/* ========================================
 * Filename: control.h
 * Author: Ricardo L. Stephen
 * Github: RicardoStephen
 * ========================================
*/

#ifndef CONTROL_H
#define CONTROL_H
#include "PWM_1.h"
#include "PWM_2.h"
#include "Control_Reg_1.h"
    

// assignment format: (control_reg_val&CONTROL_MASK_1)|CONTROL_DRIVE_1x
#define CONTROL_MASK_1     (0xf0u) // 8'b1111_0000
#define CONTROL_DRIVE_1A   (0x9u)  // 8'b0000_1001
#define CONTROL_DRIVE_1B   (0x6u)  // 8'b0000_0110  
#define CONTROL_STOP_1     (0x0u)
    
// assignment format: (control_reg_val&CONTROL_MASK_2)|CONTROL_DRIVE_2x
#define CONTROL_MASK_2     (0xfu)  // 8'b0000_1111
#define CONTROL_DRIVE_2A   (0x90u) // 8'b1001_0000
#define CONTROL_DRIVE_2B   (0x60u) // 8'b0110_0000
#define CONTROL_STOP_2     (0x0u)

#define MAX_PWM            (255u)  // results in max speed
#define MIN_PWM            (0u)    // results in min speed
    
    
    
// hbridge 1 controls
void control_drive_1A(const uint8 pwm); // enable upper left and bottom right bjts
void control_drive_1B(const uint8 pwm); // enable upper right and bottom left bjts
void control_stop_1(); // disable all bjts

// hbrdige 2 controls
void control_drive_2A(const uint8 pwm);
void control_drive_2B(const uint8 pwm);
void control_stop_2();

// system-level controls
void control_init(); // must be called in order to use motors
void control_stop();

// Navigation Data Format (byte 0 to byte 4)
// [on/off] [1A/1B] [pwm_1] [2A/2B] [pwm_2]
// each "[]" is a byte. [x/y] is x if the byte is 1, y if 0
void control_update(uint8* navigation);

#endif
/* [] END OF FILE */
