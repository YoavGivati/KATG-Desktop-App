//widget
// ActionScript file
//Grundle's Widget logic, ported to actionscript
//flex dates, 
/*
*  The fullYear property
* The month property, which is in a numeric format with 0 for January up to 11 for December
* The date property, which is the calendar number of the day of the month, in the range of 1 to 31
* The day property, which is the day of the week in numeric format, with 0 standing for Sunday
* The hours property, in the range of 0 to 23
* The minutes property
* The seconds property
* The milliseconds property
*/

/*  TheGrundle's Widget XML
<KATGGadget>
<FeedStatus>0</FeedStatus>
<ShowTime Status="0" Message="">November 27, 2008 03:59 GMT</ShowTime>
<LatestShow Description=""Get ready to punch your friend in the face."" URL="http://media.libsyn.com/media/shitecom/KATG-2008-11-24.mp3">853: Act Like a Man</LatestShow>
<StillAlive>11/25/2008 7:50:43 PM</StillAlive>
</KATGGadget>
*/	

import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.rpc.events.ResultEvent;

private var WidgetTimer:Timer = new Timer(60000);
private var WidgetFailedTimer:Timer = new Timer(120000);
private var Now:Date;
private var showTime:Date = new Date();
private var showTimeString:String = new String();
private var showTimeArray:Array = new Array();
///the grundle's xml is 1 hour off when no time is set.. problem??. new york is -5
private var showTimeHour:Number = new Number();
private var sStatus:Number = new Number();


