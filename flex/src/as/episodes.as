//episodes
// ActionScript file
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.filesystem.File;
import flash.net.URLRequest;
import flash.net.URLStream;

import mx.events.ListEvent;

[Bindable]
public var Episodes:Array = new Array;
[Bindable]
public var currentEpisode:Array = new Array;
public var currentEpisodePosition:int = new int(0);
private var selectEpisodes:SQLStatement = new SQLStatement;
private var insertEpisode:SQLStatement = new SQLStatement;
private var deleteEpisode:SQLStatement = new SQLStatement;
[Bindable]
public var currentEpisodeTitle:String = new String('KATG');

public function fnMillisecondsToTimeCountUp(time:Number):String {
	
	//calculate playtime from milliseconds
	var h:Number = new Number(Math.floor(time/1000/60/60));
	//minutes left shows total minutes left plus hours, 1h5m = 65mins
	//so we subtract the amount of 60's added by the hours to get just minutes
	var m:Number = new Number(Math.floor(time/1000/60)-(h*60));
	//seconds left
	var s:Number = new Number(Math.floor(time/1000)-(m*60));
	
	//create string variables
	var hours:String;
	var minutes:String;
	var seconds:String
	
	//make sure minutes and seconds are always two digits
	if(m.toString().length == 1) {
		minutes = "0"+m;
	} else {
		minutes = m.toString();
	}
	
	if(s.toString().length == 1) {
		seconds = "0"+s;
	} else {
		seconds = s.toString();
	}
	//if hours or minutes are 0 we don't need to see them
	if(h == 0) {
		hours = '';
		if(m == 0) {
			minutes = '';
		} else {
			minutes = minutes+":";
		}
	} else {
		hours = h+":"
		minutes = minutes+":";
	}
	
	// after 1 hour passes the seconds become 4 digits long
	// the last two of those digits represent the actual seconds
	seconds = seconds.slice(seconds.length-2, seconds.length);
	return hours+minutes+seconds;
	
}





public function fnSelectEpisodes(e:Event = null):void {
	// called after preferences inserted into database.
	selectEpisodes.sqlConnection = conn;
	selectEpisodes.text =
		"SELECT * FROM episodes";
	
	try{		
		var i:int = new int(episodesWindow.list_downloads.selectedIndex);
		selectEpisodes.execute();
		Episodes = selectEpisodes.getResult().data;
		episodesWindow.list_downloads.selectedIndex = i;
		
	} catch (error:SQLError) {
		Alert.okLabel = 'No brumski!';
		Alert.show('Local KATG Database Error... \nThis is something to complain about on the Forums\n Error:Episodes Table', 'Brumski', 4|Alert.NONMODAL);
	}
	trace('select episode')
}

public function fnClickList_KATG(event:ListEvent):void {
	fnDownloadEpisode(list_KATG.selectedItem.title, list_KATG.selectedItem.enclosure.url);
}	

public function fnIsEpisodeDownloaded(title:String):Boolean {
	var exists:Boolean = new Boolean(false);
	
	try{
		var numResults:int = Episodes.length;
		for (var i:int = 0; i < numResults; i++) {
			if(Episodes[i].title == title) {
				exists = true;
			}
		} 
		
		
	} catch(error:TypeError) {
		
	}
	return exists;
	
}
//call download
public var stream:URLStream;
public var fileStream:FileStream;
public var file:File;
public var req:URLRequest;
public function fnDownloadEpisode(title:String, location:String):void {
	if(fnIsEpisodeDownloaded(title) == false) {
		//episode doesn't exists download the episode.
		//check if the file exists(perhaps a partial download) and delete if exists
		downloadingEpisodeTitle = list_KATG.selectedItem.title
		downloadingEpisodeDescription= list_KATG.selectedItem.description
		
		list_KATG.enabled = false;
		opt_EpisodesKATG.visible = false;
		opt_EpisodesBackstage.visible = false;
		opt_EpisodesExtras.visible = false;
		lbl_EpisodesProgressTitle.text = "Downloading: "+title;
		list_KATG.removeEventListener(ListEvent.ITEM_CLICK, fnClickList_KATG);
		can_EpisodesDownloadProgress.visible = true;
		canvas4.setStyle('top', 192);
		
		req = new URLRequest(location);
		stream = new URLStream();
		fileStream = new FileStream();	
		
		stream.addEventListener(Event.COMPLETE, fnWriteEpisodeToFile);
		stream.addEventListener(ProgressEvent.PROGRESS, fnEpisodeDownloadProgress);
		
		
		var type:String = list_KATG.selectedItem.enclosure.type;
		if(type == 'audio/mpeg'){
			type = 'mp3';
		} else if(type == 'video/m4v'){
			type = 'm4v';
		} else if(type == 'application/pdf'){
			type = 'pdf';
		}
		type = '.'+type;
		downloadingEpisodeType = type
		var location:String = title.replace(':', '-');
		file = EpisodesDirectory.resolvePath(location+type);
		
		fileStream.openAsync(file, FileMode.WRITE);
		stream.load(req); 
		
		//when the episode is finished downloading enter it into the database	
	} else {
		Alert.okLabel = "No brumski";
		Alert.show("You've already downloaded this episode", "Brumski");
	}
}


