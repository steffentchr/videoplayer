package com.visual{
	import com.omniture.AppMeasurement;
	import com.visual.VisualVideo;
	
	import flash.utils.setInterval;
	
	import mx.core.Application;
	import mx.events.VideoEvent;

	public class VisualOmniture{
		public var appMeasurement:AppMeasurement = null;
		public var playerName:String = "Telenor Player for 23 Video";
		public var clipName:String = "";
		public var clipLength:Number = 0;
		public var video:VisualVideo = null;
		public var videoOffset:Number = 0;
		public var source = 'telenor';
		public function VisualOmniture(app:Application, video:VisualVideo):void{
			this.video = video;
			this.appMeasurement = new AppMeasurement();
			app.rawChildren.addChild(appMeasurement);

			/* Specify the Report Suite ID(s) to track here */
			/*
			Dev:
			this.appMeasurement.visitorNamespace = "ecapacity";
			this.appMeasurement.trackingServer = "ecapacity.122.2o7.net";
			this.appMeasurement.account = "ecapadev";
			*/
			this.appMeasurement.visitorNamespace = "sonofontelenorprod";
			this.appMeasurement.trackingServer = "sonofontelenorprod.122.2o7.net";
			this.appMeasurement.account = "sonofontelenorprod";
			
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
			/*
			Dev: 
			this.appMeasurement.Media.contextDataMapping = {
				"a.media.name":"eVar29",
				"a.media.segment":"eVar31",
				"a.contentType":"eVar32",
				"a.media.timePlayed":"event29",
				"a.media.view":"event30",
				"a.media.segmentView":"event32",
				"a.media.complete":"event31",
				"a.media.source":"eVar75"
			}
			*/
			this.appMeasurement.Media.contextDataMapping = {
				"a.media.name":"eVar72",
				"a.media.segment":"eVar73",
				"a.contentType":"eVar74",
				"a.media.timePlayed":"event92",
				"a.media.view":"event93",
				"a.media.segmentView":"event95",
				"a.media.complete":"event94"
			}
				
			var $:Object = this;	
			this.appMeasurement.Media.monitor = function (s,media){
				s.eVar75 = $.source; //dev: ingen
			}
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
		
		public function load(clipName:String, length:Number, source:String):void {
			this.clipName = clipName;
			this.clipLength = length;
			this.source = source;
			this.appMeasurement.Media.open(this.clipName, this.clipLength, playerName);
			this.appMeasurement.Media.track(this.clipName);
		} 
		public function play(time:Number):void {
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
		public function trackEvent(event:String) {
			switch(event) {
				case 'yes':
					event = 'event96'; //dev: event34
					break;
				case 'no':
					event = 'event97'; //dev: event35
					break;
			}
			this.appMeasurement.eventList = [event];
			this.appMeasurement.Media.track(this.clipName);	
		}
	}
}
