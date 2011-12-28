package com
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.html.HTMLHost;
	import flash.html.HTMLLoader;
	import flash.html.HTMLWindowCreateOptions;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
	import mx.controls.HTML;
	import mx.managers.HistoryManager;

	public class MyHTMLHost extends HTMLHost
	{
		
		
	
		
		public function MyHTMLHost(defaultBehaviors:Boolean=true)
		{
			super(defaultBehaviors);
			
			htmlLoader2.addEventListener(Event.LOCATION_CHANGE, openNewTab)
			htmlLoader2.addEventListener(Event.COMPLETE, hLoader2Complete)
		}
		private var htmlLoader2:HTMLLoader = new HTMLLoader();
		override public function createWindow(windowCreateOptions:HTMLWindowCreateOptions):HTMLLoader
		{
			// you return to whichever htmlLoader you want to handle the createWindow function.
			return htmlLoader2;
			
		
			
		}
		
		private var alreadyOpened:Boolean = new Boolean(false)
		private function openNewTab(e:Event):void
		{
			if(alreadyOpened == false)
			{
				alreadyOpened = true
					htmlLoader2.cancelLoad()
					
				trace("location change location: "+ e.target.location)
				navigateToURL(new URLRequest(e.target.location))
				
			}
			
			//window.close()
		}
		
		private function hLoader2Complete(e:Event):void
		{
			alreadyOpened = false
		}
	}
}