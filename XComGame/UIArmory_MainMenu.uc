
class UIArmory_MainMenu 
	extends UIArmory
	dependson(UIDialogueBox)
	dependson(UIUtilities_Strategy);

var localized string m_strTitle;
var localized string m_strCustomizeSoldier;
var localized string m_strCustomizeWeapon;
var localized string m_strAbilities;
var localized string m_strPromote;
var localized string m_strPropaganda;
var localized string m_strImplants;
var localized string m_strLoadout;
var localized string m_strTrain;
var localized string m_strBiography;
var localized string m_strUpgrade;
var localized string m_strRepair;
var localized string m_strArmorTint;
var localized string m_strApplyArmorTintToEveryone;

var localized string m_strPromoteDesc;
var localized string m_strImplantsDesc;
var localized string m_strLoadoutDesc;
var localized string m_strBiographyDesc;
var localized string m_strSoldierBondsDesc;
var localized string m_strTrainDesc;
var localized string m_strUpgradeDesc;
var localized string m_strRepairDesc;
var localized string m_strPropagandaDesc;
var localized string m_strCustomizeWeaponDesc;
var localized string m_strCustomizeSoldierDesc;
var localized string m_strArmorTintDesc;

var localized string m_strDismissDialogTitle;
var localized string m_strDismissDialogDescription;

var localized string m_strRookiePromoteTooltip;
var localized string m_strNoImplantsTooltip;
var localized string m_strNoGTSTooltip;
var localized string m_strCantEquiqPCSTooltip;
var localized string m_strNoModularWeaponsTooltip;
var localized string m_strCannotUpgradeWeaponTooltip;
var localized string m_strNoWeaponUpgradesTooltip;
var localized string m_strInsufficientRankForImplantsTooltip;
var localized string m_strCombatSimsSlotsFull;

var localized string m_strToggleAbilities;
var localized string m_strToggleTraits;

var localized string m_strMainMenuTitle;
var localized string m_strColorPickerTitle;

// set to true to prevent spawning popups when cycling soldiers
var bool bIsHotlinking;
var bool bIsColorPicking;

var int previewColor;

var UIList List;
var UIListItemString PromoteItem;
var protected UIColorSelector ColorSelector;
var int						  OriginalSelectedColor;
var XComCharacterCustomization CustomizeManager;
var bool bListingTraits; 

simulated function InitArmory(StateObjectReference UnitRef, optional name DispEvent, optional name SoldSpawnEvent, optional name NavBackEvent, optional name HideEvent, optional name RemoveEvent, optional bool bInstant = false, optional XComGameState InitCheckGameState)
{
	bUseNavHelp = true;
	super.InitArmory(UnitRef, DispEvent, SoldSpawnEvent, NavBackEvent, HideEvent, RemoveEvent, bInstant, CheckGameState);

	List = Spawn(class'UIList', self).InitList('armoryMenuList');
	List.OnItemClicked = OnItemClicked;
	List.OnSelectionChanged = OnSelectionChanged;

	Movie.Pres.InitializeCustomizeManager(GetUnit());
	CustomizeManager = Movie.Pres.GetCustomizeManager();

	RegisterForEvents();
	CreateSoldierPawn();
	PopulateData();
}

function RegisterForEvents()
{
	local X2EventManager EventManager;
	local Object SelfObject;

	EventManager = `XEVENTMGR;
	SelfObject = self;

	EventManager.RegisterForEvent(SelfObject, 'STRATEGY_AndroidRepaired_Submitted', OnAndroidRepaired, ELD_OnStateSubmitted);
}

//---------------------------------------------------------------------------------------
function UnRegisterForEvents()
{
	local X2EventManager EventManager;
	local Object SelfObject;

	EventManager = `XEVENTMGR;
	SelfObject = self;

	EventManager.UnRegisterFromEvent(SelfObject, 'STRATEGY_AndroidRepaired_Submitted');
}

