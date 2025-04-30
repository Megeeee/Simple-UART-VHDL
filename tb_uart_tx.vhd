
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tb_uart_tx IS
    GENERIC (
        clk_freq : INTEGER := 100_000_000;
        baud_rate : INTEGER := 10_000_000;
        stopbit : INTEGER := 2
    );
END tb_uart_tx;

ARCHITECTURE Behavioral OF tb_uart_tx IS
    COMPONENT uart_tx IS
        GENERIC (
            clk_freq : INTEGER := 100_000_000;
            baud_rate : INTEGER := 112_500;
            stopbit : INTEGER := 2
        );
        PORT (
            clk : IN STD_LOGIC;
            tx_start : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            tx : OUT STD_LOGIC;
            tx_done : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC :=  '0';
    SIGNAL tx_start : STD_LOGIC := '0';
    SIGNAL din : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tx : STD_LOGIC;
    SIGNAL tx_done : STD_LOGIC;
    
BEGIN

DUT: uart_tx 
GENERIC map (
    clk_freq  => clk_freq ,
    baud_rate => baud_rate,
    stopbit   => stopbit
)
PORT map (
    clk       => clk     ,   
    tx_start  => tx_start,
    din       => din     ,   
    tx        => tx      ,   
    tx_done   => tx_done        
);

    clk_process : PROCESS
    BEGIN
    clk <= '0';
    WAIT FOR 5 ns;
    clk <= '1';
    WAIT FOR 5 ns;
    END PROCESS;

    stimulus_process : PROCESS
    begin
        din <= x"00";
        tx_start <= '0';
        wait for 100 ns;
        din <= x"51";
        tx_start <= '1';
        wait for 10 ns;
        tx_start <= '0';
        wait for 1.2 us;
        din <= x"38";
        tx_start <= '1';
        wait for 10 ns;
        tx_start <= '0';
        wait for 4 us;


    end process;
    

END Behavioral;