//database


// ActionScript file
import flash.data.SQLConnection;
import flash.data.SQLStatement;
import flash.errors.SQLError;
import flash.filesystem.File;

public var conn:SQLConnection = new SQLConnection();
public var connAsync:SQLConnection = new SQLConnection();
//root user path
public var UserDirectory:File = File.userDirectory.resolvePath("KATG Desktop");
//path to database file
public var dbFile:File = UserDirectory.resolvePath("KATG.db");
private var createStmt:SQLStatement = new SQLStatement();

private var updateStmt:SQLStatement = new SQLStatement();
public function fnCreateDatabase():void {
	//Create or open the database.
	conn.open(dbFile);
	connAsync.openAsync(dbFile);
	//Create Tables
	createStmt.sqlConnection = conn;
	
	//create preferences table	 --- consists of one row 'preferences' so that each preference can be a different type, 
	//the type of preference is the column name and the value is the column value
	createStmt.text = 
		"CREATE TABLE IF NOT EXISTS preferences (" + 
		"    pref TEXT PRIMARY KEY UNIQUE" +
		")";
	createStmt.execute();
	
	//now run update statement added as alter table incase there was an upgrade this will make sure all the columns exist.
	updateStmt.sqlConnection = conn;
	updateStmt.text = 
		"ALTER TABLE preferences ADD AutoTuneIn BOOLEAN DEFAULT false";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD AutoLaunchChat BOOLEAN DEFAULT false";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD FollowMouse BOOLEAN DEFAULT true";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD CurrentState TEXT DEFAULT 'News'";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD x NUMERIC DEFAULT 0";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD y NUMERIC DEFAULT 0";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD Maximized BOOLEAN DEFAULT false";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD LastState TEXT DEFAULT 'News'";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD LastStateX NUMERIC DEFAULT 20";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD LastStateY NUMERIC DEFAULT 20";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD MiniStateX NUMERIC DEFAULT 20";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD MiniStateY NUMERIC DEFAULT 20";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD ShoutcastVolume NUMERIC DEFAULT 1";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD AudioPlayerVolume NUMERIC DEFAULT 1";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	
	updateStmt.text = 
		"ALTER TABLE preferences ADD FontSizeBoost NUMBER DEFAULT 0";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD FeedbackName TEXT DEFAULT ''";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE preferences ADD FeedbackLocation TEXT DEFAULT ''";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	
	
	
	//create row (becuase of unique preference name constraint, duplicates will not be created. and defaults should be auto set)
	// create the SQL statement
	
	createStmt.text = 
		"INSERT INTO preferences (pref) " + 
		"VALUES ('preferences')";
	
	// execute the statement
	try{	
		createStmt.execute();
	} catch(error:SQLError) {
		
	}
	
	
	
	
	
	//create episodes table	 
	createStmt.text = 
		"CREATE TABLE IF NOT EXISTS episodes (" + 
		"    title TEXT PRIMARY KEY UNIQUE" +
		")";
	createStmt.execute();
	
	//now run update statement added as alter table incase there was an upgrade this will make sure all the columns exist.
	updateStmt.sqlConnection = conn;
	updateStmt.text = 
		"ALTER TABLE episodes ADD location TEXT";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE episodes ADD description TEXT";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE episodes ADD type TEXT";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	updateStmt.text = 
		"ALTER TABLE episodes ADD position NUMBER DEFAULT 0";
	try {
		updateStmt.execute();
	} catch(error:SQLError) {
		
	}
	
}













/*var result:SQLResult = selectStmt.getResult();
var numResults:int = result.data.length;
for (var i:int = 0; i < numResults; i++)
{
var row:Object = result.data[i];
var output:String = "pref: " + row.itemId;
output += "; itemName: " + row.itemName;
output += "; price: " + row.price;
Alert.show(output);
}*/

// Alert.show(selectStmt.getResult().data[0].value)