simulated function PopulateData()
{
	local string PromoteIcon;
	local XComGameState_Unit Unit;
	local UIListItemString listItem;
	local XGParamTag LocTag;
	local string TempString;
	local int Cost;

	super.PopulateData();
	MC.FunctionString("setMainMenuTitle", m_strMainMenuTitle);

	if (bIsColorPicking)
		return;

	List.ClearItems();

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));

	// -------------------------------------------------------------------------------
	// Loadout:
	listItem = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strLoadout);
	listItem.metadataInt = 0;

	// -------------------------------------------------------------------------------
	// Weapon Upgrade:
	/*if (`DIOHQ.HasCompletedResearchByName('DioResearch_ModularWeapons') || `CheatStart)
	{
		listItem = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strCustomizeWeapon);
		listItem.metadataInt = 1;
	}*/

	//--------------------------------------------------------------------------------
	// ANDROID Options
	//--------------------------------------------------------------------------------	
	
	if (Unit.IsAndroid())
	{
		// Upgrade
		listItem = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strUpgrade);
		listItem.metadataInt = 3;

		// Repair
		if (Unit.IsInjured())
		{
			// Button labels
			Cost = class'DioStrategyAI'.static.GetAndroidRepairCost(UnitReference);
			LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
			LocTag.IntValue0 = Cost;
			TempString = `XEXPAND.ExpandString(class'UIDIOArmory_AndroidRepair'.default.TagStr_RepairOne);
			listItem = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(TempString);
			listItem.metadataInt = 4;

			Cost = class'DioStrategyAI'.static.GetAndroidRepairCost(UnitReference, true);
			LocTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
			LocTag.IntValue0 = Cost;
			TempString = `XEXPAND.ExpandString(class'UIDIOArmory_AndroidRepair'.default.TagStr_RepairAll);			

			listItem = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(TempString);
			listItem.metadataInt = 7;
		}
	}
	else
	{
		// -------------------------------------------------------------------------------
		// Promotion:

		if(Unit.ShowPromoteIcon())
		{
			PromoteIcon = class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.const.HTML_PromotionIcon, 20, 20, 0) $ " ";
			PromoteItem = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(PromoteIcon $ m_strPromote);
		}
		else
		{
			PromoteItem = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strAbilities);
		}
		PromoteItem.metadataInt = 2;

		listItem = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strBiography);
		listItem.metadataInt = 6;
	}
	// issue RM 10 begins: use our RMHelpers function to check for upgrades for units that may need it despite not being a normal android
	if(class'RMHelpers'.static.IsLikeAndroidForArmory(Unit))
	{
		// Upgrade
		listItem = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strUpgrade);
		listItem.metadataInt = 3;
	}
		// end issue RM 10
	listItem = Spawn(class'UIListItemString', List.ItemContainer).InitListItem(m_strArmorTint);
	listItem.metadataInt = 5;

	RefreshAbilitySummary();
	UpdateNavHelp();

	List.Navigator.SelectFirstAvailable();

	// Strategy Tutorial: spoof active screen event to refresh tutorial in case of scars/promotions on new agent
	`XEVENTMGR.TriggerEvent('UIEvent_ActiveScreenChanged', self);
}

simulated function RefreshAbilitySummary()
{
	local XComGameState_Unit Unit;
	local bool bHasTraits;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
	if( bListingTraits )
	{
		bHasTraits = class'UIUtilities_Strategy'.static.PopulateAbilitySummary_Traits(self, Unit, true);

		if( !bHasTraits )
		{
			bHasTraits = class'UIUtilities_Strategy'.static.PopulateAbilitySummary(self, Unit, true);
		}
	}
	else
	{
		bHasTraits = class'UIUtilities_Strategy'.static.PopulateAbilitySummary(self, Unit, true);
	}
}

simulated function UpdateNavHelp()
{
	local XComGameState_Unit Unit;

	m_HUD.NavHelp.ClearButtonHelp();
	m_HUD.NavHelp.AddBackButton(OnCancel);

	if (`ISCONTROLLERACTIVE)
	{
		m_HUD.NavHelp.AddSelectNavHelp();
		if (IsAllowedToCycleSoldiers())
		{
			m_HUD.NavHelp.AddLeftHelp(Caps(ChangeSoldierLabel), class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_LBRB_L1R1);
		}
	}
	
	if (bIsColorPicking)
	{
		if (`ISCONTROLLERACTIVE)
			m_HUD.NavHelp.AddCenterHelp(m_strApplyArmorTintToEveryone, class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_Y_Triangle); // bsg-jrebar (05/19/17): Changing to X
		else
			m_HUD.NavHelp.AddCenterHelp(m_strApplyArmorTintToEveryone, , ApplyArmorTintToEveryone);
	}

	// If you don't have any traits, then we aren't going to show you toggle option at all. 
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
	if( Unit.AcquiredTraits.length == 0 ) return;

	if( bUseNavHelp )
	{

		if( XComHQPresentationLayer(Movie.Pres) != none )
		{	
			if( bListingTraits )
			{
				if( `ISCONTROLLERACTIVE )
					m_HUD.NavHelp.AddRightHelp(m_strToggleAbilities, class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_X_SQUARE); // bsg-jrebar (05/19/17): Changing to X
				else
					m_HUD.NavHelp.AddRightHelp(m_strToggleAbilities, , ToggleAbilitiesAndTraits);
			}
			else
			{
				if( `ISCONTROLLERACTIVE )
					m_HUD.NavHelp.AddRightHelp(m_strToggleTraits, class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_X_SQUARE); // bsg-jrebar (05/19/17): Changing to X
				else
					m_HUD.NavHelp.AddRightHelp(m_strToggleTraits, , ToggleAbilitiesAndTraits);
			}
		}
	}
}

simulated function ToggleAbilitiesAndTraits()
{
	if( bUseNavHelp )
	{
		bListingTraits = !bListingTraits; 
		RefreshAbilitySummary();
		UpdateNavHelp();
	}
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	PopulateData();
	CreateSoldierPawn();
	Header.PopulateData();
}

simulated function OnAccept()
{
	local XComStrategyPresentationLayer StratPres;
	local X2StrategyGameRuleset StratRules;
	local string AkEventName;

	if( UIListItemString(List.GetSelectedItem()).bDisabled )
	{
		PlayNegativeMouseClickSound();
		return;
	}

	StratPres = XComStrategyPresentationLayer(Movie.Pres);


	// Index order matches order that elements get added in 'PopulateData'
	switch(UIListItemString(List.GetSelectedItem()).metadataInt)
	{
	case 0: // LOADOUT
		if(StratPres != none )
			OnClickArmoryLoadout();
		break;
	case 1:
		if (`DIOHQ.HasCompletedResearchByName('DioResearch_ModularWeapons') || `CheatStart)
			OnClickArmoryWeaponMods();
	
		break;
	case 2: // PROMOTE
		
		OnClickArmoryPromotion();				
		break;
	case 3: // PROMOTE
		
		if (StratPres != none)
			OnClickUpgrade();
		break;
	case 4: // REPAIR 1 
		
		AkEventName = "UI_Strategy_Android_Repair_Confirm";
		`SOUNDMGR.PlayAkEventDirect(AkEventName, self);
		StratRules = `STRATEGYRULES;
		StratRules.SubmitRepairAndroid(UnitReference, false);
		break;

	case 5:
		OnClickTintArmor();
		break;

	case 6:
		OnClickBiography();
		break;

	case 7:// REPAIR All

		AkEventName = "UI_Strategy_Android_Repair_Confirm";
		`SOUNDMGR.PlayAkEventDirect(AkEventName, self);
		StratRules = `STRATEGYRULES;
		StratRules.SubmitRepairAndroid(UnitReference, true);
		break;
	}

	//`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuSelect");
}

function EventListenerReturn OnAndroidRepaired(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	Header.PopulateData();
	PopulateData();
	return ELR_NoInterrupt;
}

function OnClickArmoryLoadout()
{
	if (`ScreenStack.IsNotInStack(class'UIArmory_CompactLoadout'))
	{
		UIArmory_CompactLoadout(`ScreenStack.Push(Spawn(class'UIArmory_CompactLoadout', self))).InitArmory(UnitReference, , , , , , , CheckGameState);
	}
}

