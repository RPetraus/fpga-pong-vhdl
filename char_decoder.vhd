-- Character Decoder (7-segment, two digits)
-- Authors: Zuhair AlMassri, Michael Kahn, Ryan Petrauskas
-- Course: ECE318 – Lab 7
-- Description: Converts a 7-bit unsigned value on SW into its decimal
--              tens (HEX1) and ones (HEX0) digits displayed on two
--              common-anode seven-segment outputs.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity char_decoder is
    port (
        SW   : in  integer;
        HEX0 : out std_logic_vector(0 to 6);
        HEX1 : out std_logic_vector(0 to 6)
    );
end entity;

architecture char_decoder_arch of char_decoder is
    signal SevenSeg_int_0, SevenSeg_int_1 : integer range 0 to 9;
begin
    -- Split SW (0-127) into decimal tens and ones
    SevenSeg_int_1 <= SW / 10;   -- tens digit
    SevenSeg_int_0 <= SW mod 10; -- ones digit

    -- Lookup table: ones digit → segment pattern
    with SevenSeg_int_0 select
        HEX0 <= not "1111110" when 0,
                not "0110000" when 1,
                not "1101101" when 2,
                not "1111001" when 3,
                not "0110011" when 4,
                not "1011011" when 5,
                not "1011111" when 6,
                not "1110000" when 7,
                not "1111111" when 8,
                not "1111011" when 9;

    -- Lookup table: tens digit → segment pattern
    with SevenSeg_int_1 select
        HEX1 <= not "1111110" when 0,
                not "0110000" when 1,
                not "1101101" when 2,
                not "1111001" when 3,
                not "0110011" when 4,
                not "1011011" when 5,
                not "1011111" when 6,
                not "1110000" when 7,
                not "1111111" when 8,
                not "1111011" when 9;
end architecture;
