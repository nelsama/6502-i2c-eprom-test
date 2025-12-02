# Makefile para proyecto 6502

# Directorios
SRC_DIR = src
LIB_DIR = libs
INC_DIR = include
BUILD_DIR = build
OUTPUT_DIR = output
CONFIG_DIR = config
SCRIPTS_DIR = scripts

# Nombre del programa final
TARGET = $(BUILD_DIR)/main.bin

# Compilador y enlazador
CC65 = cc65
CA65 = ca65
CL65 = cl65
LD65 = ld65
PYTHON = py

# Archivo de configuracion del enlazador
CONFIG = $(CONFIG_DIR)/fpga.cfg

# Archivos fuente - Nueva estructura modular en libs/
MAIN_SRC = $(SRC_DIR)/main.c
TM1638_SRC = $(LIB_DIR)/tm1638/src/tm1638.c
TM1638_INC = -I $(LIB_DIR)/tm1638/include/
TM1638_HEADER = $(LIB_DIR)/tm1638/include/tm1638.h

# Archivos objeto
MAIN_OBJ = $(BUILD_DIR)/main.o
TM1638_OBJ = $(BUILD_DIR)/tm1638.o
OBJ = $(MAIN_OBJ) $(TM1638_OBJ)

# Bibliotecas de la Plataforma objetivo
PLATAFORMA = D:\cc65\lib\none.lib

# Archivos generados
GENERATED = $(OBJ) $(TARGET)
MAPFILE = $(BUILD_DIR)/main.map

# Flags de compilación (incluye el path correcto para TM1638)
CFLAGS = -t none -I$(INC_DIR) $(TM1638_INC)

# Regla por defecto - compila main
all: main

# Targets para test de EPROM
I2C_DIR = $(LIB_DIR)/i2c
EPROM_DIR = $(LIB_DIR)/eprom24c
EPROM_OBJ = $(BUILD_DIR)/eprom24c.o

# Compilar librería EPROM (versión mínima para ahorrar espacio)
$(EPROM_OBJ): $(EPROM_DIR)/eprom24c.c $(EPROM_DIR)/eprom24c.h
	$(CC65) -t none -I$(INC_DIR) $(TM1638_INC) -I$(I2C_DIR) -I$(EPROM_DIR) -O --cpu 6502 -o $(BUILD_DIR)/eprom24c.s $<
	$(CA65) -t none -o $@ $(BUILD_DIR)/eprom24c.s

# Test EPROM nuevo
test-eprom: dirs $(BUILD_DIR)/eprom_test.bin
	@echo ========================================
	@echo ✅ TEST EPROM COMPILADO
	@echo ========================================
	@echo Binario: $(BUILD_DIR)/eprom_test.bin
	@echo.
	@echo Para generar VHDL:
	@echo   make test-eprom-convert
	@echo ========================================

$(BUILD_DIR)/eprom_test.o: $(SRC_DIR)/eprom_test.c $(TM1638_HEADER)
	$(CL65) $(CFLAGS) -I$(I2C_DIR) -I$(EPROM_DIR) -c -o $@ $<

$(BUILD_DIR)/eprom_test.bin: $(BUILD_DIR)/eprom_test.o $(TM1638_OBJ) $(I2C_OBJ) $(I2C_VECTORS_OBJ) $(EPROM_OBJ) $(CONFIG)
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/eprom_test.o $(TM1638_OBJ) $(I2C_OBJ) $(EPROM_OBJ) $(I2C_VECTORS_OBJ) $(PLATAFORMA)

test-eprom-convert: $(BUILD_DIR)/eprom_test.bin
	$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/eprom_test.bin -s 8192 --name rom_eprom_test --data-width 8 -o $(OUTPUT_DIR)
	@echo ========================================
	@echo ✅ VHDL GENERADO: output/rom_eprom_test.vhd
	@echo ========================================

# Test EPROM con librería (versión limpia)
test-eprom-lib: dirs $(BUILD_DIR)/test_eprom_lib.bin
	@echo ========================================
	@echo ✅ TEST EPROM LIB COMPILADO
	@echo ========================================
	@$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/test_eprom_lib.bin -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)
	@echo VHDL: output/rom.vhd
	@echo ========================================

$(BUILD_DIR)/test_eprom_lib.o: $(SRC_DIR)/test_eprom_lib.c $(TM1638_HEADER)
	$(CL65) $(CFLAGS) -I$(UART_DIR) -I$(I2C_DIR) -I$(EPROM_DIR) -c -o $@ $<

