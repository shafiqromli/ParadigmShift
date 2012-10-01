class PSPawn extends UTPawn;

var bool bHoldingKey;
var float LastTakeDamage;

replication
{
	if(bNetDirty)
		LastTakeDamage;
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	//PSPlayerController(Controller).ClientMessage(""@WorldInfo.TimeSeconds@" | "@LastPainTime@" | "@WorldInfo.TimeSeconds - LastPainTime);
	if(WorldInfo.TimeSeconds - LastTakeDamage > 2.000)
	{
		if(VestArmor < 100)
			VestArmor = FMin(VestArmor += 2.0*DeltaTime,100.00);
	}
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	InvManager.CreateInventory(class'ParadigmShift.PSWeap_ShockRifleBase',false);
}

function int ShieldAbsorb( int Damage )
{
	if ( Health <= 0 )
	{
		return damage;
	}

	if ( VestArmor > 0 )
	{
		bShieldAbsorb = true;
		VestArmor = AbsorbDamage(Damage, VestArmor, 1.0);
		if ( Damage == 0 )
		{
			return 0;
		}
	}
	return Damage;
}

simulated function Reload()
{
	local PSWeapon PSW;

	PSW = PSWeapon(Weapon);
	if(PSW != none)
	{
		PSW.ReloadWeapon();
	}
}

function ShouldCrouch(bool bCrouch)
{
	if(PSPlayerController(Controller) != none)
	{
		if(PSPlayerController(Controller).bSprinting && !bIsCrouched)
			return;
	}
	super.ShouldCrouch(bCrouch);
}

reliable server function SetSuicide()
{
	SetTimer(0.1, false, 'Suicide');
}

simulated function GoToMap()
{
	PSGame(WorldInfo.Game).TransitionToMap(Controller);
}

simulated function StartTeleportCountdown()
{
	SetTimer(5.000, false, 'GoToMap');
}

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	LastTakeDamage = WorldInfo.TimeSeconds;
}

DefaultProperties
{	
	bHoldingKey = false
	VestArmor = 100.000000
}