private function fnCancelEpisodeDownload():void {
	stream.close();
	fileStream.close();
	fnSelectEpisodes();
	lbl_EpisodesProgressTitle.text = "Complete";
	can_EpisodesDownloadProgress.visible = false;
	canvas4.setStyle('top', 162);
	list_KATG.addEventListener(ListEvent.ITEM_CLICK, fnClickList_KATG);
	list_KATG.enabled = true;
	opt_EpisodesKATG.visible = true;
	opt_EpisodesBackstage.visible = true;
	opt_EpisodesExtras.visible = true;
}
private function fnEpisodeDownloadProgress(event:ProgressEvent):void {
	progress_Episodes.setProgress(event.bytesLoaded, event.bytesTotal);
	progress_Episodes.label = (Math.round(event.bytesLoaded/1000/10))/100+"MB of "+(Math.round(event.bytesTotal/1000/10))/100+"MB";
	if (stream.connected) {
		if (stream.bytesAvailable > 51200) {
			var data:ByteArray = new ByteArray();
			stream.readBytes(data,0,stream.bytesAvailable);
			fileStream.writeBytes(data,0,data.length);
		}
	}
}

public var downloadingEpisodeTitle:String = new String('');
public var downloadingEpisodeDescription:String = new String('');
public var downloadingEpisodeType:String = new String('');

private function fnWriteEpisodeToFile(evt:Event = null):void {
	can_EpisodesDownloadProgress.toolTip = "";
	fileStream.close();
	stream.close();
	var title:String = downloadingEpisodeTitle
	var description:String = downloadingEpisodeDescription
	description = description.replace('&quot;', '"');
	description = description.replace('&quot;', '"');
	if(description.charAt(0) == '"' && description.charAt(description.length-1) == '"') {
		description = description.slice(1, description.length-1);
	} 
	var type:String = downloadingEpisodeType
	
	
	
	
	var location:String = title.replace(':', '-');
	fnInsertEpisode(title, location, description, type); 
	
	
}

public function fnInsertEpisode(title:String, location:String, description:String, type:String):void {
	insertEpisode.sqlConnection = conn;	
	insertEpisode.text = 
		"INSERT INTO episodes (title, location, description, type) " + 
		'VALUES ("'+title+'","'+location+'","'+description+'","'+type+'")';
	try {
		insertEpisode.execute();
	} catch (error:SQLError) {
	}
	//once inserted update Episodes 
	fnSelectEpisodes();
	lbl_EpisodesProgressTitle.text = "Complete";
	can_EpisodesDownloadProgress.visible = false;
	canvas4.setStyle('top', 162);
	list_KATG.addEventListener(ListEvent.ITEM_CLICK, fnClickList_KATG);
	
	list_KATG.enabled = true;
	
	opt_EpisodesKATG.visible = true;
	opt_EpisodesBackstage.visible = true;
	opt_EpisodesExtras.visible = true;
}

