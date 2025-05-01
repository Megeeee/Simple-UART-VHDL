library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tb_uart_rx is
    GENERIC (
        clk_freq     : INTEGER := 100_000_000;
        baud_rate    : INTEGER := 1_000_000
    );
end tb_uart_rx;

architecture Behavioral of tb_uart_rx is

    component uart_rx is
        GENERIC (
            clk_freq     : INTEGER := 100_000_000;
            baud_rate    : INTEGER := 112_500
        );
        Port ( 
            clk     : IN STD_LOGIC;
            rx      : IN STD_LOGIC;
            rx_done : OUT STD_LOGIC;
            dout    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    end component;

    signal   clk     : STD_LOGIC := '0';
    signal   rx      : STD_LOGIC := '1';
    signal   rx_done : STD_LOGIC;
    signal   dout    : STD_LOGIC_VECTOR (7 DOWNTO 0);

    constant test_vector : STD_LOGIC_VECTOR (9 DOWNTO 0) := '1' & x"38" &'0';
    constant test_vector2 : STD_LOGIC_VECTOR (9 DOWNTO 0) := '1' & x"06" & '0';
begin

    DUTY : uart_rx
        GENERIC MAP (
            clk_freq => clk_freq,
            baud_rate => baud_rate
        )
        PORT MAP (
            clk => clk,
            rx => rx,
            rx_done => rx_done,
            dout => dout
        );
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR 5 ns;
        clk <= '1';
        WAIT FOR 5 ns;
    END PROCESS;
    stimulus_process : PROCESS
    BEGIN

        wait for 100 ns;

        for i in 0 to 9 loop
            rx <= test_vector(i);
            wait for 1 us;
        end loop;

        wait for 20 ns;

        for i in 0 to 9 loop
            rx <= test_vector2(i);
            wait for 1 us;
        end loop;

        wait for 20 ns;

        assert false report "End of simulation" severity failure;
    end process;

end Behavioral;
