A working MIDI piano that's a Figura player head!
# Basic Usage
You can spawn it in the world with this command. Simply copy and paste it and run it in game:

**1.20:** `/give @p minecraft:player_head{SkullOwner:{Id:[I;-1808656131,1539063829,-1082155612,-209998759]}}`

**1.21+:** `/give @p minecraft:player_head[minecraft:profile={id:[I;-1808656131,1539063829,-1082155612,-209998759],name:"Piano"}]`

Before you can use the piano, you will need to set the `midi player cloud` avatar to MAX perms. To do so:

1. Load your avatar with the midi player set up
2. Go to the Figura `Permissions` screen
3. Click `Show disconnected avatars` on the top right of the permissions window
4. Scroll down (not search!) until you find `Midi Player Cloud`, and change its permissions to `MAX`

Once in the world, simply punch the notes, or right-click them with a shield to play. Crouch to sustain pressed keys.

Additionally, the piano has model variants that can be accessed by placing a block 2 blocks below the piano. These modes include:
- `Default Piano`:  Any Block (apart from the below)
- `Fancy Piano`: Gold Block
- `Electric Keyboard`: Iron Block
- `Drum Kit`: Lapis Block

# Advanced Usage (MIDI Instrument Support)
## Sign Data Input
By placing a sign 2 blocks below instead, you can customise the piano further by writing on the front of the sign on lines 1 - 3. You can leave any of these lines blank.
### Piano Model
The first line of the sign should contain which model the piano will use. This is stored as a number from 1 - 4, where:
- `1` is `Default Piano`
- `2` is `Fancy Piano`
- `3` is `Electric Keyboard`
- `4` is `Drum Kit`
This can be left empty, and model 1 will be used
### Default Instrument
The second line of the sign should contain the default instrument the piano will use. This is stored as a number from 0 to 128. These are the instruments:

| PC# | Instrument                        | PC#  | Instrument                |
| --- | --------------------------------- | ---- | ------------------------- |
| 0.  | Acoustic Grand Piano              | 64.  | Soprano Sax               |
| 1.  | Bright Acoustic Piano             | 65.  | Alto Sax                  |
| 2.  | Electric Grand Piano              | 66.  | Tenor Sax                 |
| 3.  | Honky-tonk Piano                  | 67.  | Baritone Sax              |
| 4.  | Electric Piano 1 (Rhodes Piano)   | 68.  | Oboe                      |
| 5.  | Electric Piano 2 (Chorused Piano) | 69.  | English Horn              |
| 6.  | Harpsichord                       | 70.  | Bassoon                   |
| 7.  | Clavinet                          | 71.  | Clarinet                  |
| 8.  | Celesta                           | 72.  | Piccolo                   |
| 9.  | Glockenspiel                      | 73.  | Flute                     |
| 10. | Music Box                         | 74.  | Recorder                  |
| 11. | Vibraphone                        | 75.  | Pan Flute                 |
| 12. | Marimba                           | 76.  | Blown Bottle              |
| 13. | Xylophone                         | 77.  | Shakuhachi                |
| 14. | Tubular Bells                     | 78.  | Whistle                   |
| 15. | Dulcimer (Santur)                 | 79.  | Ocarina                   |
| 16. | Drawbar Organ (Hammond)           | 80.  | Lead 1 (square wave)      |
| 17. | Percussive Organ                  | 81.  | Lead 2 (sawtooth wave)    |
| 18. | Rock Organ                        | 82.  | Lead 3 (calliope)         |
| 19. | Church Organ                      | 83.  | Lead 4 (chiffer)          |
| 20. | Reed Organ                        | 84.  | Lead 5 (charang)          |
| 21. | Accordion (French)                | 85.  | Lead 6 (voice solo)       |
| 22. | Harmonica                         | 86.  | Lead 7 (fifths)           |
| 23. | Tango Accordion (Band neon)       | 87.  | Lead 8 (bass + lead)      |
| 24. | Acoustic Guitar (nylon)           | 88.  | Pad 1 (new age Fantasia)  |
| 25. | Acoustic Guitar (steel)           | 89.  | Pad 2 (warm)              |
| 26. | Electric Guitar (jazz)            | 90.  | Pad 3 (polysynth)         |
| 27. | Electric Guitar (clean)           | 91.  | Pad 4 (choir space voice) |
| 28. | Electric Guitar (muted)           | 92.  | Pad 5 (bowed glass)       |
| 29. | Overdriven Guitar                 | 93.  | Pad 6 (metallic pro)      |
| 30. | Distortion Guitar                 | 94.  | Pad 7 (halo)              |
| 31. | Guitar harmonics                  | 95.  | Pad 8 (sweep)             |
| 32. | Acoustic Bass                     | 96.  | FX 1 (rain)               |
| 33. | Electric Bass (fingered)          | 97.  | FX 2 (soundtrack)         |
| 34. | Electric Bass (picked)            | 98.  | FX 3 (crystal)            |
| 35. | Fretless Bass                     | 99.  | FX 4 (atmosphere)         |
| 36. | Slap Bass 1                       | 100. | FX 5 (brightness)         |
| 37. | Slap Bass 2                       | 101. | FX 6 (goblins)            |
| 38. | Synth Bass 1                      | 102. | FX 7 (echoes, drops)      |
| 39. | Synth Bass 2                      | 103. | FX 8 (sci-fi, star theme) |
| 40. | Violin                            | 104. | Sitar                     |
| 41. | Viola                             | 105. | Banjo                     |
| 42. | Cello                             | 106. | Shamisen                  |
| 43. | Contrabass                        | 107. | Koto                      |
| 44. | Tremolo Strings                   | 108. | Kalimba                   |
| 45. | Pizzicato Strings                 | 109. | Bag pipe                  |
| 46. | Orchestral Harp                   | 110. | Fiddle                    |
| 47. | Timpani                           | 111. | Shanai                    |
| 48. | String Ensemble 1 (strings)       | 112. | Tinkle Bell               |
| 49. | String Ensemble 2 (slow strings)  | 113. | Agogo                     |
| 50. | SynthStrings 1                    | 114. | Steel Drums               |
| 51. | SynthStrings 2                    | 115. | Woodblock                 |
| 52. | Choir Aahs                        | 116. | Taiko Drum                |
| 53. | Voice Oohs                        | 117. | Melodic Tom               |
| 54. | Synth Voice                       | 118. | Synth Drum                |
| 55. | Orchestra Hit                     | 119. | Reverse Cymbal            |
| 56. | Trumpet                           | 120. | Guitar Fret Noise         |
| 57. | Trombone                          | 121. | Breath Noise              |
| 58. | Tuba                              | 122. | Seashore                  |
| 59. | Muted Trumpet                     | 123. | Bird Tweet                |
| 60. | French Horn                       | 124. | Telephone Ring            |
| 61. | Brass Section                     | 125. | Helicopter                |
| 62. | SynthBrass 1                      | 126. | Applause                  |
| 63. | SynthBrass 2                      | 127. | Gunshot                   |
|     |                                   | 128. | Percussion                |
This can be left empty, and instrument 0 will be used
### Tuner Box Position
The third line of the sign should contain the position of the piano's tuner box. This is stored as 3 numbers separated by commas. For example: `-128,64,200`. This is the coordinates of the tuner box block in the world. If left empty, the piano will have no tuner box.
## Tuner Box
The tuner box is a block in the world that lets you configure the piano's instrument in real time. The tuner box firsts needs its position to be configured in sign data. Next, place a note block at that position. Finally, place an item frame on that note block and an item inside it. You should now have a tuner box. By cycling the item frame's item, you cycle the instrument category. By cycling the note block, it cycles the instruments inside that category. These are the instrument categories:

