class AMUAC extends IPDrv.TCPLink	transient;

var AMGameMod AGM;

var() globalconfig string MatchID;

var bool ready;
var int boundport;
var string data;
var string mirror;
var string file;
var array<string> queuedData;
var IPAddr savedAddress;

function BeginPlay()
{
	ready = true;
	mirror = "www.hybridxs.co.uk";
	file = "/uac_test/admin_mod.php";

	boundport = BindPort();

	if( boundport == 0 )
		warn( "AMMod.AMUAC: Could not bind a port" );

	if ( MatchID != "" )
		Initialise();
}

function Initialise()
{
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
	warn( "AMMod.AMUAC: Mirror "$mirror$" timed out" );
	Destroy();
}

event ResolveFailed()
{
	warn( "AMMod.AMUAC: Could not resolve "$mirror );
	Destroy();
}

event Opened()
{
	log( "AMMod.AMUAC: Connected to mirror "$mirror );

	if ( queuedData.length > 0 )
	{
		SendData( queuedData[0] );
		queuedData.Remove( 0, 1 );
	}

	SendData( "GET "$file$"?wid="$MatchID$" HTTP/1.1\r\nHost: "$mirror$"\r\n\r\n" );
}

function Reconnect()
{
	log ( "AMMod.AMUAC: Reconnecting to "$mirror );

	if ( savedAddress.Addr != 0 )
	{
		SetTimer(10.0, false);
		Open( savedAddress );
	}
	else
		Initialise();
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

function AppendText( string text )
{
	data = data$text;

	if ( Right( data, 4 ) == "\r\n\r\n" )
		Success( data );
}

function Finished()
{
	ready = true;
}

function Failure()
{
	ready = true;
}

function Success( string text )
{
	ready = true;
}

event ReceivedText( string text )
{
	local string header;

	if ( text == "" )
		return;

	SetTimer(0.0, false);

	header = GetHeader( text );

	if ( InStr( header, "HTTP/1.1" ) == -1 && InStr( header, "HTTP/1.0" ) == -1 )
	{
		AppendText( text );
		return;
	}
	else if ( InStr( header, "HTTP/1.1 200 OK" ) == -1 && InStr( header, "HTTP/1.0 200 OK" ) == -1 )
	{
		Failure();
		return;
	}

	data = GetHTML( text );
	if ( Right( data, 4 ) == "\r\n\r\n" )
		Success( data );
}

function string GetHeader( string text )
{
	local int i;

	i = InStr( text, "\r\n\r\n" );

	if ( i == -1 )
		return text;

	return Left( text, i );
}

function string GetHTML( string text )
{
	local int i;

	i = InStr( text, "\r\n\r\n" );

	if ( i != -1 )
		i += 4;
	else
		return "";

	return Mid( text, i );
}

event Closed()
{
	ready = true;
}