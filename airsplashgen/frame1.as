import flash.sampler.StackFrame;
import flash.display.BitmapData;
import com.hurlant.util.Base64;
import flash.utils.ByteArray;
import flash.events.Event;
import fl.display.ProLoader;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipOutput;

var arrSnapshotParam:Array = this.loaderInfo.parameters.snapshot.split(',');

var zipOut:ZipOutput;

var ldr:ProLoader = new ProLoader();
ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
var urlreq:URLRequest = new URLRequest("target.swf");
var ldrctx:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
//addChildAt(ldr, 0);
ldr.load(urlreq, ldrctx);

function completeHandler(e:Event):void
{
	zipOut = new ZipOutput();
	var cntEntry:Number = 0;

	while(arrSnapshotParam.length>=3)
	{
		btnSave.label = "ˆ—’†"+(cntEntry+1).toString();
		var h:Number = Number(arrSnapshotParam.pop());
		var w:Number = Number(arrSnapshotParam.pop());
		var filename:String = arrSnapshotParam.pop();
		addPNG2ZIP(filename, w, h, zipOut);
		cntEntry++;
	}
	if(cntEntry>0)
	{
		zipOut.finish();
		btnSave.addEventListener(MouseEvent.CLICK, onSave);
		btnSave.label = "ZIP•Û‘¶";
		btnSave.enabled = true;
	} else {
		btnSave.label = "¶¬‰æ‘œ0";
	}
}

function onSave(e:Event):void
{
	var fr:FileReference = new FileReference();
	fr.save(zipOut.byteArray, "splashImg.zip");
}
function addPNG2ZIP(filename:String, scrW:Number, scrH:Number, zipOut:ZipOutput):void
{
	var swf:DisplayObject = ldr.content as DisplayObject;
	var wW:Number = scrW;//Number(this.loaderInfo.parameters.width);
	var wH:Number = scrH;//Number(this.loaderInfo.parameters.height);
	var srcW:Number = Number(ldr.contentLoaderInfo.width);
	var srcH:Number = Number(ldr.contentLoaderInfo.height);
	var wRatio:Number = wW/srcW;
	var hRatio:Number = wH/srcH;
	
	ldr.graphics.beginFill(uint(this.loaderInfo.parameters.bgcolor));
    ldr.graphics.drawRect(-5,-5,wW+10, wH+10);
	
	var newW:Number;
	var newH:Number;
	if(wRatio > hRatio)
	{
		ldr.content.scaleX = hRatio;
		ldr.content.scaleY = hRatio;
		ldr.content.x = (wW-srcW*hRatio)/2;
		ldr.content.y = (wH-srcH*hRatio)/2;
		ldr.x = 0;
		newW = Number(ldr.contentLoaderInfo.width)*hRatio;
		newH = Number(ldr.contentLoaderInfo.height)*hRatio;
	} else {
		ldr.content.scaleX = wRatio;
		ldr.content.scaleY = wRatio;
		ldr.content.x = (wW-srcW*wRatio)/2;
		ldr.content.y = (wH-srcH*wRatio)/2;
		ldr.x = 0;
		newW = Number(ldr.contentLoaderInfo.width)*wRatio;
		newH = Number(ldr.contentLoaderInfo.height)*wRatio;
	}
	var scrBmp:BitmapData = new BitmapData(scrW, scrH);
	scrBmp.draw(ldr);
	var scrPNG:ByteArray = new ByteArray();
	scrBmp.encode(scrBmp.rect, new flash.display.PNGEncoderOptions(), scrPNG);
	
	zipOut.putNextEntry(new ZipEntry(filename));
	zipOut.write(scrPNG);
	zipOut.closeEntry();
}


stop();

