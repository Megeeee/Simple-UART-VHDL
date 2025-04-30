LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY uart_tx IS
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
END uart_tx;

ARCHITECTURE Behavioral OF uart_tx IS

    CONSTANT clk_period : INTEGER := clk_freq / baud_rate;

    TYPE state_type IS (idle, start, transfer, stop);
    SIGNAL state : state_type := idle;

    SIGNAL counter : INTEGER RANGE 0 TO (stopbit* clk_period) := 0;
    SIGNAL shreg : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL bitcounter : INTEGER RANGE 0 TO 7 := 0;

BEGIN

    main : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            CASE state IS
                WHEN idle =>

                    tx <= '1';
                    tx_done <= '0';

                    IF tx_start = '1' THEN
                        state <= start;
                        tx <= '0';
                        shreg <= din;
                    END IF;

                WHEN start =>
                    tx <= '0';
                    IF counter = clk_period - 1 THEN
                        counter <= 0;
                        state <= transfer;
                        tx <= shreg(0);
                        shreg(6 DOWNTO 0) <= shreg(7 DOWNTO 1); --shift register
                        shreg(7) <= shreg(0);
                    ELSE
                        counter <= counter + 1;
                    END IF;

                WHEN transfer =>

                    
                    IF bitcounter = 7 THEN
                        IF counter = clk_period - 1 THEN
                            counter <= 0;
                            bitcounter <= 0;
                            tx <= '1';
                            state <= stop;
                        ELSE
                            counter <= counter + 1;
                    END IF;
                    ELSE
                        IF counter = clk_period - 1 THEN
                            counter <= 0;
                            bitcounter <= bitcounter + 1;
                            tx <= shreg(0);
                            shreg(6 DOWNTO 0) <= shreg(7 DOWNTO 1); --shift register
                            shreg(7) <= shreg(0);
                        ELSE
                            counter <= counter + 1;
                        END IF;
                    END IF;

                WHEN stop =>

                    IF counter = ((clk_period * stopbit) - 1) THEN
                        counter <= 0;
                        state <= transfer;
                        tx_done <= '1';
                    ELSE
                        counter <= counter + 1;
                    END IF;

            END CASE;
        END IF;
        END PROCESS;
    END Behavioral;