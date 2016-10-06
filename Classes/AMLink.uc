class AMLink extends IPDrv.TCPLink	transient;

var AMGameMod AGM;

var int stage;
var int boundport;
var int mirrornum;
var int packetlen;
var bool checkedkey;
var bool checkingkey;
var bool retrievingmsg;
var bool retrievingheader;
var bool retrievingfooter;
var bool retrievingbans;
var bool ready;
var bool receivingdata;
var IPAddr savedAddress;
var array<string> queuedData;
var string data;
var string version;
var string mirror;
var string directory;
var() globalconfig string Key;

function BeginPlay()
{
	ready = true;
	boundport = BindPort();

	if( boundport == 0 )
	{
		AGM.keyMsg = "Could not bind a port";
		warn( "AMMod.AMLink:"@AGM.keyMsg );
	}
}

function Initialise( int inMirror )
{
	mirrornum = inMirror;

#if !KEYS
	AGM.validKey = true;
	checkedkey = true;
#endif

	if ( mirrornum == 2 )
	{
		mirror = "knightofsorrow.com";
		directory = "";
	}
	else if ( mirrornum == 1 )
	{
		mirror = "www.gezmods.co.uk";
		directory = "";
	}
	else if ( mirrornum == 0 )
	{
		mirror = "www.gezmods.com";
		directory = "";
	}
	else
	{
		AGM.keyMsg = "Invalid mirror";
		warn( "AMMod.AMLink:"@AGM.keyMsg );
		InitKeyClasses();
		Destroy();
	}

	SetTimer(10.0, false);
	Resolve( mirror );
}

event Resolved( IpAddr Addr )
{
	Addr.Port = 80;

	savedAddress = Addr;

	SetTimer(10.0, false);
	Open( Addr );
}

event Timer()
{
	if ( mirrornum == 0 )
	{
		AGM.keyMsg = "Could not connect to a mirror";
		warn( "AMMod.AMLink:"@AGM.keyMsg );
		InitKeyClasses();
	}
	else
	{
		AGM.keyMsg = "Mirror "$mirrornum$" ("$mirror$") timed out";
		warn( "AMMod.AMLink:"@AGM.keyMsg );
		AGM.iLink = AGM.Spawn( class'AMLink' );
		AGM.iLink.AGM = AGM;
		AGM.iLink.Initialise( mirrornum-1 );
	}

	Destroy();
}

event ResolveFailed()
{
	if ( mirrornum == 0 )
	{
		AGM.keyMsg = "Could not connect to a mirror";
		warn( "AMMod.AMLink:"@AGM.keyMsg );
		InitKeyClasses();
	}
	else
	{
		AGM.keyMsg = "Could not resolve mirror "$mirrornum$" ("$mirror$")";
		warn( "AMMod.AMLink:"@AGM.keyMsg );
		AGM.iLink = AGM.Spawn( class'AMLink' );
		AGM.iLink.AGM = AGM;
		AGM.iLink.Initialise( mirrornum-1 );
	}

	Destroy();
}

function Reconnect()
{
	log ( "AMMod.AMLink: Reconnecting to "$mirror );

	if ( savedAddress.Addr != 0 )
	{
		SetTimer(10.0, false);
		Open( savedAddress );
	}
	else
		Initialise( 2 );
}

function bool SendData( string text )
{
	SetTimer(10.0, false);

	if ( !IsConnected() )
	{
		Reconnect();
	}
	else
	{
		ready = false;
		SendText( text );
		return true;
	}

	log ( "AMMod.AMLink: Queuing data for "$mirror );
	queuedData[queuedData.length] = text;
	return false;
}

function bool ValidKey( string k )
{
	local int i;
	local float hex, cur, mod, checknum;

	checknum = 357660;

	for ( i = 0; i < len(k); i++ )
	{
		cur = GetHexDigit(Mid( k, i, 1 ))*(16**(len(k)-i-1));
		hex = hex + cur;
	}

	mod = hex % checknum;

	if ( hex > 0 && mod == 0 )
		return true;

	AGM.keyMsg = "Invalid Key Hash";
	warn( "AMMod.AMLink:"@AGM.keyMsg );
	return false;
}

function bool ValidClientKey( string k )
{
	local int i;
	local float hex, cur, mod, checknum;

	checknum = 426936;

	for ( i = 0; i < len(k); i++ )
	{
		cur = GetHexDigit(Mid( k, i, 1 ))*(16**(len(k)-i-1));
		hex = hex + cur;
	}

	mod = hex % checknum;

	if ( hex > 0 && mod == 0 )
		return true;

	return false;
}

function int GetHexDigit(string D)
{
	switch(caps(D))
	{
	case "0": return 0;
	case "1": return 1;
	case "2": return 2;
	case "3": return 3;
	case "4": return 4;
	case "5": return 5;
	case "6": return 6;
	case "7": return 7;
	case "8": return 8;
	case "9": return 9;
	case "A": return 10;
	case "B": return 11;
	case "C": return 12;
	case "D": return 13;
	case "E": return 14;
	case "F": return 15;
	}

	return 0;
}