function OnClickBiography()
{
	`STRATPRES.UIBiographyScreen();
}

function OnClickArmoryPromotion()
{
	if (`ScreenStack.IsNotInStack(class'UIArmory_Promotion'))
	{
		UIArmory_Promotion(`ScreenStack.Push(Spawn(class'UIArmory_Promotion', self))).InitPromotion(UnitReference, true);
	}
}

function OnClickArmoryTraining()
{
	local XComStrategyPresentationLayer StratPres;

	if (!class'DioStrategyAI'.static.CanStartTrainingAction(UnitReference))
	{
		return;
	}

	StratPres = XComStrategyPresentationLayer(Movie.Pres);
	StratPres.UITrainingActionPicker(UnitReference);
}

function OnClickTintArmor()
{
	if (ColorSelector == none)
	{
		List.Hide();
		ColorSelector = Spawn(class'UIColorSelector', self);
		ColorSelector.InitColorSelector(, 125, 200, 350, 500, CustomizeManager.GetColorList(eUICustomizeCat_PrimaryArmorColor), PreviewArmorColor, SetArmorColor, GetUnit().kAppearance.iArmorTint);
		ColorSelector.SetSelectedNavigation();
		//ListBG.ProcessMouseEvents(ColorSelector.OnChildMouseEvent);
		MC.FunctionVoid("HideBGTint");
		MC.FunctionString("setMainMenuTitle", m_strColorPickerTitle);
		OnSelectionChanged(List, -1);
		bIsColorPicking = true;

		UpdateNavHelp();
	}
}

function PreviewArmorColor(int iColorIndex)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	
	if(`ISCONTROLLERACTIVE)
	{	
		previewColor = iColorIndex;

		ActorPawn = Movie.Pres.GetUIPawnMgr().RequestPawnByState(self, GetUnit());

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Armor Color Change");

		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', GetUnitRef().ObjectID));
		UnitState.kAppearance.iArmorTint = iColorIndex;
		UnitState.kAppearance.iArmorTintSecondary = iColorIndex;

		XComUnitPawn(ActorPawn).SetArmorTint(iColorIndex);

		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		ActorPawn = none;
	}
}