$(BUILD_DIR)/test_eprom_lib.bin: $(BUILD_DIR)/test_eprom_lib.o $(TM1638_OBJ) $(UART_OBJ) $(I2C_OBJ) $(EPROM_OBJ) $(I2C_VECTORS_OBJ) $(CONFIG)
	$(CC65) -t none -I$(INC_DIR) $(TM1638_INC) -I$(I2C_DIR) -I$(EPROM_DIR) -O --cpu 6502 -o $(BUILD_DIR)/eprom24c.s $(EPROM_DIR)/eprom24c.c
	$(CA65) -t none -o $(EPROM_OBJ) $(BUILD_DIR)/eprom24c.s
	$(CC65) $(CFLAGS) -I$(LIB_DIR)/i2c -O --cpu 6502 -o $(BUILD_DIR)/i2c.s $(LIB_DIR)/i2c/i2c.c
	$(CA65) -t none -o $(I2C_OBJ) $(BUILD_DIR)/i2c.s
	$(CA65) -t none -o $(I2C_VECTORS_OBJ) $(LIB_DIR)/i2c/i2c_vectors.s
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/test_eprom_lib.o $(TM1638_OBJ) $(UART_OBJ) $(I2C_OBJ) $(EPROM_OBJ) $(I2C_VECTORS_OBJ) $(PLATAFORMA)

# Test EPROM con debug por UART (versión con mucho debug)
test-eprom-uart: dirs $(BUILD_DIR)/test_eprom_uart.bin
	@echo ========================================
	@echo ✅ TEST EPROM UART COMPILADO
	@echo ========================================
	@$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/test_eprom_uart.bin -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)
	@echo VHDL: output/rom.vhd
	@echo ========================================

$(BUILD_DIR)/test_eprom_uart.o: $(SRC_DIR)/test_eprom_uart.c $(TM1638_HEADER)
	$(CL65) $(CFLAGS) -I$(UART_DIR) -I$(I2C_DIR) -I$(EPROM_DIR) -c -o $@ $<

$(BUILD_DIR)/test_eprom_uart.bin: $(BUILD_DIR)/test_eprom_uart.o $(TM1638_OBJ) $(UART_OBJ) $(I2C_OBJ) $(EPROM_OBJ) $(I2C_VECTORS_OBJ) $(CONFIG)
	$(CC65) -t none -I$(INC_DIR) $(TM1638_INC) -I$(I2C_DIR) -I$(EPROM_DIR) -O --cpu 6502 -o $(BUILD_DIR)/eprom24c.s $(EPROM_DIR)/eprom24c.c
	$(CA65) -t none -o $(EPROM_OBJ) $(BUILD_DIR)/eprom24c.s
	$(CC65) $(CFLAGS) -I$(LIB_DIR)/i2c -O --cpu 6502 -o $(BUILD_DIR)/i2c.s $(LIB_DIR)/i2c/i2c.c
	$(CA65) -t none -o $(I2C_OBJ) $(BUILD_DIR)/i2c.s
	$(CA65) -t none -o $(I2C_VECTORS_OBJ) $(LIB_DIR)/i2c/i2c_vectors.s
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/test_eprom_uart.o $(TM1638_OBJ) $(UART_OBJ) $(I2C_OBJ) $(EPROM_OBJ) $(I2C_VECTORS_OBJ) $(PLATAFORMA)

# Test EPROM directo (sin librerías I2C/EPROM)
test-eprom-direct: dirs $(BUILD_DIR)/test_eprom_direct.bin
	@echo ========================================
	@echo ✅ TEST EPROM DIRECTO COMPILADO
	@echo ========================================
	@$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/test_eprom_direct.bin -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)
	@echo VHDL: output/rom.vhd
	@echo ========================================

$(BUILD_DIR)/test_eprom_direct.o: $(SRC_DIR)/test_eprom_direct.c $(TM1638_HEADER)
	$(CL65) $(CFLAGS) -I$(UART_DIR) -c -o $@ $<

$(BUILD_DIR)/simple_vectors.o: $(SRC_DIR)/simple_vectors.s
	$(CA65) -t none -o $@ $<

