	(
	SynthDef.new(\LahmscheOrgel, {
		| mainfreq = 440,
		sustain = 1,
        gainSonor = 1,
		gainVoll = 1,
		gainMarkant = 1,
		gainNaselnd = 1,
		gainHell = 1,
		gainBrilliant = 1,
		gainSpitz = 1,
		gainScharf = 1,
		reqvibSonor = 0,
		reqvibVoll = 0,
		reqvibMarkant = 0,
		reqvibNaselnd = 0,
		reqvibHell = 0,
		reqvibBrilliant = 0,
		reqvibSpitz = 0,
		reqvibScharf = 0,
		   envvibSonor = 0,
		envvibVoll = 0,
		envvibMarkant = 0,
		envvibNaselnd = 0,
		envvibHell = 0,
		envvibBrilliant = 0,
		envvibSpitz = 0,
		envvibScharf = 0|

		var qsig;
		var ffdSonor,
		    ffdVoll,
		    ffdMarkant,
		    ffdNaselnd,
		    ffdHell,
		    ffdBrilliant,
		    ffdSpitz,
		    ffdScharf,
		ffSonorh,
		ffSonorl,
		ffVollh,
		ffVolll,
		ffMarkanth,
		ffMarkantl,
		ffNaselndh,
		ffNaselndl,
		ffHellh,
		ffHelll,
		ffBrillianth,
		ffBrilliantl,
		ffSpitz,
		ffScharf,
		mainEnv,
		fsig,
		resSig,
		fEnv,
		ifEnv,
		fe,
		freq,
		hasFreq,
		hasGain,
		hg;

		// reqvibSonor = rrand(0.8, 3);

		// Erzeugen des Quell-Signals

		qsig = Impulse.ar(mainfreq, 0, 0.2);

		// Formant Filter
		// Filter Envelope
		fe = 0;
		mainEnv = Env.triangle(sustain, 1);
		fEnv = EnvGen.kr(mainEnv, doneAction: 2);
		ifEnv = 1- fEnv;

		// Filter Frequenzen mit Frequenz Vibrato.
		// Prototyp Frequenz Vibrato
		//  Crackle.ar(freqvibSonor/10, freqvibSonor)*//Freq//  || ;

		ffSonorh = Crackle.kr(reqvibSonor/10, reqvibSonor)*400*ifEnv+400;
		ffSonorl = Crackle.kr(reqvibSonor/10, reqvibSonor)*200*ifEnv+200;
		ffVollh = Crackle.kr(reqvibVoll/10, reqvibVoll)*600*ifEnv+600;
		ffVolll = Crackle.kr(reqvibVoll/10, reqvibVoll)*400*ifEnv+400;
		ffMarkanth = Crackle.kr(reqvibMarkant/10, reqvibMarkant)*1200*ifEnv+1200;
		ffMarkantl = Crackle.kr(reqvibMarkant/10, reqvibMarkant)*800*ifEnv+800;
		ffNaselndh = Crackle.kr(reqvibNaselnd/10, reqvibNaselnd/10)*1800*ifEnv+1800;
		ffNaselndl = Crackle.kr(reqvibNaselnd/10, reqvibNaselnd/10)*1200*ifEnv+1200;
		ffHellh = Crackle.kr(reqvibHell/10, reqvibHell)*400*ifEnv+400;
		ffHelll = Crackle.kr(reqvibHell/10, reqvibHell)*1800*ifEnv+1800;
		ffBrillianth = Crackle.kr(reqvibBrilliant/10, reqvibBrilliant)*4000*ifEnv+4000;
		ffBrilliantl = Crackle.kr(reqvibBrilliant/10, reqvibBrilliant)*400*ifEnv+400;
		ffSpitz = Crackle.kr(reqvibSpitz/10, reqvibSpitz)*8000*ifEnv+8000;
		ffScharf = Crackle.kr(reqvibScharf/10, reqvibScharf)*10000*ifEnv+10000;

		// r = RHPF.ar(BLowPass4.ar(qsig, freqh), freql); // Muster eines Formant Filter Bandes
		ffdSonor = RHPF.ar(BLowPass4.ar(qsig, ffSonorh), ffSonorl)*gainSonor;
		ffdVoll = RHPF.ar(BLowPass4.ar(qsig, ffVollh), ffVolll)*gainVoll;
		ffdMarkant = RHPF.ar(BLowPass4.ar(qsig, ffMarkanth), ffMarkantl)*gainMarkant;
		ffdNaselnd = RHPF.ar(BLowPass4.ar(qsig, ffNaselndh), ffNaselndl)*gainNaselnd;
		ffdHell = RHPF.ar(BLowPass4.ar(qsig, ffHellh), ffHelll)*gainHell;
		ffdBrilliant = RHPF.ar(BLowPass4.ar(qsig, ffBrillianth), ffBrilliantl)*gainBrilliant;
		ffdSpitz = RHPF.ar(qsig, ffSpitz)*gainSpitz;
		ffdScharf = RHPF.ar(qsig, ffScharf)*gainScharf;

		fsig = (ffdSonor + ffdVoll + ffdMarkant + ffdNaselnd + ffdBrilliant + ffdSpitz + ffdScharf)/7;

		fsig = fsig*fEnv;
		// Pitch-Filter
		# freq, hasFreq = Pitch.kr(fsig, ampThreshold: 0.02, median: 7, peakThreshold: 0.01);
		fsig = fsig * hasFreq;

		// Envelope Filter

		hasGain = Amplitude.kr(fsig, attackTime: 0.01, releaseTime: 0.01, mul: 1.0, add: 0.0);
		// hg = if ((hasGain < 0.8), { 1 },{ 0 });
		// fsig = fsig * hg;
		// fsig = fsig*(hasGain>1.1);
		resSig = GVerb.ar(fsig);

		Out.ar(0, [resSig, resSig]);
	}).send(s);
	)

