/*
 * Copyright (c) 2015, Intel Corporation
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of the Intel Corporation nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE INTEL CORPORATION OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

ENTRY(_rom_start)

MEMORY
{
	rom_data (rw)	: ORIGIN = 0xFFFFE000, LENGTH = 1K		/* rom manufacturing data */
	rom (rw)	: ORIGIN = 0xFFFFE400, LENGTH = 7K - 16		/* rom */
	esram_idt (rw)	: ORIGIN = 0xA8000000, LENGTH = 0x220		/* idt (68 gates) */
	esram (rw)	: ORIGIN = 0xA8000220, LENGTH = 80K - 1K - 0x220 /* esram: ram size - stack - idt */
	stack (rw)	: ORIGIN = 0xA8013C00, LENGTH = 1K		/* stack */
}

/* Stack definition */
__stack_start = ORIGIN(stack) + LENGTH(stack);

/* IDT definition */
__idt_start = ORIGIN(esram_idt);
__idt_end = __idt_start + LENGTH(esram_idt);

SECTIONS
{
	. = ORIGIN(rom_data);
	/* Reserve area for manufacturing data */
	_rom_data_base = .;
	my : { } >rom_data

	. = ORIGIN(rom);
	.text :
	{
		*(.text.entry)
		*(.text)
		*(.text.last)
		*(.text.*)
	} >rom

	.rodata :
	{
		*(.rdata*)
		*(.rodata*)        /* .rodata*   sections (constants, strings, etc.) */
	} >rom

	.data :
	{
		*(.data*)
	} >esram  AT>rom

	.bss :
	{
		*(.bss*)
		*(COMMON)
	} >esram  AT>esram

	/* Symbols for C runtime init code. */
	__data_lma = LOADADDR(.data);
	__data_vma = ADDR(.data);
	__data_size = SIZEOF(.data);
	__bss_start = ADDR(.bss);
	__bss_end = __bss_start + SIZEOF(.bss);

	.comment 0 : { *(.comment) }
}
