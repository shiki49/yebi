library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fadd is

  port (
    x, y : in  std_logic_vector(31 downto 0);
--    clk  : in  std_logic;
    q    : out std_logic_vector(31 downto 0));
  
end fadd;


architecture fadd of fadd is

  component BitShift_R
    port (
      Data  : in  std_logic_vector(27 downto 0);
      Shift : in  std_logic_vector(7  downto 0);
      q     : out std_logic_vector(27 downto 0));
  end component;

  component zlc
    port (
      frc : in  std_logic_vector(27 downto 0);
      q   : out std_logic_vector(4 downto 0));
  end component;

  component BitShift_L1
    port (
      Data  : in  std_logic_vector(27 downto 0);
      Shift : in  std_logic_vector(1 downto 0);
      q     : out std_logic_vector(27 downto 0));
  end component;

  component BitShift_L2
    port (
      Data  : in  std_logic_vector(27 downto 0);
      Shift : in  std_logic_vector(2 downto 0);
      q     : out std_logic_vector(27 downto 0));
  end component;
  
  -- stage1
  signal input_x,input_y : std_logic_vector(31 downto 0);  
  signal cmp_abs : std_logic_vector(1 downto 0);
  signal arg_large,arg_small : std_logic_vector(31 downto 0);
  signal frc_large,frc_small,frc_small_shifted,frc_result1,frc_result2,frc_uped,frc_result3,frc_ans : std_logic_vector(27 downto 0);
  signal exp_large,exp_small,exp_gap,exp_ans : std_logic_vector(7 downto 0);
  signal exp_ans2 : std_logic_vector(8 downto 0);
  signal sgn_large,sgn_small,sgn_ans : std_logic;
  signal op : std_logic;
  signal shift : std_logic_vector(4 downto 0);
  signal exp_up :std_logic;
  signal rounding :std_logic;
  signal ans_head : std_logic_vector(8 downto 0);  
begin  

  input_x <= x;
  input_y <= y;

  --絶対値の比較
  --if |a| > |b| return 10
  --   |a| < |b| return 01
  --   |a| = |b| return 00
  cmp_abs <= "10" when input_x(30 downto 0) > input_y(30 downto 0)
             else "01" when input_x(30 downto 0) < input_y(30 downto 0)
             else "00";

  --絶対値の大きい方をarg_large、小さい方をarg_small
  arg_large <= input_x when cmp_abs(1) = '1' else input_y;
  arg_small <= input_y when cmp_abs(1) = '1' else input_x;  

  --仮数部
  frc_large <= "01" & arg_large(22 downto 0) & "000";
  frc_small <= "01" & arg_small(22 downto 0) & "000";

  --指数部
  exp_large <= arg_large(30 downto 23);
  exp_small <= arg_small(30 downto 23);

  exp_gap <= exp_large - exp_small;
  exp_ans <= exp_large;

  --符号部
  sgn_large <= arg_large(31);
  sgn_small <= arg_small(31);

  sgn_ans <= sgn_large;

  --計算
  op <= '0' when sgn_large = sgn_small else '1';

  RightShift: BitShift_R
  port map(frc_small,exp_gap,frc_small_shifted);

  frc_result1 <= frc_large + frc_small_shifted when op = '0'
                else frc_large - frc_small_shifted;

  --先頭の0をカウント
  ZeroLeadingCounter: zlc
  port map(frc_result1,shift);

  --丸めによって桁があがる場合を判定
  --011...1XX or 0011...11X の場合は先に桁上がり  
  exp_up <= '1' when frc_result1(25 downto 2) = "111111111111111111111111" and (frc_result1(26) or frc_result1(1))='1'
             else '0';

  frc_uped <= "1000000000000000000000000000"
              when frc_result1(26 downto 2) = "1111111111111111111111111"
              else "0100000000000000000000000000"
              when frc_result1(25 downto 1) = "1111111111111111111111111"
              else frc_result1;
  
  ls: BitShift_L1
    port map (frc_uped,shift(1 downto 0),frc_result2);
  
  rounding <= frc_result2(3) and (frc_result2(4) or frc_result2(2) or frc_result2(1));

  ls2: BitShift_L2
  port map (frc_result2,shift(4 downto 2),frc_result3);
  
  frc_ans <= frc_result2 + (rounding & "0000") when shift(4 downto 2) = "000" 
             else frc_result3;
  
  --exp_ans2 <= exp_ans + exp_up + 1 - zlc;
  exp_ans2 <= ('0'&exp_ans) + ("0000000" & exp_up & (not exp_up)) - ("0000"&shift);
  
  ans_head <= "000000000" when exp_ans2(8)='1' or shift >= "11010" or exp_ans ="00000000"
             else sgn_ans&exp_ans2(7 downto 0);

  q <= ans_head & frc_ans(26 downto 4);
               
end fadd;