function SetArmorColor(int iColorIndex)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	
	previewColor = iColorIndex;
	OriginalSelectedColor = iColorIndex;

	ActorPawn = Movie.Pres.GetUIPawnMgr().RequestPawnByState(self, GetUnit());

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Armor Color Change");

	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', GetUnitRef().ObjectID));
	UnitState.kAppearance.iArmorTint = iColorIndex;
	UnitState.kAppearance.iArmorTintSecondary = iColorIndex;

	XComUnitPawn(ActorPawn).SetArmorTint(iColorIndex);

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	//CloseColorSelector();

	ActorPawn = none;

	//Movie.Pres.GetUIPawnMgr().ReleasePawn(self, GetUnitRef().ObjectID, true);
}

function ApplyArmorTintToEveryone()
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local StateObjectReference unitRef;

	PlayConfirmSound();

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Armor Color Change");
	OriginalSelectedColor = previewColor;

	foreach `DioHQ.Squad(unitRef)
	{
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', unitRef.ObjectID));
		UnitState.kAppearance.iArmorTint = previewColor;
		UnitState.kAppearance.iArmorTintSecondary = previewColor;

		ActorPawn = Movie.Pres.GetUIPawnMgr().RequestPawnByState(self, UnitState);
		XComUnitPawn(ActorPawn).SetArmorTint(previewColor);
	}

	foreach `DioHQ.Androids(unitRef)
	{
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', unitRef.ObjectID));
		UnitState.kAppearance.iArmorTint = previewColor;
		UnitState.kAppearance.iArmorTintSecondary = previewColor;

		ActorPawn = Movie.Pres.GetUIPawnMgr().RequestPawnByState(self, UnitState);
		XComUnitPawn(ActorPawn).SetArmorTint(previewColor);
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	CloseColorSelector();
}

