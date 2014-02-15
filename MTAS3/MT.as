// �����Z���k�E�c�C�X�^�[ ActionScript3�ڐA��
// 0.2 (2014/02/15)
/*
�g����:

import MT;

for(var j:uint = 0;j<50;j++)
  trace(MT.randomMax(5).toString());//randomMax(5)�ŁA0�`5�̐��l���Ԃ��Ă���
for(var i:uint = 0;i<50;i++)
  trace(MT.random().toString()); //random()��AS3��Math.random()�Ɠ����B[0.0-1.0) <--1.0�͊܂܂�܂���B0.9999....�܂łł��B1.0�܂Ŋ܂݂����ꍇ�Arandom()��genrand_real1()�ɏ��������܂��傤

*/
/*
�ύX����:
0.2(2014/02/15) - �֐���static���B�ϐ��錾���s�v�ɁB
0.1(2014/02/15) - �ŏ��̃����[�X

*/

// Original mt19937ar.c:
//   Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura, All rights reserved.
//   Copyright (C) 2005, Mutsuo Saito, All rights reserved.
// http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/mt19937ar.html
//
/* 
   Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
   All rights reserved.                          
   Copyright (C) 2005, Mutsuo Saito,
   All rights reserved.                          
   Copyright (C) 2014, devil.tamachan@gmail.com,
   All rights reserved.                          

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

     1. Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

     2. Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.

     3. The names of its contributors may not be used to endorse or promote 
        products derived from this software without specific prior written 
        permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


package
{
  public class MT
  {
    static const N:int = 624;
    static const M:int = 397;
    static var mt:Vector.<uint> = new Vector.<uint>(624, true);
    static var mti:uint = 625;
    static const mag01:Vector.<uint> = new <uint>[0, 0x9908b0df];
    static const UPPER_MASK:uint = 0x80000000;
    static const LOWER_MASK:uint = 0x7fffffff;
    public function MT(seed:uint = 0):void
    {
      if(seed == 0)
      {
        if(mti == N+1)initByDate();
      } else {
        init(seed);
      }
    }
    /* generates a random number on [0,1)-real-interval */
    public static function random():Number
    {
      return genrand_uint32()*(1.0/4294967296.0);
    }
    /* [0-max] */
    public static function randomMax(max:uint):uint
    {
      return uint(Math.floor(random()*(Number(max)+1)));
    }
    
    public static function initByDate():void
    {
      var now:Date = new Date();
      init(uint(now.getTime()));
    }
    public static function init(seed:uint):void
    {
      mt[0]= seed & uint.MAX_VALUE;
      for (mti=1; mti<N; mti++) {
        mt[mti] = (uint(1812433253) * (mt[mti-1] ^ (mt[mti-1] >>> 30)) + mti);
        /* See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier. */
        /* In the previous versions, MSBs of the seed affect   */
        /* only MSBs of the array mt[].                        */
        /* 2002/01/09 modified by Makoto Matsumoto             */
        mt[mti] &= uint.MAX_VALUE;
        /* for >32 bit machines */
      }
    }
    /* generates a random number on [0,0xffffffff]-interval */
    public static function genrand_uint32():uint
    {
      var y:uint;
      //static uint mag01[2]={0x0UL, MATRIX_A};
      /* mag01[x] = x * MATRIX_A  for x=0,1 */
      
      if (mti >= N) { /* generate N words at one time */
        var kk:int;
        
        if (mti == N+1)   /* if init_genrand() has not been called, */
          initByDate();
        
        for (kk=0;kk<N-M;kk++) {
          y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
          mt[kk] = mt[kk+M] ^ (y >>> 1) ^ mag01[y & 0x1];
        }
        for (;kk<N-1;kk++) {
          y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
          mt[kk] = mt[kk+(M-N)] ^ (y >>> 1) ^ mag01[y & 0x1];
        }
        y = (mt[N-1]&UPPER_MASK)|(mt[0]&LOWER_MASK);
        mt[N-1] = mt[M-1] ^ (y >>> 1) ^ mag01[y & 0x1];

        mti = 0;
      }
      y = mt[mti++];
      
      /* Tempering */
      y ^= (y >>> 11);
      y ^= (y << 7) & uint(0x9d2c5680);
      y ^= (y << 15) & uint(0xefc60000);
      y ^= (y >>> 18);

      return y;
    }
    /* generates a random number on [0,1]-real-interval */
    public static function genrand_real1():Number
    {
      return genrand_uint32()*(1.0/4294967295.0);
    }
  }
}