public function fnDeleteEpisodeClick():void {
	fnStopEpisode();
	var location:String = episodesWindow.list_downloads.selectedItem.location;
	var type:String = episodesWindow.list_downloads.selectedItem.type;
	var file:File = EpisodesDirectory.resolvePath(location+type);
	currentEpisodeTitle = 'KATG';
	fnCreateAppMenu();
	txt_EpisodesTitle.visible = false;
	txt_EpisodesTitle.text = '';
	txt_EpisodesTitle.visible = true;
	if(vid_Episodes.playing) {
		vid_Episodes.stop();
		vid_Episodes.source = '';
	}
	try{
		file.deleteFile();
	} catch (error:Error) {
		Alert.okLabel = 'No brumski';
		Alert.show("Couldn't access the actual file to delete it.", 'Brumski');
	}
	deleteEpisode.sqlConnection = conn;
	deleteEpisode.text =
		'DELETE FROM episodes where title="'+episodesWindow.list_downloads.selectedItem.title+'"';
	
	try {
		deleteEpisode.execute();
	} catch (error:SQLError) {
	}
	btn_DeleteEpisode.enabled = false;
	fnSelectEpisodes();
}


import flash.events.Event;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundMixer;
import flash.media.SoundTransform;

import mx.events.SliderEvent;
import mx.events.VideoEvent;
import flash.events.IOErrorEvent;
import flash.errors.IOError;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.MouseEvent;
import mx.controls.HTML;




private var s:Sound = new Sound;
private var sc:SoundChannel = new SoundChannel;

public var s_PausePosition:int = new int(0);
public var s_trans:SoundTransform = new SoundTransform(.5, 0); 

private function fnLoadEpisode():void {
	
	if (episodesWindow.list_downloads.enabled == true) {
		if(episodesWindow.list_downloads.selectedItem.title == currentEpisode['title']) {
			if(btn_EpisodesPause.visible == true) {
				fnPauseEpisode();
			} else {
				fnPlayEpisode();	
			}
		} else {
			
			currentEpisode['position'] = sc.position
			fnUpdateEpisodePosition()	
			
			currentEpisode['title'] = episodesWindow.list_downloads.selectedItem.title;
			currentEpisode['location'] = episodesWindow.list_downloads.selectedItem.location;
			currentEpisode['description'] = episodesWindow.list_downloads.selectedItem.description;
			currentEpisode['type'] = episodesWindow.list_downloads.selectedItem.type;
			txt_EpisodesTitle.text = currentEpisode['title'];
			if(episodesWindow.list_downloads.selectedItem.type == '.m4v') {
				fnLoadTVEpisode();
				
			} else if(currentEpisode['type'] == '.mp3') {
				episodesWindow.list_downloads.enabled = false;
				fnPauseEpisode(false);
				s = new Sound;
				s.addEventListener(IOErrorEvent.IO_ERROR, fnIOError);
				//s.addEventListener(ProgressEvent.PROGRESS, fnProgressEpisode);
				sc = new SoundChannel;
				sc.soundTransform.volume = hslide_EpisodesVolume.value;
				//sc.stop();
				var location:String = currentEpisode['location'];
				var type:String = currentEpisode['type'];
				var file:File = EpisodesDirectory.resolvePath(location+type);
				//var fileStream:FileStream = new FileStream
				s.addEventListener(IOErrorEvent.IO_ERROR, fnIOError);
				s.load(new URLRequest(file.url));
				s_trans.volume = hslide_EpisodesVolume.value;
				sc.soundTransform = s_trans;
				currentEpisode['position'] = episodesWindow.list_downloads.selectedItem.position;
				addEventListener(Event.ENTER_FRAME, fnSoundProgress);
				s.addEventListener(Event.COMPLETE, fnPlayEpisode)
				/* var playtimer:Timer = new Timer(1200, 1);
				playtimer.addEventListener(TimerEvent.TIMER, fnPlayEpisode);
				playtimer.start(); */
				trace('look!')
				
			} else if(currentEpisode['type'] == '.pdf') {
				var pdfLocation:String = currentEpisode['location'];
				var pdfType:String = currentEpisode['type'];
				var pdfFile:File = EpisodesDirectory.resolvePath(pdfLocation+pdfType);
				fnClickWeb(null, pdfFile.url);
			}
		}}
	trace(currentEpisode['type'])
	
}



