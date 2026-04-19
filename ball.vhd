-- Bouncing Ball Video from DE2Core Library
-- Documentation added to clarify code behavior - CT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all; 
USE  IEEE.STD_LOGIC_UNSIGNED.all; 


ENTITY ball IS

   PORT(pixel_row, pixel_column		: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        Red,Green,Blue 				: OUT std_logic;
        Vert_sync, H_sync, Collide	: IN std_logic;
		  Ball_Y_out, Ball_x_out 		: OUT STD_logic_vector(9 downto 0); -- Vert_sync signal is a clock input that triggers the Move_Ball process
		  win_occ : in std_logic;
		  rst : in std_logic);
END ball;

architecture behavior of ball is
--Internal Signals to implement ball presence, direction, size, motion, and posiiton  
SIGNAL Ball_on        				: std_logic;  --1 in area of ball, 0 otherwise
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
    (CONV_STD_LOGIC_VECTOR(0,10))  when win_occ = '1' or rst = '0' else
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
RGB_Display: Process (Ball_X_pos, Ball_Y_pos, pixel_column, pixel_row, Size)
BEGIN
-- Check if the current pixel column is within the Ball X posiion (+/- Size)
--        Ball_X_pos - Size -------------- Ball_X_pos + Size
-- Then check if the current pixel row is within the Ball Y position (+/- Size)
--                         Ball_Y_pos - Size
--                                 |
--                         Ball_Y_pos + Size
-- Comparisons manipulated to always compare positive numbers ('0'&) and sums

IF (pixel_column + Size >= Ball_X_pos) AND
 	(pixel_column <= Ball_X_pos + Size) AND
 	(pixel_row + Size >= Ball_Y_pos) AND
 	(pixel_row <= Ball_Y_pos + Size) THEN
 		Ball_on <= '1';
 	ELSE
 		Ball_on <= '0';
END IF;
END process RGB_Display;

-- Clocked process with vert_sync clock that sets the Y position of the ball. 
Move_Ball_Y : process(vert_sync)
BEGIN
      IF rising_edge(vert_sync) THEN 
				if win_occ = '1' or rst = '0'   then
 					 Ball_Y_pos    <= CENTRE_Y;
                Ball_Y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
            --  NEW:  serve from centre when Reset_Ball is high
            ELSIF Reset_Ball = '1' THEN
                Ball_Y_pos    <= CENTRE_Y;
                Ball_Y_motion <= CONV_STD_LOGIC_VECTOR( 2,10);

            --  existing top/bottom bounce logic
            ELSIF (Ball_Y_pos) >= 480 - Size THEN
                Ball_Y_motion <= CONV_STD_LOGIC_VECTOR(-2,10);
            ELSIF Ball_Y_pos <= Size THEN
                Ball_Y_motion <= CONV_STD_LOGIC_VECTOR( 2,10);
            END IF;

            -- update Y position
            Ball_Y_pos <= Ball_Y_pos + Ball_Y_motion;
      END IF;
END process Move_Ball_Y;


Move_Ball_X : process (vert_sync)
    variable Latched : std_logic := '0';
BEGIN
    IF rising_edge(vert_sync) THEN
		 if(win_occ = '1' or rst = '0') then
				Ball_X_pos <= CENTRE_X;
            Ball_X_motion <= CONV_STD_LOGIC_VECTOR(0,10);
        -- paddle hit -> flip + speed-up (once per contact)
        ELSIF (Collide = '1') AND (Latched = '0') THEN
            -- change sign bit
            Ball_X_motion <= not Ball_X_motion(9) & Ball_X_motion(8 downto 0);

            -- bump speed (cap at 5)
            IF Speed < 5 THEN
                Speed <= Speed + 1;
            END IF;

            Ball_X_pos <= Ball_X_pos + Step_Vector;  -- clear overlap
            Latched    := '1';
        END IF;

        -- release latch when overlap is gone
        IF Collide = '0' THEN
            Latched := '0';
        END IF;

        -- miss left / right wall -> centre reset + speed reset
        IF Ball_X_pos >= 640 - Size THEN          -- missed right
            Ball_X_pos    <= CENTRE_X;
            Ball_X_motion <= CONV_STD_LOGIC_VECTOR(-1,10);  -- restart left
            Speed         <= 1;
            Reset_Ball    <= '1';

        ELSIF Ball_X_pos <= Size or rst = '0' THEN             -- missed left
            Ball_X_pos    <= CENTRE_X;
            Ball_X_motion <= CONV_STD_LOGIC_VECTOR( 1,10);  -- restart right
            Speed         <= 1;
            Reset_Ball    <= '1';

        -- normal frame advance 
        ELSE
		  
            Ball_X_pos  <= Ball_X_pos + Step_Vector;
            Reset_Ball  <= '0';
        END IF;
    END IF;

END process Move_Ball_X;

    ball_x_out <= Ball_X_pos;
    ball_y_out <= Ball_Y_pos;
	 
END behavior;
