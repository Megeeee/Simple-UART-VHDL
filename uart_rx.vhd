library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity uart_rx is
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
end uart_rx;

architecture Behavioral of uart_rx is

    CONSTANT clk_period : INTEGER := clk_freq / baud_rate;

    TYPE state_type IS (idle, start, transfer, stop);
    SIGNAL state : state_type := idle;

    SIGNAL counter : INTEGER RANGE 0 TO clk_period := 0;
    SIGNAL shreg : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL bitcounter : INTEGER RANGE 0 TO 7 := 0;

begin

process(clk) 
begin
    if rising_edge(clk) THEN
        case state is

            when idle =>

                rx_done <= '0';
                if rx = '0' then
                    state <= start;
                    counter <= 0;
                end if;

            when start =>
                    
                    if counter = ((clk_period/2) - 1) then
                        state <= transfer;
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;
                    
            when transfer =>

                        if counter = clk_period -1 then
                            if bitcounter = 7 then
                                state <= stop;
                                rx_done <= '1';
                            else
                                bitcounter <= bitcounter + 1;
                            end if;
                            counter <= 0;
                            shreg <= rx & shreg(7 DOWNTO 1);
                        else
                            counter <= counter + 1;
                        end if;

            when stop =>
                if counter = clk_period - 1 then
                    state <= idle;
                    counter <= 0;
                    bitcounter <= 0;
                    rx_done <= '1';
                else
                    counter <= counter + 1;
                end if;

            when others =>
                state <= idle;

        end case;
    end if;
end process;

dout <= shreg;

end Behavioral;
