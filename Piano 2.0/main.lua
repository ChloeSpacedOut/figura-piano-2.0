local midiPlayerCloudID = "b0e11a12-eada-4f28-bb70-eb8903219fe5"
local avatarID = {}
avatarID[1],avatarID[2],avatarID[3],avatarID[4] = client.uuidToIntArray(midiPlayerCloudID)
local midiPlayerHeadItem = world.newItem([=[minecraft:player_head{display:{Name:'{"text":"midiHead"}'},SkullOwner:{Id:[I;]=]..avatarID[1]..","..avatarID[2]..","..avatarID[3]..","..avatarID[4]..[=[]}}]=])
local midiPlayerHeadTask = models.Piano.SKULL:newItem("midiPlayerHead")
midiPlayerHeadTask:setItem(midiPlayerHeadItem)
    :setScale(0)

local tunerBoxRot = models.Piano.SKULL:newPart("tunerBoxText")
local tunerBoxParent = tunerBoxRot:newPart("tunerBoxText")
local tunerBox = tunerBoxParent:newPart("tunerBoxText","Camera")
local tunerBoxText = tunerBox:newText("tunerBoxText")
tunerBoxText:setText("test")
    :setAlignment("CENTER")
    :setScale(0.125)
    :setBackground(true)
    :setPos(0,3,0)
local permisisonWarning = models.Piano.SKULL:newText("permisisonWarning")
    :setText("§cSet 'Midi Player Cloud' in 'Disconnected Avatars' to MAX")
    :setAlignment("CENTER")
    :setScale(0.125)
    :setPos(0,20,-2)
    :setBackground(true)
    :setBackgroundColor(vec(0,0,0,1))
    :setVisible(false)
local keyboardScreen = models.Piano.SKULL.Piano.KeyboardBase:newText("keyboardScreen")
    :setPos(0,17,1.5)
    :setScale(0.125/2)
    :setRot(90)
    :setAlignment("CENTER")
    :setWrap(true)
    :setWidth(120)

local baseNotes = {
    [0] = "C",
    [1] = "C#",
    [2] = "D",
    [3] = "D#",
    [4] = "E",
    [5] = "F",
    [6] = "F#",
    [7] = "G",
    [8] = "G#",
    [9] = "A",
    [10] = "A#",
    [11] = "B",
}

local noteStringToNote = {}
for i = 21, 95 do
    noteStringToNote[baseNotes[i % 12] .. math.floor(i/12) - 1] = i
end

local midiAPI = world.avatarVars()[midiPlayerCloudID]
local obb = require("OBB_Raycast_API")

local pianos = {}
local piano = {}
piano.__index = piano

function piano:new(pos)
    self = setmetatable({},piano)
    self.ID = tostring(pos)
    self.instance = midiAPI.newInstance(tostring(pos),pos)
    self.midi = self.instance.midi
    self.playingKeys = {}
    self.lastWorldTime = world.getTime()
    self.lastInstrument = 0
    self.model = 1
    self.shouldRenderTunerBox = false
    self.tunerBoxText = ""
    self.instance.channels[1] = self.midi.channel:new(self.instance,1)
    self.instance.tracks[1] = {}
    self.instance:setVolume(0.5)
    self.instance:setShouldKillInstance(function(instance)
        local valString = string.sub(instance.ID,2,-2)
        local vals = {}
        for numString in valString:gmatch("[^,]+") do
            table.insert(vals, tonumber(numString))
        end
        local instancePos = vec(vals[1],vals[2],vals[3])
        if world.getBlockState(instancePos).id ~= "minecraft:player_head" then
            return true
        else
            return false
        end
    end)
    return self
end

function piano:remove()
    self.instance:remove()
    pianos[self.ID] = nil
end

