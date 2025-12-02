# 6502 I2C EPROM Test

Sistema de test para 6502 en FPGA con comunicación I2C y memoria EEPROM 24C64.

## Características

- ✅ CPU 6502 @ 6.75MHz en FPGA Tang Nano
- ✅ Display TM1638 (7-segmentos + teclado)
- ✅ UART 115200 baud para debug
- ✅ Bus I2C a 100kHz
- ✅ Soporte EEPROM 24Cxx (24C01-24C256)

## Hardware

| Componente | Dirección | Descripción |
|------------|-----------|-------------|
| TM1638 | $C000-$C003 | Display 7-seg + teclado |
| I2C | $C010-$C014 | Bus I2C (OpenCores) |
| UART | $C020-$C023 | Serial 115200 baud |
| EEPROM | I2C 0x50 | 24C64 (8KB) |

## Estructura

```
6502-i2c-eprom-test/
├── src/
│   ├── main.c              # Ejemplo principal
│   └── simple_vectors.s    # Vectores 6502
├── libs/                   # Librerías (repos independientes)
│   ├── tm1638/             # github.com/nelsama/tm1638-6502-cc65
│   ├── uart/               # github.com/nelsama/uart-6502-cc65
│   ├── i2c/                # github.com/nelsama/i2c-6502-cc65
│   └── eprom24c/           # github.com/nelsama/eprom24c-i2c-6502-cc65
├── fpga/                   # Módulos VHDL para FPGA
├── config/
│   └── fpga.cfg            # Configuración del linker cc65
├── scripts/
│   └── bin2rom3.py         # Conversor BIN → VHDL
├── output/                 # ROM generada (ignorado en git)
└── makefile
```

## Instalación

### 1. Clonar el proyecto
```bash
git clone https://github.com/nelsama/6502-i2c-eprom-test.git
cd 6502-i2c-eprom-test
```

### 2. Clonar las librerías
```bash
mkdir -p libs
cd libs
git clone https://github.com/nelsama/tm1638-6502-cc65.git tm1638
git clone https://github.com/nelsama/uart-6502-cc65.git uart
git clone https://github.com/nelsama/i2c-6502-cc65.git i2c
git clone https://github.com/nelsama/eprom24c-i2c-6502-cc65.git eprom24c
cd ..
```

### 3. Compilar
```bash
make
```

### 4. Cargar en FPGA
Copiar `output/rom.vhd` al proyecto FPGA y sintetizar.

## Uso

El programa `main.c` ejecuta tests de todos los componentes:

1. **Display**: Muestra "HELLO" en TM1638
2. **UART**: Envía mensajes de debug a 115200 baud
3. **I2C**: Detecta EEPROM en dirección 0x50
4. **EPROM**: Lee/escribe/verifica un byte

### Salida UART esperada:
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

## Requisitos

- [cc65](https://cc65.github.io/) - Compilador C para 6502
- Python 3 - Para el script bin2rom3.py
- FPGA Tang Nano (o compatible)

## Licencia

MIT
