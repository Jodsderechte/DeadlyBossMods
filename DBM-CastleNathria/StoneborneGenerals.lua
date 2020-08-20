local mod	= DBM:NewMod(2425, "DBM-CastleNathria", nil, 1190)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(168112, 168113)
mod:SetEncounterID(2417)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)
mod:SetBossHPInfoToHighest()
mod:SetHotfixNoticeRev(20200820000000)--2020, 8, 20
mod:SetMinSyncRevision(20200820000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 333387 334765 334929 334498 339690 342544 339164 334009 342256 340043 342722 332683 342425",
	"SPELL_CAST_SUCCESS 334765 334929",
	"SPELL_AURA_APPLIED 329636 333913 334765 338156 338153 329808 333377 339690 342655 340037 343273 342425 336212",
	"SPELL_AURA_APPLIED_DOSE 333913",
	"SPELL_AURA_REMOVED 329636 333913 334765 329808 333377 339690 340037",
	"SPELL_AURA_REMOVED_DOSE 333913",
--	"SPELL_PERIODIC_DAMAGE",
--	"SPELL_PERIODIC_MISSED",
	"UNIT_DIED",
	"RAID_BOSS_WHISPER",
	"UNIT_SPELLCAST_SUCCEEDED boss3 boss4 boss5",
	"UNIT_SPELLCAST_START boss1 boss2"
)

--TODO, Target scan meteor target, if it's not same target as crystalize
--TODO, add https://ptr.wowhead.com/spell=343060/stone-spike when Grashaal is in air?
--TODO, add https://ptr.wowhead.com/spell=336231/cluster-bombardment for adds?
--TODO, verify timer for https://ptr.wowhead.com/spell=340043
--TODO, stack announces for https://ptr.wowhead.com/spell=340042/punishment if it stacks
--TODO, https://shadowlands.wowhead.com/spell=342254/wicked-slaughter targeting?
--TODO, https://ptr.wowhead.com/spell=342985/stonegale-effigy needs announcing probably, but what event?
--TODO, target scan/yell for https://ptr.wowhead.com/spell=343086/ricocheting-shuriken ?
--TODO, is https://ptr.wowhead.com/spell=342425/stone-fist stacked or always swap at 1 in proper situation?
--[[
(ability.id = 333387 or ability.id = 334929 or ability.id = 339164 or ability.id = 334009 or ability.id = 334498 or ability.id = 342544) and type = "begincast"
 or (ability.id = 334765 or ability.id = 339690) and type = "cast"
 or ability.id = 329636 or ability.id = 329808
 --]]
 --General
local warnHardenedStoneForm						= mod:NewTargetNoFilterAnnounce(329636, 2)
local warnHardenedStoneFormOver					= mod:NewEndAnnounce(329636, 1)
local warnSoldiersOath							= mod:NewTargetNoFilterAnnounce(336212, 4)
--General Kaal
local warnWickedBlade							= mod:NewTargetNoFilterAnnounce(333376, 4)
local warnHeartRend								= mod:NewTargetNoFilterAnnounce(334765, 4)
local warnCallShadowForces						= mod:NewSpellAnnounce(342256, 2)
--General Grashaal
local warnReverberatingLeap						= mod:NewTargetNoFilterAnnounce(334004, 3)
local warnCrystalize							= mod:NewTargetNoFilterAnnounce(339690, 2)
local warnPulverizingMeteor						= mod:NewTargetNoFilterAnnounce(342544, 4)
--Adds
local warnVolatileAnimaInfusion					= mod:NewTargetNoFilterAnnounce(342655, 2, nil, false)
local warnRavenousFeast							= mod:NewTargetNoFilterAnnounce(343273, 3)
local warnStonewrathExhaust						= mod:NewCastAnnounce(342722, 3)
--local warnStonegaleEffigy						= mod:NewSpellAnnounce(342985, 3)

