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
    self.drumAnimations = {}
    self.lastWorldTime = world.getTime()
    self.lastInstrument = 0
    self.model = 1
    self.shouldRenderTunerBox = false
    self.tunerBoxText = ""
    self.tunerBoxRot = nil
    self.tunerBoxPos = nil
    self.instrumentOverride = nil
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

local drumIndex = {
    bassDrum = 35,
    snareCrossStick = 37,
    snareDrum = 38,
    floorTom = 41,
    lowTom = 45,
    highTom = 47,
    rideCymbal = 51,
    crashCymbal = 49,
    hiHatsOpen = 46,
    hiHatsClosed = 42,
    hiHatsPedal = 44
}

local function getDrumOOBs(skullPos,skullRot)
    skullRot = skullRot + 180
    local oobs = {
        bassDrum = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(-6/16,0/16,-8/16),vec(6/16,12/16,7/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        },
        snareCrossStick = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(-21/16,16/16,11/16),vec(-11/16,19/16,21/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        },
        snareDrum = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(-21/16,19/16,11/16),vec(-11/16,20/16,21/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        },
        floorTom = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(10/16,11/16,6/16),vec(20/16,16/16,16/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        },
        lowTom = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(1/16,16/16,-7/16),vec(12/16,23/16,2/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        },
        highTom = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(-11/16,16/16,-6/16),vec(-1/16,22/16,2/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        },
        rideCymbal = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(5/16,25/16,-15/16),vec(20/16,28/16,-2/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        },
        crashCymbal = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(-5/16,25/16,-15/16),vec(-20/16,28/16,-1/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        },
        hiHatsOpen = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(-13/16,20/16,-5/16),vec(-22/16,22/16,5/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        },
        hiHatsClosed = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(-13/16,14/16,-5/16),vec(-22/16,20/16,5/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        },
        hiHatsPedal = {
            position = skullPos + vec(0.5,0,0.5),
            corners = {vec(-13/16,0/16,-5/16),vec(-22/16,14/16,5/16)},
            rotation = matrices.mat3():rotateY(skullRot)
        }
    }
    return oobs
end

local function getSin(delta, min,max,period,phaseShift)
  return math.abs((min-max)/2) * math.sin((2*math.pi*(delta+phaseShift))/(period+(math.pi/2))) + ((min+max)/2)
end

local drumSet = models.Piano.SKULL.Piano.DrumSet
local drumAnims = {
    [35] = function(animFrame,pianoInstance)
        if animFrame < 4 then
            drumSet.BassDrum.KickPedal.Pedal:setRot(0)
            drumSet.BassDrum.KickPedal.Beater:setRot(getSin(animFrame,-45,0,4,0))
            drumSet.BassDrum.BDrum:setScale(getSin(animFrame,1,1.03,4,0))
        else
            pianoInstance.drumAnimations[35] = nil
        end
    end,
    [37] = function(animFrame,pianoInstance)
        if animFrame < 3 then
            local rot = getSin(animFrame,-0.5,0,1.5,0)
            drumSet.Snare:setRot(0,0,rot)
        else
            pianoInstance.drumAnimations[37] = nil
        end
    end,
    [38] = function(animFrame,pianoInstance)
        if animFrame < 4 then
            drumSet.Snare.SDrum:setScale(getSin(animFrame,1,1.03,4,0))
        else
            pianoInstance.drumAnimations[38] = nil
        end
    end,
    [41] = function(animFrame,pianoInstance)
        if animFrame < 4 then
            drumSet.FloorTom.FTDrum:setScale(getSin(animFrame,1,1.03,4,0))
        else
            pianoInstance.drumAnimations[41] = nil
        end
    end,
    [45] = function(animFrame,pianoInstance)
        if animFrame < 4 then
            drumSet.MediumTom.MDrum:setScale(getSin(animFrame,1,1.03,4,0))
        else
            pianoInstance.drumAnimations[45] = nil
        end
    end,
    [47] = function(animFrame,pianoInstance)
        if animFrame < 4 then
            drumSet.HiTom.HDrum:setScale(getSin(animFrame,1,1.03,4,0))
        else
            pianoInstance.drumAnimations[47] = nil
        end
    end,
    [51] = function(animFrame,pianoInstance)
        if animFrame < 40 then
            local mod = 1 - animFrame/40
            local rot = getSin(animFrame,-5,5,20,10)*mod
            drumSet.RideCymbal.RCStand.RCDrum:setRot(rot-35,0,rot/3)
        else
            pianoInstance.drumAnimations[51] = nil
        end
    end,
    [49] = function(animFrame,pianoInstance)
        if animFrame < 80 then
            local mod = 1 - animFrame/80
            local rot = getSin(animFrame,-10,10,20,10)*mod
            drumSet.CrashCymbal.CCStand.CCCymbal:setRot(rot-35,0,-rot/3)
        else
            pianoInstance.drumAnimations[49] = nil
        end
    end,
    [46] = function(animFrame,pianoInstance)
        if animFrame < 20 then
            local mod = 1 - animFrame/20
            local rot = getSin(animFrame,-2,2,10,5)*mod
            drumSet.HiHats.HHCymbal:setRot(rot,-45,-rot)
        else
            pianoInstance.drumAnimations[46] = nil
        end
    end,
    [42] = function(animFrame,pianoInstance)
        if animFrame < 15 then
            local mod = 1 - animFrame/15
            local rot = getSin(animFrame,-2,2,10,5)*mod
            drumSet.HiHats.HHCymbal:setRot(rot,-45,-rot)
            drumSet.HiHats.HHCymbal:setScale(1,0.5,1)
            drumSet.HiHats.Pedal2:setRot(0,45,0)
        else
            pianoInstance.drumAnimations[42] = nil
        end
    end,
    [44] = function(animFrame,pianoInstance)
        if animFrame < 4 then
            drumSet.HiHats.HHCymbal:setScale(1,0.5,1)
            drumSet.HiHats.Pedal2:setRot(0,45,0)
        else
            pianoInstance.drumAnimations[44] = nil
        end
    end
}

