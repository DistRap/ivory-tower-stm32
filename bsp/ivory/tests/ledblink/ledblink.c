/* This file has been autogenerated by Ivory
 * Compiler version  0.1.0.0
 */
#include <FreeRTOS.h>
#include "ledblink.h"
void main()
{
    xTaskCreate(main_task, "main_task", 1000U, NULL, 0U, NULL);
    vTaskStartScheduler();
    for (int forever_loop = 0; FOREVER; FOREVER_INC) { }
}
void main_task(uint8_t* n_var0)
{
    uint32_t n_r0 = ivory_hw_io_read_u32(1073887280U);
    
    ivory_hw_io_write_u32(1073887280U, n_r0 | 1U << 1U);
    
    uint32_t n_r1 = ivory_hw_io_read_u32(1073873924U);
    
    ivory_hw_io_write_u32(1073873924U, n_r1 & ~((1U << 1U) - 1U << 14U) | 0U <<
                          14U);
    
    uint32_t n_r2 = ivory_hw_io_read_u32(1073873928U);
    
    ivory_hw_io_write_u32(1073873928U, n_r2 & ~((1U << 2U) - 1U << 28U) | 0U <<
                          28U);
    
    uint32_t n_r3 = ivory_hw_io_read_u32(1073873932U);
    
    ivory_hw_io_write_u32(1073873932U, n_r3 & ~((1U << 2U) - 1U << 28U) | 0U <<
                          28U);
    
    uint32_t n_r4 = ivory_hw_io_read_u32(1073873920U);
    
    ivory_hw_io_write_u32(1073873920U, n_r4 & ~((1U << 2U) - 1U << 28U) | 3U <<
                          28U);
    
    uint32_t n_r5 = ivory_hw_io_read_u32(1073887280U);
    
    ivory_hw_io_write_u32(1073887280U, n_r5 | 1U << 1U);
    
    uint32_t n_r6 = ivory_hw_io_read_u32(1073873924U);
    
    ivory_hw_io_write_u32(1073873924U, n_r6 & ~((1U << 1U) - 1U << 15U) | 0U <<
                          15U);
    
    uint32_t n_r7 = ivory_hw_io_read_u32(1073873928U);
    
    ivory_hw_io_write_u32(1073873928U, n_r7 & ~((1U << 2U) - 1U << 30U) | 0U <<
                          30U);
    
    uint32_t n_r8 = ivory_hw_io_read_u32(1073873932U);
    
    ivory_hw_io_write_u32(1073873932U, n_r8 & ~((1U << 2U) - 1U << 30U) | 0U <<
                          30U);
    
    uint32_t n_r9 = ivory_hw_io_read_u32(1073873920U);
    
    ivory_hw_io_write_u32(1073873920U, n_r9 & ~((1U << 2U) - 1U << 30U) | 3U <<
                          30U);
    for (int forever_loop = 0; FOREVER; FOREVER_INC) {
        vTaskDelay(250U);
        
        uint32_t n_r10 = ivory_hw_io_read_u32(1073873944U);
        
        ivory_hw_io_write_u32(1073873944U, n_r10 | 1U << 30U);
        
        uint32_t n_r11 = ivory_hw_io_read_u32(1073873920U);
        
        ivory_hw_io_write_u32(1073873920U, n_r11 & ~((1U << 2U) - 1U << 28U) |
                              1U << 28U);
        
        uint32_t n_r12 = ivory_hw_io_read_u32(1073873920U);
        
        ivory_hw_io_write_u32(1073873920U, n_r12 & ~((1U << 2U) - 1U << 30U) |
                              3U << 30U);
        vTaskDelay(250U);
        
        uint32_t n_r13 = ivory_hw_io_read_u32(1073873920U);
        
        ivory_hw_io_write_u32(1073873920U, n_r13 & ~((1U << 2U) - 1U << 28U) |
                              3U << 28U);
        
        uint32_t n_r14 = ivory_hw_io_read_u32(1073873944U);
        
        ivory_hw_io_write_u32(1073873944U, n_r14 | 1U << 31U);
        
        uint32_t n_r15 = ivory_hw_io_read_u32(1073873920U);
        
        ivory_hw_io_write_u32(1073873920U, n_r15 & ~((1U << 2U) - 1U << 30U) |
                              1U << 30U);
    }
}