--General Kaal
local specWarnWickedBlade						= mod:NewSpecialWarningYouPos(333376, nil, nil, nil, 1, 2)
local yellWickedBlade							= mod:NewPosYell(333376)
local yellWickedBladeFades						= mod:NewIconFadesYell(333376)
local specWarnHeartRend							= mod:NewSpecialWarningYou(334765, false, nil, nil, 1, 2)
local specWarnSerratedSwipe						= mod:NewSpecialWarningDefensive(334929, nil, nil, nil, 1, 2)
--local specWarnLaceration						= mod:NewSpecialWarningStack(333913, nil, 3, nil, nil, 1, 6)
--local specWarnGTFO							= mod:NewSpecialWarningGTFO(270290, nil, nil, nil, 1, 8)
--General Grashaal
local specWarnReverberatingLeap					= mod:NewSpecialWarningMoveAway(334004, nil, nil, nil, 1, 2)
local yellReverberatingLeap						= mod:NewYell(334004, 183611)--Short text "Leap"
local yellReverberatingLeapFades				= mod:NewFadesYell(334004, 183611)--Short text "Leap"
local specWarnSeismicUpheaval					= mod:NewSpecialWarningDodge(334498, nil, nil, nil, 2, 2)
local specWarnCrystalize						= mod:NewSpecialWarningYou(339690, nil, nil, nil, 1, 2)
local yellCrystalize							= mod:NewYell(339690, nil, nil, nil, "YELL")
local yellCrystalizeFades						= mod:NewFadesYell(339690, nil, nil, nil, "YELL")
local specWarnMeteor							= mod:NewSpecialWarningYou(342544, nil, nil, nil, 1, 2)
local yellMeteor								= mod:NewYell(342544, nil, nil, nil, "YELL")
local specWarnStoneFist							= mod:NewSpecialWarningDefensive(342425, nil, nil, nil, 1, 2)
local specWarnStoneFistTaunt					= mod:NewSpecialWarningTaunt(342425, nil, nil, nil, 1, 2)
--Adds/Intermissions
local specWarnVolatileStoneShell				= mod:NewSpecialWarningSwitch(340037, "Dps", nil, nil, 1, 2)
local specWarnShatteringBlast					= mod:NewSpecialWarningSpell(332683, nil, nil, nil, 2, 2)

--General Kaal
mod:AddTimerLine(DBM:EJ_GetSectionInfo(22284))
local timerWickedBladeCD						= mod:NewAITimer(28.9, 333387, nil, nil, nil, 3)
local timerHeartRendCD							= mod:NewAITimer(43.6, 334765, nil, nil, nil, 3, nil, DBM_CORE_L.DEADLY_ICON)
local timerSerratedSwipeCD						= mod:NewAITimer(11.1, 334929, nil, "Tank", nil, 5, nil, DBM_CORE_L.TANK_ICON)--12.6-18.1
local timerCallShadowForcesCD					= mod:NewAITimer(28.9, 342256, nil, nil, nil, 1, nil, DBM_CORE_L.MYTHIC_ICON)
--General Grashaal
mod:AddTimerLine(DBM:EJ_GetSectionInfo(22288))
local timerReverberatingLeapCD					= mod:NewAITimer(29.8, 334004, 183611, nil, nil, 3)--Short text "Leap"
local timerSeismicUpheavalCD					= mod:NewAITimer(28.3, 334498, nil, nil, nil, 3)--28.3-32
local timerStoneBreakersComboCD					= mod:NewAITimer(24.6, 339690, nil, nil, nil, 5, nil, nil, nil, 2, 3)--24.6-33.8
local timerStoneFistCD							= mod:NewAITimer(11.1, 342425, nil, "Tank", nil, 5, nil, DBM_CORE_L.TANK_ICON)
--Adds
local timerPunishingBlowCD						= mod:NewAITimer(24.6, 340043, nil, nil, nil, 5, nil, DBM_CORE_L.TANK_ICON)
local timerRavenousFeastCD						= mod:NewAITimer(24.6, 343273, nil, nil, nil, 3)
local timerShatteringBlast						= mod:NewCastTimer(5, 332683, nil, nil, nil, 2)

--local berserkTimer							= mod:NewBerserkTimer(600)

--mod:AddRangeFrameOption(10, 310277)
mod:AddInfoFrameOption(333913, true)
mod:AddSetIconOption("SetIconOnWickedBlade", 333387, true, false, {1, 2})--off by default since it relies on 100% boss mod raid
mod:AddSetIconOption("SetIconOnCrystalize", 339690, true, false, {3})
mod:AddSetIconOption("SetIconOnMeteor", 342544, true, false, {3})
mod:AddSetIconOption("SetIconOnHeartRend", 334765, false, false, {4, 5, 6, 7})
mod:AddSetIconOption("SetIconOnLeap", 334004, false, false, {8})
mod:AddNamePlateOption("NPAuraOnVolatileShell", 340037)

local playerName = UnitName("player")
local LacerationStacks = {}
mod.vb.HeartIcon = 4
mod.vb.wickedBladeIcon = 1
mod.vb.phase = 1

