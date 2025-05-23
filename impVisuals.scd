
var win, inChan, outChan, startFreq, endFreq, freqTextAnchor = [140, 160],
chanAnchor = [140, 100], inChanText, outChanText, genImpResp, saveImpresp, monitorResponse,
freqText = 2.collect{}, chanText = 2.collect{}, rountTripLatency, systemDelayText, fileNameText,
sweepTime, tail, sweepTimeText, tailText, folderName;

win = Window("Impulse response recording", Rect(128, 64, 800, 800));

folderName = DragSink(win, Rect(10, 10, 600, 25));
folderName.string = "%".format(~folderName);
folderName.action = {|field|
	~folderName  = "%".format(field.value);
	~folderName.postln;
};

fileNameText = TextField(win, Rect(10, 50, 600, 25));
fileNameText.string = "%".format(~name);
fileNameText.action = {|field|
	var date = Date.getDate.stamp.asString;
	~name = "%".format(field.value);
	~objName = ~name ++ "_%_%_%_%".format("objectResponse", s.sampleRate, ~dur, ~roundTripLatency);
	~impulseName = ~name ++ "_%_%_%".format("impulseResponse", s.sampleRate, ~dur);
	"Object responses will be saved with: %".format(~objName).postln;
	"Impulse responses will be saved with: %".format(~impulseName).postln;
};

inChan = NumberBox(win, Rect(chanAnchor[0], chanAnchor[1], 60, 20));
inChan.value = ~inChan.getSynchronous.asInteger;
inChan.action = {|field| ~inChan.set(field.value.asInteger)};

outChan = NumberBox(win, Rect(chanAnchor[0], chanAnchor[1] + 30, 60, 20));
outChan.value = ~outChan.getSynchronous.asInteger;
outChan.action = {|field| ~outChan.set(field.value.asInteger)};

chanText[0] = StaticText(win, Rect(10, chanAnchor[1], 100, 20)).string = "Input Channel";
chanText[1] = StaticText(win, Rect(10,chanAnchor[1] + 30, 100, 20)).string = "Output Channel";

startFreq = NumberBox(win, Rect(freqTextAnchor[0], freqTextAnchor[1], 60, 20));
startFreq.value = ~startFreqBus.getSynchronous;
startFreq.action = {|text|
	~startFreqBus.set(text.value.asFloat);
	~sineChangeDetect = 1;
};
endFreq = NumberBox(win, Rect(freqTextAnchor[0], freqTextAnchor[1] + 30, 60, 20));
endFreq.value = ~endFreqBus.getSynchronous;
endFreq.action = {|field|
	~endFreqBus.set(field.value.asFloat);
	~sineChangeDetect = 1;
};

freqText[0] = StaticText(win, Rect(10, freqTextAnchor[1], 100, 20)).string = "Start Frequency";
freqText[1] = StaticText(win, Rect(10, freqTextAnchor[1] + 30, 100, 20)).string = "End Frequency";

sweepTime = NumberBox(win, Rect(140, freqTextAnchor[1] + 60 , 60, 20));
sweepTime.value = ~recDur;
sweepTime.action = {|field|
	~recDur = field.value;
	~dur = ~recDur + ~tail;
	~sineChangeDetect = 1;

};

tail = NumberBox(win, Rect(140, freqTextAnchor[1] + 90, 60, 20));
tail.value = ~tail;
tail.action = {|field|
	~tail = field.value;
	~dur = ~recDur + ~tail;
};

sweepTimeText = StaticText(win, Rect(10, freqTextAnchor[1] + 60, 100, 20)).string = "Sweep time";
tailText = StaticText(win, Rect(10, freqTextAnchor[1] + 90, 100, 20)).string = "Tail";


genImpResp = Button(win, Rect(250, chanAnchor[1], 100, 40))
.states_([
	["Play Sine", Color.black, Color.white]])
.mouseDownAction_({|val| ~playTestSignal.fork});

monitorResponse = Button(win, Rect(250, chanAnchor[1] + 60, 100, 40))
.states_([
	["Monitor Response", Color.black, Color.white]])
.mouseDownAction_({|val| ~objBuf.play});

monitorResponse = Button(win, Rect(250, chanAnchor[1] + 120, 100, 40))
.states_([
	["Monitor Impulse Response", Color.black, Color.white]])
.mouseDownAction_({|val| ~impResponseBuf.play});

saveImpresp = Button(win, Rect(250, chanAnchor[1] + 180, 100, 40))
.states_([
	["Save response", Color.black, Color.white]])
.mouseDownAction_({~writeAudioToDisk.fork});

systemDelayText = TextField(win, Rect(530, freqTextAnchor[1], 50, 40));
rountTripLatency = Button(win, Rect(380, freqTextAnchor[1], 130, 40))
.states_([
	["Get system delay", Color.black, Color.white]])
.mouseDownAction_({|val|
	~calcRTLatency.fork;
	{systemDelayText.string = "%".format(~roundTripLatency)}.defer(1.2)
});

~sfView = SoundFileView(win, Rect(10, freqTextAnchor[1] + 200, 600, 150));

~irView = SoundFileView(win, Rect(10, freqTextAnchor[1] + 400, 600, 150));


win.front;
win.alwaysOnTop = true;


