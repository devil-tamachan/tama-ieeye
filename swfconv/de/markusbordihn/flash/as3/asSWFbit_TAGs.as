/*
 asSWFbit_TAGs v0.2 - a ActionScript based SWF Decompiler / Compiler
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
 
 public class asSWFbit_TAGs {
  private static var Version:String = "0.2";                   // asSWFbit_TAGs Verison
  private static var _BITS_:Array = [1,2,4,8,16,32,64,128];    // Simple Bit Array for Bit Manipulations
  private var ActionParser;                                    // Action Parser for ActionScript
  private var _DATA_:ByteArray;                                // Keep the SWF Data to allow a faster parsing of the Data
  private var _CONTENT_:Object = {                             // General TAGs Object which cointain all TAGs and parsed Informations
   infos: {                                                    // - Info Object of File Informations and Meta Informations
    FileAttributes: {},
    Metadata: {},
    TAGs: {                                                    // - TAG Object for all the TAGs inside the SWF
     index: {},                                                // -- Small Search Index
     NumberOfTAGs: 0                                           // -- Save Number of TAGs for a faster access
     /*
     "ID[Position]" : {                                        // -- Example Entry for for a TAG each TAG has a unique ID
      type: 69,                                                // --- Tag Type
      name: "",                                                // --- Parsed Tag Type Name
      start: "",                                               // --- Start Position of the DATA
      end: "",                                                 // --- End Position of the DATA
      size: "",                                                // --- Size of the Informations (not include RECORDHEADER)
      pos: 0,                                                  // --- General Position of all TAGs
      raw: "",                                                 // --- Raw Content of the DATA
      content: ""                                              // --- Parsed Informations of the TAG when possible
     }
     */
    }
   }
  };

  private var _TAG_TYPE_:Object = {
    0 : { name: "End" },
    1 : { name: "ShowFrame" },
    2 : { name: "DefineShape" },
    4 : { name: "PlaceObject" },
    5 : { name: "RemoveObject" },
    6 : { name: "DefineBits" },
    7 : { name: "DefineButton" },
    8 : { name: "JPEGTables" },
    9 : { name: "SetBackgroundColor" },
   10 : { name: "DefineFont" },
   11 : { name: "DefineText" },
   12 : { name: "DoAction" },
   13 : { name: "DefineFontInfo" },
   14 : { name: "DefineSound" },
   15 : { name: "StartSound" },
   17 : { name: "DefineButtonSound" },
   18 : { name: "SoundStreamHead" },
   19 : { name: "SoundStreamBlock" },
   20 : { name: "DefineBitsLossless" },
   21 : { name: "DefineBitsJPEG2" },
   22 : { name: "DefineShape2" },
   23 : { name: "DefineButtonCxform" },
   24 : { name: "Protect" },
   26 : { name: "PlaceObject2" },
   28 : { name: "RemoveObject2" },
   32 : { name: "DefineShape3" },
   33 : { name: "DefineText2" },
   34 : { name: "DefineButton2" },
   35 : { name: "DefineBitsJPEG3" },
   36 : { name: "DefineBitsLossless2" },
   37 : { name: "DefineEditText" },
   39 : { name: "DefineSprite" },
   43 : { name: "FrameLabel" },
   45 : { name: "SoundStreamHead2" },
   46 : { name: "DefineMorphShape" },
   48 : { name: "DefineFont2" },
   56 : { name: "ExportAssets" },
   57 : { name: "ImportAssets" },
   58 : { name: "EnableDebugger" },
   59 : { name: "DoInitAction" },
   60 : { name: "DefineVideoStream" },
   61 : { name: "VideoFrame" },
   62 : { name: "DefineFontInfo2" },
   64 : { name: "EnableDebugger2" },
   65 : { name: "ScriptLimits" },
   66 : { name: "SetTabIndex" },
   69 : { name: "FileAttributes" },
   70 : { name: "PlaceObject3" },
   71 : { name: "ImportAssets2" },
   73 : { name: "DefineFontAlignZones" },
   74 : { name: "CSMTextSettings" },
   75 : { name: "DefineFont3" },
   76 : { name: "SymbolClass" },
   77 : { name: "Metadata" },
   78 : { name: "DefineScalingGrid" },
   82 : { name: "DoABC" },
   83 : { name: "DefineShape4" },
   84 : { name: "DefineMorphShape2" },
   86 : { name: "DefineSceneAndFrameLabelData" },
   87 : { name: "DefineBinaryData" },
   88 : { name: "DefineFontName" },
   89 : { name: "StartSound2" },
   90 : { name: "DefineBitsJPEG4" },
   91 : { name: "DefineFont4" }
  };

  /* Define get Types to read out the values */
  private function get_FileAttributes (_DATA_:ByteArray) : Object {
   /*
    Field         Type         Comment
    ============================================================================
    Header        RECORDHEADER Tag type = 69
    Reserved      UB[1]        Must be 0
    UseDirectBlit UB[1]        If 1, the SWF file uses hardware acceleration
                               to blit graphics to the screen, where such
                               acceleration is available.
                               If 0, the SWF file will not use hardware
                               accelerated graphics facilities.
                               Minimum file version is 10.
    UseGPU        UB[1]        If 1, the SWF file uses GPU compositing
                               features when drawing graphics, where such
                               acceleration is available.
                               If 0, the SWF file will not use hardware
                               accelerated graphics facilities.
                               Minimum file version is 10.
    HasMetadata   UB[1]        If 1, the SWF file contains the Metadata tag.
                               If 0, the SWF file does not contain the
                               Metadata tag.
    ActionScript3 UB[1]        If 1, this SWF uses ActionScript 3.0.
                               If 0, this SWF uses ActionScript 1.0 or 2.0.
                               Minimum file format version is 9.
    Reserved      UB[2]        Must be 0
    UseNetwork    UB[1]        If 1, this SWF file is given network file access
                               when loaded locally.
                               If 0, this SWF file is given local file access
                               when loaded locally.
   */

   return {
    UseDirectBlit : BIT(_DATA_,7),
    UseGPU        : BIT(_DATA_,6),
    HasMetadata   : BIT(_DATA_,5),
    ActionScript3 : BIT(_DATA_,4),
    UseNetwork    : BIT(_DATA_,1)
   }
  }

  private function get_Metadata (_DATA_:ByteArray) : Object {
   /*
    Field     Type          Comment
    ======================================
    Header    RECORDHEADER  Tag type = 77
    Metadata  STRING        XML Metadata
   */

   var 
    Metadata:XML = new XML(_DATA_.toString()),
    rdf:Namespace = new Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#"),
    xmp:Namespace = new Namespace("http://ns.adobe.com/xap/1.0/"),
	dc:Namespace = new Namespace("http://purl.org/dc/elements/1.1/");
	
   return {
    Description : {
     xmp : { 
      CreatorTool:  Metadata.rdf::Description.xmp::CreatorTool,
      CreateDate:   Metadata.rdf::Description.xmp::CreateDate,
      MetadataDate: Metadata.rdf::Description.xmp::MetadataDate,
      ModifyDate:   Metadata.rdf::Description.xmp::ModifyDate
     },
	 dc: {
	  format:      Metadata.rdf::Description.dc::format,
	  description: Metadata.rdf::Description.dc::description.rdf::Alt.rdf::li,
	  creator:     Metadata.rdf::Description.dc::creator.rdf::Seq.rdf::li,
	  title:       Metadata.rdf::Description.dc::title.rdf::Alt.rdf::li
	 }
    },
    raw : Metadata
   };
  }

  private function get_SetBackgroundColor (_DATA_:ByteArray) : Object {
   /*
    Field            Type          Comment
    ===============================================================
    Header           RECORDHEADER  Tag type = 9
    BackgroundColor  RGB           Color of the display background
   */
   var o:Object = RGB(_DATA_);
   return {
    BackgroundColor: o.RGB,
    BackgroundColorUInt: o.color,
    BackgroundColorUIntA: o.colorWithAlpha
   }
  }

  private function get_DoInitAction (_DATA_:ByteArray) : Object {
   /*
    Field Type Comment
    =========================================================================
    Header         RECORDHEADER                Tag type = 59
    Sprite ID      UI16                        Sprite to which these actions 
                                               apply
    Actions        ACTIONRECORD[zero or more]  List of actions to perform
    ActionEndFlag  UI8                         Always set to 0
   */

   return {
    SpriteID: _DATA_.readUnsignedShort(),
    Actions: parseActionRecord(_DATA_)
   };
   
  }

  private function get_DoAction (_DATA_:ByteArray) : Object {
   /*
    Field          Type          Comment
    ========================================================================
    Header         RECORDHEADER  Tag type = 12
    Actions        ACTIONRECORD  [zero or more] List of actions to perform 
                                 (see following table, ActionRecord)
    ActionEndFlag  UI8 = 0       Always set to 0
   */

   return {
    Actions: parseActionRecord(_DATA_)
   };
  }

  private function get_ScriptLimits (_DATA_:ByteArray) : Object {
   /*
    Field                 Type          Comment
    ============================================================================
    Header                RECORDHEADER  Tag type = 65
    MaxRecursionDepth     UI16          Maximum recursion depth
    ScriptTimeoutSeconds  UI16          Maximum ActionScript processing time 
                                        before script stuck dialog box displays
   */
   return {
    MaxRecursionDepth:    _DATA_.readUnsignedShort(),
    ScriptTimeoutSeconds: _DATA_.readUnsignedShort()
   }
  }

  private function parseActionRecord (_DATA_:ByteArray) : Object {
   /*
    Simple Parser for ActionRecord and check for ActionEndFlag
   */

   if (typeof this.ActionParser == 'undefined') {
       //this.ActionParser = new de.markusbordihn.flash.as3.asSWFbit_Actions();
   }

   if (typeof this.ActionParser != 'undefined') {
       var result = {Actions: ""};
       if (_DATA_.bytesAvailable >= 2) {
           var raw:ByteArray = new ByteArray();
           raw.endian = Endian.LITTLE_ENDIAN;
           _DATA_.readBytes(raw,0,_DATA_.bytesAvailable-1);
           var endtag = _DATA_.readByte();
           if (endtag == 0) {
               this.ActionParser.load(raw);
               //result = ActionParser.content;
           } else {
               trace('ActionRecord EndTag is not correct: ' + endtag);
           }
       } else {
           trace('ActionRecord is to short');
       }
   } else {
       //trace('asSWFBit Actions is not loaded, so ActionScript will be not parsed !');
   }
   return result;
  }

  private function create_function_mapping () : void {
   /*
    Dynamic Function Mapping for Read and Write Operations.
    All avalible Functions will be mapped to the TAG_TYPE Object.
   */
   trace('Create Dynamic Function Mapping');
    for(var _TAG_ in this._TAG_TYPE_){
        var functionName = this._TAG_TYPE_[_TAG_].name
        try {
         if (this["get_" + functionName] != null) {
             trace('- [Read]', functionName);
             this._TAG_TYPE_[_TAG_].get = this["get_" + functionName];
         }
        }
        catch(error: ReferenceError) {}
    }
  }

  public function asSWFbit_TAGs(... args) : void {
   trace('Load asSWFbit Tags Version: ' + Version + ' from Markus Bordihn (http://markusbordihn.de)');
   create_function_mapping();
   if (args) {
       if (args[0]) {
           trace('Data Type: ',typeof args[0]);
           if (typeof args[0] === "object" && args[0] !== null && args[0] !== "") {
               load(args[0]);
           }
       }
   }

  }

  public function load(_DATA_:ByteArray) : void {
   if (_DATA_) {
       this._DATA_ = _DATA_;
       trace('asSWFbit TAGs Load Data:' + this._DATA_.length, 'Format: ' + this._DATA_.endian);
   }
  }

  public function parse() : Object {
   /*
    Field             Type  Comment
    ===========================================================
    TagCodeAndLength  UI16  Upper 10 bits: tag type
                            Lower 6 bits: tag length
    Length            SI32  Only exists when TagCodeAndLength 
                            (tag length) lower 6 bits are 0x3F
   */   

   /*
    Simple Search Index for faster access of Informations
    ======================================================
     9 - Background Color
    65 - ScriptLimits
    69 - FileAttributes 
    77 - Metadata
   */
   var _SEARCH_INDEX_ = [9,65,69,77];
   var pos:int = 0;

   while (this._DATA_.bytesAvailable) {
          var 
           start:int = this._DATA_.position,
           tag:uint = this._DATA_.readUnsignedShort(),
           id:int = tag>>6,
           name:String = getName(id),
           unique_id:String = "ID" + pos,
           size:int = tag&0x3F,
           end:int = 0,
           raw:ByteArray = new ByteArray();
          
          /* Get RAW Data when avalible */
          if (this._DATA_.bytesAvailable) {
              if (size == 0x3F) {
                  size = this._DATA_.readUnsignedInt();
              }
              if (size > 0 && size <= this._DATA_.bytesAvailable) {
                  raw.endian = Endian.LITTLE_ENDIAN;
                  _DATA_.readBytes(raw,0,size);
              }
              end = (this._DATA_.position-1);
          } else {
              end = this._DATA_.position;
          }

          /* 
           Small Search Index for Important Informations
          */
          for(var i:uint = 0; i < _SEARCH_INDEX_.length; i++) {
               if (_SEARCH_INDEX_[i] == id) {
                   this._CONTENT_.infos.TAGs.index[name] = unique_id;  // Set Search Index to unique ID
                   _SEARCH_INDEX_.splice(i,1);                         // Remove ID from the Search Index
                   break;
               }
          }

          trace(pos + "\t[" + name + "]\t(" + tag + ")\tstart:" + start + "\tsize:" + size + "\tend:" + end);

          /*
            Save all Information in the TAG Object
          */
          this._CONTENT_.infos.TAGs[unique_id] = {
           type: id,
           name: name,
           start: start,
           end: end,
           size: size,
           pos: pos++,
           raw: raw,
           content: getContent(raw,id)
          };
          raw.clear();
   }
   if (this._CONTENT_.infos.TAGs.index) {
       setIndex();
   }
   this._CONTENT_.infos.TAGs.NumberOfTAGs = pos;
   return this._CONTENT_;
  }

  private function setIndex() : void {
   for (var _TAG_ in this._CONTENT_.infos.TAGs.index) {
        this._CONTENT_.infos[_TAG_] = this._CONTENT_.infos.TAGs[this._CONTENT_.infos.TAGs.index[_TAG_]].content;
   }
  }

  public function getName(id:Number) : String {
   var result:String = "-" + id + "-";
   if (this._TAG_TYPE_[id]) {
       if (this._TAG_TYPE_[id].name) {
           result = this._TAG_TYPE_[id].name;
       }
   }
   return result;
  }

  public function exists(id:Number) : Boolean {
   return (_TAG_TYPE_[id]) ? true : false;
  } 

  private function getContent(_DATA_:ByteArray,id:Number) : Object {
   var result:Object = new Object();
   if (_TAG_TYPE_[id]) {
       if (_TAG_TYPE_[id].get) {
           result = _TAG_TYPE_[id].get(_DATA_);
       } else {
           /* TAG_TYPE is not implemented yet ! */;
           result = "";
       }
   }
   return result;
  }

  public function getValues(_DATA_:ByteArray,id:Number,size:Number) : Object {
   var result:Object = new Object();
   var raw:ByteArray = new ByteArray();
   if (size > 0) {
       _DATA_.readBytes(raw,0,size);
   } else {
       raw = _DATA_;
   }
   return getContent(raw,id);
  }
  
  private function RGB(_DATA_:ByteArray) : Object {
   /*
    Field Type Comment
    ==============================
    Red    UI8  Red color value
    Green  UI8  Green color value
    Blue   UI8  Blue color value
   */
   var
    Red   = _DATA_.readUnsignedByte(),
    Green = _DATA_.readUnsignedByte(),
    Blue  = _DATA_.readUnsignedByte(),
    c:uint = (65280 + Red << 16 | Green << 8 | Blue),
    c2:uint = (Red << 16 | Green << 8 | Blue),
    RGB =  (256 + Red << 16 ^ Green << 8 ^ Blue).toString(16);

   return {
    Red:   Red,
    Green: Green,
    Blue:  Blue,
    RGB: RGB.substring(RGB.length-6),
    color: c2,
    colorWithAlpha: c
   }
  }

  private function BIT(_DATA_:ByteArray,_BIT_:Number) : Number {
   var result:int = 0;
   if (_DATA_[0]&_BITS_[_BIT_-1]) {
       result = 1;
   }
   return result;
  }
  
 }

}