$(BUILD_DIR)/test_eprom_direct.bin: $(BUILD_DIR)/test_eprom_direct.o $(TM1638_OBJ) $(UART_OBJ) $(BUILD_DIR)/simple_vectors.o $(CONFIG)
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/test_eprom_direct.o $(TM1638_OBJ) $(UART_OBJ) $(BUILD_DIR)/simple_vectors.o $(PLATAFORMA)

# Test EPROM simple (solo UART, sin TM1638)
test-eprom-simple: dirs $(BUILD_DIR)/test_eprom_simple.bin
	@echo ========================================
	@echo ✅ TEST EPROM SIMPLE COMPILADO
	@echo ========================================
	@$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/test_eprom_simple.bin -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)
	@echo VHDL: output/rom.vhd
	@echo ========================================

$(BUILD_DIR)/test_eprom_simple.o: $(SRC_DIR)/test_eprom_simple.c
	$(CL65) $(CFLAGS) -I$(UART_DIR) -I$(I2C_DIR) -c -o $@ $<

$(BUILD_DIR)/test_eprom_simple.bin: $(BUILD_DIR)/test_eprom_simple.o $(BUILD_DIR)/simple_vectors.o $(CONFIG)
	$(CC65) $(CFLAGS) -O --cpu 6502 -o $(BUILD_DIR)/uart.s $(UART_DIR)/uart.c
	$(CA65) -t none -o $(UART_OBJ) $(BUILD_DIR)/uart.s
	$(CC65) $(CFLAGS) -I$(I2C_DIR) -O --cpu 6502 -o $(BUILD_DIR)/i2c.s $(I2C_DIR)/i2c.c
	$(CA65) -t none -o $(I2C_OBJ) $(BUILD_DIR)/i2c.s
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/test_eprom_simple.o $(UART_OBJ) $(I2C_OBJ) $(BUILD_DIR)/simple_vectors.o $(PLATAFORMA)

# ============================================
# MAIN - Ejemplo principal con todas las librerías
# ============================================
main: dirs $(BUILD_DIR)/main.bin
	@echo ========================================
	@echo ✅ MAIN COMPILADO
	@echo ========================================
	@$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/main.bin -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)
	@echo VHDL: output/rom.vhd
	@echo ========================================

$(BUILD_DIR)/main.o: $(SRC_DIR)/main.c $(TM1638_HEADER)
	$(CL65) $(CFLAGS) -I$(UART_DIR) -I$(I2C_DIR) -I$(EPROM_DIR) -c -o $@ $<

$(BUILD_DIR)/main.bin: $(BUILD_DIR)/main.o $(BUILD_DIR)/simple_vectors.o $(CONFIG)
	$(CC65) $(CFLAGS) -O --cpu 6502 -o $(BUILD_DIR)/uart.s $(UART_DIR)/uart.c
	$(CA65) -t none -o $(UART_OBJ) $(BUILD_DIR)/uart.s
	$(CC65) $(CFLAGS) -I$(I2C_DIR) -O --cpu 6502 -o $(BUILD_DIR)/i2c.s $(I2C_DIR)/i2c.c
	$(CA65) -t none -o $(I2C_OBJ) $(BUILD_DIR)/i2c.s
	$(CC65) -t none -I$(INC_DIR) $(TM1638_INC) -I$(I2C_DIR) -I$(EPROM_DIR) -O --cpu 6502 -o $(BUILD_DIR)/eprom24c.s $(EPROM_DIR)/eprom24c.c
	$(CA65) -t none -o $(EPROM_OBJ) $(BUILD_DIR)/eprom24c.s
	$(CC65) $(CFLAGS) -O --cpu 6502 -o $(BUILD_DIR)/tm1638.s $(TM1638_SRC)
	$(CA65) -t none -o $(TM1638_OBJ) $(BUILD_DIR)/tm1638.s
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/main.o $(TM1638_OBJ) $(UART_OBJ) $(I2C_OBJ) $(EPROM_OBJ) $(BUILD_DIR)/simple_vectors.o $(PLATAFORMA)

# Test directo de registros I2C
test-i2c-regs: dirs $(BUILD_DIR)/test_i2c_regs.bin
	@echo ========================================
	@echo ✅ TEST I2C REGISTROS COMPILADO
	@echo ========================================
	@$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/test_i2c_regs.bin -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)
	@echo VHDL: output/rom.vhd
	@echo ========================================

