ENTRY(reset_vec)

MEMORY
{
    code_mem(rx)	: ORIGIN = 0x00000000, LENGTH = 0x8000 /* 32KB */
    data_mem(xrw)   : ORIGIN = 0x00008000, LENGTH = 0x8000 /* 32KB */
}


SECTIONS {
    /* The program code and other data goes into code section */
    .text :
    {
        . = ALIGN(4);
        *(.text)           /* .text sections (code) */
        *(.text*)          /* .text* sections (code) */
        *(.rodata)         /* .rodata sections (constants, strings, etc.) */
        *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
        *(.srodata)        /* .rodata sections (constants, strings, etc.) */
        *(.srodata*)       /* .rodata* sections (constants, strings, etc.) */
        . = ALIGN(4);
    } > code_mem

    .data :
    {
        . = ALIGN(4);
        *(.data)			/* .data sections */
        *(.data*)			/* .data* sections */
        *(.sdata)			/* .sdata sections */
        *(.sdata*)			/* .sdata* sections */
        . = ALIGN(4);
    } >  data_mem

    /* Uninitialized data section */
    .bss :
    {
        . = ALIGN(4);
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
    } > data_mem

    /* this is to define the start of the heap, and make sure we have a minimum size */
    .heap :
    {
        . = ALIGN(4);
    } > data_mem
}
