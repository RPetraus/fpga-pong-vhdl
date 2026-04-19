library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity collision is
    generic (
        BALL_HALF_SIZE : integer := 8;   -- pixels from centre to edge
        PADDLE_WIDTH   : integer := 8;   -- paddle thickness  (X direction)
        PADDLE_HEIGHT  : integer := 80   -- paddle height     (Y direction)
    );
    port (

        clk           : in  std_logic;

        paddle_1_x    : in  integer;                        -- left edge
        paddle_1_y    : in  std_logic_vector(9 downto 0);   -- top edge

        paddle_2_x    : in  integer;
        paddle_2_y    : in  std_logic_vector(9 downto 0);


        ball_x_pos    : in  std_logic_vector(9 downto 0);
        ball_y_pos    : in  std_logic_vector(9 downto 0);

        coll_detect   : out std_logic;      -- one-frame pulse on hit
        coll_height   : out integer;        -- 0 … (PADDLE_HEIGHT-1)
        num_collision : out integer         -- running total
    );
end entity;

architecture rtl of collision is

    function slv_to_int(s : std_logic_vector) return integer is
    begin
        return to_integer(unsigned(s));
    end function;

    signal ball_min_x, ball_max_x : integer;
    signal ball_min_y, ball_max_y : integer;

    signal p1_min_x, p1_max_x : integer;
    signal p1_min_y, p1_max_y : integer;

    signal p2_min_x, p2_max_x : integer;
    signal p2_min_y, p2_max_y : integer;

    signal hit_p1, hit_p2, hit_now, hit_prev : std_logic := '0';

    signal hit_count  : integer := 0;
    signal height_reg : integer := 0;

begin


    ball_min_x <= slv_to_int(ball_x_pos) - BALL_HALF_SIZE;
    ball_max_x <= slv_to_int(ball_x_pos) + BALL_HALF_SIZE;
    ball_min_y <= slv_to_int(ball_y_pos) - BALL_HALF_SIZE;
    ball_max_y <= slv_to_int(ball_y_pos) + BALL_HALF_SIZE;

    p1_min_x <= paddle_1_x;
    p1_max_x <= paddle_1_x + PADDLE_WIDTH  - 1;   
    p1_min_y <= slv_to_int(paddle_1_y);
    p1_max_y <= p1_min_y  + PADDLE_HEIGHT - 1;    

    p2_min_x <= paddle_2_x;
    p2_max_x <= paddle_2_x + PADDLE_WIDTH  - 1;
    p2_min_y <= slv_to_int(paddle_2_y);
    p2_max_y <= p2_min_y  + PADDLE_HEIGHT - 1;


    --  paddle-1  (left side)
    hit_p1 <= '1' when
                (ball_max_x >= p1_min_x) and      -- X rectangles overlap
                (ball_min_x <= p1_max_x) and
                (ball_max_y >= p1_min_y) and      -- Y rectangles overlap
                (ball_min_y <= p1_max_y)
              else '0';

    --  paddle-2  (right side)
    hit_p2 <= '1' when
                (ball_max_x >= p2_min_x) and
                (ball_min_x <= p2_max_x) and
                (ball_max_y >= p2_min_y) and
                (ball_min_y <= p2_max_y)
              else '0';

    hit_now <= hit_p1 or hit_p2;


	 
    process(clk)
    begin
        if falling_edge(clk) then         
            hit_prev <= hit_now;

            -- one-frame pulse
            coll_detect <= hit_now;

            -- rising edge of hit_now → new collision
            if (hit_now = '1') and (hit_prev = '0') then
                hit_count <= hit_count + 1;

                if hit_p1 = '1' then
                    -- 0 at paddle’s lower end, upwards positive
                    height_reg <= p1_max_y - ball_max_y;  -- 0 … 79
                else
                    height_reg <= p2_max_y - ball_max_y;
                end if;
            end if;
        end if;
    end process;

    num_collision <= hit_count;
    coll_height   <= height_reg;

end architecture;
