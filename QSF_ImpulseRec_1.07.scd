(
s.options.sampleRate_(48000);
s.options.numInputBusChannels_(6);
s.options.numOutputBusChannels_(6);
s.options.hardwareBufferSize = 64;
s.recHeaderFormat = "wav";

~interface = "Fireface UCX (23732049)";

s.options.outDevice_(~interface);

s.options.inDevice_(~interface);

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




