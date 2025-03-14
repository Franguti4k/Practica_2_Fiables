library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divisor_3 is
    port(
        clk         : in  std_logic;
        ena         : in  std_logic;  -- reset asíncrono (activo en '0')
        f_div_2_5   : out std_logic;  -- salida de 2.5MHz (10MHz/4)
        f_div_1_25  : out std_logic;  -- salida de 1.25MHz (10MHz/8)
        f_div_500   : out std_logic   -- salida de 500KHz (10MHz/20)
    );
end entity divisor_3;

architecture Behavioral of divisor_3 is
     -- Contador de módulo 4
     signal count4 : unsigned(5 downto 0) := (others => '0');
     -- Contador de módulo 2 (para dividir la señal de 2.5MHz a 1.25MHz)
     signal count2 : unsigned(0 downto 0) := (others => '0');
     -- Contador de módulo 5 (para dividir la señal de 2.5MHz a 500KHz)
     signal count5 : unsigned(2 downto 0) := (others => '0');

     signal pulso_25 : std_logic := '0';
     signal pulso_125 : std_logic := '0';  
     signal pulso_500 : std_logic := '0';
begin
     -- Proceso del contador de módulo 4
     process(clk, ena)
     begin 
         if ena = '0' then
             count4 <= (others => '0');
             pulso_125 <= '1';
         elsif rising_edge(clk) then 
             count4 <= count4 + 1;
             if count4 = "000011" then
                 count4 <= (others => '0');
                 pulso_125 <= '1';
             else
                 pulso_125 <= '0';
             end if;
         end if;
     end process;

     -- Procesos para actualizar los contadores secundarios (mod 2 y mod 5)
     process(clk, ena) 
     begin
        if ena = '0' then
             count2 <= (others => '0');
             count5 <= (others => '0');
             pulso_25 <= '1';
             pulso_500 <= '1';
         elsif rising_edge(clk) then 
            count2 <= count2 + 1;
            if count2 = "1" then
                 count2 <= (others => '0');
                 count5 <= count5 + 1;
                 pulso_25 <= '1';
                 if count5 = "100" then 
                    count5 <= (others => '0');
                    pulso_500 <= '1';
                 end if;
            else 
                pulso_25 <= '0';
                pulso_500 <= '0';
            end if;
         end if;
     end process;

     -- Asignaciones de salida: cada señal es un pulso de 1 ciclo de reloj
     f_div_2_5  <= pulso_25;
     f_div_1_25 <= pulso_125;
     f_div_500  <= pulso_500;
end Behavioral;