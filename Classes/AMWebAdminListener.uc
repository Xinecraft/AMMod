class AMWebAdminListener extends IPDrv.TCPLink;

var AMGameMod AGM;
var() globalconfig int WebAdminListenPort;
var() globalconfig array<string> WebAdminUsers;
#if KEYS
	var() globalconfig bool ShowHeader;
#endif

struct LoggedInAdmins
{
	var IPAddr Addr;
	var string cookie;
	var string name;
	var string password;
	var string console;
	var int lastAccess;
};

var array<LoggedInAdmins>	Admins;

var int boundport;

function string GetLocalAddress()
{
	local IpAddr addr;

	GetLocalIP( addr );
	return IpAddrToString( addr );
}

function BeginPlay()
{
	if ( WebAdminListenPort == 0 )
	{
		Destroy();
		return;
	}

	boundport = BindPort( WebAdminListenPort, true );

	if( boundport == 0 )
	{
		warn( "AMWebAdminListener: Could not bind a port" );
		Destroy();
	}

	if ( Listen() )
		log( "AMMod.AMWebAdminListener: Listening on "$boundport );
	else
	{
		warn( "AMMod.AMWebAdminListener: Failed to listen on port"$boundport );
		Destroy();
	}

	AcceptClass = class'AMWebAdmin';
	SetTimer( 1, true );
}

event GainedChild( Actor Child )
{
	Super.GainedChild( Child );

	AMWebAdmin(Child).Listener = self;
}

event Timer()
{
	local int i;

	for ( i = Admins.Length-1; i >= 0; i-- )
	{
		if ( Admins[i].lastAccess + 30 < Level.TimeSeconds )
		{
			if ( Admins[i].name != "" )
				log( "AMMod.AMWebAdminListener: Web Admin Auto Logout after 30 seconds: User: "$Admins[i].name$" ("$IpAddrToString( Admins[i].Addr )$")" );
			Admins.Remove( i, 1 );
		}
	}
}

function bool ValidUser( string username, string password )
{
	local int i, j;
	local string u, p;

	if ( username == "" || password == "" )
		return false;

	for ( i = 0; i < WebAdminUsers.Length; i++ )
	{
		j = InStr( WebAdminUsers[i], " " );

		if ( j == -1 )
			continue;

		u = Left( WebAdminUsers[i], j );
		p = Mid( WebAdminUsers[i], j+1 );

		if ( username ~= u && password == p )
			return true;
	}

	return false;
}

function AddLogin( IPAddr Addr, string cookie, string user, string password )
{
	local LoggedInAdmins newAdmin;

	newAdmin.Addr = Addr;
	newAdmin.cookie = cookie;
	newAdmin.name = user;
	newAdmin.password = password;
	newAdmin.lastAccess = Level.TimeSeconds;

	Admins[Admins.Length] = newAdmin;

	log( "AMMod.AMWebAdminListener: Web Admin Login: User: "$user$" Password: "$password$" from: "$IpAddrToString( Addr ) );
}

function bool IsAdmin( IPAddr Addr, string cookie, out string name, out string console )
{
	local int i;

	if ( cookie == "" )
		return false;

	i = GetAdmin( Addr, cookie );
	if ( i != -1 )
	{
		name = Admins[i].name;
		console = GetConsole( Addr, cookie );
		Admins[i].lastAccess = Level.TimeSeconds;
		return true;
	}

	return false;
}

function int GetAdmin( IPAddr Addr, string cookie )
{
	local int i;

	if ( cookie == "" )
		return -1;

	for ( i = 0; i < Admins.Length; i++ )
		if ( Admins[i].Addr.Addr == Addr.Addr && Admins[i].cookie == cookie && cookie == (Admins[i].name$"&"$Admins[i].Password) )
			return i;

	return -1;
}

function string GetConsole( IPAddr Addr, string cookie )
{
	local int i;

	i = GetAdmin( Addr, cookie );
	if ( i != -1 )
	{
		if ( Admins[i].console == "" )
			Admins[i].console = AGM.BroadcastHandler.savedwebtext;

		return Admins[i].console;
	}
	return AGM.BroadcastHandler.savedwebtext;
}

function UpdateConsole( IPAddr Addr, string cookie, string console )
{
	local int i;

	i = GetAdmin( Addr, cookie );
	if ( i != -1 )
		Admins[i].console = console;
}

function LogOut( IPAddr Addr, string cookie )
{
	local int i;

	i = GetAdmin( Addr, cookie );
	if ( i != -1 )
		Admins.Remove( i, 1 );
}

defaultproperties
{
	 WebAdminListenPort=10490
}