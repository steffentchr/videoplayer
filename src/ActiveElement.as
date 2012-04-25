import flash.events.ErrorEvent;
import mx.events.VideoEvent;
[Bindable] public var numVideoElements:int = 0;
[Bindable] public var currentElementIndex:int = 0;
[Bindable] public var activeElement:HashCollection = new HashCollection();
public var itemsArray: Array;
private var supportedFormats:Array = [];
[Bindable]public var currentVideoFormat:String = 'video_medium';
[Bindable] public var showBeforeIdentity:Boolean = false; 

private function initActiveElement():void {
	resetActiveElement();
}
 
private function resetActiveElement():void {
  	activeElement.put('photo_id', '');
	activeElement.put('video_p', false);
  	activeElement.put('title', '');
  	activeElement.put('content', '');
	activeElement.put('date', '');
	activeElement.put('short_date', '');
  	activeElement.put('link', '');
	activeElement.put('album_id', '');
  	activeElement.put('videoSource', '');
  	activeElement.put('photoSource', '');
  	activeElement.put('photoWidth', new Number(0));
  	activeElement.put('photoHeight', new Number(0));
  	activeElement.put('aspectRatio', new Number(1));
	activeElement.put('beforeDownloadType', ''); 
	activeElement.put('beforeDownloadUrl', '');
	activeElement.put('beforeLink', ''); 
	activeElement.put('afterDownloadType', ''); 
	activeElement.put('afterDownloadUrl', ''); 
	activeElement.put('afterLink', ''); 
	activeElement.put('afterText', '');
	activeElement.put('length', '0');
	activeElement.put('start', '0');
	activeElement.put('skip', '0');
	activeElement.put('live', false);
	
	// Reset other stuff related to the active video
	clearVideo();
	//progress.setSections([]);
}

private function setActiveElementToLiveStream(stream:Object, startPlaying:Boolean=false):void {
	resetActiveElement();

	// Handle video title and description
	var title:String = stream.name.replace(new RegExp('(<([^>]+)>)', 'ig'), '');
	activeElement.put('video_p', true);
	activeElement.put('photo_id', stream.liveevent_stream_id);
	activeElement.put('title', title);
	activeElement.put('content', "");
	activeElement.put('hasInfo', false);
	activeElement.put('link', stream.one);
	activeElement.put('length', 0); 
	activeElement.put('start', 0);
	activeElement.put('skip', false);
	activeElement.put('live', true);
	activeElement.put('one', props.get('site_url') + stream.one); 
	activeElement.put('photoSource', props.get('site_url') + stream.large_download);
	activeElement.put('videoSource', stream.rtmp_stream);
	video.source = getFullVideoSource();
	
	showVideoElement();
	if(startPlaying) playVideoElement();

	// Aspect ratios
	activeElement.put('aspectRatio', stream.thumbnail_large_aspect_ratio*1.0);
	video.aspectRatio = 0;
	
	// Make embed code current
	updateCurrentVideoEmbedCode();
	
	// Note that we've loaded the video 
	reportEvent('load');

}

private function setActiveElement(i:int, startPlaying:Boolean=false, start:Number=0, skip:int=0, format:String=null):Boolean {
	if (!context || !context.photos || !context.photos[i]) return(false);
	resetActiveElement();

	numVideoElements = context.photos.length;
	currentElementIndex = i;
	var o:Object = context.photos[i];
  	var video_p:Boolean = new Boolean(parseInt(o.video_p)) && new Boolean(parseInt(o.video_encoded_p));
  	activeElement.put('video_p', video_p);
  	
  	// Handle video title and description
  	var title:String = o.title.replace(new RegExp('(<([^>]+)>)', 'ig'), '');
  	var content:String = o.content_text.replace(new RegExp('(<([^>]+)>)', 'ig'), '');
  	var hasInfo:Boolean =  (props.get('showDescriptions') && (title.length>0 || content.length>0));
  	activeElement.put('photo_id', o.photo_id);
  	//activeElement.put('title', title);
	activeElement.put('title', o.album_title)
	activeElement.put('album_id', o.album_id);
  	activeElement.put('content', content);
	activeElement.put('date', o.publish_date__date);
	activeElement.put('short_date', o.publish_date_ansi.substr(8,2) + '/' + o.publish_date_ansi.substr(5,2) + '/' + o.publish_date_ansi.substr(2,2));
  	activeElement.put('hasInfo', hasInfo);
  	activeElement.put('link', o.one);
  	activeElement.put('length', o.video_length); 
  	activeElement.put('start', start);
  	activeElement.put('skip', skip);
	smallPlayheadTime.text = formatTime(activeElement.getNumber('length'));
	
	// Supported formats, default format and build menu
	if(!skip) prepareSupportedFormats(o);
	// Switch to format if needed
	setVideoFormat(format || currentVideoFormat);
	
	// Link back to the video
	activeElement.put('one', props.get('site_url') + o.one); 
  	
  	// Photo source
  	activeElement.put('photoSource', props.get('site_url') + o.large_download);
  	activeElement.put('photoWidth', new Number(o.large_width));
  	activeElement.put('photoHeight', new Number(o.large_height));
	
	// Aspect ratios
	var ar:Number = parseInt(o.large_width) / parseInt(o.large_height);
  	activeElement.put('aspectRatio', ar);
	video.aspectRatio = ar;
 
 	if(video_p) {
  		showVideoElement();
  		if (props.get('autoPlay') || props.get('loop') || startPlaying) playVideoElement();
  	} else {
  		showImageElement();
  	}

	// Make embed code current
	updateCurrentVideoEmbedCode();

	// Note that we've loaded the video 
	reportEvent('load');

	return(true);
} 	