| PC#       | Category                            |
|-----------|-------------------------------------|
| 0 - 23    | Piano, Chromatic Percussion & Organ |
| 24 - 47   | Guitar, Bass & Strings              |
| 48 - 71   | Ensemble, Brass & Reed              |
| 72 - 95   | Pipe, Synth Lead & Synth Pad        |
| 96 - 119  | Synth Effects, Ethnic, Percussive   |
| 120 - 128 | Sound Effects, Percussion           |
| 128       | Percussion Only                     |
| 128       | Percussion Only                     |
# Piano API
The piano API opens up extra functionality, like triggering notes and setting the instrument through your script. If you ping this, everyone will be able to hear your note play. This can be used to automate playing songs, or use custom inputs like with your keyboard (or a midi keyboard). You'll need to script this yourself though. To access the piano library, first create a variable based on the avatar variable.
```lua
pianoLib  =  world.avatarVars()["943218fd-5bbc-4015-bf7f-9da4f37bac59"]
```
(note, if you're using a 'ChloeSpacedIn' piano, instead use the UUID `b0e11a12-eada-4f28-bb70-eb8903219fe5`)
Once this is created, you'll be able to access the following functions:

## playMidiNote()
`<pianoLib>.playMidiNote(String pianoID, Number pitch, Number volume, String type, Entity playerEntity, Vec3 notePos) → Returns nil`

Plays a midi note through the piano where:
- `pianoID` is a string containing the ID of the selected piano. E.g. `"{1, 65, -102}"`. The ID is determined by the player head coordinates. To easily grab the ID, run `tostring(pos)` where `pos` is a vec3 of the selected piano head position
- `pitch` is the pitch of the note between 0 and 127
- `volume` is the volume where 1 is the default
- `type` is the mode of the note press with values:
	- `PRESS`: the key is pressed and will be released after 300ms automatically. If you leave `type` empty `PRESS` is used
	- `SPAM_HOLD`: the key is pressed and released the next tick, unless the press event has been triggered again, in which case it will be held. This means by spamming this event, your note will be held
	- `MANUAL_RELEASE`: the key is pressed and held forever. It will only be released with `releaseMidiNote()`
- `playerEntity` is the player who pressed the keys. This is used for checking if the player is crouching, and by including it sustain will function. It is optional.
- `notePos` is the world position the note will play at. If left empty it will play at the piano position.
```lua
pianoLib.playMidiNote(tostring(pianoPosVec),60,1,"PRESS")
```
## releaseMidiNote()
`<pianoLib>.releaseMidiNote(String pianoID, Number pitch) → Returns nil`

Releases a played note.
```lua
pianoLib.releaseMidiNote(tostring(pianoPosVec),60)
```
## setInstrumentOverride()
`<pianoLib>.setInstrumentOverride(String pianoID, Number instrumentID) → Returns nil`

Overrides the piano's instrument to the provided instrument.
```lua
pianoLib.setInstrumentOverride(tostring(pianoPosVec),128)
```
## getInstrumentOverride()
`<pianoLib>.getInstrumentOverride(String pianoID) → Returns Number`

Gets the piano instrument override.
```lua
local instrumentOverride = pianoLib.getInstrumentOverride(tostring(pianoPosVec))
```
## getPiano()
`<pianoLib>.getPiano(String pianoID) → Returns Piano`

Gets the piano object of the given piano
```lua
local piano = pianoLib.getPiano(tostring(pianoPosVec))
```
## getItem()
`<pianoLib>.getItem(Table data) → Returns ItemStack`

Gets an itemstack of a head with piano "sign data" stored inside it. This allows you to set a piano's model, default instrument and tuner box position directly inside a head, no sign required. `data` is a table that contains this information. This table should the following:
- `model` contains as a number with the default model from 1 - 4.
- `defaultInstrument` contains a number with the default instrument from 0 - 128
- `tunerBoxPos` contains a table with the position of the tuner box. This must not be a vector.
Just like the sign data, any of these table entries are optional. With this data, you can use `host:setSlot()` to add this item to your inventory if you are in creative. For example:
```lua
local dataTable = {
	model = 3,
	defaultInstrument = 128,
	tunerBoxPos = {-128,64,200}
}
local pianoItem = pianoLib.getItem(dataTable)
host:setSlot(0,pianoItem)
```
# Legacy Piano API
These are functions from the original piano 1.0 avatar that are included for backwards compatibility. It is not recommended you use these functions
## validPos()
`<pianoLib>.validPos(String pianoID) → Returns Bool`

Gets the if the piano exists. You can instead use `getPiano()`
```lua
local isValidPos = pianoLib.validPos(tostring(pianoPosVec))
```
## getPlayingKeys()
`<pianoLib>.getPlayingKeys(String pianoID) → Returns Table`

Returns the table of all currently playing keys. You can instead use `getPiano()`
```lua
local playingKeys = pianoLib.getPlayingKeys(tostring(pianoPosVec))
```
## playNote()
`<pianoLib>.getPlayingKeys(String pianoID String keyID, Bool doesPlaySound, Vec3 notePos, Number noteVolume)) → Returns nil`

The `playNote()` function just plays a note on the piano when run. It contains the following:
- `pianoID` is a string containing the ID of the selected piano. E.g. `"{1, 65, -102}"`. The ID is determined by the player head coordinates. To easily grab the ID, run `tostring(pos)` where `pos` is a vec3 of the selected piano head position
- `keyID` is a string containing the ID of the note that should play. E.g. `"C2"`,`"F#3"`,`"A0"` This is just standard notation formatting of note as a letter, followed by octave as a number
- `doesPlaySound` is a boolean which determines if a sound will play when the note is pressed. This exists to make the implementation for holding notes simple. Just keep this as `true`
- `notePos` is a vec3 containing the world coordinates the note should play at. If left empty, it will just play at. You can simply ignore this and it will play at the player head coordinates. This is rarely useful, but if you want you can use the piano as a piano sample library (assuming you have it loaded), and play piano sounds anywhere in the world
  - `noteVolume` is a number containing the volume of the played note, where 1 is the default. You can ignore this and it will be the default value.
You can instead use `playMidiNote()`
```lua
pianoLib.playNote(tostring(pianoPosVec),"F#3",true,vec(-128,64,200),1)
```
# Additional Notes
By storing `eyePos` as a vector 3 inside your avatar variables, the piano will adjust they eye raycast to match your new eye height. This means you can re-align your key presses if your avatar changes the eye height from the vanilla value
# Credits
- Piano Model by TechnoCatza
- Default texture by PierraNova
- Fancy texture by Toast
- Drum Kit model & texture by Gloomsys
