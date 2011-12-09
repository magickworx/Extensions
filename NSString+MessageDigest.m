/*****************************************************************************
 *
 * FILE:	NSString+MessageDigest.m
 * DESCRIPTION:	NSString: Message-Digest extensions
 * DATE:	Thu, Apr 29 2010
 * UPDATED:	Fri, Jul  2 2010
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
 * $Id: NSString_MessageDigest.m,v 1.2 2010/07/02 05:15:31 kouichi Exp $
 *
 *****************************************************************************/

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#import "NSString+MessageDigest.h"

#ifndef	SHA_DIGEST_LENGTH
#define	SHA_DIGEST_LENGTH	20
#endif	/* SHA_DIGEST_LENGTH */

struct SHA1Context {
  uint32_t	 state[5];
  uint32_t	 count[2];
  unsigned char	buffer[64];
};

typedef struct SHA1Context SHA1_CTX;

static void	SHA1Init(SHA1_CTX * context);
static void	SHA1Update(SHA1_CTX * context, const void * data, size_t len);
static void	SHA1Final(unsigned char digest[20], SHA1_CTX * context);
static char *	SHA1End(SHA1_CTX * context, char * buf);
static char *	toHex(unsigned char digest[SHA_DIGEST_LENGTH], char * buf);

@implementation NSString (NSString_MessageDigest)

-(NSData *)sha1Data
{
  SHA1_CTX	ctx;
  NSData *	s = [self dataUsingEncoding:NSASCIIStringEncoding];
  const void *	d = [s bytes];
  size_t	l = [s length];
  unsigned char	digest[SHA_DIGEST_LENGTH];

  SHA1Init(&ctx);
  SHA1Update(&ctx, d, l);
  SHA1Final(digest, &ctx);

  return [NSData dataWithBytes:digest length:SHA_DIGEST_LENGTH];
}

-(NSString *)sha1String
{
  SHA1_CTX	ctx;
  NSData *	s = [self dataUsingEncoding:NSASCIIStringEncoding];
  const void *	d = [s bytes];
  size_t	l = [s length];
#if	0
  unsigned char	digest[SHA_DIGEST_LENGTH];
#endif

  SHA1Init(&ctx);
  SHA1Update(&ctx, d, l);
#if	0
  SHA1Final(digest, &ctx);
#endif
  /*
   * XXX:
   * ここで、digest を NSData で返せばバイナリ形式の SHA1 値となる。
   * [NSData dataWithBytes:digest length:SHA_DIGEST_LENGTH];
   *
   * でも、文字列として処理したいので 16進数表記に変換する。
   */
  char	buf[SHA_DIGEST_LENGTH * 2 + 1];
  memset(buf, 0, sizeof(buf));
  SHA1End(&ctx, buf);
#if	0
  register int	i;
  for (i = 0; i < SHA_DIGEST_LENGTH; i++) {
    strlcat(buf, digest[i], sizeof(buf));
  }
#endif

  return [NSString stringWithCString:(const char *)buf
		   encoding:NSASCIIStringEncoding];
}

// XXX: 以下のコードは RFC2104 の Sample Code を元に SHA1 用に改良した
-(NSData *)hmacDataWithSHA1ForKey:(NSString *)keyStr
{
#define	BYTE_LENGTH	64
  NSData *	textData = [self dataUsingEncoding:NSASCIIStringEncoding];
  uint8_t *	text	 = (uint8_t *)[textData bytes];	// pointer to data stream
  size_t	text_len = [textData length];	// length of data stream
  NSData *	keyData  = [keyStr dataUsingEncoding:NSASCIIStringEncoding];
  uint8_t *	key	 = (uint8_t *)[keyData bytes];	// pointer to authentication key
  size_t	key_len  = [keyData length];	// length of authentication key
  unsigned char	digest[SHA_DIGEST_LENGTH];	// caller digest to be filled in

  SHA1_CTX	ctx;
  uint8_t	k_ipad[65];	// inner padding - key XORd with ipad
  uint8_t	k_opad[65];	// outer padding - key XORd with ipad
  uint8_t	tk[SHA_DIGEST_LENGTH];
  unsigned int	i;

  /* if key is longer than 64 bytes reset it to key=SHA1(key) */
  if (key_len > BYTE_LENGTH) {
    SHA1_CTX	tctx;
    SHA1Init(&tctx);
    SHA1Update(&tctx, key, key_len);
    SHA1Final(tk, &tctx);

    key	    = tk;
    key_len = SHA_DIGEST_LENGTH;
  }

  /*
   * the HMAC_SHA1 transform look like:
   *
   * SHA1(K XOR opad, SHA1(K XOR ipad, text))
   *
   * where K is an n byte key
   * ipad is the byte 0x36 repeated 64 times
   * opad is the byte 0x5c repeated 64 times
   * and text is the data being protected
   */

  /* start out by storing key in pads */
  memset(k_ipad, 0, sizeof(k_ipad));
  memset(k_opad, 0, sizeof(k_opad));
  memcpy(k_ipad, key, key_len);
  memcpy(k_opad, key, key_len);

  /* XOR key with ipad and opad values */
  for (i = 0; i < BYTE_LENGTH; i++) {
    k_ipad[i] ^= 0x36;
    k_opad[i] ^= 0x5c;
  }
  /*
   * perform inner SHA1
   */
  SHA1Init(&ctx);				// init context for 1st pass
  SHA1Update(&ctx, k_ipad, BYTE_LENGTH);	// start with inner pad
  SHA1Update(&ctx, text, text_len);		// then text of datagram
  SHA1Final(digest, &ctx);			// finish up 1st pass
  /*
   * perform outer SHA1
   */
  SHA1Init(&ctx);				// init context for 2nd pass
  SHA1Update(&ctx, k_opad, BYTE_LENGTH);	// start with outer pad
  SHA1Update(&ctx, digest, SHA_DIGEST_LENGTH);	// then results of 1st hash
  SHA1Final(digest, &ctx);			// finish up 2nd pass

  return [NSData dataWithBytes:digest length:SHA_DIGEST_LENGTH];
}