private function fnIOError(error:IOErrorEvent):void {
	Alert.okLabel = "No Brumski";
	Alert.show("Couldn't find the actual file", 'Brumski');
}
public function fnStopEpisode(playNext:Boolean = false):void {
	btn_EpisodesPlay.visible = true;
	btn_EpisodesPause.visible = false;
	hslide_EpisodesPlayPosition.enabled = false;
	if(vid_Episodes.playing) {
		vid_Episodes.stop();
	} else {
		
		if(sc.position > 0 && sc.position < s.length) {
			sc.stop();
		}
		//SoundMixer.stopAll();
		
		currentEpisode['position'] = 0;
		hslide_EpisodesPlayPosition.value = 0;
		fnUpdateEpisodePosition(true);
		/* episodesWindow.list_downloads.selectedItem.position = 0; */
		/* try {
		fnUpdateEpisodePosition();
		} catch(err:Error) {trace('stop error')}*/
		removeEventListener(Event.ENTER_FRAME, fnSoundProgress);
	} 
	currentEpisodeTitle = '';
	fnCreateAppMenu();	
	
}



public function fnPlayEpisode(e:Event = null):void {
	
	if (episodesWindow.list_downloads.selectedItem.title != txt_EpisodesTitle.text ) {
		
		fnLoadEpisode();
		
	} else {
		
		btn_EpisodesPause.visible = true;
		btn_EpisodesPlay.visible = false;
		hslide_EpisodesPlayPosition.enabled = true;
		currentEpisodeTitle = "Now playing - "+currentEpisode['title'];
		fnCreateAppMenu();	
		
		
		
		
		if(currentEpisode['title'] == null || !currentEpisode['title']) {
			btn_EpisodesPause.visible = false;
			btn_EpisodesPlay.visible = true;
			hslide_EpisodesPlayPosition.enabled = false;
			Alert.okLabel = 'No brumski!'
			Alert.show('Try selecting an episode first..', 'Brumski');
		} else {
			if(currentEpisode['type'] == '.m4v') {
				try{						
					vid_Episodes.play();
				} catch(error:Error){Alert.show("Invalid Video File, maybe it was deleted?");}
			} else if(currentEpisode['type'] == '.mp3') { 
				try{
					/* currentEpisode['position'] = episodesWindow.list_downloads.selectedItem.position */
					sc = s.play(currentEpisode['position'],0,s_trans);
				} catch(error:Error){Alert.show("Invalid Sound File, maybe it was deleted?");}
				
				sc.addEventListener(Event.COMPLETE, fnSoundChannelComplete);
			}
		} 
	}
}

public function fnPauseEpisode(updatepos:Boolean = true):void {
	if(updatepos == true) {
		
		currentEpisode['position'] = sc.position;
		
		fnUpdateEpisodePosition()
		
	} 
	btn_EpisodesPlay.visible = true;
	btn_EpisodesPause.visible = false;
	
	try {
		vid_Episodes.stop();
		
	} catch(err:Error){trace("error can't pause video: "+err.message)}
	try {
		sc.stop();
	} catch(err:Error) {}
	removeEventListener(Event.ENTER_FRAME, fnSoundProgress);
	
	currentEpisodeTitle = "Now playing - "+currentEpisode['title']; 
	fnCreateAppMenu();	
}

public function fnProgressEpisode(event:ProgressEvent):void {
	//	progress_Episodes.maximum = s.bytesTotal;
	//mx.controls.Alert.show(s.bytesLoaded.toString(), s.bytesTotal.toString());
	
	progress_Episodes.setProgress(s.bytesLoaded, s.bytesTotal);
	
}

