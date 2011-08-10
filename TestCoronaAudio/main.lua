--[[
1. Does API internal state tests
 a. channels
 b. volume
2. Load tests
3. Seek tests
4. Plays Battle and Declaration at seeked positions (louder part of Battle, We hold these truths)
5. Plays note2 with callback
6. On callback, pauses Battle, fade-in Bouncing and play 2 times (loop=1), plays UFO infinite-looping
7. Bouncing callback: resume Battle, fade UFO to .5, play laser 3 times
8. Laser callback: fadeOut UFO in 2 secs
9. UFO callback: stop all and quit

TODO: 
a. Need to test free/in-use channels when actually playing.
b. Need to max out playing channels
c. Need to do seek channel instead of seek source
d. Need to test rewind
e. Need to test more file formats
--]]

require('CoronaTest')


local EXPECTED_NUMBER_OF_CHANNELS = 32
local NUMBER_OF_TOTAL_CHANNEL_LOOPS = 4
local NUMBER_OF_SINGLE_TESTS = 66
local NUMBER_OF_TESTS_IN_LOOP_INIT = 7
local NUMBER_OF_TESTS_IN_LOOP_RESERVE = 2
local NUMBER_OF_TESTS_IN_LOOP_AVERAGE_VOLUME = 2
local number_of_tests = NUMBER_OF_SINGLE_TESTS 
	+ EXPECTED_NUMBER_OF_CHANNELS * NUMBER_OF_TESTS_IN_LOOP_INIT
	+ EXPECTED_NUMBER_OF_CHANNELS * NUMBER_OF_TESTS_IN_LOOP_RESERVE
	+ EXPECTED_NUMBER_OF_CHANNELS * NUMBER_OF_TESTS_IN_LOOP_AVERAGE_VOLUME
g_numberOfTests = 0



function Quit()
	print("disposing audio memory")
	audio.dispose(declarationHandle)
	audio.dispose(battleHymnHandle)
	audio.dispose(note2Handle)
	audio.dispose(bouncingHandle)
	audio.dispose(ufoHandle)
	audio.dispose(laserHandle)
	audio.dispose(laserHandle2)
	collectgarbage()

	print("Number of audio tests run", g_numberOfTests)
	done_testing(g_numberOfTests)
	os.exit()
end
print("Expected number of audio tests", number_of_tests)
plan(number_of_tests)

local total_channels = audio.totalChannels
is(audio.totalChannels, EXPECTED_NUMBER_OF_CHANNELS, "totalChannels init")
g_numberOfTests = g_numberOfTests + 1

is(audio.reservedChannels, 0, "reservedChannels init")
g_numberOfTests = g_numberOfTests + 1

is(audio.freeChannels, EXPECTED_NUMBER_OF_CHANNELS, "freeChannels init")
g_numberOfTests = g_numberOfTests + 1

is(audio.unreservedFreeChannels, EXPECTED_NUMBER_OF_CHANNELS, "unreservedFreeChannels init")
g_numberOfTests = g_numberOfTests + 1

is(audio.usedChannels, 0, "usedChannels init")
g_numberOfTests = g_numberOfTests + 1

is(audio.unreservedUsedChannels, 0, "unreservedUsedChannels init")
g_numberOfTests = g_numberOfTests + 1
-- g_numberOfTests = 6

