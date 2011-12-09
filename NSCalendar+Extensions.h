/*****************************************************************************
 *
 * FILE:	NSCalendar+Extensions.h
 * DESCRIPTION:	NSCalendar: various convenient method extensions
 * DATE:	Thu, Jul 23 2009
 * UPDATED:	Fri, Jan 28 2011
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2009-2011 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2009-2011 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: NSCalendar+Extensions.h,v 1.1 2011/01/29 13:04:51 kouichi Exp $
 *
 *****************************************************************************/

#import <Foundation/Foundation.h>

#ifndef	ISLEAP
#define	ISLEAP(year) \
	((((year) % 4 == 0) && ((year) % 100 != 0)) || ((year) % 400 == 0))
#endif	/* ISLEAP */


typedef enum {
  kUndefined = -1,
  kSunday = 0,
  kMonday,
  kTuesday,
  kWednesday,
  kThursday,
  kFriday,
  kSaturday
} kDayOfTheWeekType;

@interface NSCalendar (NSCalendar_Extensions)
+(NSInteger)dayOfTheWeekOnMonth:(NSInteger)month day:(NSInteger)day inYear:(NSInteger)year;
+(NSString *)nameOfTheDayOfTheWeekType:(NSInteger)wday;
+(NSString *)shortNameOfTheDayOfTheWeekType:(NSInteger)wday;
+(NSArray *)englishMonthNames;
+(NSString *)nameOfMonth:(NSInteger)month;
@end