local drumResetVals = {
    [35] = function()
        drumSet.BassDrum.KickPedal.Pedal:setRot(-15)
        drumSet.BassDrum.KickPedal.Beater:setRot(-45)
        drumSet.BassDrum.BDrum:setScale(1)
    end,
    [37] = function()
        drumSet.Snare:setRot(0,0,0)
    end,
    [38] = function()
        drumSet.Snare.SDrum:setScale(1)
    end,
    [41] = function()
        drumSet.FloorTom.FTDrum:setScale(1)
    end,
    [45] = function()
        drumSet.MediumTom.MDrum:setScale(1)
    end,
    [47] = function()
        drumSet.HiTom.HDrum:setScale(1)
    end,
    [51] = function()
        drumSet.RideCymbal.RCStand.RCDrum:setRot(-35,0,0)
    end,
    [49] = function()
        drumSet.CrashCymbal.CCStand.CCCymbal:setRot(-35,0,0)
    end,
    [46] = function()
        drumSet.HiHats.HHCymbal:setRot(0,-45,0)
    end,
    [42] = function()
        drumSet.HiHats.HHCymbal:setRot(0,-45,0)
        drumSet.HiHats.HHCymbal:setScale(1,1,1)
        drumSet.HiHats.Pedal2:setRot(-15,45,0)
    end,
    [44] = function()
        drumSet.HiHats.HHCymbal:setScale(1,1,1)
        drumSet.HiHats.Pedal2:setRot(-15,45,0)
    end
}

local base64 = {}

local function validate(str)
    return #str % 4 == 0 and str:match("^[A-Za-z0-9+/]*=?=?$")
end

function base64.encode(text)
    if not text then return end
    local buffer = data:createBuffer()
    buffer:writeByteArray(text)
    buffer:setPosition(0)
    local output = buffer:readBase64()
    buffer:close()
    return output
end

function base64.decode(b)
    if not b then return end
    if not validate(b) then return end
    local buffer = data:createBuffer()
    buffer:writeBase64(b)
    buffer:setPosition(0)
    local output = buffer:readByteArray()
    buffer:close()
    return output
end

local function getItem(data)
    data = toJson(data)
    local item_str = ("player_head" .. toJson{
        SkullOwner = {
            Id = {
                client.uuidToIntArray(avatar:getUUID())
            },
            Properties = {
                textures = {
                    {
                        Value = base64.encode(data)
                    }
                }
            }
        }
    }):gsub('"Id":%[','"Id":[I;')

    return world.newItem(item_str)
end

local function getTextureValue(data)
    if not data then return end
    if data.SkullOwner then
        local properties = data.SkullOwner.Properties
        local textures = properties and properties.textures
        return textures[1].Value
    elseif data.profile or data["minecraft:profile"] then
        local properties = (data.profile or data["minecraft:profile"]).properties
        local textures = properties and properties[1]
        return textures[1].Value
    end
end

---Attempts to get a mode from the given texture data.
local function getData(head)
    local texture_value
    if type(head) == "ItemStack" then
        texture_value = getTextureValue(head:getTag(  ))
    elseif type(head) == "BlockState" then
        texture_value = getTextureValue(head:getEntityData())
    end
    if not texture_value then return end

    local decoded = base64.decode(texture_value)
    if not decoded then return end

    return decoded
