library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;    

-- Módulo para traducir direcciones de vectores 6502 a direcciones físicas de ROM

entity rom_address_mapper is 
    port(   
            cpu_addr_in : in std_logic_vector(15 downto 0);
            rom_addr_out : out std_logic_vector(15 downto 0)
    );
end rom_address_mapper;

architecture arch of rom_address_mapper is
    
    -- Configuración de memoria ROM
    constant ROM_BASE  : unsigned(15 downto 0) := x"8000";  -- Inicio de ROM
    constant ROM_SIZE  : unsigned(15 downto 0) := x"2000";  -- Tamaño ROM (8KB)
    
    signal cpu_addr_unsigned : unsigned(15 downto 0);
    
begin

    cpu_addr_unsigned <= unsigned(cpu_addr_in);

    process(cpu_addr_in)
    begin
        -- Si el CPU lee los vectores $FFFA-$FFFF, mapear a últimos 6 bytes de ROM
        if (cpu_addr_unsigned >= x"FFFA" and cpu_addr_unsigned <= x"FFFF") then
            -- Mapeo: $FFFA -> $9FFA, $FFFB -> $9FFB, etc.
            -- Fórmula: ROM_BASE + ROM_SIZE - (x"10000" - cpu_addr)
            --        = ROM_BASE + ROM_SIZE - 6 + (cpu_addr - x"FFFA")
            rom_addr_out <= std_logic_vector(ROM_BASE + ROM_SIZE - 6 + (cpu_addr_unsigned - x"FFFA"));
        else
            -- Dirección normal, pasa sin cambios
            rom_addr_out <= cpu_addr_in;
        end if;
    end process;

end arch;
