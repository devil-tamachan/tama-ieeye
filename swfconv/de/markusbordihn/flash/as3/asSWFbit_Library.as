/*
 asSWFbit_Library v0.2 - a ActionScript based SWF Decompiler / Compiler
 ==============================================================================
 Please visited also http://flash.area-network.de

 SWF v10 Specifications:
 http://www.adobe.com/devnet/swf/pdf/swf_file_format_spec_v10.pdf
 
 Copyright (c) 2007, Markus Bordihn (http://markusbordihn.de)
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the flash.area-network.de nor the names of its contributors
      may be used to endorse or promote products derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package de.markusbordihn.flash.as3 {
 
 import flash.utils.ByteArray;
 import flash.utils.Endian;
 import flash.errors.EOFError;
 
 public class asSWFbit_Library {
  
  private static var Version:String = "0.2";    // Version String
  private var _SWF_:ByteArray;                  // Keep the RAW Data of the flash file
  private var _MODE_:String = '';               // Set the Mode for the Library for e.g: Headers only
  public var infos:Object = {                   // Store the Informations of the flash file in a public avalible variable
   Header: {},
   FileAttributes: {},
   Metadata: {},
   TAGs: {}
  };

  public function asSWFbit_Library(... args) : void {
   trace('Load asSWFbit_Library Version: ' + Version + ' from Markus Bordihn (http://markusbordihn.de)');
   if (args) {
       if (args[0]) {
           if (typeof args[0] === "string" && args[0] !== null && args[0] !== "") {
               switch (args[0]) {
                case "Headers": 
                 this._MODE_ = "Headers";
                break;
           }
           trace('Set Mode to: ' + this._MODE_);
           }
       }
   }
  }

  public function parse(_DATA_:ByteArray) : Boolean {
   /*
    Field      Type Comment
    ================================================================
    Signature  UI8  Signature byte:
                    “F” indicates uncompressed
                    “C” indicates compressed (SWF 6 and later only)
    ...
   */

   var result:Boolean = false;
   if (_DATA_.length > 32) {
       _DATA_.endian = Endian.LITTLE_ENDIAN;
       var Signature:String = _DATA_.readMultiByte(3,"iso-8859-01");
       if (Signature === "FWS" || Signature === "CWS" || Signature === "ZWS") {
           trace('Found valid SWF File...\nParsing Headers...');
           this._SWF_ = _DATA_;
           this._SWF_.position = 0;
           get_SWFFileHeader();
           if(!isNaN(Number(this.infos.Header.Version))) {
              if (this._MODE_ !== "Headers") {
                  parseTAGs();
              }
              result = true;
           }
       } else {
           trace('Invalid SWF Signature...\nFAILED !');
       }
       _DATA_.clear();
   } else {
      trace('Datafile is to small for an SWF');
   }
   return result;
  }

  private function get_SWFFileHeader() : void {
   /*
    Field       Type  Comment
    =========================================================================
    Signature   UI8   Signature byte:
                      “F” indicates uncompressed
                      “C” indicates compressed (SWF 6 and later only)
    Signature   UI8   Signature byte always “W”
    Signature   UI8   Signature byte always “S”
    Version     UI8   Single byte file version (for example, 0x06 for SWF 6)
    FileLength  UI32  Length of entire file in bytes
    FrameSize   RECT  Frame size in twips
    FrameRate   UI16  Frame delay in 8.8 fixed number of frames per second
    FrameCount  UI16  Total number of frames in file
   */

   trace('Read Header Informations...');
   if (this._SWF_) {
       this.infos.Header.Signature  = this._SWF_.readMultiByte(3,"iso-8859-01"); // Signature
       this.infos.Header.Version    = this._SWF_.readByte();                     // Version
       this.infos.Header.FileLength = this._SWF_.readUnsignedInt();              // Filesize

       this._SWF_.readBytes(this._SWF_, 0, this._SWF_.length - 8);               // Remove first 8 Bytes

       if (this.infos.Header.Signature === "CWS") {                              // Check for Compress Content
           this._SWF_.uncompress();
           this.infos.Header.Compress = true;
      } else if (this.infos.Header.Signature === "ZWS") {                              // Check for Compress Content
           this._SWF_.uncompress("lzma");
           this.infos.Header.Compress = true;
       } else if (this.infos.Header.Signature === "FWS") {
           this._SWF_.position = 0;
           this._SWF_.length = this._SWF_.length - 8;
           this.infos.Header.Compress = false;
       }

       var
        FrameSize_Header:int = this._SWF_.readUnsignedByte()>>3,
        FrameSize_Bytes:ByteArray = new ByteArray();

       this._SWF_.position = 0;
       this._SWF_.readBytes(FrameSize_Bytes, 0, Math.ceil((5 + FrameSize_Header * 4)/8));
       this.infos.Header.FrameSize = FrameSize(FrameSize_Header,FrameSize_Bytes);
       this.infos.Header.Width  = ((this.infos.Header.FrameSize.Xmax - this.infos.Header.FrameSize.Xmin) / 20);
       this.infos.Header.Height = ((this.infos.Header.FrameSize.Ymax - this.infos.Header.FrameSize.Ymin) / 20);
       this.infos.Header.FrameRate = (this._SWF_.readUnsignedShort()/256);
       this.infos.Header.FrameCount = this._SWF_.readUnsignedShort();
       trace(
        ">> SWF HEADER >>",
        "Signature:"    +this.infos.Header.Signature,
        "\tCompress:"   +this.infos.Header.Compress,
        "\tVersion:"    +this.infos.Header.Version,
        "\tFileLength:" +this.infos.Header.FileLength,
        "\tWidth:"      +this.infos.Header.Width,
        "\tHeight:"     +this.infos.Header.Height,
        "\tFrameRate:"  +this.infos.Header.FrameRate,
        "\tFrameCount:" +this.infos.Header.FrameCount
       );
   }
  }

  function parseTAGs() : void {
   /*
    Parse the rest of the TAGs of the SWF file and load additional TAG Library.
    Display Information for some of the Informations which was found in the SWF file.
   */

   var 
    TAGParser = new de.markusbordihn.flash.as3.asSWFbit_TAGs(this._SWF_),
    Content = TAGParser.parse();

   if (this.infos.Header.Version >= 8) {
       /*
        File Attributes are only needed for Flash 8 and above.
       */
       this.infos.FileAttributes = Content.infos.FileAttributes;
       trace(
        ">> FileAttributes >>",
        "UseDirectBlit: "   +this.infos.FileAttributes.UseDirectBlit,
        "\tUseGPU: "        +this.infos.FileAttributes.UseGPU,
        "\tHasMetadata: "   +this.infos.FileAttributes.HasMetadata,
        "\tActionScript3: " +this.infos.FileAttributes.ActionScript3,
        "\tUseNetwork: "    +this.infos.FileAttributes.UseNetwork
       );
       if (this.infos.FileAttributes.HasMetadata) {
           /*
            Without the Meta Flag there should be no Meta Data
           */
           this.infos.Metadata = Content.infos.Metadata;
           trace(
            ">> MetaData >>",
            "CreatorTool: "    +this.infos.Metadata.Description.xmp.CreatorTool,
            "\tCreateDate: "   +this.infos.Metadata.Description.xmp.CreateDate,
            "\tMetadataDate: " +this.infos.Metadata.Description.xmp.MetadataDate,
            "\tModifyDate: "   +this.infos.Metadata.Description.xmp.ModifyDate,
			"\tformat: "       +this.infos.Metadata.Description.dc.format,
			"\tdescription: "  +this.infos.Metadata.Description.dc.description,
			"\tcreator: "      +this.infos.Metadata.Description.dc.creator,
			"\ttitle: "        +this.infos.Metadata.Description.dc.title
           );
       } else {
           this.infos.Metadata = null;
       }
   } else {
       this.infos.FileAttributes = null;
   }
   if (Content.infos.SetBackgroundColor) {
       this.infos.BackgroundColor = Content.infos.SetBackgroundColor.BackgroundColor;
       this.infos.BackgroundColorUInt = Content.infos.SetBackgroundColor.BackgroundColorUInt;
       this.infos.BackgroundColorUIntA = Content.infos.SetBackgroundColor.BackgroundColorUIntA;
       trace(
         ">> BackgroundColor >>", 
		 this.infos.BackgroundColor
        );
   } else {
      this.infos.BackgroundColor = null;
      this.infos.BackgroundColorUInt = null;
      this.infos.BackgroundColorUIntA = null;
   }
   if (Content.infos.ScriptLimits) {
       this.infos.ScriptLimits = Content.infos.ScriptLimits;
       trace(
        ">> ScriptLimits >>",
        "MaxRecursionDepth: "      +this.infos.ScriptLimits.MaxRecursionDepth,
        "\tScriptTimeoutSeconds: " +this.infos.ScriptLimits.ScriptTimeoutSeconds
       );
   } else {
       this.infos.ScriptLimits = null;
   }
   if (Content.infos.TAGs) {
       this.infos.TAGs = Content.infos.TAGs;
   } else {
       this.infos.TAGs = {};
   }

  }

  private function FrameSize(offset:int,data:ByteArray) : Object {
   /*
    Field  Type       Comment
    ================================================
    Nbits  UB[5]      Bits in each rect value field
    Xmin   SB[Nbits]  x minimum position for rect
    Xmax   SB[Nbits]  x maximum position for rect
    Ymin   SB[Nbits]  y minimum position for rect
    Ymax   SB[Nbits]  y maximum position for rect
   */

   return {
     Xmin: get_Bits(data,5,offset),
     Xmax: get_Bits(data,5+offset,offset),
     Ymin: get_Bits(data,5+offset*2,offset),
     Ymax: get_Bits(data,5+offset*3,offset)
   };
  }

  private function get_Bits(data:ByteArray,offset:int,size:int) : Number {
   /*
    Get the selected Bits from a ByteArray.
    Convert first the ByteArray to BitString and the simple substring the needed Bytes.
   */
   var BitArray:String  = "";
   data.position = 0;
   while (data.bytesAvailable) {
          var byte:String = (data.readByte()+256).toString(2);
          BitArray += byte.substring(byte.length-8);
   }
   return(parseInt((BitArray.substring(offset,offset+size)),2));   
  }

 }

}