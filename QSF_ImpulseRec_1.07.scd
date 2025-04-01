(
s.options.sampleRate_(48000);
s.options.numInputBusChannels_(6);
s.options.numOutputBusChannels_(6);
s.options.hardwareBufferSize = 64;
s.recHeaderFormat = "wav";

s.options.outDevice_(
	// "Built-in Output"
	"Fireface UCX (23732049)"
	// "MixPre-6 II"
	// "Scarlett 2i2 USB"
	//"Komplete Audio 6"
);

s.options.inDevice_(
	"Fireface UCX (23732049)"
	// "Built-in Input"
	// "MixPre-6 II"
	// "Scarlett 2i2 USB"x
	//"Komplete Audio 6"
);

~recDur = 7.0;
~tail = 4;
~waitTime = 1;
~dur = ~recDur + ~tail;

~plotFreqSpectrum = true;

~folderName = "Drop your folder address here";
~name = "Write object name here";
~objName = ~name ++ "_%_%_env".format(s.sampleRate, ~dur);
~impulseName = ~name ++ "_%_%_%".format(s.sampleRate, ~dur, "impulseResponse");
~sineName = "SineExpGuiTest_%_%_env".format(s.sampleRate, ~dur);

// Drop your folder for storing IRs here. It has to look like:
// ~writePath = "folder/anotherFolder/folderForIrs/";
~writePath = ;

~writePathFR = "Frequency Responses/";
~writePathIR = "Impulse Responses/";


~sineBuf = Bus.audio(s);

~recPathObj = PathName(thisProcess.nowExecutingPath.dirname ++ "/TestAudio/");
~recPathSine = PathName(thisProcess.nowExecutingPath.dirname ++ "/TestAudio/");

~roundTripLatency = 0;

~sineChangeDetect = 0;

s.waitForBoot({

~outChan = Bus.control(s).set(2);
~inChan = Bus.control(s).set(0);

~startFreqBus = Bus.control(s).set(20);
~endFreqBus = Bus.control(s).set(20000);

~synthGrp = Group.new;
~recGrp = Group.new(~synthGrp, \addAfter);
~latencyBuffer = Buffer.alloc(s, s.sampleRate * 0.2);

~objBuf = Buffer.alloc(s, s.sampleRate * ~dur);
~sineBuf = Buffer.alloc(s, s.sampleRate * ~recDur);

	"IR_Rec_Functions.scd".loadRelative;
	"IR_Rec_Synths.scd".loadRelative;

	s.sync;

	~expSineSweepBuffer = ~expSineSweep.(~startFreqBus.getSynchronous, ~endFreqBus.getSynchronous, ~recDur, s.sampleRate);

	s.sync;

	"impVisuals.scd".loadRelative;

});

)




