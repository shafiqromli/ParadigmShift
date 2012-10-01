class PSWeapon extends UTWeapon;

var bool bCanReload;
var repnotify int AmmoInMag;
var int MaxAmmoInMag;
var float ReloadTimer;

var float SpreadZoom;

replication
{
	if(bNetOwner)
		AmmoInMag;
}

simulated function ReloadWeapon()
{
	if(Instigator != none)
	{
		if(!bWeaponPutDown)
		{
			if(AmmoCount > 0 && AmmoInMag < MaxAmmoInMag)
			{		
				if(Role < ROLE_Authority)
				{
					ServerReloadWeapon();
				}			
				BeginReloadWeapon();
			}
		}
	}
}

reliable server function ServerReloadWeapon()
{
	if(Instigator != none || Instigator.Controller != none)
	{
		BeginReloadWeapon();
	}
}

simulated function BeginReloadWeapon()
{
	GotoState('Reloading');
}

function ConsumeAmmo(byte FireModeNum)
{
	AddAmmoToMag(-ShotCost[FireModeNum]);
}

function int AddAmmoToMag(int Amount)
{
	AmmoInMag = Clamp(AmmoInMag + Amount,0,MaxAmmoInMag);

	return AmmoInMag;
}

simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	return (AmmoInMag >= ShotCost[FireModeNum]);
}

simulated function bool HasAnyAmmo()
{
	return ( (AmmoInMag > 0) || (AmmoCount > 0) || (ShotCost[0]==0 && ShotCost[1]==0) );
}

simulated function bool HasAmmoInMag()
{
	return ( (AmmoInMag > 0) || (ShotCost[0]==0 && ShotCost[1]==0) );
}

simulated function int GetAmmoCount()
{
	return AmmoInMag;
}

simulated function StartFire(byte FireModeNum)
{
	if(!HasAmmoInMag())
	{
		WeaponEmpty();
	}
	else
	{
		super.StartFire(FireModeNum);
	}
}

simulated function BeginFire(byte FireModeNum)
{
	if(!HasAmmoInMag())
	{
		WeaponEmpty();
	}
	else
	{
		super.BeginFire(FireModeNum);
	}
}

simulated function WeaponEmpty()
{
	if(AmmoCount > 0)
		ReloadWeapon();	

	else if ( Instigator != none && Instigator.IsLocallyControlled() )
	{
		Instigator.InvManager.SwitchToBestWeapon( true );
	}
}

simulated function StartZoom(UTPlayerController PC)
{
	ChangeSpread(0,SpreadZoom);
	super.StartZoom(PC);
}

simulated function EndZoom(UTPlayerController PC)
{
	ChangeSpread(0,Default.Spread[0]);
	super.EndZoom(PC);
}

reliable server function ChangeSpread(int SpreadNum, float SpreadValue)
{
	Spread[SpreadNum] = SpreadValue;
}

simulated state Reloading
{
	simulated function BeginState(Name PreviousStateName)
	{
		SetTimer(ReloadTimer, false,'StartReload');
		EndZoom(UTPlayerController(Instigator.Controller));
	}

	simulated function BeginFire(byte FireModeNum)
	{
	}

	simulated function StartReload()
	{
		if(AmmoCount >= (MaxAmmoInMag-AmmoInMag))
		{
			AmmoCount -= (MaxAmmoInMag-AmmoInMag);
			AmmoInMag += (MaxAmmoInMag-AmmoInMag);			
		}
		else
		{
			AmmoInMag += AmmoCount;
			AmmoCount = 0;
		}

		GotoState('Active');
	}	
}

DefaultProperties
{
	AmmoInMag = 20
	MaxAmmoInMag = 20

	bZoomedFireMode(1) = 1
	ZoomedRate = 1000
	ZoomedTargetFOV = 45
}
