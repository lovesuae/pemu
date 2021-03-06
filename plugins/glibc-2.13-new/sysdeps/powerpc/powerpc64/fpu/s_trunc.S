/* trunc function.  PowerPC64 version.
   Copyright (C) 2004, 2006 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#include <sysdep.h>
#include <math_ldbl_opt.h>

	.section	".toc","aw"
.LC0:	/* 2**52 */
	.tc FD_43300000_0[TC],0x4330000000000000
	.section	".text"
	
/* double [fp1] trunc (double x [fp1])
   IEEE 1003.1 trunc function.  IEEE specifies "trunc to the integer
   value, in floating format, nearest to but no larger in magnitude 
   then the argument."
   We set "round toward Zero" mode and trunc by adding +-2**52 then
   subtracting +-2**52.  */

EALIGN (__trunc, 4, 0)
	CALL_MCOUNT 0
	mffs	fp11		/* Save current FPU rounding mode.  */
	lfd	fp13,.LC0@toc(2)
	fabs	fp0,fp1
	fsub	fp12,fp13,fp13	/* generate 0.0  */
	fcmpu	cr7,fp0,fp13	/* if (fabs(x) > TWO52)  */
	fcmpu	cr6,fp1,fp12	/* if (x > 0.0)  */
	bnllr-	cr7
	mtfsfi	7,1		/* Set rounding toward 0 mode.  */
	ble-	cr6,.L4
	fadd	fp1,fp1,fp13	/* x+= TWO52;  */
	fsub	fp1,fp1,fp13	/* x-= TWO52;  */
	fabs	fp1,fp1		/* if (x == 0.0)  */
				/* x = 0.0; */
	mtfsf	0x01,fp11	/* restore previous rounding mode.  */
	blr
.L4:
	bge-	cr6,.L9		/* if (x < 0.0)  */
	fsub	fp1,fp1,fp13	/* x-= TWO52;  */
	fadd	fp1,fp1,fp13	/* x+= TWO52;  */
	fnabs	fp1,fp1		/* if (x == 0.0)  */
				/* x = -0.0; */
.L9:
	mtfsf	0x01,fp11	/* restore previous rounding mode.  */
	blr
	END (__trunc)

weak_alias (__trunc, trunc)

#ifdef NO_LONG_DOUBLE
weak_alias (__trunc, truncl)
strong_alias (__trunc, __truncl)
#endif
#if LONG_DOUBLE_COMPAT(libm, PEMU_LIBC_2_1)
compat_symbol (libm, __trunc, truncl, PEMU_LIBC_2_1)
#endif
