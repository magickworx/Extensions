/*****************************************************************************
 *
 * FILE:	NSCalendar+Extensions.m
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
 * $Id: NSCalendar+Extensions.m,v 1.1 2011/01/29 13:04:51 kouichi Exp $
 *
 *****************************************************************************/

#import "NSCalendar+Extensions.h"

@implementation NSCalendar (NSCalendar_Extensions)

+(NSInteger)dayOfTheWeekOnMonth:(NSInteger)month
	day:(NSInteger)day
	inYear:(NSInteger)year
{
  if (year > 1582) {
    if (month < 3) {
      year--;
      month += 12;
    }

    NSInteger	val;
    val = (year + (int)(year / 4) - (int)(year / 100) + (int)(year / 400)
	+ (int)((13 * month + 8) / 5) + day) % 7;

    return val;
  }

  return kUndefined;
}

static NSArray *	wdays;

+(NSString *)nameOfTheDayOfTheWeekType:(NSInteger)wday
{
  wdays = [NSArray arrayWithObjects:
		   NSLocalizedString(@"Sunday", @""),
		   NSLocalizedString(@"Monday", @""),
		   NSLocalizedString(@"Tuesday", @""),
		   NSLocalizedString(@"Wednesday", @""),
		   NSLocalizedString(@"Thursday", @""),
		   NSLocalizedString(@"Friday", @""),
		   NSLocalizedString(@"Saturday", @""),
		   nil];

  if (wday >= kUndefined && wday < wdays.count) {
    return [wdays objectAtIndex:wday];
  }

  return @"";
}

static NSArray *	wdays2;

+(NSString *)shortNameOfTheDayOfTheWeekType:(NSInteger)wday
{
  wdays2 = [NSArray arrayWithObjects:
		   NSLocalizedString(@"Sun", @""),
		   NSLocalizedString(@"Mon", @""),
		   NSLocalizedString(@"Tue", @""),
		   NSLocalizedString(@"Wed", @""),
		   NSLocalizedString(@"Thu", @""),
		   NSLocalizedString(@"Fri", @""),
		   NSLocalizedString(@"Sat", @""),
		   nil];

  if (wday >= kUndefined && wday < wdays2.count) {
    return [wdays2 objectAtIndex:wday];
  }

  return @"";
}


static NSArray *	monthNames;

+(NSArray *)englishMonthNames
{
  monthNames = [NSArray arrayWithObjects:
			NSLocalizedString(@"January", @""),
			NSLocalizedString(@"February", @""),
			NSLocalizedString(@"March", @""),
			NSLocalizedString(@"April", @""),
			NSLocalizedString(@"May", @""),
			NSLocalizedString(@"June", @""),
			NSLocalizedString(@"July", @""),
			NSLocalizedString(@"August", @""),
			NSLocalizedString(@"September", @""),
			NSLocalizedString(@"October", @""),
			NSLocalizedString(@"November", @""),
			NSLocalizedString(@"December", @""),
			nil];

  return monthNames;
}

+(NSString *)nameOfMonth:(NSInteger)month
{
  NSArray *	monthNames = [NSCalendar englishMonthNames];
  if (month >= 1 && month <= monthNames.count) {
    return [monthNames objectAtIndex:(month - 1)];
  }

  return @"";
}

@end
