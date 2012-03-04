package com.visual{
	import com.omniture.AppMeasurement;
	import com.visual.VisualVideo;
	
	import mx.core.Application;
	import mx.events.VideoEvent;
	import flash.utils.setInterval;

	public class VisualOmniture{
		public var appMeasurement:AppMeasurement = null;
		public var playerName:String = "Telenor Player for 23 Video";
		public var clipName:String = "";
		public var clipLength:Number = 0;
		public var video:VisualVideo = null;
		public var videoOffset:Number = 0;
		public function VisualOmniture(app:Application, video:VisualVideo):void{
			this.video = video;
			this.appMeasurement = new AppMeasurement();
			app.rawChildren.addChild(appMeasurement);

			/* Specify the Report Suite ID(s) to track here */
			this.appMeasurement.visitorNamespace = "ecapacity";
			this.appMeasurement.trackingServer = "ecapacity.122.2o7.net";
			this.appMeasurement.account = "ecapadev";

			/* Turn on and configure debugging here */
			this.appMeasurement.debugTracking = true;
			this.appMeasurement.trackLocal = true;

			/* You may add or alter any code config here */
			this.appMeasurement.pageName = "";
			this.appMeasurement.pageURL = "";
			this.appMeasurement.charSet = "UTF-8";
			this.appMeasurement.currencyCode = "USD";

			/* Turn on and configure ClickMap tracking here */
			this.appMeasurement.autoTrack = false;
			this.appMeasurement.trackClickMap = true;
			this.appMeasurement.movieID = "";
			this.appMeasurement.Media.trackMilestones="25,50,75";
			this.appMeasurement.Media.playerName=playerName;
			this.appMeasurement.Media.trackUsingContextData = true;
			this.appMeasurement.Media.segmentByMilestones = true;
			//this.appMeasurement.Media.autoTrackNetStreams = false;
			this.appMeasurement.Media.contextDataMapping = {
				"a.media.name":"eVar29",
				"a.media.segment":"eVar31",
				"a.contentType":"eVar32",
				"a.media.timePlayed":"event29",
				"a.media.view":"event30",
				"a.media.segmentView":"event32",
				"a.media.complete":"event31"
			}
				
			var $:Object = this;	
			this.video.addEventListener(VideoEvent.STATE_CHANGE, function(e:VideoEvent):void{
					if(e.state=='paused') {
						$.play($.videoOffset + $.video.playheadTime);
					}
					if(e.state=='paused') {
						$.pause($.videoOffset + $.video.playheadTime);
						
					}
				});
			this.video.addEventListener(VideoEvent.COMPLETE, function(e:VideoEvent):void{
					$.complete();
				});
			
			setInterval(function():void{
				 	if($.video.playing) $.play($.videoOffset + $.video.playheadTime);
				}, 5000);
		}
		
		public function load(clipName:String, length:Number):void {
			trace('length', length);
			this.clipName = clipName;
			this.clipLength = length;
			this.appMeasurement.Media.open(this.clipName, this.clipLength, playerName);
			this.appMeasurement.Media.track(this.clipName);
		} 
		public function play(time:Number):void {
			trace('time', time);
			this.appMeasurement.Media.play(this.clipName, time);
			this.appMeasurement.Media.track(this.clipName);
		} 
		public function pause(time:Number):void {
			this.appMeasurement.Media.stop(this.clipName, time);
			this.appMeasurement.Media.track(this.clipName);
		} 
		public function complete():void {
			this.appMeasurement.Media.close(this.clipName);
			this.appMeasurement.Media.track(this.clipName);
		} 
	}
}