function mod:LeapTarget(targetname, uId)
	if not targetname then return end
	if self:AntiSpam(4, targetname.."2") then
		if targetname == playerName then
			specWarnReverberatingLeap:Show()
			specWarnReverberatingLeap:Play("runout")
			yellReverberatingLeap:Yell()
			yellReverberatingLeapFades:Countdown(3.97)--This scan method doesn't support scanningTime, but should be about right
		else
			warnReverberatingLeap:Show(targetname)
		end
		if self.Options.SetIconOnLeap then
			self:SetIcon(targetname, 8, 5)--So icon clears 1 second after blast
		end
	end
end

function mod:MeteorTarget(targetname, uId)
	if not targetname then return end
	if targetname == playerName then
		specWarnMeteor:Show()
		specWarnMeteor:Play("runout")
		yellMeteor:Yell()
	else
		warnPulverizingMeteor:Show(targetname)
	end
	if self.Options.SetIconOnMeteor then
		self:SetIcon(targetname, 3, 3)--So icon clears 1 second after
	end
end

function mod:OnCombatStart(delay)
	table.wipe(LacerationStacks)
	self.vb.HeartIcon = 4
	self.vb.wickedBladeIcon = 1
	self.vb.phase = 1
	--General Kaal
	timerSerratedSwipeCD:Start(1-delay)--START, but next timer is started at SUCCESS
	timerWickedBladeCD:Start(1-delay)
	timerHeartRendCD:Start(1-delay)--SUCCESS
	if self:IsMythic() then
		timerCallShadowForcesCD:Start(1-delay)
	end
	--General Grashaal Air ability
	timerStoneBreakersComboCD:Start(1-delay)
	if self.Options.NPAuraOnVolatileShell then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Show(4)--For Acid Splash
--	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(DBM:GetSpellInfo(333913))
		DBM.InfoFrame:Show(10, "table", LacerationStacks, 1)
	end
--	berserkTimer:Start(-delay)--Confirmed normal and heroic
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
--	if self.Options.RangeFrame then
--		DBM.RangeCheck:Hide()
--	end
	if self.Options.NPAuraOnVolatileShell then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 333387 then
		self.vb.wickedBladeIcon = 1
		timerWickedBladeCD:Start()
	elseif spellId == 334765 then
		self.vb.HeartIcon = 4
	elseif spellId == 334929 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnSerratedSwipe:Show()
			specWarnSerratedSwipe:Play("defensive")
		end
	elseif spellId == 339164 or spellId == 334009 then--LFR/Normal, Heroic/Mythic
		timerReverberatingLeapCD:Start()
		--self:BossTargetScanner(args.sourceGUID, "LeapTarget", 0.01, 12)
	elseif spellId == 334498 then
		specWarnSeismicUpheaval:Show()
		specWarnSeismicUpheaval:Play("watchstep")
		timerSeismicUpheavalCD:Start()
	elseif spellId == 342544 then
		--warnPulverizingMeteor:Show()
		self:BossTargetScanner(args.sourceGUID, "MeteorTarget", 0.05, 12)
	elseif spellId == 342256 then
		warnCallShadowForces:Show()
		timerCallShadowForcesCD:Start()
	elseif spellId == 340043 then
		timerPunishingBlowCD:Start(10, args.sourceGUID)
	elseif spellId == 342722 then
		warnStonewrathExhaust:Show()
	elseif spellId == 332683 then
		specWarnShatteringBlast:Show()
		specWarnShatteringBlast:Play("carefly")
		timerShatteringBlast:Start()
	elseif spellId == 342425 then
		timerStoneFistCD:Start()
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnStoneFist:Show()
			specWarnStoneFist:Play("defensive")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 334765 then
		timerHeartRendCD:Start()
	elseif spellId == 334929 then--Boss stutter casts this often
		timerSerratedSwipeCD:Start()
	elseif spellId == 339690 then
		timerStoneBreakersComboCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 329636 then--50% transition for Kaal
		warnHardenedStoneForm:Show(args.destName)
		--General Kaal
--		timerWickedBladeCD:Stop()
--		timerHeartRendCD:Stop()
--		timerSerratedSwipeCD:Stop()
--		timerCallShadowForcesCD:Stop()
		--Ability Grashaal still uses when in air
		timerStoneBreakersComboCD:Stop()
	elseif spellId == 329808 then--50% transition for Grashaal
		warnHardenedStoneForm:Show(args.destName)
		--General Grashaal