-(NSString *)hmacStringWithSHA1ForKey:(NSString *)keyStr
{
  NSData *	d = [self hmacDataWithSHA1ForKey:keyStr];
  unsigned char	digest[SHA_DIGEST_LENGTH];
  char		buf[SHA_DIGEST_LENGTH * 2 + 1];

  memset(buf, 0, sizeof(buf));
  memcpy(digest, [d bytes], SHA_DIGEST_LENGTH);
  toHex(digest, buf);

  return [NSString stringWithCString:(const char *)buf
		   encoding:NSASCIIStringEncoding];
}

@end

/*****************************************************************************/

static char *
toHex(unsigned char digest[SHA_DIGEST_LENGTH], char * buf)
{
  size_t	len = SHA_DIGEST_LENGTH * 2 + 1;
  unsigned int	i;
  int		n;

  for (n = i = 0; i < SHA_DIGEST_LENGTH; i++) {
    n += snprintf(&buf[n], len - n, "%02x", digest[i]);
  }

  return buf;
}

static char *
SHA1End(SHA1_CTX * context, char * buf)
{
#if	0
  unsigned char	digest[SHA_DIGEST_LENGTH];
  size_t	len = SHA_DIGEST_LENGTH * 2 + 1;
  unsigned int	i;
  int		n;

  SHA1Final(digest, context);

  for (n = i = 0; i < SHA_DIGEST_LENGTH; i++) {
    n += snprintf(&buf[n], len - n, "%02x", digest[i]);
  }

  return buf;
#else
  unsigned char	digest[SHA_DIGEST_LENGTH];

  SHA1Final(digest, context);

  return toHex(digest, buf);
#endif
}

/*
SHA-1 in C
By Steve Reid <sreid@sea-to-sky.net>
100% Public Domain

-----------------
Modified 7/98 
By James H. Brown <jbrown@burgoyne.com>
Still 100% Public Domain

Corrected a problem which generated improper hash values on 16 bit machines
Routine SHA1Update changed from
	void SHA1Update(SHA1_CTX* context, unsigned char* data, unsigned int
len)
to
	void SHA1Update(SHA1_CTX* context, unsigned char* data, unsigned
long len)

The 'len' parameter was declared an int which works fine on 32 bit machines.
However, on 16 bit machines an int is too small for the shifts being done
against
it.  This caused the hash function to generate incorrect values if len was
greater than 8191 (8K - 1) due to the 'len << 3' on line 3 of SHA1Update().

Since the file IO in main() reads 16K at a time, any file 8K or larger would
be guaranteed to generate the wrong hash (e.g. Test Vector #3, a million
"a"s).

I also changed the declaration of variables i & j in SHA1Update to 
unsigned long from unsigned int for the same reason.

These changes should make no difference to any 32 bit implementations since
an
int and a long are the same size in those environments.

--
I also corrected a few compiler warnings generated by Borland C.
1. Added #include <process.h> for exit() prototype
2. Removed unused variable 'j' in SHA1Final
3. Changed exit(0) to return(0) at end of main.

ALL changes I made can be located by searching for comments containing 'JHB'
-----------------
Modified 8/98
By Steve Reid <sreid@sea-to-sky.net>
Still 100% public domain

1- Removed #include <process.h> and used return() instead of exit()
2- Fixed overwriting of finalcount in SHA1Final() (discovered by Chris Hall)
3- Changed email address from steve@edmweb.com to sreid@sea-to-sky.net

-----------------
Modified 4/01
By Saul Kravitz <Saul.Kravitz@celera.com>
Still 100% PD
Modified to run on Compaq Alpha hardware.  

-----------------
Modified 4/01
By Jouni Malinen <j@w1.fi>
Minor changes to match the coding style used in Dynamics.

Modified September 24, 2004
By Jouni Malinen <j@w1.fi>
Fixed alignment issue in SHA1Transform when SHA1HANDSOFF is defined.

*/

