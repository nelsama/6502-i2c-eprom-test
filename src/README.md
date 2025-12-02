# Código Fuente - 6502 System

## Archivos

| Archivo | Descripción |
|---------|-------------|
| `main.c` | **Ejemplo principal** - Demuestra todas las librerías |
| `simple_vectors.s` | Vectores de interrupción para 6502 |

## main.c - Ejemplo Principal

Programa de demostración que usa todas las librerías del sistema:

- **TM1638**: Display 7-segmentos y teclado
- **UART**: Comunicación serial (115200 baud)
- **I2C**: Bus de comunicación
- **EPROM 24C64**: Memoria EEPROM externa

### Funcionalidad

1. Ejecuta tests de cada componente
2. Muestra resultados en UART y display
3. Modo interactivo: lee teclas y las guarda en EPROM

### Compilación

```bash
make main
```

### Salida esperada (UART 115200 baud)

```
================================
   6502 System Test
   All Libraries Demo
================================

1.Display: OK
2.UART: OK
3.I2C 0x50: OK
4.EPROM:
  Read: 0xXX
  Write 0xAB: OK
  Wait: OK
  Verify: 0xAB OK

*** ALL TESTS PASSED ***

Press keys on TM1638...
```

## Hardware Requerido

- 6502 CPU @ 6.75MHz en FPGA Tang Nano
- TM1638 en $C000-$C003
- I2C en $C010-$C014
- UART en $C020-$C023
- EEPROM 24C64 en dirección I2C 0x50