end

local function playMidiNote(pianoID,pitch,volume,type,playerEntity,notePos)
    if not volume then volume = 1 end
    if not type then type = "PRESS" end
    local pianoInstance = pianos[pianoID]
    if not pianoInstance then return end
    local note = pianoInstance.playingKeys[pitch]
    local midiNote = pianoInstance.instance.tracks[1][pitch]
    local sysTime = client.getSystemTime()
    if note then
        if type == "SPAM_HOLD" then
            note.lastHeld = world.getTime()
            return
        end
    end
    pianoInstance.midi.note:play(pianoInstance.instance,pitch,100 * volume,1,1,sysTime,notePos)
    pianoInstance.playingKeys[pitch] = {
        type = type,
        player = playerEntity,
        lastHeld = world.getTime(),
        state = "PLAYING",
        initTime = sysTime
    }
    if pianoInstance.model == 4 then           
        pianoInstance.drumAnimations[pitch] = {
            initTime = sysTime
        }
    end
end

local function releaseMidiNote(pianoID,pitch)
    local pianoInstance = pianos[pianoID]
    if not pianoInstance then return end
    if not pianoInstance.instance.tracks[1][pitch] then return end
    pianoInstance.instance.tracks[1][pitch]:release(client.getSystemTime())
    pianoInstance.playingKeys[pitch] = nil
    if models.Piano.SKULL.Piano.Keys[pitch] then
        models.Piano.SKULL.Piano.Keys[pitch]:setRot(0,0,0)
    end
end

local function setInstrument(pianoID,ID)
    local pianoInstance = pianos[pianoID]
    if not pianoInstance then return end
    pianoInstance.instance.channels[1].instrument = ID
end

local function setInstrumentOverride(pianoID,ID)
    local pianoInstance = pianos[pianoID]
    if not pianoInstance then return end
    pianoInstance.instrumentOverride = ID
end

local function getInstrumentOverride(pianoID)
    local pianoInstance = pianos[pianoID]
    if not pianoInstance then return end
    return pianoInstance.instrumentOverride
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

local pianoType = {
    [1] = function(pianoInstance)
        models.Piano.SKULL.Piano.PianoBase:setVisible(true)
        models.Piano.SKULL.Piano.KeyboardBase:setVisible(false)
        models.Piano.SKULL.Piano.Keys:setVisible(true)
        models.Piano.SKULL.Piano.DrumSet:setVisible(false)
        models:setPrimaryTexture("CUSTOM",textures["PierraNovaPiano"])
        if pianoInstance and (not pianoInstance.instrumentOverride) then
            pianoInstance.instance.channels[1].instrument = 0
        end
    end,
    [2] = function(pianoInstance)
        models.Piano.SKULL.Piano.PianoBase:setVisible(true)
        models.Piano.SKULL.Piano.KeyboardBase:setVisible(false)
        models.Piano.SKULL.Piano.Keys:setVisible(true)
        models.Piano.SKULL.Piano.DrumSet:setVisible(false)
        models:setPrimaryTexture("CUSTOM",textures["ToastPiano"])
        if pianoInstance and (not pianoInstance.instrumentOverride) then
            pianoInstance.instance.channels[1].instrument = 0
        end
    end,
    [3] = function(pianoInstance)
        models.Piano.SKULL.Piano.PianoBase:setVisible(false)
        models.Piano.SKULL.Piano.KeyboardBase:setVisible(true)
        models.Piano.SKULL.Piano.Keys:setVisible(true)
        models.Piano.SKULL.Piano.DrumSet:setVisible(false)
        models:setPrimaryTexture("CUSTOM",textures["ChloeKeyboard"])
        if pianoInstance and (not pianoInstance.instrumentOverride) then
            pianoInstance.instance.channels[1].instrument = 0
        end
    end,
    [4] = function(pianoInstance)
        models.Piano.SKULL.Piano.PianoBase:setVisible(false)
        models.Piano.SKULL.Piano.KeyboardBase:setVisible(false)
        models.Piano.SKULL.Piano.Keys:setVisible(false)
        models.Piano.SKULL.Piano.DrumSet:setVisible(true)
        models:setPrimaryTexture("CUSTOM",textures["GloomsysDrumKit"])
        if pianoInstance and (not pianoInstance.instrumentOverride) then
            pianoInstance.instance.channels[1].instrument = 128
        end
    end
}

