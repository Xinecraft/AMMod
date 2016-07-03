class BotNavigator extends SwatGame.SwatMutator;

var AMGameMod AGM;
var KZMod KZMod;
var array<PathNodeInfo> PathNodeList;
var bool DidInitialise;

function BeginPlay()
{
    local int Space, spaceB;
    local PathNode StartPathNode, ToPathNode;

    // End:0x0E
    if(DidInitialise)
    {
        return;
    }
    // End:0x16
    else
    {
        DidInitialise = true;
    }
    // End:0x123
    foreach AllActors(class'PathNode', StartPathNode)
    {
        Space = PathNodeList.Length;
        PathNodeList[Space] = Spawn(class'PathNodeInfo');
        PathNodeList[Space].PathNode = StartPathNode;
        // End:0x121
        foreach AllActors(class'PathNode', ToPathNode)
        {
            // End:0x83
            if(StartPathNode == ToPathNode)
            {
                continue;
            }
            // End:0x120
            if(IsAClearWay(StartPathNode.Location, ToPathNode.Location))
            {
                spaceB = PathNodeList[Space].ToPathNode.Length;
                PathNodeList[Space].ToPathNode[spaceB] = ToPathNode;
                PathNodeList[Space].Distance[spaceB] = VDist(StartPathNode.Location, ToPathNode.Location);
            }
        }
    }
}

function PathNode FindClosestPath(Vector MyLocation)
{
    local PathNode CheckPathNode, FoundPathNode;
    local float FoundDistance;
    local bool FoundFirstPathNode;

    // End:0xC4
    foreach RadiusActors(class'PathNode', CheckPathNode, 500.0, MyLocation)
    {
        // End:0xC3
        if(IsAClearWay(MyLocation, CheckPathNode.Location))
        {
            // End:0x76
            if(!FoundFirstPathNode)
            {
                FoundFirstPathNode = true;
                FoundDistance = VDist(MyLocation, CheckPathNode.Location);
                FoundPathNode = CheckPathNode;
                // End:0xC3
                continue;
            }
            // End:0xC3
            if(VDist(MyLocation, CheckPathNode.Location) < FoundDistance)
            {
                FoundDistance = VDist(MyLocation, CheckPathNode.Location);
                FoundPathNode = CheckPathNode;
            }
        }
    }
    // End:0xD6
    if(FoundPathNode != none)
    {
        return FoundPathNode;
    }
    // End:0x190
    foreach AllActors(class'PathNode', CheckPathNode)
    {
        // End:0x18F
        if(IsAClearWay(MyLocation, CheckPathNode.Location))
        {
            // End:0x142
            if(!FoundFirstPathNode)
            {
                FoundFirstPathNode = true;
                FoundDistance = VDist(MyLocation, CheckPathNode.Location);
                FoundPathNode = CheckPathNode;
                // End:0x18F
                continue;
            }
            // End:0x18F
            if(VDist(MyLocation, CheckPathNode.Location) < FoundDistance)
            {
                FoundDistance = VDist(MyLocation, CheckPathNode.Location);
                FoundPathNode = CheckPathNode;
            }
        }
    }
    return FoundPathNode;
}

function bool IsAClearWay(Vector FromLocation, Vector ToLocation)
{
    local Actor HitActor;
    local Vector HitLocation, HitNormal;
    local Material HitMaterial;
    local bool DirectPath;

    // End:0x11
    if(FromLocation == ToLocation)
    {
        return true;
    }
    // End:0x26
    if(FastTrace(FromLocation, ToLocation))
    {
        return true;
    }
    // End:0xBC
    else
    {
        DirectPath = true;
        // End:0xB9
        foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, HitMaterial, ToLocation, FromLocation)
        {
            // End:0xB8
            if(((!HitActor.IsA('SwatDoor') && !HitActor.IsA('DoorModel')) && !HitActor.IsA('DoorWay')) && !HitActor.IsA('DoorBufferVolume'))
            {
                return false;
            }
        }
        return true;
    }
}

function array<PathNode> FastestWay(PathNode FromPathNode, PathNode ToPathNode)
{
    local array<PathNode> FastestWay;

    // End:0x1E
    if((FromPathNode == none) || ToPathNode == none)
    {
        return FastestWay;
    }
    // End:0x49
    if(IsAClearWay(FromPathNode.Location, ToPathNode.Location))
    {
        return FastestWay;
    }
    return FastestWay;
}

function array<PathNodeInfo> GetNavigationPointInfo(PathNode FromPathNode)
{
    local int i;
    local PathNodeInfo CheckingPathNode;
    local array<PathNodeInfo> PathNodeStorage;

    // End:0x11
    if(FromPathNode == none)
    {
        return PathNodeStorage;
    }

    for (i = 0; i < PathNodeList.Length ; i++)
    {
        CheckingPathNode = PathNodeList[i];
        if(CheckingPathNode.PathNode != FromPathNode)
        {
            continue;
        }
        PathNodeStorage[PathNodeStorage.Length] = CheckingPathNode;
    }

    return PathNodeStorage;
}
