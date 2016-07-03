class AMLanguage extends SwatGame.SwatMutator;

var AMGameMod AGM;

var		globalconfig string		WAFNDescString;
var		globalconfig string		WAAddBanDescString;
var		globalconfig string		WARemoveBanDescString;
var		globalconfig string		WAAddReplacementDescString;
var		globalconfig string		WARemoveReplacementDescString;
var		globalconfig string		WALockedDTeamDescString;
var		globalconfig string		WAAdminSayDescString;
var		globalconfig string		WAMOTDDescString;
var		globalconfig string		WASayDescString;
var		globalconfig string		WASCDescString;
var		globalconfig string		WAAddMapDescString;
var		globalconfig string		WARemoveMapDescString;
var		globalconfig string		WASetMapDescString;
var		globalconfig string		WAKickString;
var		globalconfig string		WABanString;
var		globalconfig string		WAFLLString;
var		globalconfig string		WAFLString;
var		globalconfig string		WAMakeVIPString;
var		globalconfig string		WAFNWString;
var		globalconfig string		WAFNString;
var		globalconfig string		WASwitchTeamString;
var		globalconfig string		WAFJoinString;
var		globalconfig string		WAFSpecString;
var		globalconfig string		WAFViewString;
var		globalconfig string		WAAddBanString;
var		globalconfig string		WAGetBansString;
var		globalconfig string		WARemoveBanString;
var		globalconfig string		WAAddReplacementString;
var		globalconfig string		WAGetReplacementsString;
var		globalconfig string		WARemoveReplacementString;
var		globalconfig string		WABalanceString;
var		globalconfig string		WALockTeamsString;
var		globalconfig string		WALockedDTeamString;
var		globalconfig string		WASwitchAllString;
var		globalconfig string		WAAdminSayString;
var		globalconfig string		WAHelpString;
var		globalconfig string		WAInfoString;
var		globalconfig string		WAMOTDString;
var		globalconfig string		WASaveConfigString;
var		globalconfig string		WASayString;
var		globalconfig string		WASCString;
var		globalconfig string		WAAddMapString;
var		globalconfig string		WAGetMapsString;
var		globalconfig string		WAGetSMapsString;
var		globalconfig string		WALockMaplistString;
var		globalconfig string		WARemoveMapString;
var		globalconfig string		WARestartString;
var		globalconfig string		WARestoreSGString;
var		globalconfig string		WARestoreMapsString;
var		globalconfig string		WASaveMapsString;
var		globalconfig string		WASetMapString;
var		globalconfig string		WAUsersOnlineString;
var		globalconfig string		WATitleString;
var		globalconfig string		WAIDString;
var		globalconfig string		WANameString;
var		globalconfig string		WAScoreString;
var		globalconfig string		WAPingString;
var		globalconfig string		WAIPString;
var		globalconfig string		WASettingsUpdatedString;
var		globalconfig string		WANameChangeMessage;
var		globalconfig string		WAKickMessage;
var		globalconfig string		WABanMessage;
var		globalconfig string		WASwitchTeamsMessage;
var		globalconfig string		WACoopQMMMessage;
var		globalconfig string		WAStatsMessage;
var		globalconfig string		WAYesVoteMessage;
var		globalconfig string		WANoVoteMessage;
var		globalconfig string		WAKickReferendumStartedMessage;
var		globalconfig string		WABanReferendumStartedMessage;
var		globalconfig string		WALeaderReferendumStartedMessage;
var		globalconfig string		WAMapReferendumStartedMessage;
var		globalconfig string		WACOOPMessageLeaderSelected;
var		globalconfig string		WAStatsValidatedMessage;
var		globalconfig string		WAStatsBadProfileMessage;
var		globalconfig string		WASmashAndGrabGotItemMessage;
var		globalconfig string		WASmashAndGrabDroppedItemMessage;
var		globalconfig string		WASmashAndGrabArrestTimeDeductionMessage;
var		globalconfig string		WAReferendumAlreadyActiveMessage;
var		globalconfig string		WAReferendumStartCooldownMessage;
var		globalconfig string		WAPlayerImmuneFromReferendumMessage;
var		globalconfig string		WAReferendumAgainstAdminMessage;
var		globalconfig string		WAReferendumsDisabledMessage;
var		globalconfig string		WALeaderVoteTeamMismatchMessage;
var		globalconfig string		WAReferendumSucceededMessage;
var		globalconfig string		WAReferendumFailedMessage;
var		globalconfig string		WATeamChatMessage;
var		globalconfig string		WAGlobalChatMessage;
var		globalconfig string		WASwatSuicideMessage;
var		globalconfig string		WASuspectsSuicideMessage;
var		globalconfig string		WASwatTeamKillMessage;
var		globalconfig string		WASuspectsTeamKillMessage;
var		globalconfig string		WASwatKillMessage;
var		globalconfig string		WASuspectsKillMessage;
var		globalconfig string		WASwatArrestMessage;
var		globalconfig string		WASuspectsArrestMessage;
var		globalconfig string		WAConnectedMessage;
var		globalconfig string		WADisconnectedMessage;
var		globalconfig string		WAMissionFailedString;
var		globalconfig string		WAMissionCompletedString;
var		globalconfig string		WANewObjectiveString;
var		globalconfig string		ConnectedString;
var		globalconfig string		JoinedSpecString;
var		globalconfig string		JoinedGameString;
var		globalconfig string		MaxTeamSpreadString;
var		globalconfig string		TeamsLockedString;
var		globalconfig string		PingTooHighString;
var		globalconfig string		KickPingString;
var		globalconfig string		CannotBanAdminsString;
var		globalconfig string		MultipleTKString;
var		globalconfig string		KickBanTKString;
var		globalconfig string		KickTKString;
var		globalconfig string		EquipmentReplacedString;
var		globalconfig string		KilledVIPString;
var		globalconfig string		IdleActionString;
var		globalconfig string		KickBanIdleString;
var		globalconfig string		KickIdleString;
var		globalconfig string		DisconnectedString;
var		globalconfig string		ModOutOfDateString;
var		globalconfig string		LessLethalString;
var		globalconfig string		NoWeaponsString;
var		globalconfig string		KickRoomString;
var		globalconfig string		SecondsAddedString;
var		globalconfig string		CouldNotFindPlayerString;
var		globalconfig string		UnRecognisedCCString;
var		globalconfig string		CCCommandsString;
var		globalconfig string		OnlyAdminsSpecString;
var		globalconfig string		TooManySpecString;
var		globalconfig string		FreeSpecDisabledString;
var		globalconfig string		SpecDisabledString;
var		globalconfig string		ACCommandsString;
var		globalconfig string		UnPausedString;
var		globalconfig string		PausedString;
var		globalconfig string		ReplacementListString;
var		globalconfig string		NoReplacementsString;
var		globalconfig string		ReplacementRemovedString;
var		globalconfig string		ReplacementAddedString;
var		globalconfig string		CouldNotPromoteString;
var		globalconfig string		PromotedAString;
var		globalconfig string		PromotedString;
var		globalconfig string		KickAString;
var		globalconfig string		KickBanAString;
var		globalconfig string		LockedDTeamString;
var		globalconfig string		TeamsSwitchedString;
var		globalconfig string		SwitchAllString;
var		globalconfig string		CannotSwitchVIPString;
var		globalconfig string		ForceSwitchString;
var		globalconfig string		ForceJoinString;
var		globalconfig string		ForceViewString;
var		globalconfig string		ForceSpecString;
var		globalconfig string		CouldNotChangeVIPSpecString;
var		globalconfig string		RemoveNWString;
var		globalconfig string		ForceNWString;
var		globalconfig string		PlayerNWString;
var		globalconfig string		CannotNWVIPString;
var		globalconfig string		RemoveLLString;
var		globalconfig string		ForceLLString;
var		globalconfig string		PlayerLLString;
var		globalconfig string		CannotLLVIPString;
var		globalconfig string		ForceNameString;
var		globalconfig string		ChangedVIPString;
var		globalconfig string		SetVIPString;
var		globalconfig string		MapAddedString;
var		globalconfig string		CouldNotFindMapString;
var		globalconfig string		MapRemovedString;
var		globalconfig string		MapSetString;
var		globalconfig string		InvalidMapIndexString;
var		globalconfig string		GetMapsString;
var		globalconfig string		MaplistIsLockedString;
var		globalconfig string		MapsSavedString;
var		globalconfig string		MapsRestoredString;
var		globalconfig string		KeyCmdString;
var		globalconfig string		ConfigSavedString;
var		globalconfig string		MaplistLockedString;
var		globalconfig string		MaplistUnlockedString;
var		globalconfig string		MOTDSetString;
var		globalconfig string		ExecuteResultString;
var		globalconfig string		ExecuteString;
var		globalconfig string		AccessRestrictedString;
var		globalconfig string		CouldNotFindBanString;
var		globalconfig string		RemoveBanString;
var		globalconfig string		BanExistsString;
var		globalconfig string		AddBanString;
var		globalconfig string		BanListString;
var		globalconfig string		NoBanListString;
var		globalconfig string		LockedAString;
var		globalconfig string		UnlockedAString;
var		globalconfig string		LockedString;
var		globalconfig string		UnlockedString;
var		globalconfig string		ServerString;
var		globalconfig string		MovedTeamString;
var		globalconfig string		BalanceAString;
var		globalconfig string		BalanceString;
var		globalconfig string		GetPlayersString;
var		globalconfig string		KickBanString;
var		globalconfig string		KickString;
var		globalconfig string		ModVersionString;
var		globalconfig string		LatestVersionString;
var		globalconfig string		ComputerString;
var		globalconfig string		SuperAdminString;
var		globalconfig string		UsageString;
var		globalconfig string		UnrecognisedACString;
var		globalconfig string		MutedString;
var		globalconfig string		ForceMuteString;
var		globalconfig string		ForceUnMuteString;
var		globalconfig string		KickVIPKillString;
var		globalconfig string		KickBanVIPKillString;
var		globalconfig string		TempBanExistsString;
var		globalconfig string		AddTempBanString;
var		globalconfig string		TempBanListString;
var		globalconfig string		NoTempBanListString;
var		globalconfig string		WAGetTempBansString;
var		globalconfig string		WAMuteString;
var		globalconfig string		MaxPlayingClientsString;