public function fnSoundProgress(event:Event):void {
	hslide_EpisodesPlayPosition.maximum = s.length;
	hslide_EpisodesPlayPosition.setThumbValueAt(0, sc.position);
	txt_EpisodesTime.text = fnMillisecondsToTimeCountUp(s.length);
	txt_EpisodesTimePosition.text = fnMillisecondsToTimeCountUp(sc.position);
	if(episodesWindow.list_downloads.enabled == false) {
		if (btn_EpisodesPlay.visible == false) {
			if(sc.position > 100) {
				episodesWindow.list_downloads.enabled = true;
			}
		}
		
		
	}
	if ( btn_EpisodesPause.visible == true && s.length - sc.position - 100 <= 0) {
		//when an episode finishes
		fnStopEpisode(true)
		
		
	}
	
	
	//trace(playbackPercent.toString()+' - '+estimatedLength.toString()+' - '+s.length+' - '+sc.position);
	
}

public function fnNextEpisode(event:SQLEvent = null):void {
	if (episodesWindow.list_downloads.selectedIndex != episodesWindow.list_downloads.numChildren-1) {
		episodesWindow.list_downloads.selectedIndex += 1	
	} else {
		episodesWindow.list_downloads.selectedIndex = 0;	
	}
	fnLoadEpisode()
	
}

public function fnSoundComplete(event:Event):void {
	//removeEventListener(Event.ENTER_FRAME, fnSoundProgress);
	
}

public function fnSoundChannelComplete(event:Event):void {
	
	
}

public function fnVolume(event:SliderEvent):void {
	//s_trans = new SoundTransform;
	s_trans.volume = event.value;
	sc.soundTransform = s_trans;
	vid_Episodes.volume = event.value;
	//s_trans.volume = event.value;
	
}

public function fnScrub(event:SliderEvent):void {
	
	if(currentEpisode['type'] == '.mp3') {
		
		sc.stop();
		
		
		
		//fnPlayEpisode();
		sc = s.play(hslide_EpisodesPlayPosition.value,0,s_trans);
		btn_EpisodesPlay.visible = false;
		btn_EpisodesPause.visible = true;
	}  else  {
		//videodisplays can't handle dragging/scrubbing, so the mouse up event will set the video time
	} 
}

public function fnScrubMouseDown():void {
	//when mousedown stop it from moving under user
	vid_Episodes.removeEventListener(VideoEvent.PLAYHEAD_UPDATE, fnVidPlayheadUpdate);
	
}

public function fnScrubMouseUp():void {
	if(currentEpisode['type'] == '.m4v') {
		vid_Episodes.playheadTime = hslide_EpisodesPlayPosition.value;
		vid_Episodes.addEventListener(VideoEvent.PLAYHEAD_UPDATE, fnVidPlayheadUpdate);
		
	} 
}


//TV Episodes
public function fnLoadTVEpisode():void {
	fnPauseEpisode();
	hslide_EpisodesPlayPosition.value = 0;
	//called by the global laod function if type == .m4v
	var location:String = currentEpisode['location'];
	var type:String = currentEpisode['type'];
	var file:File = EpisodesDirectory.resolvePath(location+type);
	
	/* 	list_Backstage.selectedItem = false; */
	btn_EpisodesPlay.visible = true;
	btn_EpisodesPause.visible = false;
	/* txt_EpisodesTitle.text = list_TV.selectedItem.title; */
	vid_Episodes.addEventListener(VideoEvent.PLAYHEAD_UPDATE, fnVidPlayheadUpdate);
	vid_Episodes.source = file.url;
	vid_Episodes.load();
	trace('loaded')
	fnPlayEpisode();
	
}


public function fnVidPlayheadUpdate(event:VideoEvent):void {
	hslide_EpisodesPlayPosition.maximum = (vid_Episodes.totalTime);
	hslide_EpisodesPlayPosition.setThumbValueAt(0, vid_Episodes.playheadTime);
	txt_EpisodesTimePosition.text = fnMillisecondsToTimeCountUp(vid_Episodes.playheadTime*1000)
	if(vid_Episodes.totalTime != -1) {
		txt_EpisodesTime.text = fnMillisecondsToTimeCountUp(vid_Episodes.totalTime*1000)
	}
}

public function fnClearVideo():void {
	vid_Episodes.source = ''
	vid_Episodes.removeEventListener(VideoEvent.PLAYHEAD_UPDATE, fnVidPlayheadUpdate);
}