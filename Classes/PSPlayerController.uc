class PSPlayerController extends UTPlayerController;

var float SprintSpeed;
var float WalkSpeed;

var float DefaultStamina;
var repnotify float Stamina;

var repnotify bool bSprinting;

var PSExperienceSystem Exp;
var class<PSExperienceSystem> ExpClass;

replication
{
	if( bNetOwner )
		Stamina, bSprinting;
}


simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if(Role < ROLE_Authority)
	{
		ServerSpawnExp();
	}
	Exp = Spawn(ExpClass,self,,,,,);
}

reliable server function ServerSpawnExp()
{
	Exp = Spawn(ExpClass,self,,,,,);
}

simulated function PlayerTick(float DeltaTime)
{	
	super.PlayerTick(DeltaTime);
	if(Pawn != none)
	{
		if(Role < ROLE_Authority)
		{
			ServerCalcGroundSpeed();
			ServerCalcStamina(DeltaTime);
		}
		CalcGroundSpeed();
		CalcStamina(DeltaTime);
	}
}

exec function StartFire(optional byte FireModeNum)
{	
	if(Pawn != None && bSprinting)
	{
		StopFiring();
	}	
	else
	{
		super.StartFire(FireModeNum);
	}
}

//-----------------------Sprint---------------------------

exec function StartSprint()
{
	if(Pawn != none)
	{
		if(Role < ROLE_Authority)
		{
			ServerBeginSprint();
		}
		BeginSprint();
	}	
}

reliable server function ServerBeginSprint()
{
	if(Pawn != none || Pawn.Controller != none)
	{
		BeginSprint();
	}
}

simulated function BeginSprint()
{
	local PSWeapon PSW;

	if(bDuck != 0)
	{
		bDuck = 0;
	}

	if(Stamina > 1.0)
	{
		bSprinting = true;	
	}

	if(Pawn.Weapon != none)
	{
		PSW = PSWeapon(Pawn.Weapon);
	}
	PSW.EndZoom(self);
}

reliable server function ServerEndSprint()
{
	if(Pawn != none || Pawn.Controller != none)
	{
		EndSprint();
	}
}

exec function StopSprint()
{
	if(Pawn != none)
	{
		if(Role < ROLE_Authority)
		{
			ServerEndSprint();
		}
		EndSprint();
	}
}

simulated function EndSprint()
{
	Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
	bSprinting = false;
}
//---------------EndSprint-------------------------
reliable server function ServerCalcGroundSpeed()
{
	if(Pawn != none)
	{
		CalcGroundSpeed();
	}
}

reliable server function ServerCalcStamina(float DeltaTime)
{
	if(Pawn != none)
	{		
		CalcStamina(DeltaTime);
	}
}

simulated function CalcGroundSpeed()
{
	local Vector X,Y,Z,Dir;

	Pawn.GetAxes(Pawn.Rotation,X,Y,Z);
	Dir = Normal(Pawn.Acceleration);

	if(bSprinting && ((X dot Dir) > 0))
	{
		Pawn.GroundSpeed = SprintSpeed;
	}
	else
	{
		Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
	}
}

simulated function CalcStamina(float DeltaTime)
{
	if(Pawn.GroundSpeed > Pawn.Default.GroundSpeed)
	{
		CheckStamina(DeltaTime);
		StopFiring();
	}
	else
	{
		if(Stamina < DefaultStamina)
		{
			ReplenishStamina(DeltaTime);
		}
	}
}

simulated function ReplenishStamina(float DeltaTime)
{
	Stamina += 1.0 * DeltaTime;
	FClamp(Stamina,0.0, DefaultStamina);	
}

simulated function CheckStamina(float DeltaTime)
{	
	Stamina -= 2.0 * DeltaTime;

	if(Stamina <= 0.0)
	{
		Stamina = 0.0;
		stopSprint();
	}
}

//---------------Reload-------------------------

exec function Reload()
{
	local PSPawn PSP;
	if(Pawn != none)
	{
		PSP = PSPawn(Pawn);
		PSP.Reload();
	}
}
//---------------EndReload----------------------

simulated function AddXP(int Value)
{
	if(Role < ROLE_Authority)
			ServerAddXP(Value);

	Exp.AddXP(Value);
}

reliable server function ServerAddXP(int value)
{
	Exp.AddXP(value);
}

state Dead
{
	function BeginState(Name PreviousStateName)
	{
		bSprinting = false;
		PSWeapon(Pawn.Weapon).EndZoom(self);
		super.BeginState(PreviousStateName);
	}
}

DefaultProperties
{
	ExpClass = class'PSExperienceSystem'
	WalkSpeed=440.0
	SprintSpeed=1000.0
	bSprinting = false
	Stamina=10.0
	DefaultStamina = 10.00000
}
