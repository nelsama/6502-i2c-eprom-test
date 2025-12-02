# Calculadora 6502 TM1638

Calculadora funcional de 8 dígitos para microcontrolador 6502 con display TM1638, implementada en FPGA usando CC65. 

## 🧮 Características de la Calculadora

- ✅ **8 Dígitos**: Capacidad de 0 a 99,999,999
- ✅ **Operaciones Básicas**: Suma (+), Resta (-), Multiplicación (*), División (/)
- ✅ **Operaciones Continuas**: Ejemplo: 5+3+2=10
- ✅ **Manejo de Errores**: "ERROR" para división por cero, "OVERFLOW" para desborde
- ✅ **Interface Completa**: Teclado 4x4 y display 8 dígitos en TM1638
- ✅ **Anti-rebote**: Gestión de rebote de teclas integrada

## Estructura del Proyecto

```text
calculadora-6502-tm1638/
├── src/                    # Código fuente principal
│   ├── calculadora.c       # ⭐ Calculadora principal (9.6KB)
│   └── main_teclado.c      # 🔧 Test de teclado
├── output/                 # 🎯 ROM para FPGA (listo para usar)
│   ├── rom.vhd             # ⭐ Archivo VHDL para síntesis FPGA
│   ├── rom.bin             # ROM binaria
│   └── rom.hex             # Formato Intel HEX
├── config/                 # ⚙️ Configuración
│   └── fpga.cfg            # Configuración del enlazador
├── scripts/                # 🔧 Herramientas
│   └── bin2rom3.py         # Conversor BIN → VHDL
├── makefile                # 🛠️ Sistema de compilación
└── README.md               # 📚 Esta documentación
├── config/                 # Configuraciones
│   └── fpga.cfg            # Configuración del linker
├── scripts/                # Scripts de conversión
│   └── bin2rom3.py         # Conversor binario a ROM
├── tests/                  # Pruebas básicas
│   ├── main_test.c         # Programa de prueba simple
│   └── makefile_test       # Makefile para pruebas
├── makefile                # Makefile principal
└── README.md               # Esta documentación
```

## 📋 Requisitos

### Librería TM1638 Requerida

Esta calculadora requiere la **Librería TM1638 v2.0** para funcionar. Debes descargarla e instalarla por separado:

```bash
# 1. Descargar la librería TM1638
git clone https://github.com/nelsama/tm1638-6502-cc65.git tm1638-lib

# 2. Instalar en el proyecto de la calculadora
cd tm1638-lib
make lib-install DEST_DIR=../calculadora-6502-tm1638/libs/tm1638
```

### Herramientas Necesarias
- **CC65**: Compilador C para 6502
- **Python 3**: Para scripts de conversión VHDL
- **Make**: Sistema de compilación

## Comandos Disponibles

### Compilación Principal
```bash
make            # Compilar proyecto completo
make map        # Compilar con mapa de memoria
make clean      # Limpiar archivos generados
make convert    # Generar archivos ROM para FPGA
```

### Pruebas Básicas
```bash
cd tests
make -f makefile_test       # Compilar prueba básica
make -f makefile_test clean # Limpiar pruebas
```

## Hardware

- **FPGA**: Gowin Tang Nano 9K
- **CPU**: 6502 implementado en FPGA @ 3.375 MHz
- **Memoria ROM**: 8KB (0x8000-0x9FFF)
- **Memoria RAM**: 16KB total (0x0000-0x3FFF) implementada en BRAM de la FPGA
- **Display**: TM1638 (8 dígitos 7-segmentos + LEDs + 16 teclas)
- **Puertos E/S**:
  - `0xC000`: PORT_SALIDA (datos TM1638 - salida)
  - `0xC001`: PORT_ENTRADA (datos TM1638 - entrada/teclado)
  - `0xC002`: CONF_PORT_SALIDA (configuración salida)
  - `0xC003`: CONF_PORT_ENTRADA (configuración entrada)

## 📚 Librería TM1638

### Funciones Principales

```c
// ==================== API SIMPLIFICADA (TODO-EN-UNO) ====================
tm1638_init();                          // Inicialización robusta anti-ghosting
tm1638_set_brightness(4);               // Configurar brillo (0-7, persistente)
tm1638_show_text(" HOLA   ");           // Mostrar texto (8 chars, auto-limpia)
tm1638_show_number(12345);              // Mostrar número (auto-alineado derecha)
tm1638_show_hex(hex_array);             // Mostrar hexadecimal (8 dígitos)
tm1638_clear_display();                 // Limpiar display (mantiene brillo)

// ==================== TECLADO QYF-TM1638 ====================
uint8_t tecla = tm1638_get_key_pressed(); // Leer tecla (1-16, 0=ninguna)
uint8_t todas[16];
uint8_t n = tm1638_get_all_keys_pressed(todas); // Leer múltiples teclas

// ==================== API AVANZADA (MODULAR) ====================
tm1638_encode_ascii8("MENSAJE ", segments);    // Solo codificar texto
tm1638_number_to_segments8(12345, segments);   // Solo convertir número
tm1638_digits_common_anode8(segments, grids);  // Solo convertir a grids
tm1638_display(grids);                         // Solo mostrar (respeta brillo)
```

