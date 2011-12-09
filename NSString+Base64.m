/*****************************************************************************
 *
 * FILE:	NSString+Base64.m
 * DESCRIPTION:	NSString: base64 extensions
 * DATE:	Thu, Apr 29 2010
 * UPDATED:	Thu, Apr 29 2010
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2010 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2010 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
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
 * $Id: NSString_Base64.m,v 1.1 2010/05/01 21:41:25 kouichi Exp $
 *
 *****************************************************************************/

#import "NSString+Base64.h"

static const char	base64[] =
	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

@implementation NSString (NSString_Base64)

+(NSString *)base64EncodedStringWithData:(NSData *)data
{
  const char *	s = (const char *)[data bytes];
  NSUInteger	l = [data length];
  char *	t = (char *)malloc(l * 4 / 3 + 4);
  char *	p = t;

  /*
   * encode 3-bytes (24-bits) at a time
   */
  NSUInteger	n = l - (l % 3);
  NSUInteger	i;
  NSUInteger	j;	// 最終的な文字列長が格納される
  for (i = j = 0; i < n; i += 3, j += 4) {
    p[j]   = base64[( s[i]   & 0xfc) >> 2];
    p[j+1] = base64[((s[i]   & 0x03) << 4) | ((s[i+1] & 0xf0) >> 4)];
    p[j+2] = base64[((s[i+1] & 0x0f) << 2) | ((s[i+2] & 0xc0) >> 6)];
    p[j+3] = base64[( s[i+2] & 0x3f)];
  }

  i = n;	/* rest size */
  switch (l % 3) {
    case 2:	/* one character padding */
      p[j]   = base64[( s[i]   & 0xfc) >> 2];
      p[j+1] = base64[((s[i]   & 0x03) << 4) | ((s[i+1] & 0xf0) >> 4)];
      p[j+2] = base64[( s[i+1] & 0x0f) << 2];
      p[j+3] = base64[64];	/* Pad	*/
      j += 4;
      break;
    case 1:	/* two character padding */
      p[j]   = base64[(s[i] & 0xfc) >> 2];
      p[j+1] = base64[(s[i] & 0x03) << 4];
      p[j+2] = base64[64];	/* Pad	*/
      p[j+3] = base64[64];	/* Pad	*/
      j += 4;
      break;
    default:
      break;
  }
  p[j] = '\0';

  NSString *	sval = [NSString stringWithCString:t
				 encoding:NSASCIIStringEncoding];
  free(t);

  return sval;
}

-(NSString *)base64EncodedString
{
  return [NSString base64EncodedStringWithData:[self dataUsingEncoding:NSASCIIStringEncoding]];
}


-(NSString *)base64DecodedString
{
#if	0
#define	VAL(x)	(s[(x)] == '=' ? 0 : strchr(base64, s[(x)]) - base64)
  NSData *	d = [self dataUsingEncoding:NSASCIIStringEncoding];
  const char *	s = (const char *)[d bytes];
  NSUInteger	l = [d length];
  char *	t = (char *)malloc(l * 3 / 4 + 4);
  char *	p = t;

  /*
   * work on 4-words (24-bits) at a time
   */
  NSUInteger	i;
  NSUInteger	j;	// 最終的な文字列長が格納される
  for (i = j = 0; i < l; i += 4, j += 3) {
    p[j]   =  (VAL(i) << 2)	      | ((VAL(i+1) & 0x30) >> 4);
    p[j+1] = ((VAL(i+1) & 0x0f) << 4) | ((VAL(i+2) & 0x3c) >> 2); 
    p[j+2] = ((VAL(i+2) & 0x03) << 6) |  (VAL(i+3) & 0x3f);
  }
  /* remove padding data */
  if (s[l - 1] == '=') { j--; }
  if (s[l - 2] == '=') { j--; }

  p[j] = '\0';

  NSString *	sval = [NSString stringWithCString:t
				 encoding:NSASCIIStringEncoding];
  free(t);

  return sval;
#else
  NSData *	d = [self base64DecodedData];
  NSString *	s = [[NSString alloc]
		      initWithData:d encoding:NSASCIIStringEncoding];

  return [s autorelease];
#endif
}

-(NSData *)base64DecodedData
{
#define	VAL(x)	(s[(x)] == '=' ? 0 : strchr(base64, s[(x)]) - base64)
  NSData *	d = [self dataUsingEncoding:NSASCIIStringEncoding];
  const char *	s = (const char *)[d bytes];
  NSUInteger	l = [d length];
  char *	t = (char *)malloc(l * 3 / 4 + 4);
  char *	p = t;

  /*
   * work on 4-words (24-bits) at a time
   */
  NSUInteger	i;
  NSUInteger	j;	// 最終的な文字列長が格納される
  for (i = j = 0; i < l; i += 4, j += 3) {
    p[j]   =  (VAL(i) << 2)	      | ((VAL(i+1) & 0x30) >> 4);
    p[j+1] = ((VAL(i+1) & 0x0f) << 4) | ((VAL(i+2) & 0x3c) >> 2); 
    p[j+2] = ((VAL(i+2) & 0x03) << 6) |  (VAL(i+3) & 0x3f);
  }
  /* remove padding data */
  if (s[l - 1] == '=') { j--; }
  if (s[l - 2] == '=') { j--; }

  p[j] = '\0';

  NSData *	dval = [NSData dataWithBytes:t length:j];
  free(t);

  return dval;
}

@end
