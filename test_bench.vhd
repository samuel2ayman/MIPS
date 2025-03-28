library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Reg_File_tb is
end Reg_File_tb;

architecture Sim of Reg_File_tb is
    constant CLK_PERIOD : time := 10 ns;

    signal tb_clk       : std_logic := '0';   
    signal tb_wr_enable : std_logic := '0';   
    signal tb_rd_addr1  : std_logic_vector(4 downto 0);  
    signal tb_rd_addr2  : std_logic_vector(4 downto 0);  
    signal tb_wr_addr   : std_logic_vector(4 downto 0);   
    signal tb_wr_data   : std_logic_vector(31 downto 0);  
    signal tb_rd_data1  : std_logic_vector(31 downto 0);  
    signal tb_rd_data2  : std_logic_vector(31 downto 0);  

    component Reg_File is
        Port (
                clk       : in  STD_LOGIC;
                regWrite  : in  STD_LOGIC;
                writeAddr : in  STD_LOGIC_VECTOR (4 downto 0);
                writeData : in  STD_LOGIC_VECTOR (31 downto 0);
                readAddr1 : in  STD_LOGIC_VECTOR (4 downto 0);
                readAddr2 : in  STD_LOGIC_VECTOR (4 downto 0);
                readData1 : out STD_LOGIC_VECTOR (31 downto 0);
                readData2 : out STD_LOGIC_VECTOR (31 downto 0)
            );
    end component;

begin
    DUT: Reg_File
    port map (
        clk       => tb_clk,
        regWrite  => tb_wr_enable,
        writeAddr => tb_wr_addr,
        writeData => tb_wr_data,
        readAddr1 => tb_rd_addr1,
        readAddr2 => tb_rd_addr2,
        readData1 => tb_rd_data1,
        readData2 => tb_rd_data2
    );

    -- Clock Process (Generate a clock signal)
    clk_proc: process
    begin
        while true loop
            tb_clk <= '0';
            wait for CLK_PERIOD / 2;
            tb_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Test Process
    tb_proc: process
    begin
        wait for CLK_PERIOD / 2;

        -- Case 1: Write to register then read from it in the same cycle
        tb_wr_enable <= '1';
        tb_wr_addr   <= "00010";  
        tb_rd_addr1  <= "00010";  
        tb_wr_data   <= x"00000019"; 
        wait for CLK_PERIOD;  

        assert tb_rd_data1 = x"00000019"
            report "Case 1 Failed: Expected x19 in Register 2" severity error;

        -- Case 2: WWrite to two registers and read from both at the same time
        tb_wr_addr   <= "00001"; 
        tb_wr_data   <= x"00000032";  
        wait for CLK_PERIOD;
        
        tb_wr_addr   <= "00010"; 
        tb_wr_data   <= x"0000004B"; 
        
        tb_rd_addr1  <= "00001";  
        tb_rd_addr2  <= "00010";
        wait for CLK_PERIOD;

        assert tb_rd_data1 = x"00000032"
            report "Case 2 Failed: Expected x32 in Register 1" severity error;
        assert tb_rd_data2 = x"0000004B"
            report "Case 2 Failed: Expected x4b in Register 2" severity error;

        -- Case 3: Trying to write while enable=0
        tb_wr_enable <= '0';
        tb_wr_addr   <= "00001";  
        tb_rd_addr1  <= "00001";  
        tb_wr_data   <= x"00000064"; 
        wait for CLK_PERIOD;

        assert tb_rd_data1 = x"00000032"
            report "Case 3 Failed: Write ignored when enable is 0" severity error;

        -- Case 4: Verify Read on Falling Edge
        tb_wr_enable <= '1';
        tb_wr_addr   <= "00001";
        tb_wr_data   <= x"00000096"; 
        wait for CLK_PERIOD;

        tb_wr_enable <= '0';
        tb_rd_addr1  <= "00001";  
        wait for CLK_PERIOD;

        assert tb_rd_data1 = x"00000096"
            report "Case 4 Failed: Expected x96 in Register 1" severity error;
        
        -- Case 5: Verify Zero Register Always Reads as Zero
        tb_wr_enable <= '1';
        tb_wr_addr   <= "00000";  
        tb_wr_data   <= x"00000077"; 
        wait for CLK_PERIOD;

        tb_wr_enable <= '0';
        tb_rd_addr1  <= "00000";  
        wait for CLK_PERIOD;

        assert tb_rd_data1 = x"00000000"
            report "Case 5 Failed: Zero register should always be 0" severity error;
            
        -- Print Success Message
        report "All test cases passed successfully!" severity note;
        
        -- Stop Simulation            
        std.env.stop;
    end process;

end Sim;