### 🚀 Ejemplo Básico (¡Súper Fácil!)

```c
void main(void) {
    uint8_t key_pressed, last_key;
    
    /* ==================== CONFIGURACIÓN ==================== */
    CONF_PORT_SALIDA = 0b00000000;        // TM1638 como salida
    
    /* ==================== INICIALIZACIÓN ==================== */
    tm1638_init();                        // ¡Una línea para todo!
    tm1638_set_brightness(4);             // Brillo al 50%
    
    /* ==================== DEMO FUNCIONES ==================== */
    tm1638_show_text(" HOLA   ");         // Texto automático
    tm1638_delay(2000);
    
    tm1638_show_number(12345);            // Número automático
    tm1638_delay(2000);
    
    tm1638_clear_display();               // Limpiar y mantener brillo
    
    /* ==================== TECLADO INTERACTIVO ==================== */
    last_key = 0;
    while(1) {
        key_pressed = tm1638_get_key_pressed();
        
        if (key_pressed > 0 && key_pressed != last_key) {
            tm1638_show_number(key_pressed); // Mostrar tecla presionada
            last_key = key_pressed;
        } else if (key_pressed == 0) {
            last_key = 0;
        }
        
        tm1638_delay(100);                // Anti-rebote integrado
    }
}
```

### 🎯 Características v2.0

| Característica | Estado | Descripción |
|----------------|--------|-------------|
| **Anti-Ghosting** | ✅ COMPLETO | Eliminación total de segmentos fantasma |
| **Brillo Inteligente** | ✅ COMPLETO | Persistente, gestión automática |
| **API Simplificada** | ✅ COMPLETO | Funciones todo-en-uno para principiantes |
| **QYF-TM1638** | ✅ COMPLETO | Mapeo específico del hardware probado |
| **C89 Estricto** | ✅ COMPLETO | Compatible CC65, sin warnings |
| **Modularidad** | ✅ COMPLETO | Funciones separadas para expertos |
| **Documentación** | ✅ COMPLETO | Manual completo con ejemplos |

```

### 📚 Documentación Completa

Ver [MANUAL_TM1638.md](libs/tm1638/MANUAL_TM1638.md) para documentación detallada, ejemplos avanzados y referencia completa de todas las funciones.

```text
docs/
├── MANUAL_TM1638.md           # Manual completo de la librería
├── ANTI_GHOSTING_NOTES.md     # Notas técnicas anti-ghosting
├── libs/tm1638/README.md      # Documentación de la librería
└── scripts/README.md          # Documentación de scripts
```

## 🛠️ Desarrollo

### Agregar Nueva Librería

1. Crear carpeta en `libs/nueva_lib/`
2. Agregar header en `include/`
3. Actualizar Makefile con nuevas rutas
4. Incluir en `src/calculadora.c`

### Flujo de Trabajo

1. Editar código fuente en `src/`
2. Compilar con `make`
3. Generar ROM con `make convert`
4. Cargar `output/rom.vhd` en proyecto FPGA
5. Sintetizar y programar FPGA

## Herramientas Necesarias

- **CC65**: Compilador cruzado para 6502
- **Python**: Para scripts de conversión  
- **Gowin EDA**: IDE oficial para Tang Nano 9K (síntesis y programación)
- **Make**: Para automatización de build

## Especificaciones Técnicas

- **FPGA**: Gowin GW1NR-9C (Tang Nano 9K)
- **Frecuencia de reloj**: 3.375 MHz
- **Arquitectura**: 6502 compatible

### Mapa de Memoria

#### Segmento RAM: 16KB (0x0000-0x3FFF)

- **Reservado**: 2 bytes (0x0000-0x0001) - Sistema
- **Zero Page**: 254 bytes (0x0002-0x00FF) - Acceso rápido  
- **RAM Principal**: 15.25KB (0x0100-0x3DFF) - Memoria de trabajo (OPTIMIZADA)
- **Stack**: 512 bytes (0x3E00-0x3FFF) - Stack del 6502

#### Otros segmentos

- **ROM**: 8KB (0x8000-0x9FFF) - Código del programa
- **E/S**: 4 bytes (0xC000-0xC003) - Puertos del TM1638