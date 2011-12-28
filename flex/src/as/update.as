// ActionScript file


import com.UpdateWindow;

import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.rpc.events.ResultEvent;

/** 
 * fetches the latest version info
 */

public var CurrentVersion:String = new String();
// the version from which a user must manually upgrade.
public var ManualUpdateVersion:String = new String();
// the url to take the user to for instructions re: a manual upgrade
public var ManualUpdateURL:String = new String();

public var updateWindow:com.UpdateWindow;

// used to determine if user initiates update check.
private var manualUpdateCheck:Boolean = new Boolean(false);

// boolean that indicates whether a manual re-install is required
private var ManualRequired:Boolean = new Boolean(false);

private function CheckForUpdatesResultHandler(event:ResultEvent):void
{
	
	CurrentVersion = event.result.data.currentVersion
	ManualUpdateVersion = event.result.data.manualUpdateVersion
	ManualUpdateURL = event.result.data.manualUpdateURL
		
	//trace('update result ' + CurrentVersion + " - " + VERSION)
	// launch update window
	if (!Capabilities.isDebugger)
	{
		//trace('debugger pass')
		if(Version != CurrentVersion || manualUpdateCheck == true)
		{
			//trace('should open window now...')
			// reset manual Update
			manualUpdateCheck = false;
			
			// see if user has to manually reinstall app
			// now check if the user has a version that requires a manual update.
			var VERSIONArray:Array;
			var ManualUpdateVersionArray:Array;
			
			VERSIONArray = Version.split(".");
			ManualUpdateVersionArray = ManualUpdateVersion.split(".");
			if(VERSIONArray['0'] <= ManualUpdateVersionArray['0'])
			{
				if(VERSIONArray['0'] < ManualUpdateVersionArray['0'])
				{
					// manual update
					ManualRequired = true;
					
				} else if(VERSIONArray['1'] <= ManualUpdateVersionArray['1']) {
					
					if(VERSIONArray['1'] < ManualUpdateVersionArray['1'])
					{
						// manual update
						ManualRequired = true;
						
					} else if(VERSIONArray['2'] <= ManualUpdateVersionArray['2'])
					{
						// manual update
						ManualRequired = true;
						
					}
				}
			}
			
			var CurrentVersionArray:Array;
			CurrentVersionArray = CurrentVersion.split(".");
			
			// Same == same as current version
			// Update == user can update
			// can add later Beta, in case user is using beta advanced version of the app.
			var appVersionNess:String = new String("Same");
			
			if(VERSIONArray['0'] <= CurrentVersionArray['0'])
			{
				if(VERSIONArray['0'] < CurrentVersionArray['0'])
				{
					
					appVersionNess = "Update";
					
				} else if(VERSIONArray['1'] <= CurrentVersionArray['1']) {
					
					if(VERSIONArray['1'] < CurrentVersionArray['1'])
					{
						// manual update
						appVersionNess = "Update";
						
					} else if(VERSIONArray['2'] <= CurrentVersionArray['2'])
					{
						// manual update
						appVersionNess = "Update";
						
					}
				}
			}
			
			
			
			if(appVersionNess == "Update")
			{
				
				updateWindow = new UpdateWindow();
				updateWindow.VERSION = Version;
				updateWindow.CurrentVersion = CurrentVersion;
				updateWindow.releaseNotes = event.result.data.releaseNotes;
				updateWindow.ManualUpdateVersion = ManualUpdateVersion;
				updateWindow.ManualUpdateURL = ManualUpdateURL;
				updateWindow.ManualRequired = ManualRequired;
				updateWindow.open()
				
				//this.status = "You're using version " + VERSION + " - Please update to the latest version " + CurrentVersion;
			}
			
		} 
	}
}

