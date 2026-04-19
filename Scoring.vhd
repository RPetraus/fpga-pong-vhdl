library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity scoring is
  port (
	 clk		 : in std_logic;
    ball_x   : in std_logic_vector(9 downto 0);
    p1_score : out integer;
    p2_score : out integer;
	 win_score : in integer;
	 win_occ : out std_logic;
	 rst 		: in std_logic
  );
end entity;

architecture arch of scoring is
  signal ball_min_x, ball_max_x : integer;
  signal hit_p1, hit_p2, hit_now_p1, hit_now_p2, hit_prev_p1, hit_prev_p2 : std_logic := '0';
  signal hit_count_p1, hit_count_p2  : integer := 0;

begin
	ball_min_x <= to_integer(unsigned(ball_x)) - 8;
   ball_max_x <= to_integer(unsigned(ball_x)) + 8;
	
	hit_p1 <= '1' when
                (ball_max_x = 640) 
              else '0';

    hit_p2 <= '1' when 
                (ball_min_x = 0)
              else '0';

    hit_now_p1 <= hit_p1;
	 hit_now_p2 <= hit_p2;
	

    process(clk, rst)
    begin
        if falling_edge(clk) then        
            -- rising edge of hit_now → new collision
            if (hit_now_p2 = '1') and (hit_prev_p2 = '0') and (rst = '1')then
                hit_count_p2 <= hit_count_p2 + 1;
				elsif(rst = '0') then
					hit_count_p2 <= 0;
            end if;	
				hit_prev_p2 <= hit_now_p2;
        end if;
    end process;
	 
	 process(clk)
    begin
        if falling_edge(clk) then        
            -- rising edge of hit_now → new collision
            if (hit_now_p1 = '1') and (hit_prev_p1 = '0') and (rst = '1') then
                hit_count_p1 <= hit_count_p1 + 1;
				elsif(rst = '0') then
					hit_count_p1 <= 0;
            end if;	
				hit_prev_p1 <= hit_now_p1;
        end if;
    end process;
	 
	 
	 process(hit_count_p1, hit_count_p2)
	 begin
		if (hit_count_p1 >= win_score) or (hit_count_p2 >= win_score) then
			win_occ <= '1';
		else 
			win_occ <= '0';
		end if;
	end process;

    p1_score <= hit_count_p1;
    p2_score <= hit_count_p2;
end architecture;

