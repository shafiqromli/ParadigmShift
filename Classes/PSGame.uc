class PSGame extends UTTeamGame;

var int CurrentMapIndex, PrevMapIndex;

var int NumberOfMaps;

var float MapTimer, PortalCloseTimer;


function PostBeginPlay()
{	
	CheckNumberOfMaps();
	NextMap();	
	super.PostBeginPlay();	
}

event PlayerController Login(string Portal,string Options,UniqueNetId UniqueId, out string ErrorMessage)
{
	local PlayerController NewPlayer;	

	NewPlayer = super.Login(Portal, Options, UniqueId,ErrorMessage);

	PSPlayerReplicationInfo(NewPlayer.PlayerReplicationInfo).CurrentMapIndex = CurrentMapIndex;
	NewPlayer.StartSpot = FindPlayerStart(NewPlayer, NewPlayer.GetTeamNum(), Portal);

	return NewPlayer;
}

function bool ShouldSpawnAtStartSpot(Controller Player)
{
	return false;
}

reliable server function CheckNumberOfMaps()
{
	local PSTrigger PST;

	foreach WorldInfo.AllActors(class'PSTrigger', PST)
	{
		if(PST.MapIndex > NumberOfMaps)
		{
			NumberOfMaps = PST.MapIndex;
		}
	}
	
	NumberOfMaps++;
	
}

function StartMatch()
{
	local PSPlayerController PSP;

	foreach WorldInfo.AllControllers(class'PSPlayerController',PSP)
	{
		PSP.StartSpot = FindPlayerStart(PSP, PSP.GetTeamNum());
	}

	SetTimer(MapTimer, false,'NextMap');

	WorldInfo.Game.Broadcast(self,'NumberOfMaps '$NumberOfMaps);

	super.StartMatch();
}

reliable server function NextMap()
{
	local bool MapCycleDone;
	local int MI;
	local PSGameReplicationInfo PSGRI;

	MapCycleDone = false;

	PSGRI = PSGameReplicationInfo(WorldInfo.GRI);

	if(IsInState('MatchInProgress'))
	{
		ChoosePortal();		
		DestroyKey();
		SetTimer(PortalCloseTimer,false,'ClosePortal');
		SetTimer(PortalCloseTimer,false,'UnstreamLevel');
		//WorldInfo.Game.Broadcast(self,'Portal Open');
	}

	while(!MapCycleDone)
	{
		MI = Rand(NumberOfMaps);
		if(NumberOfMaps <= 2)
		{
			if(MI != CurrentMapIndex)
				MapCycleDone = true;

			CurrentMapIndex = MI;
		}
		else
		{
			if(MI != CurrentMapIndex && MI != PrevMapIndex)
			{
				MapCycleDone = true;
				PrevMapIndex = CurrentMapIndex;
				CurrentMapIndex = MI;
			}
		}
	}
	PSGRI.CurrentMapIndex = CurrentMapIndex;
	PSGRI.PrevMapIndex = PrevMapIndex;

	
	StreamLevel();
	CreateObjective();

	//WorldInfo.Game.Broadcast(self,'MapIndex '$CurrentMapIndex);
}