$(BUILD_DIR)/test_i2c_regs.o: $(SRC_DIR)/test_i2c_regs.c $(TM1638_HEADER)
	$(CL65) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/test_i2c_regs.bin: $(BUILD_DIR)/test_i2c_regs.o $(TM1638_OBJ) $(CONFIG)
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/test_i2c_regs.o $(TM1638_OBJ) $(PLATAFORMA)

# I2C Scanner - Escanea el bus I2C
i2c-scanner: dirs $(BUILD_DIR)/i2c_scanner.bin
	@echo ========================================
	@echo ✅ I2C SCANNER COMPILADO
	@echo ========================================
	@$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/i2c_scanner.bin -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)
	@echo VHDL: output/rom.vhd
	@echo ========================================

$(BUILD_DIR)/i2c_scanner.o: $(SRC_DIR)/i2c_scanner.c $(TM1638_HEADER)
	$(CL65) $(CFLAGS) -I$(I2C_DIR) -c -o $@ $<

$(BUILD_DIR)/i2c_scanner.bin: $(BUILD_DIR)/i2c_scanner.o $(TM1638_OBJ) $(I2C_OBJ) $(I2C_VECTORS_OBJ) $(CONFIG)
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/i2c_scanner.o $(TM1638_OBJ) $(I2C_OBJ) $(I2C_VECTORS_OBJ) $(PLATAFORMA)

# ============================================
# UART
# ============================================
UART_DIR = $(LIB_DIR)/uart
UART_OBJ = $(BUILD_DIR)/uart.o

$(UART_OBJ): $(UART_DIR)/uart.c $(UART_DIR)/uart.h
	$(CC65) -t none -I$(INC_DIR) $(TM1638_INC) -I$(UART_DIR) -O --cpu 6502 -o $(BUILD_DIR)/uart.s $<
	$(CA65) -t none -o $@ $(BUILD_DIR)/uart.s

# Test UART simple
test-uart: dirs $(BUILD_DIR)/test_uart.bin
	@echo ========================================
	@echo ✅ TEST UART COMPILADO
	@echo ========================================
	@$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/test_uart.bin -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)
	@echo VHDL: output/rom.vhd
	@echo ========================================

$(BUILD_DIR)/test_uart.o: $(SRC_DIR)/test_uart.c $(TM1638_HEADER) $(UART_DIR)/uart.h
	$(CL65) $(CFLAGS) -I$(UART_DIR) -c -o $@ $<

$(BUILD_DIR)/test_uart.bin: $(BUILD_DIR)/test_uart.o $(TM1638_OBJ) $(UART_OBJ) $(BUILD_DIR)/simple_vectors.o $(CONFIG)
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/test_uart.o $(TM1638_OBJ) $(UART_OBJ) $(BUILD_DIR)/simple_vectors.o $(PLATAFORMA)

# Test I2C con debug por UART
test-i2c-debug: dirs $(BUILD_DIR)/test_i2c_debug.bin
	@echo ========================================
	@echo ✅ TEST I2C DEBUG COMPILADO
	@echo ========================================
	@$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/test_i2c_debug.bin -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)
	@echo VHDL: output/rom.vhd
	@echo ========================================

$(BUILD_DIR)/test_i2c_debug.o: $(SRC_DIR)/test_i2c_debug.c $(TM1638_HEADER) $(UART_DIR)/uart.h $(I2C_DIR)/i2c.h
	$(CL65) $(CFLAGS) -I$(UART_DIR) -I$(I2C_DIR) -c -o $@ $<

$(BUILD_DIR)/test_i2c_debug.bin: $(BUILD_DIR)/test_i2c_debug.o $(TM1638_OBJ) $(UART_OBJ) $(I2C_OBJ) $(I2C_VECTORS_OBJ) $(CONFIG)
	$(CC65) $(CFLAGS) -I$(LIB_DIR)/i2c -O --cpu 6502 -o $(BUILD_DIR)/i2c.s $(LIB_DIR)/i2c/i2c.c
	$(CA65) -t none -o $(I2C_OBJ) $(BUILD_DIR)/i2c.s
	$(CA65) -t none -o $(I2C_VECTORS_OBJ) $(LIB_DIR)/i2c/i2c_vectors.s
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/test_i2c_debug.o $(TM1638_OBJ) $(UART_OBJ) $(I2C_OBJ) $(I2C_VECTORS_OBJ) $(PLATAFORMA)

