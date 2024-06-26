
#include "freertos_time_wrapper.h"

#include "FreeRTOS.h"
#include "task.h"

void ivory_freertos_time_delay(uint32_t ticks)
{   vTaskDelay(ticks);
}

void ivory_freertos_time_delayuntil(uint32_t *lastwaketicks, uint32_t ticks)
{
    vTaskDelayUntil(lastwaketicks, ticks);
}

uint32_t ivory_freertos_time_gettickcount(void) {
    return xTaskGetTickCount();
}

uint32_t ivory_freertos_time_gettickrate_ms(void)
{
  return portTICK_PERIOD_MS;
}