--		timerReverberatingLeapCD:Stop()
--		timerSeismicUpheavalCD:Stop()
--		timerStoneBreakersComboCD:Stop()
--		timerStoneFistCD:Stop()
	elseif spellId == 333913 then
		local amount = args.amount or 1
		LacerationStacks[args.destName] = amount
		if self.Options.InfoFrame then
			DBM.InfoFrame:UpdateTable(LacerationStacks)
		end
	elseif spellId == 334765 then
		if args:IsPlayer() then
			specWarnHeartRend:Show()
			specWarnHeartRend:Play("targetyou")
		end
		if self.Options.SetIconOnHeartRend then
			self:SetIcon(args.destName, self.vb.HeartIcon)
		end
		self.vb.HeartIcon = self.vb.HeartIcon + 1
	elseif spellId == 333377 and self:AntiSpam(4, args.destName .. "1") then
		warnWickedBlade:CombinedShow(0.3, args.destName)
		local icon = self.vb.wickedBladeIcon
		if args:IsPlayer() then
			specWarnWickedBlade:Show(self:IconNumToTexture(icon))
			specWarnWickedBlade:Play("mm"..icon)
			yellWickedBlade:Yell(icon, icon, icon)
			yellWickedBladeFades:Countdown(4, nil, icon)
		end
		if self.Options.SetIconOnWickedBlade then
			self:SetIcon(args.destName, icon, 5)
		end
		self.vb.wickedBladeIcon = self.vb.wickedBladeIcon + 1
	elseif spellId == 339690 then
		if args:IsPlayer() then
			specWarnCrystalize:Show()
			specWarnCrystalize:Play("targetyou")
			yellCrystalize:Yell()
			yellCrystalizeFades:Countdown(spellId)
		else
			warnCrystalize:Show(args.destName)
		end
		if self.Options.SetIconOnCrystalize then
			self:SetIcon(args.destName, 3)
		end
	elseif spellId == 342655 then
		warnVolatileAnimaInfusion:Show(args.destName)
	elseif spellId == 340037 then
		if self:AntiSpam(5, 1) then
			specWarnVolatileStoneShell:Show()
			specWarnVolatileStoneShell:Play("targetchange")
		end
--		if self.Options.InfoFrame then--Will only work if it has a valid boss unit ID, so hold off for now
--			DBM.InfoFrame:SetHeader(args.spellName)
--			DBM.InfoFrame:Show(2, "enemyabsorb", nil, args.amount, "boss1")
--		end
		if self.Options.NPAuraOnVolatileShell then
			DBM.Nameplate:Show(true, args.destGUID, spellId, nil, 6)
		end
	elseif spellId == 343273 then
		if self:AntiSpam(3, 2) then
			timerRavenousFeastCD:Start()
		end
		warnRavenousFeast:CombinedShow(0.3, args.destName)--Combined in case it'll clobber everyone near them too
	elseif spellId == 342425 and not args:IsPlayer() and not DBM:UnitDebuff("player", spellId) then
		specWarnStoneFistTaunt:Show(args.destName)
		specWarnStoneFistTaunt:Play("tauntboss")
	elseif spellId == 336212 then
		warnSoldiersOath:Show(args.destName)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 329636 then--phase 2 (Kael Departing, Grashaal landing)
		self.vb.phase = 2
		warnHardenedStoneFormOver:Show()
		--Stop Kael's timers for ground phase
		timerWickedBladeCD:Stop()
		timerHeartRendCD:Stop()
		timerSerratedSwipeCD:Stop()
		timerCallShadowForcesCD:Stop()
		--General Kael (stuff he still casts airborn)
		timerWickedBladeCD:Start(2)
		if self:IsMythic() then
			timerCallShadowForcesCD:Start(2)
		end
		--General Grashaal
		timerReverberatingLeapCD:Start(2)
		timerStoneBreakersComboCD:Start(2)
		timerSeismicUpheavalCD:Start(2)
		timerStoneFistCD:Start(2)
	elseif spellId == 329808 then--Phase 3 (Both Generals at once)
		self.vb.phase = 3
		warnHardenedStoneFormOver:Show()
		--Stop/reset Grashaal timers
		timerReverberatingLeapCD:Stop()
		timerSeismicUpheavalCD:Stop()
		timerStoneBreakersComboCD:Stop()
		timerStoneFistCD:Stop()
		--General Kaal
		timerSerratedSwipeCD:Start(3)--START, but next timer is started at SUCCESS
		timerWickedBladeCD:Start(3)
		timerHeartRendCD:Start(3)--SUCCESS
		if self:IsMythic() then
			timerCallShadowForcesCD:Start(3)
		end
		--General Grashaal
		timerReverberatingLeapCD:Start(3)
		timerStoneBreakersComboCD:Start(3)
		timerSeismicUpheavalCD:Start(3)
		timerStoneFistCD:Start(3)
	elseif spellId == 333913 then
		LacerationStacks[args.destName] = nil
		if self.Options.InfoFrame then
			DBM.InfoFrame:UpdateTable(LacerationStacks)
		end
	elseif spellId == 334765 then
		if self.Options.SetIconOnHeartRend then
			self:SetIcon(args.destName, 0)
		end
	elseif spellId == 339690 then
		if args:IsPlayer() then
			yellCrystalizeFades:Cancel()
		end
		if self.Options.SetIconOnCrystalize then
			self:SetIcon(args.destName, 0)
		end
	elseif spellId == 340037 then