simulated function CloseColorSelector(optional bool bCancelColorSelection)
{
	if (bCancelColorSelection)
		ColorSelector.OnCancelColor();

	if (OriginalSelectedColor != previewColor)
	{
		SetArmorColor(OriginalSelectedColor);
	}

	ColorSelector.Remove();
	ColorSelector = none;

	bIsColorPicking = false;

	//ListBG.ProcessMouseEvents(List.OnChildMouseEvent);
	List.Show();
	List.SetSelectedNavigation();

	MC.FunctionVoid("ShowBGTint");
	MC.FunctionString("setMainMenuTitle", m_strMainMenuTitle);

	UpdateNavHelp();
}

function OnClickUpgrade()
{
	if (`ScreenStack.IsNotInStack(class'UIArmory_AndroidUpgrades'))
	{
		UIArmory_AndroidUpgrades(`ScreenStack.Push(Spawn(class'UIArmory_AndroidUpgrades', self))).InitArmory_AndroidUpgrades(UnitReference, , , , , , , CheckGameState);
	}
}

function OnClickRepair()
{
	if (`ScreenStack.IsNotInStack(class'UIDIOArmory_AndroidRepair'))
	{
		UIDIOArmory_AndroidRepair(`ScreenStack.Push(Spawn(class'UIDIOArmory_AndroidRepair', self))).InitArmory_AndroidRepair(UnitReference, , , , , , , CheckGameState);
	}
}

function OnClickArmoryPropaganda()
{
	local UIArmory_Photobooth photoBoothScreen;

	if (`ScreenStack.IsNotInStack(class'UIArmory_Photobooth'))
	{
		photoBoothScreen = UIArmory_Photobooth(`ScreenStack.Push(Spawn(class'UIArmory_Photobooth', self)));
		photoBoothScreen.InitPropaganda(UnitReference);
	}
}

function OnClickArmoryWeaponMods()
{
	if (`ScreenStack.IsNotInStack(class'UIArmory_WeaponUpgrade'))
	{
		UIArmory_WeaponUpgrade(`ScreenStack.Push(Spawn(class'UIArmory_WeaponUpgrade', self))).InitArmory(UnitReference, , , , , , , CheckGameState);
	}
}

simulated function OnItemClicked(UIList ContainerList, int ItemIndex)
{
	OnAccept();
}

