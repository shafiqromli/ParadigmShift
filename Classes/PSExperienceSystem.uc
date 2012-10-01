class PSExperienceSystem extends Actor;

const MaxLevel = 3;
const XPIncrement = 500;

var repnotify int TotalXP;
var repnotify int Level;
var repnotify int XPGatheredForCurrentLevel;

var array<int> XPRequireForLevel;

replication
{
	if (bNetOwner)
		TotalXP,Level,XPGatheredForCurrentLevel;
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	if(Role < ROLE_Authority)
		ServerCalcAllLevelXP();

	CalcAllLevelXP();
}

reliable server function ServerCalcAllLevelXP()
{
	CalcAllLevelXP();
}

function CalcAllLevelXP()
{
	local int i;
	local int XPRequire;

	for(i = 0; i < MaxLevel;i++)
	{
		XPRequire = (i+1) * XPIncrement;
		XPRequireForLevel[XPRequireForLevel.Length] = XPRequire;
	}
}

function AddXP(int Value)
{
	if(Level != MaxLevel)
	{
		TotalXP += Value;
		WorldInfo.Game.Broadcast(self,""$PSPlayerController(Owner)$" "$TotalXP);
		//PSPlayerController(Owner).myHUD.Message(PSPlayerController(Owner).PlayerReplicationInfo,"+"$Value,'none',2.0);
	
		CalcProgress();
		while(XPGatheredForCurrentLevel >= XPRequireForLevel[Level] && Level != MaxLevel)
		{
			Level++;
			CalcProgress();
		}
		PSPlayerReplicationInfo(PSPlayerController(Owner).PlayerReplicationInfo).TotalXP = TotalXP;
		PSPlayerReplicationInfo(PSPlayerController(Owner).PlayerReplicationInfo).XPGatheredForCurrentLevel = XPGatheredForCurrentLevel;
		PSPlayerReplicationInfo(PSPlayerController(Owner).PlayerReplicationInfo).Level = Level;
		
	}
}

function CalcProgress()
{
	if(Level == 0)
	{
		XPGatheredForCurrentLevel = TotalXP;
	}
	else
	{
		XPGatheredForCurrentLevel = TotalXP - TotalPreviousXP();
	}


}

function int TotalPreviousXP()
{
	local int i;
	local int XPPrev;
	XPPrev = 0;
	for(i = 0; i < Level; i++)
	{
		XPPrev += XPRequireForLevel[i];
	}
	return XPPrev;
}

simulated function int GetXPRequiredForLevel(int lvl)
{
	return XPRequireForLevel[lvl];
	//return TotalXP;
}

DefaultProperties
{
	bOnlyRelevantToOwner = true
	TickGroup=TG_DuringAsyncWork
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=1
	
	TotalXP = 0
	Level = 0
}
