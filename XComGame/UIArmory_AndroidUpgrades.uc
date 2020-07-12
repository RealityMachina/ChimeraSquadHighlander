//---------------------------------------------------------------------------------------
//  FILE:    	UIArmory_AndroidUpgrades
//  AUTHOR:  	David McDonough  --  4/18/2019
//  PURPOSE: 	Specialization of UIArmory for equipping Android Upgrades.
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2019 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class UIArmory_AndroidUpgrades extends UIArmory_CompactLoadout;

simulated function InitArmory_AndroidUpgrades(StateObjectReference UnitRef, optional name DispEvent, optional name SoldSpawnEvent, optional name NavBackEvent, optional name HideEvent, optional name RemoveEvent, optional bool bInstant = false, optional XComGameState InitCheckGameState)
{
	super.InitArmory(UnitRef, DispEvent, SoldSpawnEvent, NavBackEvent, HideEvent, RemoveEvent, bInstant, InitCheckGameState);
	MC.FunctionString("setLeftPanelTitle", class'XLocalizedData'.default.UpgradesHeader);
	UpdateNavHelp();
}

simulated function InitializeLists()
{
	WeaponList.InitLoadoutList(UnitReference, eInvSlot_AndroidVision, 'section0');
	ArmorList.InitLoadoutList(UnitReference, eInvSlot_AndroidCPU, 'section1');
	BreachList.InitLoadoutList(UnitReference, eInvSlot_AndroidChassis, 'section2');
	UtilityList.InitLoadoutList(UnitReference, eInvSlot_AndroidMotor, 'section3');
}

simulated static function bool CanCycleTo(XComGameState_Unit Unit)
{
	// issue RM 10 begins: use our RMHelpers function to check for this
	return class'RMHelpers'.static.IsLikeAndroidForArmory(Unit, true);
}