function String FormatLangString( string Format, optional coerce string Param1, optional coerce string Param2, optional coerce string Param3 )
{
    Format = LangReplaceExpression( Format, "%1", Param1 );
    Format = LangReplaceExpression( Format, "%2", Param2 );
    Format = LangReplaceExpression( Format, "%3", Param3 );
        
    return Format;
}

function string LangReplaceExpression( string in, string expression, string replace )
{
    local int index;

    index = InStr( in, expression );

    if( index >= 0 )
        return Left( in, index ) $ replace $ Right( in, len(in) - (index+Len(expression)) );
    else
        return in;
}

function string LangGetFirstField( out string In, string Seperator )
{
    local int Index;
    local string RetStr;

    Index = InStr( In, Seperator );
    if( Index >= 0 )
    {
        RetStr = Left( In, Index );
        In = Right( In, len(In) - (len(Seperator) + Index));
    }
    else
    {
        RetStr = In;
        In = "";
    }

    return RetStr;
}

defaultproperties
{
	WAFNDescString="Enter the new player name:"
	WAAddBanDescString="Enter the ip or range to ban:"
	WARemoveBanDescString="Enter the ip or range to unban:"
	WAAddReplacementDescString="Enter the old class and the replacement class:"
	WARemoveReplacementDescString="Enter the replacement to remove:"
	WALockedDTeamDescString="Enter the team name:"
	WAAdminSayDescString="Enter the admin chat message to send:"
	WAMOTDDescString="Enter the new message of the day:"
	WASayDescString="Enter the chat message to send:"
	WASCDescString="Enter the server command to send:"
	WAAddMapDescString="Enter the new map name:"
	WARemoveMapDescString="Enter the map index to remove:"
	WASetMapDescString="Enter the map index to set:"
	WAKickString="Kick"
	WABanString="Ban"
	WAFLLString="Force Less Lethal"
	WAFLString="Force Leader"
	WAMakeVIPString="Make VIP"
	WAFNWString="Force No Weapons"
	WAFNString="Force Name"
	WASwitchTeamString="Switch Team"
	WAFJoinString="Force Join"
	WAFSpecString="Force Spec"
	WAFViewString="Force View"
	WAAddBanString="Add Ban"
	WAGetBansString="Get Bans"
	WARemoveBanString="Remove Ban"
	WAAddReplacementString="Add Replacement"
	WAGetReplacementsString="Get Replacements"
	WARemoveReplacementString="Remove Replacement"
	WABalanceString="Balance Teams"
	WALockTeamsString="Lock Teams"
	WALockedDTeamString="Locked Default Team"
	WASwitchAllString="Switch All"
	WAAdminSayString="Admin Say"
	WAHelpString="Help"
	WAInfoString="Info"
	WAMOTDString="MOTD"
	WASaveConfigString="Save Config"
	WASayString="Say"
	WASCString="Server Command"
	WAAddMapString="Add Map"
	WAGetMapsString="Get Maps"
	WAGetSMapsString="Get Saved Maps"
	WALockMaplistString="Lock Maplist"
	WARemoveMapString="Remove Map"
	WARestartString="Restart"
	WARestoreSGString="Restore S&G"
	WARestoreMapsString="Restore Maps"
	WASaveMapsString="Save Maps"
	WASetMapString="Set Map"
	WAUsersOnlineString="Web Admin Users Online:"
	WATitleString="SWAT 4 Web Admin"
	WAIDString="ID"
	WANameString="Name"
	WAScoreString="Score"
	WAPingString="Ping"
	WAIPString="IP Address"
	WASettingsUpdatedString="[c=ffff00][b]%1[\\b] updated the server settings."
	WANameChangeMessage="[c=ff00ff][b]%1[\\b] changed name to [b]%2[\\b]."
	WAKickMessage="[c=ff00ff][b]%1[\\b] kicked [b]%2[\\b]."
	WABanMessage="[c=ff00ff][b]%1[\\b] BANNED [b]%2[\\b]!"
	WASwitchTeamsMessage="[c=00ffff][b]%1[\\b] switched teams."
	WACoopQMMMessage="[c=ffff00]%1"
	WAStatsMessage="[c=ffff00]%1"
	WAYesVoteMessage="[c=ff00ff]%1 voted yes"
	WANoVoteMessage="[c=ff00ff]%1 voted no"
	WAKickReferendumStartedMessage="[c=ff00ff]%1 has started a vote to kick %2"
	WABanReferendumStartedMessage="[c=ff00ff]%1 has started a vote to ban %2"
	WALeaderReferendumStartedMessage="[c=ff00ff]%1 has started a vote to promote %2 to leader"
	WAMapReferendumStartedMessage="[c=ff00ff]%1 has started a vote to change the map to %2 and the game mode to %3"
	WACOOPMessageLeaderSelected="[c=ffff00][b]%1[\\b] has been promoted to leader."
	WAStatsValidatedMessage="[c=ffff00][b][STATS][\\b] The server has validated your profile and is tracking statistics."
	WAStatsBadProfileMessage="[c=ffff00][b][STATS][\\b] Your profile data is invalid. Please ensure your profile data is entered correctly."
	WASmashAndGrabGotItemMessage="[c=ffff00]%1 has picked up the briefcase."
	WASmashAndGrabDroppedItemMessage="[c=ffff00]%1 dropped the briefcase."
	WASmashAndGrabArrestTimeDeductionMessage="[c=ffff00]%1 seconds deducted from round time."
	WAReferendumAlreadyActiveMessage="[c=ff00ff]A vote is already in progress"
	WAReferendumStartCooldownMessage="[c=ff00ff]You may only start a vote once every 60 seconds"
	WAPlayerImmuneFromReferendumMessage="[c=ff00ff]%1 is currently immune from voting"
	WAReferendumAgainstAdminMessage="[c=ff00ff]You may not start a vote against an admin"
	WAReferendumsDisabledMessage="[c=ff00ff]Voting has been disabled on this server"
	WALeaderVoteTeamMismatchMessage="[c=ff00ff]You may not start leadership votes for players on the other team"
	WAReferendumSucceededMessage="[c=ff00ff]The vote succeeded"
	WAReferendumFailedMessage="[c=ff00ff]The vote failed"
	WATeamChatMessage="[c=808080][b]%1[\\b]: %2"
	WAGlobalChatMessage="[c=00ff00][b]%1[\\b]: %2"
	WASwatSuicideMessage="[c=0000ff][b]%1[\\b] suicided!"
	WASuspectsSuicideMessage="[c=ff0000][b]%1[\\b] suicided!"
	WASwatTeamKillMessage="[c=0000ff][b]%1[\\b] betrayed [b]%2[\\b] with a %3!"
	WASuspectsTeamKillMessage="[c=ff0000][b]%1[\\b] double crossed [b]%2[\\b] with a %3!"
	WASwatKillMessage="[c=0000ff][b]%1[\\b] neutralized [b]%2[\\b] with a %3!"
	WASuspectsKillMessage="[c=ff0000][b]%1[\\b] killed [b]%2[\\b] with a %3!"
	WASwatArrestMessage="[c=0000ff][b]%1[\\b] arrested [b]%2[\\b]!"
	WASuspectsArrestMessage="[c=ff0000][b]%1[\\b] arrested [b]%2[\\b]!"
	WAConnectedMessage="[c=ffff00][b]%1[\\b] connected to the server."
	WADisconnectedMessage="[c=ffff00][b]%1[\\b] dropped from the server."
	WAMissionFailedString="[c=ffffff]You have [c=ff0000]FAILED[c=ffffff] the mission!"
	WAMissionCompletedString="[c=ffffff]You have [c=00ff00]COMPLETED[c=ffffff] the mission!"
	WANewObjectiveString="[c=ffffff]You have received a new objective."
	ConnectedString="[b]%1[\\b] connected (%2)."
	JoinedSpecString="[c=00ffff][b]%1[\\b] joined the spectators."
	JoinedGameString="[c=00ffff][b]%1[\\b] joined the game."
	MaxTeamSpreadString="[c=ffff00]Maximum team spread is %1."
	TeamsLockedString="[c=ffff00]Teams are locked."
	PingTooHighString="[c=ffff00]Your ping is too high (Max: %1). You will be kicked in %2 seconds."
	KickPingString="[c=ff00ff][b]%1[\\b] kicked [b]%2[\\b] for high ping."
	CannotBanAdminsString="Cannot ban admins."
	MultipleTKString="You are a multiple teamkiller."
	KickBanTKString="[c=ff00ff][b]%1[\\b] BANNED [b]%2[\\b] for teamkilling!"
	KickTKString="[c=ff00ff][b]%1[\\b] kicked [b]%2[\\b] for teamkilling."
	EquipmentReplacedString="[c=ffff00]Note: Some of your equipment has been replaced by the server."
	KilledVIPString="You have killed the VIP."
	IdleActionString="[c=ffff00]You are idle. The action: [b]%1[\\b] will be taken in %2 seconds."
	KickBanIdleString="[c=ff00ff][b]%1[\\b] BANNED [b]%2[\\b] for idling!"
	KickIdleString="[c=ff00ff][b]%1[\\b] kicked [b]%2[\\b] for idling."
	DisconnectedString="[b]%1[\\b] disconnected (%2)."
	ModOutOfDateString="(The server's mod is NOT up to date)"
	LessLethalString="[c=ffff00]%1 You must now use less lethal weapons for one round."
	NoWeaponsString="[c=ffff00]%1 You must now use no weapons for one round."
	KickRoomString="[c=ff00ff][b]%1[\\b] kicked [b]%2[\\b] to make room for [b]%3[\\b]."
	SecondsAddedString="[c=ffff00]%1 seconds added to round time."
	CouldNotFindPlayerString="Could not find the specified player."
	UnRecognisedCCString="[c=ffff00]Unrecognised cc command: [b]%1[\\b]"
	CCCommandsString="[b]cc[\\b] commands:"
	OnlyAdminsSpecString="[c=ffff00]Only admins may spectate."
	TooManySpecString="[c=ffff00]Too many spectators."
	FreeSpecDisabledString="[c=ffff00]Free roam spectating is disabled."
	SpecDisabledString="[c=ffff00]Spectating is disabled."
	ACCommandsString="[b]ac[\\b] commands:"
	UnPausedString="[c=ffff00][b]%1[\\b] unpaused the game."
	PausedString="[c=ffff00][b]%1[\\b] paused the game."
	ReplacementListString="Equipment Replacement List:"
	NoReplacementsString="No Equipment Replacements were found."
	ReplacementRemovedString="Replacement: [b]%1[\\b] removed."
	ReplacementAddedString="Replacement: [b]%1[\\b] added."
	CouldNotPromoteString="Could not promote [b]%1[\\b] to the leader."
	PromotedAString="[b]%1[\\b] promoted to the leader."
	PromotedString="[c=ff00ff][b]%1[\\b] promoted [b]%2[\\b] to the leader."
	KickBanAString="[b]%1[\\b] BANNED [b]%2[\\b]!"
	KickAString="[b]%1[\\b] kicked [b]%2[\\b]."
	LockedDTeamString="Locked Default Team set to: [b]%1[\\b]."
	TeamsSwitchedString="Teams Switched."
	SwitchAllString="[c=00ffff][b]%1[\\b] switched the teams."
	CannotSwitchVIPString="Cannot switch the VIP's team."
	ForceSwitchString="[c=ff00ff][b]%1[\\b] moved [b]%2[\\b] to the other team."
	ForceJoinString="[c=ff00ff][b]%1[\\b] forced [b]%2[\\b] to join the game."
	ForceViewString="[c=ff00ff][b]%1[\\b] forced [b]%2[\\b] to spectate."
	ForceSpecString="[c=ff00ff][b]%1[\\b] forced [b]%2[\\b] to spectate."
	CouldNotChangeVIPSpecString="Could not change the VIP to force %1 to spectate."
	RemoveNWString="[c=ff00ff][b]%1[\\b] gave back [b]%2[\\b]'s weapons."
	ForceNWString="[c=ff00ff][b]%1[\\b] forced [b]%2[\\b] to use no weapons."
	PlayerNWString="An admin has decided that your behaviour is disruptive."
	CannotNWVIPString="Cannot force the VIP to use no weapons."
	RemoveLLString="[c=ff00ff][b]%1[\\b] gave back [b]%2[\\b]'s weapons."
	ForceLLString="[c=ff00ff][b]%1[\\b] forced [b]%2[\\b] to use less lethal weapons."
	PlayerLLString="An admin has decided that your behaviour is disruptive."
	CannotLLVIPString="Cannot force the VIP to go less lethal."
	ForceNameString="[c=ff00ff][b]%1[\\b] changed [b]%2[\\b]'s name."
	ChangedVIPString="[c=ff00ff][b]%1[\\b] changed the VIP to [b]%2[\\b]."
	SetVIPString="[b]%1[\\b] set the VIP to [b]%2[\\b]."
	MapAddedString="[b]%1[\\b] added."
	CouldNotFindMapString="Could not find map: [b]%1[\\b]."
	MapRemovedString="[b]%1[\\b] removed."
	MapSetString="Map set to: [b]%1[\\b]."
	InvalidMapIndexString="Invalid map index."
	GetMapsString="[b]ID - Map Name:[\\b]"
	MaplistIsLockedString="Maplist is locked"
	MapsSavedString="Maps Saved."
	MapsRestoredString="Maps Restored."
	ConfigSavedString="Configuration Saved."
	MaplistLockedString="MapList Locked."
	MaplistUnlockedString="MapList Unlocked."
	MOTDSetString="MOTD set to:\n%1"
	ExecuteResultString="[b]Server[\\b]: %1."
	ExecuteString="[b]%1[\\b] executed: [b]%2[\\b] on the server."
	AccessRestrictedString="Access to this property has been restricted."
	CouldNotFindBanString="Could not find [b]%1[\\b] in the ban list."
	RemoveBanString="[b]%1[\\b] removed an IP Ban rule for: [b]%2[\\b]."
	BanExistsString="Ban rule already exists for [b]%1[\\b]."
	AddBanString="[b]%1[\\b] added an IP Ban for: [b]%2[\\b]."
	BanListString="[b]Ban List[\\b]: %1"
	NoBanListString="No Ban List Found."
	LockedAString="Teams Locked."
	UnlockedAString="Teams Unlocked."
	LockedString="[c=00ffff][b]%1[\\b] locked the teams."
	UnlockedString="[c=00ffff][b]%1[\\b] unlocked the teams."
	ServerString="The Server"
	MovedTeamString="[c=ff00ff][b]%1[\\b] moved [b]%2[\\b] to the other team."
	BalanceAString="Teams Balanced."
	BalanceString="[c=00ffff][b]%1[\\b] balanced the teams."
	GetPlayersString="[b]ID - Name - Score - IP[\\b]:"
	KickBanString="[c=ff00ff][b]%1[\\b] BANNED [b]%2[\\b]!"
	KickString="[c=ff00ff][b]%1[\\b] kicked [b]%2[\\b]."
	ModVersionString="[b]Mod Version[\\b]: %1"
	LatestVersionString="[b]Latest Version[\\b]: %1"
	ComputerString="[b]Computer[\\b]: %1"
	SuperAdminString="You must be a super admin to use this command."
	UsageString="Usage: [b]%1[\\b] %2"
	UnrecognisedACString="Unrecognised ac command: [b]%1[\\b]"
	MutedString="[c=ffff00]You have been muted for %1 seconds."
	ForceMuteString="[c=ff00ff][b]%1[\\b] muted [b]%2[\\b]."
	ForceUnMuteString="[c=ff00ff][b]%1[\\b] unmuted [b]%2[\\b]."
	KickVIPKillString="[c=ff00ff][b]%1[\\b] kicked [b]%2[\\b] for VIP killing."
	KickBanVIPKillString="[c=ff00ff][b]%1[\\b] BANNED [b]%2[\\b] for VIP killing."
	TempBanExistsString="Temporary ban rule already exists for [b]%1[\\b]."
	AddTempBanString="[b]%1[\\b] added a temporary IP Ban for: [b]%2[\\b]."
	TempBanListString="[b]Temporary Ban List[\\b]: %1"
	NoTempBanListString="No Temporary Ban List Found."
	WAGetTempBansString="Get Temporary Bans"
	WAMuteString="Force Mute"
	MaxPlayingClientsString="[c=ffff00]Maximum number of playing clients reached."
}