/*
Test Vectors (from FIPS PUB 180-1)
"abc"
  A9993E36 4706816A BA3E2571 7850C26C 9CD0D89D
"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
  84983E44 1C3BD26E BAAE4AA1 F95129E5 E54670F1
A million repetitions of "a"
  34AA973C D4C4DAA4 F61EEB2B DBAD2731 6534016F
*/

#define SHA1HANDSOFF

#define rol(value, bits) (((value) << (bits)) | ((value) >> (32 - (bits))))

/* blk0() and blk() perform the initial expand. */
/* I got the idea of expanding during the round function from SSLeay */
#ifndef WORDS_BIGENDIAN
#define blk0(i) (block->l[i] = (rol(block->l[i], 24) & 0xFF00FF00) | \
	(rol(block->l[i], 8) & 0x00FF00FF))
#else
#define blk0(i) block->l[i]
#endif
#define blk(i) (block->l[i & 15] = rol(block->l[(i + 13) & 15] ^ \
	block->l[(i + 8) & 15] ^ block->l[(i + 2) & 15] ^ block->l[i & 15], 1))

/* (R0+R1), R2, R3, R4 are the different operations used in SHA1 */
#define R0(v,w,x,y,z,i) \
	z += ((w & (x ^ y)) ^ y) + blk0(i) + 0x5A827999 + rol(v, 5); \
	w = rol(w, 30);
#define R1(v,w,x,y,z,i) \
	z += ((w & (x ^ y)) ^ y) + blk(i) + 0x5A827999 + rol(v, 5); \
	w = rol(w, 30);
#define R2(v,w,x,y,z,i) \
	z += (w ^ x ^ y) + blk(i) + 0x6ED9EBA1 + rol(v, 5); w = rol(w, 30);
#define R3(v,w,x,y,z,i) \
	z += (((w | x) & y) | (w & x)) + blk(i) + 0x8F1BBCDC + rol(v, 5); \
	w = rol(w, 30);
#define R4(v,w,x,y,z,i) \
	z += (w ^ x ^ y) + blk(i) + 0xCA62C1D6 + rol(v, 5); \
	w=rol(w, 30);


/* Hash a single 512-bit block. This is the core of the algorithm. */