simulated function OnSelectionChanged(UIList ContainerList, int ItemIndex)
{
	local XComStrategyPresentationLayer Pres;
	local string Description;

	Description = ""; 
	
	if( ItemIndex > -1 ) //may be intentionally blank
	{
		// Index order matches order that elements get added in 'PopulateData'
		switch( UIListItemString(List.GetSelectedItem()).metadataInt )
		{
		case 0: // LOADOUT
			Description = m_strLoadoutDesc;
			break;
		case 1: // LOADOUT
			Description = m_strCustomizeWeaponDesc;
			break;
		case 2: // PROMOTE
			Description = m_strPromoteDesc;
			break;
		case 3: // ANDROID UPGRADE
			Description = m_strUpgradeDesc;
			break;
		case 4: // ANDROID UPGRADE
			Description = m_strRepairDesc;
			break;
		case 5: // PHOTOBOOTH
			Description = m_strArmorTintDesc;
			break;
		case 6: // BIOGRAPHY
			Description = m_strBiographyDesc;
			break;
		}
	}

	Pres = `STRATPRES;
	Pres.ForceRefreshActiveScreenChanged();

	MC.ChildSetString("descriptionText", "htmlText", class'UIUtilities_Text'.static.AddFontInfo(Description, bIsIn3D));
}

//==============================================================================

simulated function OnCancel()
{
	if (ColorSelector != none)
	{
		CloseColorSelector();
	}
	else
	{
		super.OnCancel();
	}
}

//==============================================================================

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	// bsg-jrebar (5/23/17): Added error handling and replaced ti use X button
	local XComGameState_Unit Unit;
	local bool bHandled; // Has input been 'consumed'?
	
	if ( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
		return false;

	switch( cmd )
	{
	case class'UIUtilities_Input'.const.FXS_KEY_ENTER :
	case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR :
		// If enter and/or spacebar are changed to set armor color, use the mouse click sound
		//PlayMouseClickSound();
		SuppressNextNonCursorConfirmSound();
		break;
	case class'UIUtilities_Input'.const.FXS_BUTTON_A :
		PlayMouseClickSound();
		if (bIsColorPicking)
		{
			SetArmorColor(previewColor);
			return true;
		}
		else
		{
			SuppressNextNonCursorConfirmSound();
		}
		break;
	case class'UIUtilities_Input'.const.FXS_BUTTON_X :
		// If you don't have any traits, then we aren't going to show you toggle option at all. 
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));

		if( Unit.AcquiredTraits.length >= 0 )
		{
			PlayMouseClickSound();
			ToggleAbilitiesAndTraits(); 
		}
		return true; 
	case class'UIUtilities_Input'.const.FXS_BUTTON_Y :
		if (bIsColorPicking)
		{
			ApplyArmorTintToEveryone();
			return true;
		}
		break;

	case class'UIUtilities_Input'.const.FXS_BUTTON_RBUMPER :
		PlayMouseClickSound();
		NextSoldier();
		bHandled = true;
		break;

	case class'UIUtilities_Input'.const.FXS_BUTTON_LBUMPER :
		PlayMouseClickSound();
		PrevSoldier();
		bHandled = true;
		break;

	case class'UIUtilities_Input'.const.FXS_DPAD_UP:
	case class'UIUtilities_Input'.const.FXS_DPAD_DOWN:
	case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_UP:
	case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_DOWN:
	case class'UIUtilities_Input'.const.FXS_KEY_W:
	case class'UIUtilities_Input'.const.FXS_KEY_S:
	case class'UIUtilities_Input'.const.FXS_ARROW_UP:
	case class'UIUtilities_Input'.const.FXS_ARROW_DOWN:
		if (!`XSTRATEGYSOUNDMGR.IsBiographyScreenOpen())
		{
			PlayMouseOverSound();
		}
		// Leave bHandled false
		break;
	case class'UIUtilities_Input'.const.FXS_DPAD_LEFT:
	case class'UIUtilities_Input'.const.FXS_DPAD_RIGHT:
	case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_LEFT:
	case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_RIGHT:
	case class'UIUtilities_Input'.const.FXS_KEY_A:
	case class'UIUtilities_Input'.const.FXS_KEY_D:
	case class'UIUtilities_Input'.const.FXS_ARROW_LEFT:
	case class'UIUtilities_Input'.const.FXS_ARROW_RIGHT:
		if (bIsColorPicking)
		{
			PlayMouseOverSound();
		}
		// Leave bHandled false
		break;

	default:
		bHandled = false;
		break;
	}

	if (!bHandled)
	{
		return super.OnUnrealCommand(cmd, arg);
		// bsg-jrebar (5/23/17): end
	}

	return bHandled;
}

//---------------------------------------------------------------------------------------
simulated function CloseScreen()
{
	UnRegisterForEvents();
	super.CloseScreen();
}

defaultproperties
{
	LibID = "ArmoryMenuScreenMC";
	DisplayTag = "UIBlueprint_ArmoryMenu";
	CameraTag = "UIBlueprint_ArmoryMenu";

	bShowExtendedHeaderData = true;
	bListingTraits = true; 
	bIsColorPicking = false;
}