event Opened()
{
	log( "AMMod.AMLink: Connected to mirror "$mirror );

	/**if ( queuedData.length > 0 )
	{
		log( "GET "$directory$"/stats?"$queuedData[0]$"&key=Zishan HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
		SendData( "GET "$directory$"/stats?"$queuedData[0]$"&key=Zishan HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
		//SendData( queuedData[0] );
		queuedData.Remove( 0, 1 );
	}*/

	stage = 0;
	SendData( "GET "$directory$"/download/adminmoddata/testactive.txt HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
}

function OnActiveSuccess()
{
	if ( Key != "" && ValidKey( Key ) && !checkedkey )
	{
		log("Check gezmod for keys: "$Key);
		stage = 2;
		checkedkey = true;
		SendData( "GET "$directory$"/download/adminmoddata/key"$Key$".txt HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
	}
	else
	{
		stage = 2;
		AttemptNextStage();
	}
}

function Finished()
{
	InitKeyClasses();
	ready = true;
}

function Failure()
{
	switch ( stage )
	{
		case 0:
			Timer();
			break;
		case 1:
			Finished();
			break;
		case 2:
			AGM.keyMsg = "Invalid Key";
			warn( "AMMod.AMLink:"@AGM.keyMsg );
			AGM.validkey = false;
			AttemptNextStage();
			break;
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
			AttemptNextStage();
			break;
		default:
			Finished();
			break;
	}
}

function AttemptNextStage()
{
	stage++;

	switch ( stage )
	{
		case 1:
		case 2:
			OnActiveSuccess();
			break;
		case 3:
#if SWAT_EXPANSION
			SendData( "GET "$directory$"/download/adminmoddata/tssversion.txt HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
#else
			SendData( "GET "$directory$"/download/adminmoddata/version.txt HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
#endif
			break;
		case 4:
			SendData( "GET "$directory$"/download/adminmoddata/adminmsg"$MOD_VERSION$".txt HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
			break;
		case 5:
			SendData( "GET "$directory$"/download/adminmoddata/webadminheader"$MOD_VERSION$".html HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
			break;
		case 6:
			SendData( "GET "$directory$"/download/adminmoddata/webadminfooter"$MOD_VERSION$".html HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
			break;
		case 7:
			SendData( "GET "$directory$"/download/adminmoddata/masterbanlist.txt HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
			break;
		default:
			Finished();
			break;
	}
}

function Success( string html )
{
	local string Msg;

	switch ( stage )
	{
		case 0:
			if ( html == "SUCCESS" )
				AttemptNextStage();
			else
				Timer();
			break;
		case 1:
			break;
		case 2:
			if ( html == Level.ComputerName )
			{
				AGM.keyMsg = "Key Verified";
				log( "AMMod.AMLink:"@AGM.keyMsg );
				AGM.validkey = true;
			}
			else
			{
				AGM.keyMsg = "Invalid Key Name";
				warn( "AMMod.AMLink:"@AGM.keyMsg );
				AGM.validkey = false;
			}
			AttemptNextStage();
			break;
		case 3:
			version = Mid( html, 1 );

			log( "AMMod.AMLink: Computer name is "$Level.ComputerName );
			Msg = "AMMod.AMLink: Latest Version is "$version;

			if ( version > MOD_VERSION )
				Msg = Msg$" (Your version ["$MOD_VERSION$"] is NOT up to date)";
			else
				Msg = Msg$" (Your version is up to date)";

			log( Msg );
			AGM.latestversion = version;

			AttemptNextStage();
			break;
		case 4:
			AGM.adminmsg = html;
			AttemptNextStage();
			break;
		case 5:
            AGM.webadminheader = html;
			AttemptNextStage();
			break;
		case 6:
			AGM.webadminfooter = html;
			AttemptNextStage();
			break;
		case 7:
			AGM.Admin.masterbanlist = html;
			//AGM.AccessControl.CleanUpMasterIPPolicies();
			AGM.Admin.ReceivedMasterBanList();
			AttemptNextStage();
			break;
		default:
			Finished();
			break;
	}
}

event ReceivedText( string text )
{
	local string header, temp;
	local int i;
	local bool foundEnd;

	if ( text == "" )
		return;

	if ( !receivingdata && (Left( text, len("HTTP/1.1 200 OK") ) == "HTTP/1.1 200 OK" || Left( text, len("HTTP/1.0 200 OK") ) == "HTTP/1.0 200 OK") )
	{
		packetlen = 0;
		receivingdata = true;
		data = "";
	}
	else if ( !receivingdata )
	{
		Failure();
		return;
	}

	data = data$text;

	if ( packetlen == 0 )
	{
		temp = GetHeader( data );
		i = InStr( temp, "\r\nContent-Length: " );

		if ( i != -1 )
		{
			i += len("\r\nContent-Length: ");
			temp = Mid( temp, i );
			i = InStr( temp, "\r\n" );
			if ( i != -1 )
			{
				temp = Left( temp, i );
				packetlen = int(temp);
			}
		}
	}

	if ( packetlen > 0 )
	{
		if ( len(GetHTML( data )) >= packetlen )
			foundEnd = true;
	}

	if ( !foundEnd )
	{
		SetTimer(10.0, false);
		return;
	}

	SetTimer(0.0, false);

	text = data;
	data = "";
	packetlen = 0;
	receivingdata = false;
	header = GetHeader( text );

	Success( GetHTML( text ) );
}

function string GetHTML( string text )
{
	local int i;

	i = InStr( text, "\r\n\r\n" );

	if ( i == -1 )
		return text;

	return Mid( text, i+4 );
}

function string GetHeader( string text )
{
	local int i;

	i = InStr( text, "\r\n\r\n" );

	if ( i == -1 )
		return "";

	return Left( text, i );
}

event Closed()
{
	ready = true;
}

function InitKeyClasses()
{
	if ( AGM.initialisedKeyClasses )
		return;

	AGM.initialisedKeyClasses = true;

	AGM.WebAdmin = Spawn( class'AMWebAdminListener' );
	AGM.WebAdmin.AGM = AGM;
    //AGM.MBMainserverlist.Initialise(0);

#if SWAT_EXPANSION
	if ( ServerSettings(Level.CurrentServerSettings).GameType == MPM_SmashAndGrab )
	{
			AGM.SmashGrabMod = Spawn( class'AMSaGMod' );
			AGM.SmashGrabMod.AGM = AGM;
	}
#endif
}
