# Makefile para 6502 I2C EPROM Test
# Compila main.c con todas las librerías

# ============================================
# DIRECTORIOS
# ============================================
SRC_DIR = src
LIB_DIR = libs
BUILD_DIR = build
OUTPUT_DIR = output
CONFIG_DIR = config
SCRIPTS_DIR = scripts

# ============================================
# HERRAMIENTAS
# ============================================
CC65 = cc65
CA65 = ca65
LD65 = ld65
CL65 = cl65
PYTHON = py

# ============================================
# CONFIGURACIÓN
# ============================================
CONFIG = $(CONFIG_DIR)/fpga.cfg
PLATAFORMA = D:\cc65\lib\none.lib
CFLAGS = -t none -O --cpu 6502

# ============================================
# LIBRERÍAS
# ============================================
TM1638_DIR = $(LIB_DIR)/tm1638
UART_DIR = $(LIB_DIR)/uart
I2C_DIR = $(LIB_DIR)/i2c
EPROM_DIR = $(LIB_DIR)/eprom24c

TM1638_INC = -I$(TM1638_DIR)/include
INCLUDES = -I$(UART_DIR) -I$(I2C_DIR) -I$(EPROM_DIR) $(TM1638_INC)

# ============================================
# ARCHIVOS OBJETO
# ============================================
MAIN_OBJ = $(BUILD_DIR)/main.o
TM1638_OBJ = $(BUILD_DIR)/tm1638.o
UART_OBJ = $(BUILD_DIR)/uart.o
I2C_OBJ = $(BUILD_DIR)/i2c.o
EPROM_OBJ = $(BUILD_DIR)/eprom24c.o
VECTORS_OBJ = $(BUILD_DIR)/simple_vectors.o

OBJS = $(MAIN_OBJ) $(TM1638_OBJ) $(UART_OBJ) $(I2C_OBJ) $(EPROM_OBJ) $(VECTORS_OBJ)

# ============================================
# TARGET PRINCIPAL
# ============================================
TARGET = $(BUILD_DIR)/main.bin

# Regla por defecto
all: dirs $(TARGET) rom
	@echo ========================================
	@echo COMPILADO EXITOSAMENTE
	@echo ========================================
	@echo VHDL: $(OUTPUT_DIR)/rom.vhd
	@echo ========================================

# Crear directorios
dirs:
	@if not exist "$(BUILD_DIR)" mkdir "$(BUILD_DIR)"
	@if not exist "$(OUTPUT_DIR)" mkdir "$(OUTPUT_DIR)"

# ============================================
# COMPILACIÓN DE OBJETOS
# ============================================

# Main
$(MAIN_OBJ): $(SRC_DIR)/main.c
	$(CL65) -t none $(INCLUDES) -c -o $@ $<

# TM1638
$(TM1638_OBJ): $(TM1638_DIR)/src/tm1638.c
	$(CC65) $(CFLAGS) $(TM1638_INC) -o $(BUILD_DIR)/tm1638.s $<
	$(CA65) -t none -o $@ $(BUILD_DIR)/tm1638.s

# UART
$(UART_OBJ): $(UART_DIR)/uart.c
	$(CC65) $(CFLAGS) -o $(BUILD_DIR)/uart.s $<
	$(CA65) -t none -o $@ $(BUILD_DIR)/uart.s

# I2C
$(I2C_OBJ): $(I2C_DIR)/i2c.c
	$(CC65) $(CFLAGS) -I$(I2C_DIR) -o $(BUILD_DIR)/i2c.s $<
	$(CA65) -t none -o $@ $(BUILD_DIR)/i2c.s

# EPROM
$(EPROM_OBJ): $(EPROM_DIR)/eprom24c.c
	$(CC65) $(CFLAGS) -I$(I2C_DIR) -I$(EPROM_DIR) -o $(BUILD_DIR)/eprom24c.s $<
	$(CA65) -t none -o $@ $(BUILD_DIR)/eprom24c.s

# Vectores
$(VECTORS_OBJ): $(SRC_DIR)/simple_vectors.s
	$(CA65) -t none -o $@ $<

# ============================================
# ENLAZADO
# ============================================
$(TARGET): $(OBJS)
	$(LD65) -C $(CONFIG) --start-addr 0x8000 -o $@ $(OBJS) $(PLATAFORMA)

# ============================================
# GENERACIÓN DE ROM
# ============================================
rom: $(TARGET)
	$(PYTHON) $(SCRIPTS_DIR)/bin2rom3.py $(TARGET) -s 8192 --name rom --data-width 8 -o $(OUTPUT_DIR)

# ============================================
# LIMPIEZA
# ============================================
clean:
	@if exist "$(BUILD_DIR)" rmdir /s /q "$(BUILD_DIR)"
	@if exist "$(OUTPUT_DIR)\*.vhd" del /q "$(OUTPUT_DIR)\*.vhd"
	@if exist "$(OUTPUT_DIR)\*.bin" del /q "$(OUTPUT_DIR)\*.bin"
	@if exist "$(OUTPUT_DIR)\*.hex" del /q "$(OUTPUT_DIR)\*.hex"

# ============================================
# AYUDA
# ============================================
help:
	@echo ========================================
	@echo 6502 I2C EPROM Test - Comandos
	@echo ========================================
	@echo   make        - Compilar y generar ROM
	@echo   make clean  - Limpiar archivos
	@echo   make help   - Mostrar esta ayuda
	@echo ========================================

.PHONY: all dirs rom clean help
