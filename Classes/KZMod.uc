class KZMod extends SwatGame.SwatMutator;

var AMGameMod AGM;
var BotNavigator BotNavigator;
var config bool KillCampers;
var config int InitialCampWarningInterval;
var config int CampWarningInterval;
var config int MaxCampTime;

var config bool FillServerWithBots;
var config int NumberOfFixedPlayers;
var config string BotNameA;
var config string BotNameB;
var config string BotNameC;
var config string BotNameD;
var config string BotNameE;
var config string BotNameF;
var config string BotNameG;
var config string BotNameH;
var config string BotNameI;
var config string BotNameJ;
var AMPlayerController TheVIP;


function BeginPlay()
{
    local SwatGameInfo GameInfo;

    BotNavigator = Spawn(class'BotNavigator');
    BotNavigator.KZMod = self;
    BotNavigator.AGM = AGM;

    GameInfo = SwatGameInfo(Level.Game);
    // End:0x21C
    //if((GameInfo != none) && GameInfo.GameEvents != none)
    //{
    //    GameInfo.GameEvents.MissionStarted.Register(self);
    //}
    return;
}

function Tick(float Delta)
{
    CheckPlayers();
    return;
}

function CheckPlayers()
{
    local int i;
    local AMPlayerController SPC;
    //local FiredWeapon CurrentWeapon;
    //local HandheldEquipment CurrentItem;
    //local DynamicLoadOutSpec LoadOutSpec;


    for (i = AGM.PlayerList.Length - 1; i >= 0 ; i--)
    {
        SPC = AGM.PlayerList[i];
        // End:0x4B
        if(SPC == none)
        {
            continue;
        }
        // End:0xAA
        if(((SPC.PC == none) || SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem == none) || NetConnection(SPC.PC.Player) == none)
        {
            continue;
        }

        CheckIsDead(SPC);

        // End:0x12D
        if(SwatGamePlayerController(SPC.PC).SwatPlayer != none)
        {
            // End:0x12D
            if(SwatGamePlayerController(SPC.PC).SwatPlayer.IsTheVIP() || SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP)
            {
                TheVIP = SPC;
            }
        }

        // End:0x155
        if(KillCampers)
        {
            CheckNormalCamper(SPC);
        }
    }
    return;
}

function CheckIsDead(AMPlayerController SPC)
{
    local SwatGamePlayerController SGPC;

    SGPC = SwatGamePlayerController(SPC.PC);
    SPC.wasDead = SPC.IsDead;
    // End:0x69
    if(SPC.PC.Pawn == none)
    {
        SPC.IsDead = true;
    }
    // End:0xA0
    else
    {
        // End:0x8F
        if(SGPC.IsDead())
        {
            SPC.IsDead = true;
        }
        // End:0xA0
        else
        {
            SPC.IsDead = false;
        }
    }
    // End:0xE2
    if(SwatRepo(Level.GetRepo()).GuiConfig.SwatGameState != 4)
    {
        SPC.IsDead = true;
    }
    // End:0x120
    //if(SPC.wasDead && !SPC.IsDead)
    //{
    //    SPC.ArrestSteal.IsArrested = false;
    //}
    return;
}

function CheckNormalCamper(AMPlayerController SPC)
{

}

DefaultProperties
{
    KillCampers=false;
    FillServerWithBots=true;
    NumberOfFixedPlayers=4;
    BotNameA="0";
    BotNameB="1";
    BotNameC="2";
    BotNameD="3";
    BotNameE="4";
    BotNameF="5";
    BotNameG="6";
    BotNameh="7";
    BotNameI="8";
    BotNameJ="9";
}
