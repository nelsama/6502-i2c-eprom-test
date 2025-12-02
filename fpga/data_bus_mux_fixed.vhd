library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;    

--use work.types.all;


entity data_bus_mux is 
    port(   
            clk: in std_logic;
            r_w: in std_logic;
            addr_in : in std_logic_vector(15 downto 0);

            ram_data_bus_in : in std_logic_vector(7 downto 0);
            rom_data_bus_in : in std_logic_vector(7 downto 0);
            port1_in : in std_logic_vector(7 downto 0);
            port2_in : in std_logic_vector(7 downto 0);

            data_bus_out : out std_logic_vector(7 downto 0)

);
end data_bus_mux;

architecture arch of data_bus_mux is
    
    -- Configuración de memoria ROM (fácil de cambiar)
    constant ROM_BASE  : unsigned(15 downto 0) := x"8000";  -- Inicio de ROM
    constant ROM_SIZE  : unsigned(15 downto 0) := x"2000";  -- Tamaño ROM (8KB = 0x2000)
    constant ROM_END   : unsigned(15 downto 0) := ROM_BASE + ROM_SIZE - 1;  -- Fin de ROM (0x9FFF)
    
    -- Los vectores 6502 están en las últimas 6 bytes de la ROM
    constant VEC_NMI_L   : unsigned(15 downto 0) := ROM_END - 5;  -- 0x9FFA - NMI vector LSB
    constant VEC_NMI_H   : unsigned(15 downto 0) := ROM_END - 4;  -- 0x9FFB - NMI vector MSB
    constant VEC_RESET_L : unsigned(15 downto 0) := ROM_END - 3;  -- 0x9FFC - RESET vector LSB
    constant VEC_RESET_H : unsigned(15 downto 0) := ROM_END - 2;  -- 0x9FFD - RESET vector MSB
    constant VEC_IRQ_L   : unsigned(15 downto 0) := ROM_END - 1;  -- 0x9FFE - IRQ vector LSB
    constant VEC_IRQ_H   : unsigned(15 downto 0) := ROM_END - 0;  -- 0x9FFF - IRQ vector MSB
    
    signal addr_unsigned : unsigned(15 downto 0);
    
begin

    addr_unsigned <= unsigned(addr_in);

    process(clk,r_w,addr_in,ram_data_bus_in,rom_data_bus_in,port1_in,port2_in)
    begin
        if(falling_edge(clk)) then
            if ((addr_unsigned >= x"0000") and (addr_unsigned <= x"3FFF") and r_w='1') then 
                -- RAM: 0x0000 - 0x3FFF
                data_bus_out <= ram_data_bus_in; 
                
            elsif ((addr_unsigned >= ROM_BASE) and (addr_unsigned <= ROM_END) and r_w='1') then 
                -- ROM: 0x8000 - 0x9FFF (dinámico según ROM_BASE y ROM_SIZE)
                data_bus_out <= rom_data_bus_in;  
                
            elsif (addr_in = x"C000" and r_w='1') then 
                -- Puerto 1
                data_bus_out <= port1_in;
                
            elsif (addr_in = x"C001" and r_w='1') then 
                -- Puerto 2
                data_bus_out <= port2_in; 
                
            -- === VECTORES 6502 - Mapeo a fin de ROM física ===
            
            elsif (addr_in = x"FFFA" and r_w='1') then 
                -- NMI Vector LSB -> lee byte en ROM_END-5 (0x9FFA)
                -- Redirigir lectura a la ROM en la dirección VEC_NMI_L
                data_bus_out <= rom_data_bus_in;  
                -- NOTA: Necesitas modificar rom_addr_out para apuntar a VEC_NMI_L
                
            elsif (addr_in = x"FFFB" and r_w='1') then 
                -- NMI Vector MSB -> lee byte en ROM_END-4 (0x9FFB)
                data_bus_out <= rom_data_bus_in;
                
            elsif (addr_in = x"FFFC" and r_w='1') then 
                -- RESET Vector LSB -> lee byte en ROM_END-3 (0x9FFC)
                data_bus_out <= rom_data_bus_in;
                
            elsif (addr_in = x"FFFD" and r_w='1') then 
                -- RESET Vector MSB -> lee byte en ROM_END-2 (0x9FFD)
                data_bus_out <= rom_data_bus_in;
                
            elsif (addr_in = x"FFFE" and r_w='1') then 
                -- IRQ Vector LSB -> lee byte en ROM_END-1 (0x9FFE)
                data_bus_out <= rom_data_bus_in;
                
            elsif (addr_in = x"FFFF" and r_w='1') then 
                -- IRQ Vector MSB -> lee byte en ROM_END (0x9FFF)
                data_bus_out <= rom_data_bus_in;
                
            else
                data_bus_out <= "ZZZZZZZZ";
            end if; 
        end if;
    end process;

end arch;
