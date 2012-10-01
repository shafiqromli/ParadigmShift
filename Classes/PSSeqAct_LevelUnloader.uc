class PSSeqAct_LevelUnloader extends SequenceAction;

event Activated()
{
	local PSGame World;

	World = PSGame(GetWorldInfo().Game);

	ActivateOutputLink(World.CurrentMapIndex);
}

DefaultProperties
{
	ObjName="PS Level UnLoader"
	ObjCategory="PS"
	
	InputLinks(0)=(LinkDesc="In")

	OutputLinks(0)=(LinkDesc="Level_0")
	OutputLinks(1)=(LinkDesc="Level_1")
	OutputLinks(2)=(LinkDesc="Level_2")
	OutputLinks(3)=(LinkDesc="Level_3")
	OutputLinks(4)=(LinkDesc="Level_4")
	OutputLinks(5)=(LinkDesc="Level_5")
	OutputLinks(6)=(LinkDesc="Level_6")
	OutputLinks(7)=(LinkDesc="Level_7")

	bAutoActivateOutputLinks = false
}