local function getMainOOBs(skullPos,skullRot)
    local obbs = {
        blackKeys = {
          position = skullPos + vec(0.5,0,0.5),
          corners = {vec(-21.35/16,16/16,-5/16), vec(21.35/16,16.5/16,1/16)},
          rotation = matrices.mat3():rotateY(skullRot)
        },
        whiteKeys = {
          position = skullPos + vec(0.5,0,0.5),
          corners = {vec(-22/16,15/16,-7/16), vec(22/16,16/16,1/16)},
          rotation = matrices.mat3():rotateY(skullRot)
        }
}
    return obbs
end

local function getSubOOBs(skullPos,skullRot,targetKey)
    local oobs = {}
    local calculatedKeys = {}
    for key = targetKey - 2, targetKey + 2 do
        key = math.clamp(key,1,43)
        local keyID = key - (math.floor((key + 5) / 7) + math.floor((key + 2) / 7))
        calculatedKeys[keyID] = true
    end
    for keyID,v in pairs(calculatedKeys) do
        local keyPos = keyID + (math.floor((keyID + 3) / 5) + math.floor((keyID + 1) / 5)) - 1
        oobs[keyID] = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec((20.65 - keyPos)/16,16/16,-5/16), vec((21.35 - keyPos)/16,16.5/16,1/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        }
    end
    return oobs
end

local function playMidiNote(pianoID,pitch,volume,manualRelease,playerEntity,notePos)
    if not volume then volume = 1 end
    local pianoInstance = pianos[pianoID]
    if not pianoInstance then return end
    local note = pianoInstance.playingKeys[pitch]
    local midiNote = pianoInstance.instance.tracks[1][pitch]
    local sysTime = client.getSystemTime()
    if note then
        if manualRelease then
            note.lastHeld = world.getTime()
            return
        end
    end
    pianoInstance.midi.note:play(pianoInstance.instance,pitch,100 * volume,1,1,sysTime,notePos)
    pianoInstance.playingKeys[pitch] = {
        manualRelease = manualRelease,
        player = playerEntity,
        lastHeld = world.getTime(),
        state = "PLAYING",
        initTime = sysTime
    }
end

local function releaseMidiNote(pianoID,pitch)
    local pianoInstance = pianos[pianoID]
    if not pianoInstance then return end
    pianoInstance.instance.tracks[1][pitch]:release(client.getSystemTime())
    pianoInstance.playingKeys[pitch] = nil
    models.Piano.SKULL.Piano.Keys[pitch]:setRot(0,0,0)
end

local function setMidiInstrument(pianoID,ID)
    local pianoInstance = pianos[pianoID]
    if not pianoInstance then return end
    pianoInstance.instance.channels[1].instrument = ID
end

local function getMidiInstrument(pianoID)
    local pianoInstance = pianos[pianoID]
    if not pianoInstance then return end
    return pianoInstance.instance.channels[1].instrument
end

local itemFrameGroups = {
    [0] = "Piano, Chromatic Percussion & Organ",
    [1] = "Guitar, Bass & Strings",
    [2] = "Ensemble, Brass & Reed",
    [3] = "Pipe, Synth Lead & Synth Pad",
    [4] = "Synth Effects, Ethnic, Percussive",
    [5] = "Sound Effects, Percussion",
    [6] = "Percussion Only",
    [7] = "Percussion Only",
}

local function getInstrumentName(pianoInstance,ID)
    local instrumentName
    local instrument = pianoInstance.instance.soundfont.soundTree[ID + 1]
    if instrument then
        instrumentName = "[" .. ID .. "] " .. string.sub(instrument.template,14,-2)
    elseif pianoInstance.instance.soundfont.redundancyNames[tostring(ID + 1)] then
        instrumentName = "[" .. ID .. "] " .. pianoInstance.instance.soundfont.redundancyNames[tostring(ID + 1)]
    end
    if not instrumentName then
        instrumentName = ""
    end
    return instrumentName
end