-- LOOP INIT
for i=1, audio.totalChannels do

	is(audio.isChannelActive(i), false, "isChannelActive init channel=" .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1

	is(audio.isSourceActive( audio.getSourceFromChannel(i) ), false, "isSourceActive & getSourceFromChannel init channel=" .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1

	is(audio.isChannelPlaying(i), false, "isChannelPlaying init channel=" .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1

	is(audio.isSourcePlaying( audio.getSourceFromChannel(i) ), false, "isSourcePlaying & getSourceFromChannel init channel=" .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1

	is(audio.isChannelPaused(i), false, "isChannelPaused init channel=" .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1

	is(audio.isSourcePaused( audio.getSourceFromChannel(i) ), false, "isChannelPaused & getSourceFromChannel init channel=" .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1



	is(audio.getVolume({channel=i}), 1.0, "init getVolume{channel=}"  .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1
	
end

is(audio.getVolume(), 1.0, "getVolume (master) init")
g_numberOfTests = g_numberOfTests + 1


-- Start mucking with state
is(audio.reserveChannels(2), 2, "reserveChannels( 2 )")
g_numberOfTests = g_numberOfTests + 1

is(audio.totalChannels, EXPECTED_NUMBER_OF_CHANNELS, "totalChannels reserved=2")
g_numberOfTests = g_numberOfTests + 1

is(audio.reservedChannels, 2, "reservedChannels reserved=2")
g_numberOfTests = g_numberOfTests + 1

is(audio.freeChannels, EXPECTED_NUMBER_OF_CHANNELS, "freeChannels reserved=2")
g_numberOfTests = g_numberOfTests + 1

is(audio.unreservedFreeChannels, EXPECTED_NUMBER_OF_CHANNELS-2, "unreservedFreeChannels reserved=2")
g_numberOfTests = g_numberOfTests + 1

is(audio.usedChannels, 0, "usedChannels reserved=2")
g_numberOfTests = g_numberOfTests + 1

is(audio.unreservedUsedChannels, 0, "unreservedUsedChannels reserved=2")
g_numberOfTests = g_numberOfTests + 1

-- LOOP RESERVE
for i=1, audio.totalChannels do

	is(audio.setVolume(0.5, {channel=i}), true, "RESERVE setVolume{channel=}"  .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1

	is(audio.getVolume({channel=i}), 0.5, "RESERVE getVolume{channel=}"  .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1
end
	
-- test average volume
for i=1, audio.totalChannels/2 do
	is(audio.setVolume(0.25, {channel=i}), true, " average setVolume(.25, {channel=}"  .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1
	
	is(audio.getVolume({channel=i}), 0.25, "average getVolume{channel=}"  .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1
end
for i=audio.totalChannels/2+1, audio.totalChannels do
	is(audio.setVolume(0.75, {channel=i}), true, "average setVolume(.75, {channel=}"  .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1

	is(audio.getVolume({channel=i}), 0.75, "average getVolume{channel=}"  .. tostring(i))
	g_numberOfTests = g_numberOfTests + 1
end

is(audio.getVolume({channel=0}), 0.50, "average getVolume{channel=0}")
g_numberOfTests = g_numberOfTests + 1


is(audio.getVolume(), 1.0, "average getVolume (master)")
g_numberOfTests = g_numberOfTests + 1


-- just reset volume
for i=1, audio.totalChannels do
	audio.setVolume(1.0, {channel=i})
end
audio.setVolume(1.0)
	



-- Loading tests
declarationHandle = audio.loadStream("TheDeclarationOfIndependencePreambleJFK.wav")
battleHymnHandle = audio.loadStream("battle_hymn_of_the_republic.mp3")
if system.getInfo("platformName") == "iPhone OS" or system.getInfo("platformName") == "Mac OS X" then
	-- Right now only Apple supports M4A/AAC
	note2Handle = audio.loadSound("note2_m4a.m4a")
else
	-- Only Windows, Android, and Mac support Ogg Vorbis
	note2Handle = audio.loadSound("note2_ogg.ogg")
end

bouncingHandle = audio.loadSound("bouncing_mp3.mp3")
ufoHandle = audio.loadSound("UFO_engine.wav")
laserHandle = audio.loadSound("laser1.wav")
laserHandle2 = audio.loadSound("laser1.wav")
is(laserHandle == laserHandle2, true, "double loadSound on laser1 returned cached value")
g_numberOfTests = g_numberOfTests + 1

isnt(declarationHandle, nil, "loadStream declarationHandle")
g_numberOfTests = g_numberOfTests + 1

isnt(battleHymnHandle, nil, "loadStream battleHymnHandle")
g_numberOfTests = g_numberOfTests + 1

isnt(note2Handle, nil, "loadSound note2Handle")
g_numberOfTests = g_numberOfTests + 1

isnt(bouncingHandle, nil, "loadSound bouncingHandle")
g_numberOfTests = g_numberOfTests + 1

isnt(ufoHandle, nil, "loadSound ufoHandle")
g_numberOfTests = g_numberOfTests + 1

isnt(laserHandle, nil, "loadSound laserHandle")
g_numberOfTests = g_numberOfTests + 1



badHandle = audio.loadStream("fakefile.wav")
is(badHandle, nil, "loadStream fakefile")
g_numberOfTests = g_numberOfTests + 1

badHandle = audio.loadSound("fakefile.wav")
is(badHandle, nil, "loadSound fakefile")
g_numberOfTests = g_numberOfTests + 1


badHandle = audio.loadSound("fakefile.wav")
is(badHandle, nil, "loadSound fakefile")
g_numberOfTests = g_numberOfTests + 1



-- Get times
local battle_hymm_duration = audio.getDuration(battleHymnHandle)
--print(battle_hymm_duration)
local declaration_duration = audio.getDuration(declarationHandle)
--print(declaration_duration)
local note2_duration = audio.getDuration(note2Handle)
--print(note2_duration)

-- I don't know if my times are correct, but they seem to be in the ballpark.
-- Apple returns 314613. libmpg123 (Android) returns 314070
if system.getInfo("platformName") == "iPhone OS" or system.getInfo("platformName") == "Mac OS X" then
	is(battle_hymm_duration, 314613, "battle_hymm_duration")
else
	is(battle_hymm_duration, 314070, "battle_hymm_duration")
end

g_numberOfTests = g_numberOfTests + 1

-- This is probably fragile, but I expect WAV decoders to be pretty consistent regardless of implementation
is(declaration_duration, 124308, "declaration_duration")
g_numberOfTests = g_numberOfTests + 1

is(note2_duration, 1986, "note2_duration")
g_numberOfTests = g_numberOfTests + 1

-- Seek declaration to 'We hold these truths..."
is(audio.seek(29500, declarationHandle), true, "Seek Declaration to 'We hold these truths...'")
g_numberOfTests = g_numberOfTests + 1

-- Seek battle to less silent part"
is(audio.seek(148000, battleHymnHandle), true, "Seek battle to less silent part")
g_numberOfTests = g_numberOfTests + 1



-- start playing
battleHymmChannel, battleHymmSource = audio.play(battleHymnHandle, {channel=1})
is(battleHymmChannel, 1, "play battleHymnHandle channel")
g_numberOfTests = g_numberOfTests + 1
isnt(battleHymmSource, 0, "play battleHymnHandle source")
g_numberOfTests = g_numberOfTests + 1

-- should fail because channel is in use
declarationChannel, declarationSource  = audio.play(declarationHandle, {channel=1})
is(declarationChannel, 0, "play declarationHandle (should fail because channel is in use)")
g_numberOfTests = g_numberOfTests + 1
is(declarationSource, 0, "play declarationSource")
g_numberOfTests = g_numberOfTests + 1

-- should work
declarationChannel, declarationSource = audio.play(declarationHandle, {channel=2, loops=-1})
is(declarationChannel, 2, "play declarationHandle (should work)")
g_numberOfTests = g_numberOfTests + 1
isnt(declarationSource, 0, "play declarationSource source")
g_numberOfTests = g_numberOfTests + 1

-- should fail because streamed source is already playing
battleHymmChannel2, battleHymmSource2 = audio.play(battleHymnHandle)
is(battleHymmChannel2, 0, "play battleHymnHandle (should fail because stream is already in use)")
g_numberOfTests = g_numberOfTests + 1
is(battleHymmSource2, 0, "play battleHymmSource2 source (should fail because stream is already in use)")
g_numberOfTests = g_numberOfTests + 1
-- NUMBER_OF_SINGLE_TESTS=25


-- should fail because channel exceeds max
note2Channel, note2Source = audio.play(note2Handle, {channel=33})
is(note2Channel, 0, "play note2Handle (should fail because channel exceeds max)")
g_numberOfTests = g_numberOfTests + 1
is(note2Source, 0, "play note2Handle source (should fail because channel exceeds max)")
g_numberOfTests = g_numberOfTests + 1


function laserCallback(event)
	is(event.channel, laserChannel, "laserCallback channel assert")
	g_numberOfTests = g_numberOfTests + 1
	
	is(event.source, laserSource, "laserCallback source assert")
	g_numberOfTests = g_numberOfTests + 1

	is(event.handle, laserHandle, "laserCallback handle assert")
	g_numberOfTests = g_numberOfTests + 1

	is(event.completed, true, "laserCallback completed assert")
	g_numberOfTests = g_numberOfTests + 1

	isnt(audio.fadeOut({channel=ufoChannel, time=2000}), 0, "fadeOut UFO")
	g_numberOfTests = g_numberOfTests + 1
end

function ufoCallback(event)
	is(event.channel, ufoChannel, "ufoChannel channel assert")
	g_numberOfTests = g_numberOfTests + 1
	
	is(event.source, ufoSource, "ufoSource source assert")
	g_numberOfTests = g_numberOfTests + 1

	is(event.handle, ufoHandle, "ufoHandle handle assert")
	g_numberOfTests = g_numberOfTests + 1

	is(event.completed, false, "ufoCallback NOT completed assert")
	g_numberOfTests = g_numberOfTests + 1

	is(audio.fadeOut({channel=ufoChannel, time=2000}), 0, "fadeOut UFO (should fail because nothing is playing)")
	g_numberOfTests = g_numberOfTests + 1


	is(audio.stop(), 2, "stop, expecting 2")
	g_numberOfTests = g_numberOfTests + 1

--	done_testing(g_numberOfTests)
	Quit()
	
end

function bouncingCallback(event)
	is(event.channel, bouncingChannel, "bouncingCallback channel assert")
	g_numberOfTests = g_numberOfTests + 1
	
	is(event.source, bouncingSource, "bouncingCallback source assert")
	g_numberOfTests = g_numberOfTests + 1

	is(event.handle, bouncingHandle, "bouncingCallback handle assert")
	g_numberOfTests = g_numberOfTests + 1

	is(event.completed, true, "bouncingCallback completed assert")
	g_numberOfTests = g_numberOfTests + 1


	isnt(audio.resume(battleHymmChannel), 0, "resuming Battle Hymn")
	g_numberOfTests = g_numberOfTests + 1

--	print(ufoChannel)
	isnt(audio.fade({channel=ufoChannel, time=4000, volume=0.5}), 0, "fading UFO")
	g_numberOfTests = g_numberOfTests + 1


	local free_channel, free_source = audio.findFreeChannel()
	isnt(free_channel, 0, "findFreeChannel")
	g_numberOfTests = g_numberOfTests + 1
	
	isnt(free_source, 0, "findFreeChannel source")
	g_numberOfTests = g_numberOfTests + 1


--	print(free_channel)
	laserChannel, laserSource = audio.play(laserHandle, {channel=free_channel, onComplete=laserCallback, loops=2})
--	print(laserChannel)


end

function note2Callback(event)
	is(event.channel, note2Channel, "note2Callback channel assert")
	g_numberOfTests = g_numberOfTests + 1
	
	is(event.source, note2Source, "note2Callback source assert")
	g_numberOfTests = g_numberOfTests + 1

	is(event.handle, note2Handle, "note2Callback handle assert")
	g_numberOfTests = g_numberOfTests + 1

	is(event.completed, true, "note2Callback completed assert")
	g_numberOfTests = g_numberOfTests + 1

	audio.dispose(note2Handle)
	note2Handle = nil


	isnt(audio.pause(battleHymmChannel), 0, "pausing Battle Hymn")
	g_numberOfTests = g_numberOfTests + 1

	bouncingChannel, bouncingSource = audio.play(bouncingHandle, {fadein=5000, onComplete=bouncingCallback, loops=1})

	ufoChannel, ufoSource = audio.play(ufoHandle, {fadein=10000, loops=-1, onComplete=ufoCallback})

end

-- should work
note2Channel, note2Source = audio.play(note2Handle, {onComplete=note2Callback})
isnt(note2Channel, 0, "play note2Handle (should work)")
g_numberOfTests = g_numberOfTests + 1


--[[
audio.stop()
audio.dispose(declarationHandle)
audio.dispose(battleHymnHandle)
audio.dispose(note2Handle)
--]]

--while true do
--	print("while")

--end
--done_testing(g_numberOfTests)