x = Synth.new(\LahmscheOrgel);
x.set("gainSpitz", 50);
x.set("freqvibSpitz", 1.35);

r = Routine({
    var delta, deltasus, mainFreq, newFreq,
	a, b,
	gainSonor;
	mainFreq = 440;
	a = Pxrand.new(#[0.666, 0.75, 1.333, 1.5  ], inf);
	b = a.asStream;
    loop {
		// Funktion zur Automatischen Ansteuerung der Orgel

		// Berechnung der mainFrequenz
		newFreq = mainFreq * b.next;
		mainFreq = newFreq;
		// while ( { (newFreq < 20) || (newFreq > 15000)  }, { newFreq = mainFreq * b.next });

		delta = rrand(1, 3);
		deltasus = delta * rrand(0.6, 1.5);
        Synth(\LahmscheOrgel,
			[mainfreq: exprand(200, 800),
		     sustain: deltasus,
			gainSonor: Pwhite(0.0, 25.0, inf).asStream,
			gainVoll: Pwhite(0.0, 25.0, inf).asStream,
			gainMarkant: Pwhite(0.0, 25.0, inf).asStream,
			gainNaselnd: Pwhite(0.0, 25.0, inf).asStream,
			gainHell: Pwhite(0.0, 25.0, inf).asStream,
			gainBrilliant: Pwhite(0.0, 25.0, inf).asStream,
			gainSpitz: Pwhite(0.0, 25.0, inf).asStream,
			gainScharf: Pwhite(0.0, 25.0, inf).asStream,
			reqvibSonor: Pwhite(0.8, 2, inf).asStream,
			reqvibVoll: Pwhite(0.8, 2, inf).asStream,
			reqvibMarkant: Pwhite(0.6, 2, inf).asStream,
			reqvibNaselnd: Pwhite(0.6, 2, inf).asStream,
			reqvibHell: Pwhite(0.6, 2, inf).asStream
			]);
        delta.yield;
    }
}).play;