# Test simple de TM1638 (sin I2C ni EPROM)
test-display: dirs $(BUILD_DIR)/test_tm1638_simple.bin
	@echo ========================================
	@echo ✅ TEST DISPLAY COMPILADO
	@echo ========================================
	@echo Binario: $(BUILD_DIR)/test_tm1638_simple.bin
	@echo.
	@echo Para generar VHDL:
	@echo   make test-display-convert
	@echo ========================================

$(BUILD_DIR)/test_tm1638_simple.bin: $(SRC_DIR)/test_tm1638_simple.c $(TM1638_SRC)
	@echo Compilando test display simple...
	$(CC65) $(CFLAGS) -O --cpu 6502 -o $(BUILD_DIR)/test_tm1638_simple.s $(SRC_DIR)/test_tm1638_simple.c
	$(CC65) $(CFLAGS) -O --cpu 6502 -o $(BUILD_DIR)/tm1638_simple.s $(TM1638_SRC)
	$(CA65) -t none -o $(BUILD_DIR)/test_tm1638_simple.o $(BUILD_DIR)/test_tm1638_simple.s
	$(CA65) -t none -o $(BUILD_DIR)/tm1638_simple.o $(BUILD_DIR)/tm1638_simple.s
	$(LD65) -C $(CONFIG) -o $@ $(BUILD_DIR)/test_tm1638_simple.o $(BUILD_DIR)/tm1638_simple.o $(PLATAFORMA)

test-display-convert: $(BUILD_DIR)/test_tm1638_simple.bin
	$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/test_tm1638_simple.bin -s 8192 --name rom_test_display --data-width 8 -o $(OUTPUT_DIR)
	@echo ========================================
	@echo ✅ VHDL GENERADO: output/rom_test_display.vhd
	@echo ========================================

# Crear directorios si no existen
dirs:
	@if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"
	@if not exist "$(OUTPUT_DIR)" mkdir "$(OUTPUT_DIR)"

# Regla para crear el programa final (enlazado CON I2C)
I2C_VECTORS_OBJ = $(BUILD_DIR)/i2c_vectors.o
I2C_OBJ = $(BUILD_DIR)/i2c.o

$(I2C_VECTORS_OBJ): $(LIB_DIR)/i2c/i2c_vectors.s
	$(CA65) -t none -o $@ $<

# Usar versión POLLING (sin interrupciones) para debug
$(I2C_OBJ): $(LIB_DIR)/i2c/i2c.c $(LIB_DIR)/i2c/i2c.h
	$(CC65) $(CFLAGS) -I$(LIB_DIR)/i2c -O --cpu 6502 -o $(BUILD_DIR)/i2c.s $<
	$(CA65) -t none -o $@ $(BUILD_DIR)/i2c.s

# Regla para crear el programa con mapa de memoria
map: dirs $(OBJ) $(CONFIG)
	$(LD65) -C $(CONFIG) -m $(MAPFILE) -o $(TARGET) $(OBJ) $(PLATAFORMA)
	@echo "Mapa de memoria generado: $(MAPFILE)"

# Reglas específicas para compilar cada archivo fuente
$(TM1638_OBJ): $(TM1638_SRC) $(TM1638_HEADER)
	$(CL65) $(CFLAGS) -c -o $@ $<

# Test HELLO - compilado EXACTAMENTE como calculadora
test-hello: dirs $(BUILD_DIR)/test_hello.bin
	@echo ========================================
	@echo ✅ TEST HELLO COMPILADO
	@echo ========================================
	@echo Binario: $(BUILD_DIR)/test_hello.bin
	@echo.
	@echo Para generar VHDL:
	@echo   make test-hello-convert
	@echo ========================================

$(BUILD_DIR)/test_hello.o: $(SRC_DIR)/test_hello.c $(TM1638_HEADER)
	$(CL65) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/simple_vectors.o: $(SRC_DIR)/simple_vectors.s
	$(CA65) -t none -o $@ $<

$(BUILD_DIR)/test_hello.bin: $(BUILD_DIR)/test_hello.o $(TM1638_OBJ) $(BUILD_DIR)/simple_vectors.o $(CONFIG)
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(BUILD_DIR)/test_hello.o $(TM1638_OBJ) $(BUILD_DIR)/simple_vectors.o $(PLATAFORMA)

test-hello-convert: $(BUILD_DIR)/test_hello.bin
	$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/test_hello.bin -s 8192 --name rom_test_hello --data-width 8 -o $(OUTPUT_DIR)
	@echo ========================================
	@echo ✅ VHDL GENERADO: output/rom_test_hello.vhd
	@echo ========================================