local function resetPiano(data)
    local pianoModel
    local rawData = getData(data)
    local headData
    if rawData then
        headData = parseJson(getData(data))
    end
    if headData then
        pianoModel = headData.model
    end
    if pianoModel then
        if pianoType[pianoModel] then
            pianoType[pianoModel]()
        end
    else
        pianoType[1]()
    end
    models.Piano.SKULL:setScale(0.3)
    tunerBoxText:setVisible(false)
end

function events.skull_render(delta,blockState,itemstack,entity,type)
    if not blockState then resetPiano(itemstack) return end
    local blockProperties = blockState:getProperties()
    if not blockProperties.rotation then resetPiano(blockState) return end
    resetPiano(blockState)
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
    tunerBoxRot:setRot(pianoInstance.tunerBoxRot)
    tunerBoxParent:setPos(pianoInstance.tunerBoxPos)
    local instrumentName = getInstrumentName(pianoInstance,pianoInstance.lastInstrument)
    keyboardScreen:setText([[{"text":"]] .. instrumentName .. [[","color":"#202020"}]])
    if pianoType[pianoInstance.model] then
        pianoType[pianoInstance.model](pianoInstance)
    end
    if pianoInstance.model == 4 then
        for _,piano in pairs(pianos) do
            for animaiton,_ in pairs(piano.drumAnimations) do
                if drumResetVals[animaiton] then
                    drumResetVals[animaiton]()
                end
            end
        end
        for animID,anim in pairs(pianoInstance.drumAnimations) do
            local animFrame = (client.getSystemTime() - anim.initTime) / 1000 * 20
            if drumAnims[animID] then
                drumAnims[animID](animFrame,pianoInstance,animID)
            end
        end
    else
        for keyID,key in pairs(pianoInstance.playingKeys) do
            if models.Piano.SKULL.Piano.Keys[keyID] and key.state ~= "RELEASED" then
                models.Piano.SKULL.Piano.Keys[keyID]:setRot(-4,0,0)
            end
        end
    end
    local worldTime = world.getTime()
    if worldTime == pianoInstance.lastWorldTime then return end
    
    --------- tick ----------
    pianoInstance.lastWorldTime  = worldTime
    if pianoInstance.instance.isRemoved then
        pianoInstance:remove()
        return
    end
    local pianoModel,defaultInstrument,tunerBoxPos
    local headData = parseJson(getData(blockState))


    if headData.model then
        pianoModel = headData.model
    end
    if headData.defaultInstrument then
        defaultInstrument = headData.defaultInstrument
    end
    if headData.tunerBoxPos then
        tunerBoxPos = vec(headData.tunerBoxPos[1],headData.tunerBoxPos[2],headData.tunerBoxPos[3])
    end

    local indicatorBlock = world.getBlockState(blockPos - vec(0,2,0))
    local hasSign = string.find(indicatorBlock.id,"sign")
    pianoInstance.shouldRenderTunerBox = false
    if pianoInstance.instrumentOverride then
        pianoInstance.instance.channels[1].instrument = pianoInstance.instrumentOverride
    else
        if not hasSign then
            pianoInstance.model = 1
            pianoInstance.instance.channels[1].instrument = 0
        end
    end
    local hasHeadData = pianoModel or defaultInstrument or tunerBoxPos
    if not hasHeadData then
        if indicatorBlock.id == "minecraft:gold_block" then
            pianoInstance.model = 2
        elseif indicatorBlock.id == "minecraft:iron_block" then
            pianoInstance.model = 3
        elseif indicatorBlock.id == "minecraft:lapis_block" then
            pianoInstance.model = 4
            if not pianoInstance.instrumentOverride then
                pianoInstance.instance.channels[1].instrument = 128
            end
        end
    end
    if hasSign and (not hasHeadData) then
        local signText = indicatorBlock:getEntityData().front_text.messages
        local tunerBoxString
        if client.compareVersions(client.getVersion(),"1.20.5") >= 0 then
            pianoModel = tonumber(string.sub(signText[1],2,-2))
            defaultInstrument = tonumber(string.sub(signText[2],2,-2))
            tunerBoxString = string.sub(signText[3],2,-2)
        else
            pianoModel = tonumber(string.sub(signText[1],10,-3))
            defaultInstrument = tonumber(string.sub(signText[2],10,-3))
            tunerBoxString = string.sub(signText[3],10,-3)
        end
        local val1,val2,val3 = tunerBoxString:match("([-%d]+),%s*([-%d]+),%s*([-%d]+)")
        val1 = tonumber(val1)
        val2 = tonumber(val2)
        val3 = tonumber(val3)
        if val1 and val2 and val3 then
            tunerBoxPos = vec(val1,val2,val3)
        end
        if pianoInstance.instrumentOverride then
            defaultInstrument = pianoInstance.instrumentOverride
        end
    end
    if pianoModel then
        pianoInstance.model = pianoModel
    end
    if tunerBoxPos then
        pianoInstance.shouldRenderTunerBox = true
        pianoInstance.tunerBoxRot = vec(0,blockProperties.rotation * 22.5,0)
        pianoInstance.tunerBoxPos = (tunerBoxPos - blockPos + vec(0,1.3,0)) * 16
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
                local intrumentID
                if pianoInstance.instrumentOverride then
                    intrumentID = pianoInstance.instrumentOverride
                else
                    intrumentID = math.clamp(itemFrameRot * 24 + math.clamp(note,0,23),0,128)
                end
                local groupIndex = math.floor(intrumentID/24)
                local instrumentGroup = itemFrameGroups[itemFrameRot]
                local lastInstrument = "§7" .. getInstrumentName(pianoInstance,intrumentID - 1)
                if math.floor((intrumentID - 1)/24) ~= groupIndex or itemFrameRot > 5 or pianoInstance.instrumentOverride then
                    lastInstrument = ""
                end
                local currentInstrument = getInstrumentName(pianoInstance,intrumentID)
                local nextInstrument = "§7" .. getInstrumentName(pianoInstance,intrumentID + 1)
                if math.floor((intrumentID + 1)/24) ~= groupIndex or itemFrameRot > 5 or pianoInstance.instrumentOverride then
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
                defaultInstrument = intrumentID
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
    if (not defaultInstrument) and pianoModel == 4 then
        defaultInstrument = 128
    end
    if pianoInstance.instrumentOverride then
        defaultInstrument = pianoInstance.instrumentOverride
    end
    if defaultInstrument then
        setInstrument(pianoInstance.ID,defaultInstrument)
        if pianoInstance.lastInstrument ~= defaultInstrument then
            playMidiNote(pianoInstance.ID,60,1,"PRESS")
        end
        pianoInstance.lastInstrument = pianoInstance.instance.channels[1].instrument
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
        local type
        if playerEntity:isUsingItem() then
            type = "SPAM_HOLD"
        else
            type = "PRESS"
        end
        if swinging or (type == "SPAM_HOLD") then
            local rotation = -blockProperties.rotation * 22.5
            local rayStart = playerEntity:getPos() + vec(0,playerEntity:getEyeHeight(),0) + eyeOffset
            local rayEnd = rayStart + playerEntity:getLookDir()*4
            if pianoInstance.model == 4 then
                local hits = obb:raycast(getDrumOOBs(blockPos,rotation), rayStart, rayEnd)
                local closestHit
                for ID,hit in pairs(hits) do
                    if not closestHit then
                        closestHit = ID
                    end
                    if hits[closestHit].distance > hit.distance then
                        closestHit = ID
                    end
                end
                if closestHit then
                    playMidiNote(pianoInstance.ID,drumIndex[closestHit],1,type,playerEntity)
                end
            else
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
                        playMidiNote(pianoInstance.ID,pitch,1,type,playerEntity)
                    end
                end
                if hits.whiteKeys and (not isBlackKeyHit) then
                   local key = -math.floor(hits.whiteKeys.orientedHitPos.x*16 - 21)
                   local pitch = key * 2 - (math.floor((key + 5) / 7) + math.floor((key + 2) / 7)) + 9 + 12
                   playMidiNote(pianoInstance.ID,pitch,1,type,playerEntity)
                end
            end
        end
    end
    for ID,note in pairs(pianoInstance.playingKeys) do
        local isCrouching
        if note.player then
            isCrouching = note.player:isCrouching()
        end
        if not isCrouching then
            if (note.type == "PRESS") and (note.state ~= "RELEASED") then
                if (sysTime - note.initTime) > 300 then
                    releaseMidiNote(pianoInstance.ID,ID)
                end
            elseif note.type == "SPAM_HOLD" and (note.state ~= "RELEASED") then
                if note.lastHeld ~= world.getTime() then
                    releaseMidiNote(pianoInstance.ID,ID)
                end
            end
            if not pianoInstance.instance.tracks[1][ID] then
                pianoInstance.playingKeys[ID] = nil
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
avatar:store("setInstrumentOverride",setInstrumentOverride)
avatar:store("getInstrumentOverride",getInstrumentOverride)
avatar:store("getPiano", function(pianoID) return pianos[pianoID] end)
avatar:store("validPos", function(pianoID) return pianos[pianoID] ~= nil end)
avatar:store("getPlayingKeys", function(pianoID) return pianos[pianoID] ~= nil and pianos[pianoID].playingKeys or nil end)
avatar:store("getItem",getItem)