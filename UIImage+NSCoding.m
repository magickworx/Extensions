/*****************************************************************************
 *
 * FILE:	UIImage+NSCoding.m
 * DESCRIPTION:	UIImage: NSCoding extension
 * DATE:	Sun, Jul 24 2011
 * UPDATED:	Sun, Feb 12 2012
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2011-2012 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2011-2012 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
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
 * $Id: UIImage+NSCoding.m,v 1.2 2011/02/02 15:53:46 kouichi Exp $
 *
 *****************************************************************************/

#import "UIImage+NSCoding.h"

@implementation UIImage (NSCoding)

-(id)initWithCoder:(NSCoder *)decoder
{
  NSData *	data = [decoder decodeObjectForKey:@"UIImage"];

  self = [self initWithData:data];

  return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
  NSData *	data = UIImagePNGRepresentation(self);
  [encoder encodeObject:data forKey:@"UIImage"];
}

@end