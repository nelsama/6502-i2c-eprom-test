/**
 * main.c - Ejemplo principal usando todas las librerías
 * 
 * Demuestra el uso de:
 *   - TM1638: Display 7-segmentos y teclado
 *   - UART: Comunicación serial (115200 baud)
 *   - I2C: Bus de comunicación
 *   - EPROM 24C64: Memoria EEPROM externa
 * 
 * Hardware:
 *   - 6502 CPU @ 6.75MHz en FPGA Tang Nano
 *   - TM1638 en $C000-$C003
 *   - I2C en $C010-$C014
 *   - UART en $C020-$C023
 *   - EEPROM 24C64 en dirección I2C 0x50
 * 
 * Compilar: make main
 */

#include <stdint.h>
#include "../libs/uart/uart.h"
#include "../libs/i2c/i2c.h"
#include "../libs/eprom24c/eprom24c.h"
#include "../libs/tm1638/include/tm1638.h"

/* ============================================================================
 * FUNCIONES DE UTILIDAD
 * ============================================================================ */

/**
 * Imprimir valor hexadecimal por UART
 */
void uart_hex(uint8_t val) {
    static const char hex[] = "0123456789ABCDEF";
    uart_putc(hex[val >> 4]);
    uart_putc(hex[val & 0x0F]);
}

/**
 * Pequeño delay
 */
void delay(uint16_t count) {
    volatile uint16_t i;
    for (i = 0; i < count; i++) {
        /* espera */
    }
}

/* ============================================================================
 * TESTS INDIVIDUALES
 * ============================================================================ */

/**
 * Test 1: Display TM1638
 * Muestra "HELLO" en el display
 */
uint8_t test_display(void) {
    uart_puts("1.Display: ");
    
    tm1638_init();
    tm1638_show_text("HELLO   ");
    
    uart_puts("OK\r\n");
    return 1;
}

/**
 * Test 2: UART echo
 * Verifica que UART funciona (ya lo usamos para debug)
 */
uint8_t test_uart(void) {
    uart_puts("2.UART: OK\r\n");
    return 1;
}

/**
 * Test 3: I2C scan - busca EEPROM en 0x50
 */
uint8_t test_i2c(void) {
    uint8_t found = 0;
    
    uart_puts("3.I2C 0x50: ");
    
    i2c_init();
    
    if (i2c_start(0x50, 0)) {  /* I2C_WRITE = 0 */
        i2c_stop();
        uart_puts("OK\r\n");
        found = 1;
    } else {
        uart_puts("FAIL\r\n");
    }
    
    return found;
}

/**
 * Test 4: EPROM read/write/verify
 */
uint8_t test_eprom(void) {
    uint8_t data;
    uint8_t result;
    uint8_t test_value = 0xAB;
    uint16_t test_addr = 0x0100;
    
    uart_puts("4.EPROM:\r\n");
    
    eprom_init(EPROM_24C64, 0x50);
    
    /* Leer valor actual */
    uart_puts("  Read: ");
    result = eprom_read_byte(test_addr, &data);
    if (result != 0) {
        uart_puts("ERR\r\n");
        return 0;
    }
    uart_puts("0x");
    uart_hex(data);
    uart_puts("\r\n");
    
    /* Escribir valor de prueba */
    uart_puts("  Write 0x");
    uart_hex(test_value);
    uart_puts(": ");
    
    result = eprom_write_byte(test_addr, test_value);
    if (result != 0) {
        uart_puts("ERR\r\n");
        return 0;
    }
    uart_puts("OK\r\n");
    
    /* Esperar escritura */
    uart_puts("  Wait: ");
    eprom_wait_ready();
    uart_puts("OK\r\n");
    
    /* Verificar */
    uart_puts("  Verify: ");
    result = eprom_read_byte(test_addr, &data);
    if (result != 0 || data != test_value) {
        uart_puts("FAIL\r\n");
        return 0;
    }
    uart_puts("0x");
    uart_hex(data);
    uart_puts(" OK\r\n");
    
    return 1;
}

/**
 * Test 5: Mostrar resultado en display
 */
void show_result(uint8_t success) {
    if (success) {
        tm1638_show_text("PASS    ");
    } else {
        tm1638_show_text("FAIL    ");
    }
}

/* ============================================================================
 * PROGRAMA PRINCIPAL
 * ============================================================================ */

int main(void) {
    uint8_t all_ok = 1;
    uint8_t key;
    uint8_t counter = 0;
    
    /* Inicializar UART primero (para debug) */
    uart_init();
    
    uart_puts("\r\n");
    uart_puts("================================\r\n");
    uart_puts("   6502 System Test\r\n");
    uart_puts("   All Libraries Demo\r\n");
    uart_puts("================================\r\n\r\n");
    
    /* Ejecutar tests */
    if (!test_display()) all_ok = 0;
    if (!test_uart()) all_ok = 0;
    if (!test_i2c()) all_ok = 0;
    if (!test_eprom()) all_ok = 0;
    
    /* Resultado final */
    uart_puts("\r\n");
    if (all_ok) {
        uart_puts("*** ALL TESTS PASSED ***\r\n");
        show_result(1);
    } else {
        uart_puts("*** SOME TESTS FAILED ***\r\n");
        show_result(0);
    }
    
    /* Demo interactivo: leer teclas y mostrar en display */
    uart_puts("\r\nPress keys on TM1638...\r\n");
    
    delay(30000);
    tm1638_show_text("KEYS    ");
    
    while (1) {
        key = tm1638_get_key_pressed();
        
        if (key != 0xFF) {
            /* Mostrar tecla en UART */
            uart_puts("Key: ");
            uart_hex(key);
            uart_puts("\r\n");
            
            /* Mostrar en display */
            tm1638_show_number((uint32_t)key);
            
            /* Guardar en EPROM */
            eprom_write_byte(0x0000, key);
            eprom_wait_ready();
            
            /* Esperar que suelte la tecla */
            while (tm1638_get_key_pressed() != 0xFF);
        }
        
        /* Contador visual cada cierto tiempo */
        counter++;
        if (counter == 0) {
            uart_putc('.');
        }
    }
    
    return 0;
}