private function fnConvertDayToString(d:Number):String {
	switch(d) {
		case 0:
			return "Monday";
			break;
		case 1:
			return "Tuesday";
			break;
		case 2:
			return "Wednesday";
			break;
		case 3:
			return "Thursday";
			break;
		case 4:
			return "Friday";
			break;
		case 5:
			return "Saturday";
			break;
		case 6:
			return "Sunday";
			break;	
		default:
			return "Monday";
			break;
	}
}
private var chatOpen:Boolean = false;
private function http_WidgetResultEvent(event:ResultEvent):void {
	http_Widget.cancel();
	
	if(http_Widget.lastResult.KATGGadget.FeedStatus == "1")
	{
		
		img_SpeakerOn.visible = true;
		img_SpeakerOff.visible = false;
		lbl_nextLiveShow.text = "In Progress";
		bc_nextShow.visible = true;
		liveWindow.visible = true;
		if(Preferences.AutoTuneIn == true)
		{
			// if the chat window is open, the user is already engaged in the live show,
			// and/or is listening maybe switched to the ustream/cam audio.
			// it's unlikely the user would want the audio feed to keep trying to move in.
			if(!chatWindow || chatWindow.closed)
			{
				liveWindow.fnStartShoutcast()
			}
		}
		if(Preferences.AutoLaunchChat == true)
		{
			if(!chatWindow || chatWindow.closed) {
				chatWindow = new ChatWindow;
				chatWindow.open();
			} 
		}
	}
	/*if(http_Widget.lastResult.KATGGadget.FeedStatus == 1) {
		//if the feed is up
		img_OnAir.visible = true;
		img_OffAir.visible = false;
		if(chkbox_AutoTuneIn.selected == true) {
			fnStartShoutcast();
		}
		if(AutoLaunchChat.valueOf() == true) {
			if(chatOpen == false){
				fnClickWeb(null, 'http://keithandthegirl.com/chat')
				chatOpen = true;
			}
		}
		
	} else if(http_Widget.lastResult.KATGGadget.FeedStatus == 0){
		//if the feed is down
		
		//fnStopShoutcast()
		chatOpen = false;
	} else {
		//so it won't cut the feed out when it looses the xml.
	}*/
	
	if(WidgetFailedTimer.running) {
		WidgetFailedTimer.stop();	
	}
	if(!WidgetTimer.running) {	
		WidgetTimer.addEventListener(TimerEvent.TIMER, http_Widget.send);
		WidgetTimer.start();
	}
	
	/**        Wiget logic              **/
	
	Now = new Date;
	//txt_LatestEpisode.text = http_Widget.lastResult.KATGGadget.LatestShow;
	lbl_nextLiveShow.toolTip = http_Widget.lastResult.KATGGadget.ShowTime.Message;
	showTimeString = (http_Widget.lastResult.KATGGadget.ShowTime);
	showTimeArray = showTimeString.split(' ');
	showTimeArray[1].toString().slice(0, showTimeArray[1].toString().length-1);
	switch(showTimeArray[0]) {
		case 'January':
			showTimeArray[0] = 0;
			break;
		case 'February':
			showTimeArray[0] = 1;
			break;
		case 'March':
			showTimeArray[0] = 2;
			break;
		case 'April':
			showTimeArray[0] = 3;
			break;
		case 'May':
			showTimeArray[0] = 4;
			break;
		case 'June':
			showTimeArray[0] = 5;
			break;
		case 'July':
			showTimeArray[0] = 6;
			break;
		case 'August':
			showTimeArray[0] = 7;
			break;
		case 'September':
			showTimeArray[0] = 8;
			break;
		case 'October':
			showTimeArray[0] = 9;
			break;
		case 'November':
			showTimeArray[0] = 10;
			break;
		case 'December':
			showTimeArray[0] = 11;
			break;
	}
	
	//set the utc showtime utc time to thegrundle's nextshow time.
	showTime.setUTCFullYear(showTimeArray[2], showTimeArray[0], showTimeArray[1].toString().slice(0, showTimeArray[1].toString().length-1));
	showTime.setUTCHours(((showTimeArray[3].toString().slice(0,2).valueOf())), showTimeArray[3].toString().slice(3,5));
	//add one hour to compensate for thegrundle's nextshow time.
	//showTime.setUTCMilliseconds(showTime.getUTCMilliseconds()+3600000);
	//showtime will adjust to user's timezone settings
	
	
	sStatus = http_Widget.lastResult.KATGGadget.ShowTime.Status;
	
	switch(sStatus) {
		case 0:
			if(showTime.date == Now.date){
				lbl_nextLiveShow.text = "Today";
				lbl_nextLiveShowDescription.text = http_Widget.lastResult.KATGGadget.ShowTime.Message;
			} else if (showTime.date > Now.date || showTime.month > Now.month) {
				var DayBefore:Date = new Date;
				DayBefore = showTime;
				DayBefore.setDate(DayBefore.date-1);
				if(DayBefore.date == Now.date) {
					lbl_nextLiveShow.text = "Tomorrow";
					lbl_nextLiveShowDescription.text = http_Widget.lastResult.KATGGadget.ShowTime.Message;
				} else {
					lbl_nextLiveShow.text = fnConvertDayToString(showTime.getDay());
					lbl_nextLiveShowDescription.text = http_Widget.lastResult.KATGGadget.ShowTime.Message;
				}
			} else {
				lbl_nextLiveShow.text = "Error :(";
				lbl_nextLiveShowDescription.text = http_Widget.lastResult.KATGGadget.ShowTime.Message;
			}
			break;
		
		case 1:
			
			if(showTime.getTime() < Now.getTime()) {
				lbl_nextLiveShow.text = "Any minute now."
				lbl_nextLiveShowDescription.text = http_Widget.lastResult.KATGGadget.ShowTime.Message;
			} else {
				var timeleft:Number = new Number(showTime.getTime() - Now.getTime());
				var hoursleft:Number = new Number(Math.floor(timeleft/1000/60/60));
				//minutes left shows total minutes left plus hours, 1h5m = 65mins
				//so we subtract the amount of 60's added by the hours to get just minutes
				var minutesleft:Number = new Number(Math.round(timeleft/1000/60)-(hoursleft*60));
				lbl_nextLiveShow.text = "" + hoursleft+" hours and "+minutesleft+" minutes left until:"
				lbl_nextLiveShowDescription.text = http_Widget.lastResult.KATGGadget.ShowTime.Message;
				if(hoursleft < 1)
				{
					showNextShow();
				}
			}
			break;
		
		case 2:
			lbl_nextLiveShow.text = ""
			lbl_nextLiveShowDescription.text = http_Widget.lastResult.KATGGadget.ShowTime.Message;
			break;
		
		case 3:
			lbl_nextLiveShow.text = "Any minute now.";
			break;
		
		case 4:
			lbl_nextLiveShow.text = "In progress.";
			break;
		
		case 5:
			lbl_nextLiveShow.text = ""
			
			lbl_nextLiveShowDescription.text = http_Widget.lastResult.KATGGadget.ShowTime.Message;
			break;
		
	}
	
	
	/**       ! Wiget logic              **/
	
	
	
}

private function http_WidgetFaultEvent(event:FaultEvent):void {
	if(WidgetTimer.running) {
		WidgetTimer.stop();
	}
	if(!WidgetFailedTimer.running) {
		WidgetFailedTimer.addEventListener(TimerEvent.TIMER, http_Widget.send);
		WidgetFailedTimer.start();
		if(lbl_nextLiveShow.text == '') {
			lbl_nextLiveShow.text = "Loading...";
			//txt_LatestEpisode.text = "Loading...";
		}
	}
}