reliable server function CreateObjective()
{
	local PSGameObjective GO;
	local array<PSGameObjective> Group0, Group1, Group2, Group3, Group4, Group5, Group6, Group7;
	local array<int> GOSpawns;
	local int NumOfGrp,i,RandNum;
	local bool bDone,bInnerDone;

	bDone = false;
	bInnerDone = false;
	i = 0;

	foreach WorldInfo.AllNavigationPoints(class'PSGameObjective',GO)
	{
		if(GO.MapIndex == CurrentMapIndex)
		{			
			if(NumOfGrp < GO.Group)
				NumOfGrp = GO.Group;
			switch(GO.Group)
			{
			case 0:
				Group0[Group0.Length] = GO;
				break;
			case 1:
				Group1[Group1.Length] = GO;
				break;
			case 2:
				Group2[Group2.Length] = GO;
				break;
			case 3:
				Group3[Group3.Length] = GO;
				break;
			case 4:
				Group4[Group4.Length] = GO;
				break;
			case 5:
				Group5[Group5.Length] = GO;
				break;
			case 6:
				Group6[Group6.Length] = GO;
				break;
			case 7:
				Group7[Group7.Length] = GO;
				break;

			default:
				`log("Crap. Group number not between 0-7! HELP!");
			}

		}
	}

	while(bDone==false)
	{
		while(bInnerDone==false)
		{
			RandNum = Rand(NumOfGrp+1);
			if(i==0)
			{	
				GOSpawns[GOSpawns.Length] = RandNum;
				i++;
				bInnerDone = true;
			}
			else if(i==1)
			{
				if(RandNum != GOSpawns[0])
				{
					GOSpawns[GOSpawns.Length] = RandNum;
					bInnerDone = true;
					i++;
				}
				
			}
			else
			{
				if((RandNum != GOSpawns[0]) && (RandNum != GOSpawns[1]))
				{
					i++;
					bInnerDone = true;
				}
			}
		}

		bInnerDone = false;

		switch(RandNum)
		{
		case 0:
			RandNum = Rand(Group0.Length);
			Group0[RandNum].SpawnKey();
			break;
		case 1:
			RandNum = Rand(Group1.Length);
			Group1[RandNum].SpawnKey();
			break;
		case 2:
			RandNum = Rand(Group2.Length);
			Group2[RandNum].SpawnKey();
			break;
		case 3:
			RandNum = Rand(Group3.Length);
			Group3[RandNum].SpawnKey();
			break;
		case 4:
			RandNum = Rand(Group4.Length);
			Group4[RandNum].SpawnKey();
			break;
		case 5:
			RandNum = Rand(Group5.Length);
			Group5[RandNum].SpawnKey();
			break;
		case 6:
			RandNum = Rand(Group6.Length);
			Group6[RandNum].SpawnKey();
			break;
		case 7:
			RandNum = Rand(Group7.Length);
			Group7[RandNum].SpawnKey();
			break;

		default:
			`log("Crap. can't spawn at switch, cause no effing group! HELP!");
		}		

		if(i==3)			
			bDone = true;
	}
}

function ScoreKill(Controller Killer, Controller Other)
{
	if(Killer != Other)
	{
		PSPlayerController(Killer).AddXP(50);
	}
}

reliable server function DestroyKey()
{
	local PSCarriedObject Key;

	if(Role < ROLE_Authority)
		return;

	
	foreach WorldInfo.AllActors(class'PSCarriedObject',Key)
	{
		if(Key.Holder.PlayerReplicationInfo.Team != none)
		{
			PSPawn(Key.Holder).bHoldingKey = false;
			Key.Holder.PlayerReplicationInfo.Team.Score += 1;
			PSPlayerController(Key.Holder.Controller).AddXP(100);
		}

		if(Key.MapIndex == CurrentMapIndex)
			Key.Destroy();
	}
}

reliable server function ChoosePortal()
{
	local PSTrigger PST;
	local array<PSTrigger> Portals;
	local int i;
	
	foreach WorldInfo.AllActors(class'PSTrigger', PST)
	{
		if(PST.MapIndex == CurrentMapIndex)
		{
			Portals[Portals.Length] = PST;
		}
	}

	i = Rand(Portals.Length);

	Portals[i].EnablePortal();
}

reliable server function ClosePortal()
{
	local PSTrigger PST;
	
	foreach WorldInfo.AllActors(class'PSTrigger', PST)
	{
		if(PST.bEnable)
		{
			PST.DisablePortal();
		}
	}

	KillPlayerInPrevMap();

	WorldInfo.Game.Broadcast(self,'Close Portal');
	SetTimer(MapTimer, false,'NextMap');
}

function StreamLevel()
{
	local Sequence Seq;
	local array<SequenceObject> LevelLoaders;
	local SequenceObject LevelLoader;

	Seq = WorldInfo.GetGameSequence();

	Seq.FindSeqObjectsByClass(class'PSSeqAct_LevelLoader', true, LevelLoaders);

	foreach LevelLoaders(LevelLoader)
	{
		//WorldInfo.Game.Broadcast(self,""$LevelLoader);
		PSSeqAct_LevelLoader(LevelLoader).ForceActivateOutput(PSGameReplicationInfo(WorldInfo.GRI).CurrentMapIndex);
	}
}

function UnstreamLevel()
{
	local Sequence Seq;
	local array<SequenceObject> LevelUnLoaders;
	local SequenceObject LevelUnLoader;

	Seq = WorldInfo.GetGameSequence();

	Seq.FindSeqObjectsByClass(class'PSSeqAct_LevelUnLoader', true, LevelUnLoaders);

	foreach LevelUnLoaders(LevelUnLoader)
	{
		//WorldInfo.Game.Broadcast(self,""$LevelUnLoader);
		PSSeqAct_LevelLoader(LevelUnLoader).ForceActivateOutput(PSGameReplicationInfo(WorldInfo.GRI).CurrentMapIndex);
	}
}

reliable server function KillPlayerInPrevMap()
{	
	local PSPlayerController PSC;
	//local Sequence Seq;
	//local array<SequenceObject> LevelLoaders;
	//local SequenceObject LevelLoader;
	//local array<SequenceObject> LevelLoaders;
	//local SequenceObject LevelLoader;

	local PlayerStart Target;
	local Vector NewLoc;
	local PSGame Game;

	Game = PSGame(WorldInfo.Game);

	foreach WorldInfo.AllControllers(class'PSPlayerController',PSC)
	{
		if(PSPlayerReplicationInfo(PSC.PlayerReplicationInfo).CurrentMapindex != PSGameReplicationInfo(WorldInfo.GRI).CurrentMapIndex)
		{
			Target = Game.ChooseTransitionPlayerStart(PSC, -1, PSC.GetTeamNum());
			NewLoc = Target.Location;
			PSC.Pawn.SetLocation(NewLoc);
			
			PSPlayerReplicationInfo(PSC.PlayerReplicationInfo).CurrentMapindex = PSGameReplicationInfo(WorldInfo.GRI).CurrentMapIndex;
			//WorldInfo.Game.Broadcast(self,'DeadPlayerMapIndex '$PSPlayerReplicationInfo(PSC.PlayerReplicationInfo).CurrentMapindex);
			PSPawn(PSC.Pawn).SetSuicide();
		}
	}

	//Stream/Unstream Levels
	//Seq = WorldInfo.GetGameSequence();

	//Seq.FindSeqObjectsByClass(class'PSSeqAct_LevelUnLoader', true, LevelLoaders);

	//foreach LevelLoaders(LevelLoader)
	//{
	//	WorldInfo.Game.Broadcast(self,""$LevelLoader);
	//	PSSeqAct_LevelUnLoader(LevelLoader).ForceActivateOutput(PSGameReplicationInfo(WorldInfo.GRI).CurrentMapIndex);
	//}

	//Seq.FindSeqObjectsByClass(class'PSSeqAct_LevelLoader', true, LevelLoaders);

	//foreach LevelLoaders(LevelLoader)
	//{
	//	WorldInfo.Game.Broadcast(self,""$LevelLoader);
	//	PSSeqAct_LevelUnLoader(LevelLoader).ForceActivateOutput(PSGameReplicationInfo(WorldInfo.GRI).CurrentMapIndex);
	//}
}

reliable server function TransitionToMap( Controller Player )
{
	local Vector NewLoc;
	local PlayerStart Target;
	local Rotator NewRot;

	Target = ChoosePlayerStart(Player);
	NewLoc = Target.Location;
	NewRot = Target.Rotation;

	Player.Pawn.SetLocation(NewLoc);
	Player.Pawn.ClientSetRotation(NewRot);//doesn't effing works!
}

function PlayerStart ChooseTransitionPlayerStart( Controller Player, int TransitionMapIndex,optional byte InTeam)
{
	local PSPlayerStart P, BestStart;
	local float BestRating, NewRating;
	local array<PSPlayerStart> PlayerStarts;
	local int i, RandStart;
	local byte Team;

	//local PSGameReplicationInfo PSGRI;

	//PSGRI = PSGameReplicationInfo(WorldInfo.GRI);

	// use InTeam if player doesn't have a team yet
	Team = ( (Player != None) && (Player.PlayerReplicationInfo != None) && (Player.PlayerReplicationInfo.Team != None) )
			? byte(Player.PlayerReplicationInfo.Team.TeamIndex)
			: InTeam;

	// make array of enabled playerstarts
	foreach WorldInfo.AllNavigationPoints(class'PSPlayerStart', P)
	{
		//only spawn point on current map is chosen
		if ( P.bEnabled && ( P.MapIndex == TransitionMapIndex))
			PlayerStarts[PlayerStarts.Length] = P;
		//`log(""$PSPlayerReplicationInfo(Player.PlayerReplicationInfo).CurrentMapindex);
	}

	// Avoid randomness for profiling.
	if( bFixedPlayerStart )
	{
		RandStart = 0;
	}
	// start at random point to randomize finding "good enough" playerstart
	else
	{
		RandStart = Rand(PlayerStarts.Length);
	}

	for ( i=RandStart; i<PlayerStarts.Length; i++ )
	{
		P = PlayerStarts[i];
		NewRating = RatePlayerStart(P,Team,Player);
		if ( NewRating >= 30 )
		{
			// this PlayerStart is good enough
			return P;
		}
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = P;
		}
	}
	for ( i=0; i<RandStart; i++ )
	{
		P = PlayerStarts[i];
		NewRating = RatePlayerStart(P,Team,Player);
		if ( NewRating >= 30 )
		{
			// this PlayerStart is good enough
			return P;
		}
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = P;
		}
	}
	return BestStart;
}

