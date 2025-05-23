~calcRTLatency = {
	1.0.wait;
	x = Synth(\latency);

	s.sync;

	~latencyBuffer.loadToFloatArray(action: {arg array; ~latencyArray = array;});

	s.sync;

	{var max = 0.0, maxIdx;
		~latencyArray.do{|i, idx|
			// i.postln;
			if(i > max, {
				max = i;
				maxIdx = idx;
			});
		};
		s.sync;
		~roundTripLatency = maxIdx;
		"Round trip latency = % samples".format(maxIdx).postln;
	}.fork;
};

~generateImpResponse = {|testSig, testResponse|
	var prepObj, prepSine, fftInfo, freqRespObj, freqRespSine, division;

	prepObj = ~prepareObj.(testResponse, ~roundTripLatency);
	prepSine = ~prepareSine.(testSig);

	fftInfo = ~rfftSize.(prepObj.size);

	freqRespObj = ~freqResponseObj.(prepObj, fftInfo);
	freqRespSine = ~freqResponseObj.(prepSine, fftInfo);

	division = freqRespObj / freqRespSine;
	~impResponse.(division, fftInfo);
};

~writeAudioToDisk = {
	var time, frFolder, irFolder;
	time = Date.getDate.stamp;

	if(~impResponseBuf != nil, {

		frFolder = (~folderName ++ ~writePathFR).standardizePath;
		irFolder = (~folderName ++ ~writePathIR).standardizePath;

		if(File.exists(frFolder).not, {
			File.mkdir(frFolder)
		});

		if(File.exists(irFolder).not, {
			File.mkdir(irFolder)
		});

		~objName = ~name ++ "_%_%_%_%_env".format(s.sampleRate, ~dur, ~tail, ~roundTripLatency);

		~impulseName = ~name ++ "_%_%_%".format(s.sampleRate, ~dur, "IR");

		~objBuf.write(frFolder ++ "%_%.%".format(~objName, time, "wav"), "wav");

		~impResponseBuf.write(irFolder ++ "%_%.%".format(~impulseName, time, "wav"), "wav");

		"% has been saved".format(~objName).postln;

	}, {"Nothing has been recorded. Record something before writing to disk".postln});
};

~playTestSignal = ({

	if(~sineChangeDetect != 0, {
		~expSineSweepBuffer = ~expSineSweep.(~startFreqBus.getSynchronous, ~endFreqBus.getSynchronous, ~recDur, s.sampleRate);
		s.sync;

		~objBuf = Buffer.alloc(s, s.sampleRate * ~dur);
		~sineBuf = Buffer.alloc(s, s.sampleRate * ~recDur);
		s.sync;
	});

	~objBuf = ~updateBuf.(~objBuf, ~dur);
	~sineBuf = ~updateBuf.(~sineBuf, ~recDur);

	~waitTime.wait;

	Synth(\rec, [\buf, ~objBuf, \dur, ~dur], target: ~recGrp);
	Synth(\sine, [\buf, ~expSineSweepBuffer, \recDur, ~recDur], target: ~synthGrp);

	~dur.wait;

	~impResponseBuf = ~generateImpResponse.(~expSineSweepBuffer, ~objBuf);

	s.sync;

	~objBuf.loadToFloatArray(action: {|array|
		a = array;
		{~sfView.setData(array, channels: 1, samplerate: s.sampleRate)}.defer});

	// {~sfView.setData(~objBuf, channels: 1, samplerate: s.sampleRate)}.defer;


	~impResponseBuf.loadToFloatArray(action: {|array|
		a = array;
		{~irView.setData(array[0..((array.size / 2) / 2).asInteger], channels: 1, samplerate: s.sampleRate.asInteger)}.defer});

	s.sync;

	~sineChangeDetect = 0;

	"Done".postln;

});

~prepareSine = {|buffer|
	var sineReverseArray, sineArray;

	buffer.loadToFloatArray(action: {arg array; sineArray = array});
	s.sync;
	// sineReverseArray = sineArray.reverse;
	sineArray
};

~expSineSweep = {|f1, f2, time, sRate|
	var sweepRate, array, sF, arrayLength, sine;
	sweepRate = log(f2/f1);
	sF = 1 / sRate;
	arrayLength = sRate * time;
	array = Array.fill(arrayLength, {|i| sF * i});
	sine = Array.fill(arrayLength, {|i|
		sin((2 * pi * f1 * (time / sweepRate)) * (exp(array[i] * sweepRate / time) -1))});
	Buffer.loadCollection(s, sine);
};

~prepareObj = {|buffer, rtLatency|
	var ltCorrArray, mean, bufArray, test, bufMean, env;

	buffer.loadToFloatArray(action: {arg array;
		bufArray = array;
	}); // Load buffer to array

	s.sync;

	// Adjusting array to match round-trip latency. Maybe not needed
	// ltCorrArray = bufArray[rtLatency..(bufArray.size - 1)]; //

	bufArray;
};

~rfftSize = {|bufferSize|
	var pow2, rfftSize, cosTable;
	pow2 = bufferSize.nextPowerOfTwo;
	rfftSize = (pow2 / 2 + 1).asInteger;
	cosTable = Signal.rfftCosTable(rfftSize);
	[pow2, rfftSize, cosTable];
};

~freqResponseObj = {|objectResponse, fftInfo|
	var object, real, complex;

	real = Signal.newClear(fftInfo[0]);

	// Zero-padding
	object = objectResponse.addAll(Array.fill(fftInfo[0] - objectResponse.size, {0}));

	object.do{|i, idx|
		real[idx] = i};

	real.discardDC;
	real.normalizeMagnitude;

	complex = rfft(real, fftInfo[2]);

	if (~plotFreqSpectrum, {
		{complex.magnitude.plot}.defer;
	});

	complex;
};

~impResponse = {|freqResponse, fftInfo|
	var ifft, curve;

	ifft = freqResponse.real.irfft(freqResponse.imag, fftInfo[2]);

	Buffer.loadCollection(s, (ifft[0..(ifft.size/2).asInteger]).normalize)
};

~updateBuf = {|buffer, dur|
	if (dur != (buffer.numFrames / s.sampleRate), {
		buffer.free;
		s.sync;
		buffer = Buffer.alloc(s, s.sampleRate * ~dur);
		s.sync;
	});
	buffer;
};