# Regla para limpiar los archivos generados
clean:
	@if exist "$(BUILD_DIR)" rmdir /s /q "$(BUILD_DIR)"
	@if exist "$(OUTPUT_DIR)\*.bin" del /q "$(OUTPUT_DIR)\*.bin"
	@if exist "$(OUTPUT_DIR)\*.hex" del /q "$(OUTPUT_DIR)\*.hex"
	@if exist "$(OUTPUT_DIR)\*.vhd" del /q "$(OUTPUT_DIR)\*.vhd"

convert: $(TARGET)
	$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(TARGET) -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)

# Makefile limpio - Solo librería C funcional

# Información sobre las librerías del proyecto
info-lib:
	@echo ============================================================================
	@echo LIBRERIAS DEL PROYECTO - INFORMACION
	@echo ============================================================================
	@if exist "$(LIB_DIR)\tm1638" (echo ✅ LIBRERIA TM1638 DISPONIBLE) else (echo ❌ Librería TM1638 no encontrada)
	@echo.
	@echo ESTRUCTURA ACTUAL:
	@echo   Archivo TM1638: $(TM1638_SRC)
	@echo   Include path: $(TM1638_INC)
	@echo   Header: $(TM1638_HEADER)
	@echo.
	@echo LIBRERIAS DISPONIBLES:
	@if exist "$(LIB_DIR)\tm1638" (echo   - TM1638: Display 7-segmentos + Teclado)
	@echo.
	@echo COMANDOS DE LIBRERIA:
	@echo   make lib-tm1638    - Compilar solo librería TM1638
	@echo   make lib-package   - Crear paquete distribuible TM1638
	@echo ============================================================================

# Compilar solo la librería TM1638
lib-tm1638:
	@if exist "$(LIB_DIR)\tm1638" (cd "$(LIB_DIR)\tm1638" && $(MAKE) all) else (echo Error: Librería TM1638 no encontrada)

# Crear paquete distribuible de TM1638
lib-package:
	@if exist "$(LIB_DIR)\tm1638" (cd "$(LIB_DIR)\tm1638" && $(MAKE) package) else (echo Error: Librería TM1638 no encontrada)

# Instalar TM1638 en otro proyecto
lib-install:
	@if not defined DEST_DIR (echo "Error: Usar 'make lib-install DEST_DIR=ruta_proyecto'" && exit /b 1)
	@if exist "$(LIB_DIR)\tm1638" (cd "$(LIB_DIR)\tm1638" && $(MAKE) install DEST_DIR=$(DEST_DIR)) else (echo Error: Librería TM1638 no encontrada)

# Compilar calculadora independiente
calculadora: dirs
	$(CL65) -t none -I$(INC_DIR) $(TM1638_INC) -C $(CONFIG) --start-addr 0x8000 -o $(BUILD_DIR)/calculadora.bin $(SRC_DIR)/calculadora.c $(TM1638_SRC) $(SRC_DIR)/vectors.s $(PLATAFORMA)

# Compilar calculadora y generar VHDL
calculadora-convert: calculadora
	$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(BUILD_DIR)/calculadora.bin -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)

# Mostrar ayuda
help:
	@echo ========================================================================
	@echo PROYECTO 6502 - COMANDOS DISPONIBLES
	@echo ========================================================================
	@echo.
	@echo COMPILACION BASICA:
	@echo   make all                - Compilar proyecto principal (main.c)
	@echo   make clean              - Limpiar archivos generados
	@echo   make map                - Compilar con mapa de memoria
	@echo.
	@echo TEST EPROM:
	@echo   make test-eprom         - Compilar test de EPROM con display
	@echo   make test-eprom-convert - Generar VHDL del test EPROM
	@echo.
	@echo CONVERSION A VHDL:
	@echo   make convert            - Convertir programa principal a VHDL
	@echo.
	@echo LIBRERIAS:
	@echo   make info-lib      - Información sobre librerías TM1638
	@echo   make lib-tm1638    - Compilar solo librería TM1638
	@echo   make lib-package   - Crear paquete distribuible TM1638
	@echo   make lib-install DEST_DIR=ruta - Instalar TM1638 en otro proyecto
	@echo.
	@echo ARCHIVOS GENERADOS:
	@echo   output/rom.vhd              - VHDL programa principal
	@echo.
	@echo ========================================================================
