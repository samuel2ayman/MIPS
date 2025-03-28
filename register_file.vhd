library IEEE;
use IEEE.STD_LOGIC_1164.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity Reg_File is
  generic (
    B : integer := 32;   -- data width
    W : integer := 5     -- address width
  );
  Port ( 
        clk       : in  STD_LOGIC;                          -- Clock signal
        regWrite  : in  STD_LOGIC;                          -- Write enable signal
        writeAddr : in  STD_LOGIC_VECTOR (W - 1 downto 0);  -- Write address (5-bit)
        writeData : in  STD_LOGIC_VECTOR (B - 1 downto 0);  -- Write data (32-bit)
        readAddr1 : in  STD_LOGIC_VECTOR (W - 1 downto 0);  -- Read address 1 (5-bit)
        readAddr2 : in  STD_LOGIC_VECTOR (W - 1 downto 0);  -- Read address 2 (5-bit)
        readData1 : out STD_LOGIC_VECTOR (B - 1 downto 0);  -- Read data 1 (32-bit)
        readData2 : out STD_LOGIC_VECTOR (B - 1 downto 0)   -- Read data 2 (32-bit)
    );
  
end Reg_File;

architecture Behavioral of Reg_File is
  type RegisterArray is array (0 to (2**W)-1) of std_logic_vector(B-1 downto 0);
  signal registers : RegisterArray := (others => (others => '0'));

begin
   
    process(clk)
    begin
        if rising_edge(clk) then
            if regWrite = '1' then
                registers(to_integer(unsigned(writeAddr))) <= writeData;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if falling_edge(clk) then
            if readAddr1 /= "00000" then
                readData1 <= registers(to_integer(unsigned(readAddr1)));
            else
                readData1 <= (others => '0');
            end if;
    
            if readAddr2 /= "00000" then
                readData2 <= registers(to_integer(unsigned(readAddr2)));
            else
                readData2 <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;