private function prepareSupportedFormats(o:Object):void {
	// Reset list
	supportedFormats = [];
	supportedFormats.push({format:'video_medium', pseudo:true, label: 'Standard (360p)', source:props.get('site_url') + o.video_medium_download});
}
public function setVideoFormat(format:String):void {
	var o:Object = null;
	for (var i:Object in supportedFormats) {
		if(supportedFormats[i].format==format) {
			o = supportedFormats[i];
			continue;
		}
	}
	if(!o) o=supportedFormats[supportedFormats.length-1];
	if(!o.pseudo) activeElement.put('start', 0);
	activeElement.put('videoSource', o.source);
	currentVideoFormat = o.format;
}

public function switchVideoFormat(format:String):void {
	setActiveElement(currentElementIndex, true, video.playheadTime+activeElement.getNumber('start'), 1, format);
}

private function goToActiveElement():void {
	goToUrl(activeElement.get('one') as String);
}

private function createItemsArray(p:Object) : Array {
	itemsArray = new Array();
	if (!p.photos) return(itemsArray);
	for(var i:Number = 0 ; i < p.photos.length; i++) {
		var o:Object = p.photos[i];
		var item : Object = new Object();
		item.itemID = i;		
		item.photoSource = props.get('site_url') + o.small_download;
		item.photoWidth = new Number(o.large_width);
		item.photoHeight = new Number(o.large_height);
		item.aspectRatio = parseInt(o.large_width) / parseInt(o.large_height);
		//if (o.content_text.length && !o.title.length) {o.title=o.content_text; o.content_text='';} 
		item.title = o.title.replace(new RegExp('(<([^>]+)>)', 'ig'), '');
		itemsArray.push(item);
	}
	return itemsArray;
}

private function clearVideo():void {
	video.source = null; video.visible = false;
    if(video.playing) {video.stop(); video.close();}
}
private function previousElement():Boolean {
	return(setActiveElement(currentElementIndex-1));
}
private function nextElement():Boolean {
	return(setActiveElement(currentElementIndex+1));
}
private function setElementByID(id:Number, startPlaying:Boolean=false):void {
	clearVideo(); 
	setActiveElement(id, startPlaying);
}

private function showImageElement():void {
	clearVideo(); 
}
private function showVideoElement():void {
}

public function playVideoElement():void {
	if(!activeElement.get('video_p')) return;
	//video.visible=true;
	//videoControls.visible=true;
	video.source = getFullVideoSource();
	video.play();
}
private function pauseVideoElement():void {
	try {
		video.pause();
	}catch(e:ErrorEvent){}
}

private function getFullVideoSource():String {
	var joinChar:String = (/\?/.test(activeElement.getString('videoSource')) ? '&' : '?');
	return(activeElement.getString('videoSource') + joinChar + 'start=' + encodeURIComponent(activeElement.getString('start')) + '&skip=' + encodeURIComponent(activeElement.getString('skip')));
}            


private function shareFacebook():void {
	goToUrl(activeElement.getString('link') + '/facebook');
}            
private function shareTwitter():void {
	goToUrl(activeElement.getString('link') + '/twitter');
}            
private function shareGoogle():void {
	goToUrl(activeElement.getString('link') + '/google');
}            