function PlayerStart ChoosePlayerStart( Controller Player, optional byte InTeam)
{
	local PSPlayerStart P, BestStart;
	local float BestRating, NewRating;
	local array<PSPlayerStart> PlayerStarts;
	local int i, RandStart;
	local byte Team;

	//local PSGameReplicationInfo PSGRI;

	//PSGRI = PSGameReplicationInfo(WorldInfo.GRI);

	// use InTeam if player doesn't have a team yet
	Team = ( (Player != None) && (Player.PlayerReplicationInfo != None) && (Player.PlayerReplicationInfo.Team != None) )
			? byte(Player.PlayerReplicationInfo.Team.TeamIndex)
			: InTeam;

	// make array of enabled playerstarts
	foreach WorldInfo.AllNavigationPoints(class'PSPlayerStart', P)
	{
		//only spawn point on current map is chosen
		if ( P.bEnabled && ( P.MapIndex == PSPlayerReplicationInfo(Player.PlayerReplicationInfo).CurrentMapindex))
			PlayerStarts[PlayerStarts.Length] = P;
		//`log(""$PSPlayerReplicationInfo(Player.PlayerReplicationInfo).CurrentMapindex);
	}

	// Avoid randomness for profiling.
	if( bFixedPlayerStart )
	{
		RandStart = 0;
	}
	// start at random point to randomize finding "good enough" playerstart
	else
	{
		RandStart = Rand(PlayerStarts.Length);
	}

	for ( i=RandStart; i<PlayerStarts.Length; i++ )
	{
		P = PlayerStarts[i];
		NewRating = RatePlayerStart(P,Team,Player);
		if ( NewRating >= 30 )
		{
			// this PlayerStart is good enough
			return P;
		}
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = P;
		}
	}
	for ( i=0; i<RandStart; i++ )
	{
		P = PlayerStarts[i];
		NewRating = RatePlayerStart(P,Team,Player);
		if ( NewRating >= 30 )
		{
			// this PlayerStart is good enough
			return P;
		}
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = P;
		}
	}
	return BestStart;
}


DefaultProperties
{
	PlayerReplicationInfoClass = class'ParadigmShift.PSPlayerReplicationInfo'
	GameReplicationInfoClass = class'ParadigmShift.PSGameReplicationInfo'
	DefaultPawnClass=class'ParadigmShift.PSPawn'
	PlayerControllerClass=class'ParadigmShift.PSPlayerController'

	DefaultInventory(0) = none

	CurrentMapIndex = -1
	PrevMapIndex = -1
	NumberOfMaps = 0

	MapTimer = 20.000
	PortalCloseTimer = 10.000

	HUDType = class'ParadigmShift.PSHUD'

	bUseClassicHUD = true
}