static void
SHA1Transform(uint32_t state[5], const unsigned char buffer[64])
{
  uint32_t a, b, c, d, e;
  typedef union {
    unsigned char	c[64];
    uint32_t		l[16];
  } CHAR64LONG16;
  CHAR64LONG16 *	block;
#ifdef SHA1HANDSOFF
  uint32_t		workspace[16];

  block = (CHAR64LONG16 *) workspace;
  memcpy(block, buffer, 64);
#else
  block = (CHAR64LONG16 *) buffer;
#endif
  /* Copy context->state[] to working vars */
  a = state[0];
  b = state[1];
  c = state[2];
  d = state[3];
  e = state[4];
  /* 4 rounds of 20 operations each. Loop unrolled. */
  R0(a,b,c,d,e, 0); R0(e,a,b,c,d, 1); R0(d,e,a,b,c, 2); R0(c,d,e,a,b, 3);
  R0(b,c,d,e,a, 4); R0(a,b,c,d,e, 5); R0(e,a,b,c,d, 6); R0(d,e,a,b,c, 7);
  R0(c,d,e,a,b, 8); R0(b,c,d,e,a, 9); R0(a,b,c,d,e,10); R0(e,a,b,c,d,11);
  R0(d,e,a,b,c,12); R0(c,d,e,a,b,13); R0(b,c,d,e,a,14); R0(a,b,c,d,e,15);
  R1(e,a,b,c,d,16); R1(d,e,a,b,c,17); R1(c,d,e,a,b,18); R1(b,c,d,e,a,19);
  R2(a,b,c,d,e,20); R2(e,a,b,c,d,21); R2(d,e,a,b,c,22); R2(c,d,e,a,b,23);
  R2(b,c,d,e,a,24); R2(a,b,c,d,e,25); R2(e,a,b,c,d,26); R2(d,e,a,b,c,27);
  R2(c,d,e,a,b,28); R2(b,c,d,e,a,29); R2(a,b,c,d,e,30); R2(e,a,b,c,d,31);
  R2(d,e,a,b,c,32); R2(c,d,e,a,b,33); R2(b,c,d,e,a,34); R2(a,b,c,d,e,35);
  R2(e,a,b,c,d,36); R2(d,e,a,b,c,37); R2(c,d,e,a,b,38); R2(b,c,d,e,a,39);
  R3(a,b,c,d,e,40); R3(e,a,b,c,d,41); R3(d,e,a,b,c,42); R3(c,d,e,a,b,43);
  R3(b,c,d,e,a,44); R3(a,b,c,d,e,45); R3(e,a,b,c,d,46); R3(d,e,a,b,c,47);
  R3(c,d,e,a,b,48); R3(b,c,d,e,a,49); R3(a,b,c,d,e,50); R3(e,a,b,c,d,51);
  R3(d,e,a,b,c,52); R3(c,d,e,a,b,53); R3(b,c,d,e,a,54); R3(a,b,c,d,e,55);
  R3(e,a,b,c,d,56); R3(d,e,a,b,c,57); R3(c,d,e,a,b,58); R3(b,c,d,e,a,59);
  R4(a,b,c,d,e,60); R4(e,a,b,c,d,61); R4(d,e,a,b,c,62); R4(c,d,e,a,b,63);
  R4(b,c,d,e,a,64); R4(a,b,c,d,e,65); R4(e,a,b,c,d,66); R4(d,e,a,b,c,67);
  R4(c,d,e,a,b,68); R4(b,c,d,e,a,69); R4(a,b,c,d,e,70); R4(e,a,b,c,d,71);
  R4(d,e,a,b,c,72); R4(c,d,e,a,b,73); R4(b,c,d,e,a,74); R4(a,b,c,d,e,75);
  R4(e,a,b,c,d,76); R4(d,e,a,b,c,77); R4(c,d,e,a,b,78); R4(b,c,d,e,a,79);
  /* Add the working vars back into context.state[] */
  state[0] += a;
  state[1] += b;
  state[2] += c;
  state[3] += d;
  state[4] += e;
  /* Wipe variables */
  a = b = c = d = e = 0;
#ifdef SHA1HANDSOFF
  memset(block, 0, 64);
#endif
}


/* SHA1Init - Initialize new context */

static void
SHA1Init(SHA1_CTX * context)
{
  /* SHA1 initialization constants */
  context->state[0] = 0x67452301;
  context->state[1] = 0xEFCDAB89;
  context->state[2] = 0x98BADCFE;
  context->state[3] = 0x10325476;
  context->state[4] = 0xC3D2E1F0;
  context->count[0] = context->count[1] = 0;
}


/* Run your data through this. */

static void
SHA1Update(SHA1_CTX * context, const void * _data, size_t len)
{
  uint32_t		i, j;
  const unsigned char *	data = _data;

  j = (context->count[0] >> 3) & 63;
  if ((context->count[0] += len << 3) < (len << 3)) {
    context->count[1]++;
  }
  context->count[1] += (len >> 29);
  if ((j + len) > 63) {
    memcpy(&context->buffer[j], data, (i = 64-j));
    SHA1Transform(context->state, context->buffer);
    for ( ; i + 63 < len; i += 64) {
      SHA1Transform(context->state, &data[i]);
    }
    j = 0;
  }
  else {
    i = 0;
  }
  memcpy(&context->buffer[j], &data[i], len - i);
}


/* Add padding and return the message digest. */

static void
SHA1Final(unsigned char digest[20], SHA1_CTX * context)
{
  uint32_t	i;
  unsigned char	finalcount[8];

  for (i = 0; i < 8; i++) {
    finalcount[i] = (unsigned char)((context->count[(i >= 4 ? 0 : 1)] >> ((3-(i & 3)) * 8) ) & 255);  /* Endian independent */
  }
  SHA1Update(context, (unsigned char *)"\200", 1);
  while ((context->count[0] & 504) != 448) {
    SHA1Update(context, (unsigned char *)"\0", 1);
  }
  SHA1Update(context, finalcount, 8);  /* Should cause a SHA1Transform() */

  for (i = 0; i < 20; i++) {
    digest[i] = (unsigned char)((context->state[i >> 2] >> ((3 - (i & 3)) * 8)) & 255);
  }
  /* Wipe variables */
  i = 0;
  memset(context->buffer, 0, 64);
  memset(context->state, 0, 20);
  memset(context->count, 0, 8);
  memset(finalcount, 0, 8);
}