--		if self.Options.InfoFrame then
--			DBM.InfoFrame:SetHeader(DBM:GetSpellInfo(333913))
--			DBM.InfoFrame:Show(10, "table", LacerationStacks, 1)
--		end
		if self.Options.NPAuraOnVolatileShell then
			DBM.Nameplate:Hide(true, args.destGUID, spellId)
		end
	end
end

function mod:SPELL_AURA_REMOVED_DOSE(args)
	local spellId = args.spellId
	if spellId == 333913 then
		LacerationStacks[args.destName] = args.amount or 1
		if self.Options.InfoFrame then
			DBM.InfoFrame:UpdateTable(LacerationStacks)
		end
	end
end

function mod:RAID_BOSS_WHISPER(msg)
	if msg:find("334094") and self:AntiSpam(4, playerName.."2") then--Leap Backup (if scan fails)
		specWarnReverberatingLeap:Show()
		specWarnReverberatingLeap:Play("runout")
		yellReverberatingLeap:Yell()
		yellReverberatingLeapFades:Countdown(3.5)--A good 0.5 sec slower
		if self.Options.SetIconOnLeap then
			self:SetIcon(playerName, 8, 4.5)--So icon clears 1 second after
		end
	end
end

function mod:OnTranscriptorSync(msg, targetName)
	if msg:find("334094") and targetName then--Leap Backup (if scan fails)
		targetName = Ambiguate(targetName, "none")
		if self:AntiSpam(4, targetName.."2") then--Same antispam as RAID_BOSS_WHISPER on purpose. if player got personal warning they don't need this one
			warnReverberatingLeap:Show(targetName)
			if self.Options.SetIconOnLeap then
				self:SetIcon(targetName, 8, 4.5)--So icon clears 1 second after
			end
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 172858 then--stone-legion-goliath
		timerRavenousFeastCD:Stop()
	elseif cid == 173276 then--Stone Legion Commando
		timerPunishingBlowCD:Stop(args.destGUID)
--	elseif cid == 173280 then--stone-legion-skirmisher

	elseif cid == 168112 then--Kaal
		timerWickedBladeCD:Stop()
		timerHeartRendCD:Stop()
		timerSerratedSwipeCD:Stop()
		timerCallShadowForcesCD:Stop()
	elseif cid == 168113 then--Grashaal
		timerReverberatingLeapCD:Stop()
		timerSeismicUpheavalCD:Stop()
		timerStoneBreakersComboCD:Stop()
		timerStoneFistCD:Stop()
	end
end

--[[
function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if spellId == 270290 and destGUID == UnitGUID("player") and self:AntiSpam(2, 2) then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
--]]

--"<60.93 16:11:09> [UNIT_SPELLCAST_SUCCEEDED] Stone Legion Goliath(??) -Anchor Here- [[boss3:Cast-3-2084-2296-21431-45313-0013A47ADB:45313]]", -- [3631]
function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, spellId)
	if spellId == 45313 then--Anchor Here
		--Start Goliath timers here
		if self:IsHard() then
			timerRavenousFeastCD:Start(1)
		end
	end
end

--"<10.92 16:10:19> [UNIT_SPELLCAST_START] General Grashaal(Lightea) - Reverberating Leap - 5.2s [[boss2:Cast-3-2084-2296-21431-334009-0026A47AA9:334009]]", -- [614]
--"<10.92 16:10:19> [CLEU] SPELL_CAST_START#Creature-0-2084-2296-21431-168113-0000247A6F#General Grashaal##nil#334009#Reverberating Leap#nil#nil", -- [616]
--"<10.94 16:10:19> [DBM_Debug] boss2 changed targets to Kngflyven#nil", -- [618]
--"<11.38 16:10:19> [CHAT_MSG_ADDON] RAID_BOSS_WHISPER_SYNC#|TInterface\\Icons\\INV_ElementalEarth2.blp:20|t%s targets you with |cFFFF0000|Hspell:334094|h[Reverberating Leap]|h|r!#Kngflyven-TheMaw", -- [661]
function mod:UNIT_SPELLCAST_START(uId, _, spellId)
	if spellId == 339164 or spellId == 334009 then
		self:BossUnitTargetScanner(uId, "LeapTarget", 1)
	end
end
