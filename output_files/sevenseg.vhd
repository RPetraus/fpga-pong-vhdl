library IEEE;
use IEEE.std_logic_1164.all;

entity Sevenseg is
    port (
        value    : in  integer;   -- 0–B hex
        Sevenseg : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of Sevenseg is
begin
    process(value)
    begin
        case value is
            when 0  => Sevenseg <= not "1111110";  -- 0
            when 1  => Sevenseg <= not "0110000";  -- 1
            when 2  => Sevenseg <= not "1101101";  -- 2
            when 3  => Sevenseg <= not "1111001";  -- 3
            when 4  => Sevenseg <= not "0110011";  -- 4
            when 5  => Sevenseg <= not "1011011";  -- 5
            when 6  => Sevenseg <= not "1011111";  -- 6
            when 7  => Sevenseg <= not "1110000";  -- 7
            when 8  => Sevenseg <= not "1111111";  -- 8
            when 9  => Sevenseg <= not "1111011";  -- 9
            when 10 => Sevenseg <= not "1110111";  -- A (decimal 10)
            when 11 => Sevenseg <= not "0011111";  -- b (decimal 11)
            when others =>
                Sevenseg <= not "0000000";         -- blank / error
        end case;
    end process;
end architecture;
