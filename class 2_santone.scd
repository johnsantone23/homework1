s.waitForBoot({

	// Simple tonal synth
	SynthDef(\tonalSynth, {
		arg freq=440, amp=0.3, attack=0.01, release=0.5, pan=0;
		var sig, env;

		// Envelope
		env = EnvGen.kr(Env.perc(attack, release), doneAction:2);

		// Oscillators
		sig = Mix.ar([
			SinOsc.ar(freq, 0, amp * 0.5),
			Saw.ar(freq * 0.5, amp * 0.2),
			Pulse.ar(freq * 2, 0.3, amp * 0.1)
		]);

		// Filter
		sig = LPF.ar(sig, 2000);

		// Output
		Out.ar(0, Pan2.ar(sig * env, pan));
	}).add;

	s.sync;

	// C major scale
	~scale = [261.63, 293.66, 329.63, 392.00, 440.00, 523.25, 587.33, 659.25];

	// Sequence
	fork {
		var noteIndex = 0;
		var patterns = [
			[0, 2, 4, 2],
			[4, 3, 2, 1],
			[0, 0, 5, 4],
			[2, 3, 4, 5],
		];
		var currentPattern = 0;

		120.do { |i|
			var patternArray = patterns[currentPattern];
			var note = patternArray[noteIndex % patternArray.size];
			var freq = ~scale[note % ~scale.size];

			Synth(\tonalSynth, [
				\freq, freq,
				\amp, 0.2 + (0.1.rand),
				\attack, 0.01,
				\release, 0.4,
				\pan, 0.5.rand2
			]);

			// Harmony note
			if(0.3.coin, {
				Synth(\tonalSynth, [
					\freq, freq * 1.5,
					\amp, 0.1,
					\attack, 0.02,
					\release, 0.3,
					\pan, 0.5.rand2
				]);
			});

			// Bass note
			if(i % 4 == 0, {
				Synth(\tonalSynth, [
					\freq, ~scale[0] * 0.5,
					\amp, 0.15,
					\attack, 0.05,
					\release, 0.8,
					\pan, 0
				]);
			});

			noteIndex = noteIndex + 1;

			// Change pattern
			if(i % 16 == 15, {
				currentPattern = (currentPattern + 1) % patterns.size;
				noteIndex = 0;
			});

			0.5.wait; // 120 BPM
		};
	};

});

