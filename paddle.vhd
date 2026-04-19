LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


ENTITY paddle IS

   PORT(pixel_row, pixel_column		: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		  SW : IN STD_LOGIC; 
        Red,Green,Blue 				: OUT std_logic;
        Vert_sync	: IN std_logic;
		  paddle_y : out std_logic_vector(9 downto 0); -- Vert_sync signal is a clock input that triggers the Move_Ball process
		  paddle_x : IN integer);
		 
END paddle;

architecture behavior of paddle is
--Internal Signals to implement ball presence, direction, size, motion, and posiiton  
SIGNAL Paddle_on        				: std_logic;  --1 in area of ball, 0 otherwise
SIGNAL paddle_width 						: UNSIGNED(9 DOWNTO 0);  
SIGNAL Paddle_Y_motion 	: integer;
SIGNAL Paddle_Y_pos, Paddle_X_pos		: unsigned(9 downto 0);
signal paddle_height : UNSIGNED(9 downto 0);

BEGIN

          

paddle_width <= to_unsigned(8,10); --sets size of ball to 8 pixels from center (16 x 16)
  --conversion function to set initial ball position to middle 
											  -- of screen (column 320)
											 
Paddle_X_pos <= to_unsigned(paddle_x, 10);  
											  
		-- Set color signals to define the color of the ball - these choices display a red ball on a white background
Red <=  NOT Paddle_on; 
		-- Turn off Green and Blue when displaying ball
Green <= NOT Paddle_on;
Blue <=  NOT Paddle_on;

-- Combinational process that generates the Ball_on bit for every location on the screen
-- Each part of "if" statement compares current pixel column and row to the X and Y position of the ball
-- If the current location is within the intended X and Y position of the ball, then Ball_on is set.
RGB_Display: Process (Paddle_X_pos, Paddle_Y_pos, pixel_column, pixel_row, paddle_width)
BEGIN
-- Check if the current pixel column is within the Ball X posiion (+/- Size)
--        Ball_X_pos - Size -------------- Ball_X_pos + Size
-- Then check if the current pixel row is within the Ball Y position (+/- Size)
--                         Ball_Y_pos - Size
--                                 |
--                         Ball_Y_pos + Size
-- Comparisons manipulated to always compare positive numbers ('0'&) and sums

paddle_height <= to_unsigned(to_integer(unsigned(paddle_width)) * 10, 10);

IF (unsigned(pixel_column) + paddle_width >= Paddle_X_pos) AND
 	(unsigned(pixel_column) <= Paddle_X_pos + paddle_width) AND
 	(unsigned(pixel_row) + paddle_width >= Paddle_Y_pos) AND
 	(unsigned(pixel_row) <= Paddle_Y_pos + paddle_height) THEN
 		Paddle_on <= '1';
 	ELSE
 		Paddle_on <= '0';
END IF;
END process RGB_Display;

-- Clocked process with vert_sync clock that sets the Y position of the ball. 
Move_Paddle_Y: process(vert_sync)
BEGIN
			-- Move ball once every vertical sync clock edge
--	WAIT UNTIL vert_sync'event and vert_sync = '1';
      if rising_edge(vert_sync) then 
			-- Bounce off top or bottom of screen
			-- After hitting bottom, start decrementing by 2 pixels each clock cycle
			-- After hitting top, start incrementing by 2 pixels each clock cycle
			if(SW = '0') then 
				
				if (Paddle_Y_pos) >= 480 - (paddle_width * 10) then
					paddle_y_motion <= 0;
				else
					Paddle_Y_motion <= 3;
				end if;
			else 
				if (Paddle_Y_pos) <= paddle_width then
					paddle_y_motion <= 0;
				
				else
					Paddle_Y_motion <= -3;
				end if;
			end if;
			-- Compute next ball Y position
				Paddle_Y_pos <= Paddle_Y_pos + to_unsigned(Paddle_Y_motion, 10);
		end if;
END process Move_Paddle_Y;

paddle_y <= std_logic_vector(Paddle_Y_pos);

END behavior;