function events.skull_render(delta,blockState,itemstack,entity,type)
    if not blockState then
        models.Piano.SKULL:setScale(0.3)
        tunerBoxText:setVisible(false)
        models.Piano.SKULL.Piano.PianoBase:setVisible(true)
        models.Piano.SKULL.Piano.KeyboardBase:setVisible(false)
        models:setPrimaryTexture("CUSTOM",textures["PierraNovaPiano"])
        return
    end
    local blockProperties = blockState:getProperties()
    if not blockProperties.rotation then return end
    models.Piano.SKULL:setScale(1)
    midiAPI = world.avatarVars()[midiPlayerCloudID]
    if (not midiAPI) or (not midiAPI.newInstance) then return end
    local blockPos = blockState:getPos()
    if not pianos[tostring(blockPos)] then
        pianos[tostring(blockPos)] = piano:new(blockPos)
    end
    local pianoInstance = pianos[tostring(blockPos)]
    if pianoInstance.instance:getPermissionLevel() ~= "MAX" then
        permisisonWarning:setVisible(true)
        return
    end
    for key,_ in pairs(pianoInstance.playingKeys) do
        if pianoInstance.instance.tracks[1][key] then
            pianoInstance.playingKeys[key].state = pianoInstance.instance.tracks[1][key].state
        else
            pianoInstance.playingKeys[key].state = "RELEASED"
        end
    end
    for _,piano in pairs(pianos) do
        for key,_ in pairs(piano.playingKeys) do
            if models.Piano.SKULL.Piano.Keys[key] then
                models.Piano.SKULL.Piano.Keys[key]:setRot(0,0,0)
            end
        end
    end
    permisisonWarning:setVisible(false)
    tunerBoxText:setVisible(pianoInstance.shouldRenderTunerBox)
        :setText(pianoInstance.tunerBoxText)
    local instrumentName = getInstrumentName(pianoInstance,pianoInstance.lastInstrument)
    keyboardScreen:setText([[{"text":"]] .. instrumentName .. [[","color":"#202020"}]])
    if pianoInstance.model == 1 then
        models.Piano.SKULL.Piano.PianoBase:setVisible(true)
        models.Piano.SKULL.Piano.KeyboardBase:setVisible(false)
        models:setPrimaryTexture("CUSTOM",textures["PierraNovaPiano"])
    elseif pianoInstance.model == 2 then
        models.Piano.SKULL.Piano.PianoBase:setVisible(true)
        models.Piano.SKULL.Piano.KeyboardBase:setVisible(false)
        models:setPrimaryTexture("CUSTOM",textures["ToastPiano"])
    elseif pianoInstance.model == 3 then
        models.Piano.SKULL.Piano.PianoBase:setVisible(false)
        models.Piano.SKULL.Piano.KeyboardBase:setVisible(true)
        models:setPrimaryTexture("CUSTOM",textures["ChloeKeyboard"])
    end
    for keyID,key in pairs(pianoInstance.playingKeys) do
        if models.Piano.SKULL.Piano.Keys[keyID] and key.state ~= "RELEASED" then
            models.Piano.SKULL.Piano.Keys[keyID]:setRot(-4,0,0)
        end
    end
    local worldTime = world.getTime()
    if worldTime == pianoInstance.lastWorldTime then return end
    pianoInstance.lastWorldTime  = worldTime
    if pianoInstance.instance.isRemoved then
        pianoInstance:remove()
        return
    end
    pianoInstance.model = 1
    local indicatorBlock = world.getBlockState(blockPos - vec(0,2,0))
    pianoInstance.shouldRenderTunerBox = false
    pianoInstance.lastInstrument = getMidiInstrument(pianoInstance.ID)
    if indicatorBlock.id == "minecraft:gold_block" then
        pianoInstance.model = 2
    elseif indicatorBlock.id == "minecraft:iron_block" then
        pianoInstance.model = 3
    elseif string.find(indicatorBlock.id,"sign") then
        local signText = indicatorBlock:getEntityData().front_text.messages
        local pianoModel, defaultInstrument, tunerBoxString
        if client.compareVersions(client.getVersion(),"1.20.5") >= 0 then
            pianoModel = tonumber(string.sub(signText[1],2,-2))
            defaultInstrument = tonumber(string.sub(signText[2],2,-2))
            tunerBoxString = string.sub(signText[3],2,-2)
        else
            pianoModel = tonumber(string.sub(signText[1],10,-3))
            defaultInstrument = tonumber(string.sub(signText[2],10,-3))
            tunerBoxString = string.sub(signText[3],10,-3)
        end
        local vals = {}
        for numString in tunerBoxString:gmatch("[^,]+") do
            table.insert(vals, tonumber(numString))
        end
        local tunerBoxPos
        if vals[1] and vals[2] and vals[3] then
            tunerBoxPos = vec(vals[1],vals[2],vals[3])
        end
        if pianoModel then
            pianoInstance.model = pianoModel
        end
        if defaultInstrument then
            setMidiInstrument(pianoInstance.ID,defaultInstrument)
        end
        if tunerBoxPos then
            pianoInstance.shouldRenderTunerBox = true
            tunerBoxRot:setRot(0,blockProperties.rotation * 22.5,0)
            tunerBoxParent:setPos((tunerBoxPos - blockPos + vec(0,1.3,0)) * 16)
            local noteBlock = world.getBlockState(tunerBoxPos)
            local note
            if noteBlock.id == "minecraft:note_block" then
                note = tonumber(noteBlock:getProperties().note)
            end
            local itemFrame
            local entities = world.getEntities(tunerBoxPos - vec(1,1,1),tunerBoxPos + vec(2,2,2))
            for _,foundEntity in pairs(entities) do
                local name = foundEntity:getName()
                if name == "Item Frame" or name == "Glow Item Frame" then
                    itemFrame = foundEntity
                end
            end
            if itemFrame then
                local itemFrameRot = itemFrame:getNbt().ItemRotation
                if itemFrameRot and note then
                    local intrumentID = math.clamp(itemFrameRot * 24 + math.clamp(note,0,23),0,128)
                    local groupIndex = math.floor(intrumentID/24)
                    local instrumentGroup = itemFrameGroups[itemFrameRot]
                    local lastInstrument = "§7" .. getInstrumentName(pianoInstance,intrumentID - 1)
                    if math.floor((intrumentID - 1)/24) ~= groupIndex or itemFrameRot > 5 then
                        lastInstrument = ""
                    end
                    local currentInstrument = getInstrumentName(pianoInstance,intrumentID)
                    local nextInstrument = "§7" .. getInstrumentName(pianoInstance,intrumentID + 1)
                    if math.floor((intrumentID + 1)/24) ~= groupIndex or itemFrameRot > 5  then
                        nextInstrument = ""
                    end
                    local hoverState = "NONE"
                    local client = client:getViewer()
                    if client:getTargetedBlock(true,5):getPos() == tunerBoxPos then
                        hoverState = "BLOCK"
                    end
                    local targetEntity = client:getTargetedEntity(5)
                    if targetEntity then
                        if targetEntity:getUUID() == itemFrame:getUUID() then
                            hoverState = "ENTITY"
                        end
                    end
                    if hoverState == "BLOCK" then
                        currentInstrument = "§f§n" .. currentInstrument
                    elseif hoverState == "ENTITY" then
                        instrumentGroup = "§f§n" .. instrumentGroup
                    end
                    pianoInstance.tunerBoxText = "§b" .. instrumentGroup .. "\n"  .. lastInstrument .. "\n§e" .. currentInstrument .. "\n" .. nextInstrument
                    setMidiInstrument(pianoInstance.ID,intrumentID)
                    if pianoInstance.lastInstrument ~= intrumentID then
                        playMidiNote(pianoInstance.ID,60,1,false)
                    end
                    pianoInstance.lastInstrument = intrumentID
                end
                if not itemFrameRot then
                    pianoInstance.tunerBoxText = "§cplace item in item frame"
                end 
            end
            if not itemFrame then
                pianoInstance.tunerBoxText = "§cplace item frame"
            end
            if not note then
                pianoInstance.tunerBoxText = "§cplace note block"
            end
        end
    end
    local sysTime = client:getSystemTime()
    for _,playerEntity in pairs(world:getPlayers()) do
        local avatarVars = world:avatarVars()[playerEntity:getUUID()]
        local eyeOffset
        if avatarVars then
            eyeOffset = avatarVars.eyePos
        end
        if not eyeOffset then eyeOffset = vec(0,0,0) end
        local swinging = playerEntity:getSwingTime() == 1
        local usingItem = playerEntity:isUsingItem()
        if swinging or usingItem then
            local rotation = -blockProperties.rotation * 22.5
            local rayStart = playerEntity:getPos() + vec(0,playerEntity:getEyeHeight(),0) + eyeOffset
            local rayEnd = rayStart + playerEntity:getLookDir()*4
            local hits = obb:raycast(getMainOOBs(blockPos,rotation), rayStart, rayEnd)
            local isBlackKeyHit = false
            if hits.blackKeys then
                local key = -math.floor(hits.blackKeys.orientedHitPos.x*16 - 21.5)
                local subHits = obb:raycast(getSubOOBs(blockPos,rotation,key), rayStart, rayEnd)
                local closestKey
                for ID,hit in pairs(subHits) do
                    if not closestKey then
                        closestKey = ID
                    end
                    if subHits[closestKey].distance > hit.distance then
                        closestKey = ID
                    end
                    isBlackKeyHit = true
                end
                if closestKey then
                    local pitch = closestKey*2 + (math.floor((closestKey + 3) / 5) + math.floor((closestKey + 1) / 5)) + 8 + 12
                    playMidiNote(pianoInstance.ID,pitch,1,usingItem,playerEntity)
                end
            end
            if hits.whiteKeys and (not isBlackKeyHit) then
               local key = -math.floor(hits.whiteKeys.orientedHitPos.x*16 - 21)
               local pitch = key * 2 - (math.floor((key + 5) / 7) + math.floor((key + 2) / 7)) + 9 + 12
               playMidiNote(pianoInstance.ID,pitch,1,usingItem,playerEntity)
            end
        end
    end
    for ID,note in pairs(pianoInstance.playingKeys) do
        local isCrouching
        if note.player then
            isCrouching = note.player:isCrouching()
        end
        if not isCrouching then
            if (not note.manualRelease) and (note.state ~= "RELEASED") then
                if (sysTime - note.initTime) > 300 then
                    releaseMidiNote(pianoInstance.ID,ID)
                end
            elseif note.manualRelease and (note.state ~= "RELEASED") then
                if note.lastHeld ~= world.getTime() then
                    releaseMidiNote(pianoInstance.ID,ID)
                end
            end
        end
    end
end

local function playNote(pianoID,keyID,doesPlaySound,notePos,noteVolume)
    if not noteVolume then noteVolume = 1 end
    if not doesPlaySound then noteVolume = 0 end
    playMidiNote(pianoID,noteStringToNote[keyID],noteVolume,false,nil,notePos)
end

avatar:store("playNote",playNote)
avatar:store("playMidiNote",playMidiNote)
avatar:store("releaseMidiNote",releaseMidiNote)
avatar:store("setMidiInstrument",setMidiInstrument)
avatar:store("getMidiInstrument",getMidiInstrument)
avatar:store("validPos", function(pianoID) return pianos[pianoID] ~= nil end)
avatar:store("getPlayingKeys", function(pianoID) return pianos[pianoID] ~= nil and pianos[pianoID].playingKeys or nil end)