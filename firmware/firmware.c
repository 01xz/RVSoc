#include "firmware.h"


//----------------------------------------------------------------------------
// System function:
// irq
uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
    static uint32_t ext_irq_4_count = 0;
    static uint32_t ext_irq_5_count = 0;
    static uint32_t timer_irq_count = 0;

    // checking compressed isa q0 reg handling
    if ((irqs & 6) != 0) {
        uint32_t pc = (regs[0] & 1) ? regs[0] - 3 : regs[0] - 4;
        uint32_t instr = *(uint16_t*)pc;

        if ((instr & 3) == 3)
            instr = instr | (*(uint16_t*)(pc + 2)) << 16;

        if (((instr & 3) != 3) != (regs[0] & 1)) {
            print_str("Mismatch between q0 LSB and decoded instruction word! q0=0x");
            print_hex(regs[0], 8);
            print_str(", instr=0x");
            if ((instr & 3) == 3)
                print_hex(instr, 8);
            else
                print_hex(instr, 4);
            print_str("\n");
            __asm__ volatile ("ebreak");
        }
    }

    if ((irqs & (1<<4)) != 0) {
        ext_irq_4_count++;
        print_str("[EXT-IRQ-4]");
    }

    if ((irqs & (1<<5)) != 0) {
        ext_irq_5_count++;
        print_str("[EXT-IRQ-5]");
    }

    if ((irqs & 1) != 0) {
        timer_irq_count++;
        print_str("[TIMER-IRQ]");
        set_timer(10000000);
    }

    if ((irqs & 6) != 0)
    {
        uint32_t pc = (regs[0] & 1) ? regs[0] - 3 : regs[0] - 4;
        uint32_t instr = *(uint16_t*)pc;

        if ((instr & 3) == 3)
            instr = instr | (*(uint16_t*)(pc + 2)) << 16;

        print_str("\n");
        print_str("------------------------------------------------------------\n");

        if ((irqs & 2) != 0) {
            if (instr == 0x00100073 || instr == 0x9002) {
                print_str("EBREAK instruction at 0x");
                print_hex(pc, 8);
                print_str("\n");
            } else {
                print_str("Illegal Instruction at 0x");
                print_hex(pc, 8);
                print_str(": 0x");
                print_hex(instr, ((instr & 3) == 3) ? 8 : 4);
                print_str("\n");
            }
        }

        if ((irqs & 4) != 0) {
            print_str("Bus error in Instruction at 0x");
            print_hex(pc, 8);
            print_str(": 0x");
            print_hex(instr, ((instr & 3) == 3) ? 8 : 4);
            print_str("\n");
        }

        for (int i = 0; i < 8; i++)
        for (int k = 0; k < 4; k++)
        {
            int r = i + k*8;

            if (r == 0) {
                print_str("pc  ");
            } else
            if (r < 10) {
                print_chr('x');
                print_chr('0' + r);
                print_chr(' ');
                print_chr(' ');
            } else
            if (r < 20) {
                print_chr('x');
                print_chr('1');
                print_chr('0' + r - 10);
                print_chr(' ');
            } else
            if (r < 30) {
                print_chr('x');
                print_chr('2');
                print_chr('0' + r - 20);
                print_chr(' ');
            } else {
                print_chr('x');
                print_chr('3');
                print_chr('0' + r - 30);
                print_chr(' ');
            }

            print_hex(regs[r], 8);
            print_str(k == 3 ? "\n" : "    ");
        }

        print_str("------------------------------------------------------------\n");

        print_str("Number of fast external IRQs counted: ");
        print_dec(ext_irq_4_count);
        print_str("\n");

        print_str("Number of slow external IRQs counted: ");
        print_dec(ext_irq_5_count);
        print_str("\n");

        print_str("Number of timer IRQs counted: ");
        print_dec(timer_irq_count);
        print_str("\n");

        __asm__ volatile ("ebreak");
    }

    return regs;
}

// Simple delay
void delay(uint32_t t)
{
    while(t--) {
        asm volatile("nop"); 
    }
}

//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// Peripherals operation:
// Write a byte to UART
void uart_tx_data(uint8_t data)
{
    *(volatile uint32_t*)UART_TX_ADDR = data;
}

// Read a byte from UART
uint8_t uart_rx_data()
{
    return *(volatile uint32_t*)UART_RX_ADDR;
}

// Write GPIO
void gpio_set(uint32_t data)
{
    *(volatile uint32_t*)GPIO_ADDR = data;
}

// Read GPIO
uint32_t gpio_get(void)
{
    return *(volatile uint32_t*)GPIO_ADDR;
}

// Set PWM
void pwm_set(uint16_t step, uint16_t duty)
{
    *(volatile uint32_t*)PWM_ADDR = ((step << 16) | duty);
}

//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// Basic input output functions:
// print function
void print_chr(char ch)
{
    *((volatile uint32_t*)OUT_PORT) = ch;
}

void print_str(const char *p)
{
    while (*p != 0)
        *((volatile uint32_t*)OUT_PORT) = *(p++);
}

void print_dec(unsigned int val)
{
    char buffer[10];
    char *p = buffer;
    while (val || p == buffer) {
        *(p++) = val % 10;
        val = val / 10;
    }
    while (p != buffer) {
        *((volatile uint32_t*)OUT_PORT) = '0' + *(--p);
    }
}

void print_hex(unsigned int val, int digits)
{
    for (int i = (4*digits)-4; i >= 0; i -= 4)
        *((volatile uint32_t*)OUT_PORT) = "0123456789ABCDEF"[(val >> i) % 16];
}

char get_chr(void)
{
    return *((volatile uint32_t*)IN_PORT);
}

//----------------------------------------------------------------------------
