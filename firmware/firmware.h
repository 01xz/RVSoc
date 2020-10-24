#ifndef FIRMWARE_H
#define FIRMWARE_H


//----------------------------------------------------------------------------
// Const defination:
// Peripherals' address
#define UART_RX_ADDR 0x80020004
#define UART_TX_ADDR 0x80020008
#define GPIO_ADDR    0x80010000
#define PWM_ADDR     0x80030000

#define IN_PORT      0x80020004
#define OUT_PORT     0x80020008

//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// Type defination:
typedef unsigned   char         uint8_t;
typedef signed     char         sint8_t;
typedef unsigned   short        uint16_t;
typedef signed     short        sint16_t;
typedef unsigned   int          uint32_t;
typedef signed     int          sint32_t;
typedef unsigned   long long    uint64_t;
typedef signed     long long    sint64_t;

//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// System function:
// irq
uint32_t *irq(uint32_t *regs, uint32_t irqs);

// Delay
void delay(uint32_t t);

// Set timer original value
void set_timer(uint32_t value);

//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// Peripherals operation:
// Write a byte to UART
void uart_tx_data(uint8_t data);

// Read a byte from UART
uint8_t uart_rx_data(void);

// Write GPIO
void gpio_set(uint32_t data);

// Read GPIO
uint32_t gpio_get(void);

// Set PWM
void pwm_set(uint16_t step, uint16_t duty);

//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// Basic input output functions:
// Print
void print_chr(char ch);
void print_str(const char *p);
void print_dec(uint32_t val);
void print_hex(uint32_t val, sint32_t digits);

// Get a char
char get_chr(void);

//----------------------------------------------------------------------------


#endif
