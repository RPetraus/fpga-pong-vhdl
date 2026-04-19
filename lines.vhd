-- Bouncing Ball Video from DE2Core Library
-- Documentation added to clarify code behavior - CT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all; 
USE  IEEE.STD_LOGIC_UNSIGNED.all; 
USE IEEE.NUMERIC_STD.all;


ENTITY lines IS

   PORT(pixel_row, pixel_column		: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        Red,Green,Blue 				: OUT std_logic;
        Vert_sync	: IN std_logic);
       
END lines;

architecture behavior of lines is
--Internal Signals to implement ball presence, direction, size, motion, and posiiton  
SIGNAL line_cnter        				: integer := 0;  --1 in area of ball, 0 otherwise
SIGNAL Ball_on        				: std_logic;
SIGNAL Size 						: STD_LOGIC_VECTOR(9 DOWNTO 0);  
SIGNAL Ball_Y_motion, Ball_X_motion 	: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL Ball_Y_pos, Ball_X_pos		: STD_LOGIC_VECTOR(9 DOWNTO 0);
CONSTANT CENTRE_X : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(320,10);
CONSTANT CENTRE_Y : STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240,10);

-- One-frame pulse telling the Y-process to reset position
SIGNAL Reset_Ball : STD_LOGIC := '0';

-- current horizontal speed magnitude (1 … 5 px / frame)
SIGNAL Speed           : INTEGER range 1 to 5 := 1;

-- helper:  +Speed or –Speed in std_logic_vector form
SIGNAL Step_Vector     : STD_LOGIC_VECTOR(9 downto 0);


BEGIN            

-- positive when Ball_X_motion is positive, negative otherwise
Step_Vector <=
    (CONV_STD_LOGIC_VECTOR(Speed,10))  when Ball_X_motion(9) = '0' else
    (CONV_STD_LOGIC_VECTOR(-Speed,10));
	 
Size <= CONV_STD_LOGIC_VECTOR(8,10); --sets size of ball to 8 pixels from center (16 x 16)
  --conversion function to set initial ball position to middle 
											  -- of screen (column 320)
		-- Set color signals to define the color of the ball - these choices display a red ball on a white background
Red <=  '1'; 
		-- Turn off Green and Blue when displaying ball
Green <= NOT Ball_on;
Blue <=  NOT Ball_on;

-- Combinational process that generates the Ball_on bit for every location on the screen
-- Each part of "if" statement compares current pixel column and row to the X and Y position of the ball
-- If the current location is within the intended X and Y position of the ball, then Ball_on is set.
RGB_Display: Process (pixel_row, pixel_column)
BEGIN
-- Check if the current pixel column is within the Ball X posiion (+/- Size)
--        Ball_X_pos - Size -------------- Ball_X_pos + Size
-- Then check if the current pixel row is within the Ball Y position (+/- Size)
--                         Ball_Y_pos - Size
--                                 |
--                         Ball_Y_pos + Size
-- Comparisons manipulated to always compare positive numbers ('0'&) and sums

IF (pixel_row >= CENTRE_X) AND
 	(line_cnter > 0) AND
	(line_cnter <= 16)then
 		Ball_on <= '1';
	ELSIF(line_cnter > 16) then
	Ball_on <= '0';
END IF;
END process RGB_Display;

LINE_CNTER_PROC : Process (Vert_sync)
BEGIN
	if(rising_edge(Vert_sync)) then
		if (line_cnter <= 32)then
		line_cnter <= line_cnter + 1;
	elsif(line_cnter>32) then
		line_cnter<=0;
	end if;
	end if;
	end Process;
-- Clocked process with vert_sync clock that sets the Y position of the ball. 
END behavior;
