"""Original procedural composition; Python 3 + numpy. No samples required."""
from pathlib import Path
import json
import wave
import numpy as np

OUT = Path(__file__).resolve().parent
SR = 44100
BPM = 104
BEAT = 60 / BPM
BARS = 32
N = round(BARS * 4 * BEAT * SR)
mix = np.zeros((N, 2), dtype=np.float64)
rng = np.random.default_rng(1407)
events = []


def note(beat, midi, length, voice, gain=0.1, pan=0.0):
    duration = length * BEAT
    t = np.arange(round((duration + 0.18) * SR)) / SR
    f = 440 * 2 ** ((midi - 69) / 12)
    attack = 1 - np.exp(-t / 0.006)
    release = np.exp(-np.maximum(t - duration, 0) / 0.035)
    if voice == 'bass':
        s = (np.sin(2*np.pi*f*t) + 0.25*np.sin(4*np.pi*f*t)) * np.exp(-t*3)
    elif voice == 'keys':
        s = (np.sin(2*np.pi*f*t + 1.2*np.sin(2*np.pi*f*2*t)*np.exp(-t*8))
             + 0.12*np.sin(2*np.pi*f*3*t)) * np.exp(-t*2.8)
    elif voice == 'mallet':
        s = (np.sin(2*np.pi*f*t) * np.exp(-t*5)
             + 0.23*np.sin(2*np.pi*f*2.76*t)*np.exp(-t*15)
             + 0.08*np.sin(2*np.pi*f*5.4*t)*np.exp(-t*25))
    elif voice == 'kick':
        s = np.sin(2*np.pi*(48*t + 2*(1-np.exp(-t*30)))) * np.exp(-t*24)
    else:
        noise = rng.normal(0, 1, len(t))
        high = noise - np.roll(noise, 1)
        s = high * np.exp(-t*(70 if voice == 'hat' else 40)) * 0.25
        if voice == 'rim':
            s += 0.32*np.sin(2*np.pi*1250*t)*np.exp(-t*90)
    s = s * attack * release * gain
    stereo = s[:, None] * np.array([np.sqrt((1-pan)/2), np.sqrt((1+pan)/2)])
    indices = (round(beat * BEAT * SR) + np.arange(len(t))) % N
    np.add.at(mix, indices, stereo)
    events.append(dict(beat=beat, midi=midi, length=length, voice=voice))


# F major: cheery paperwork with a minor detour. A / A' / B / A''.
progression = [
    (41, [57, 60, 64, 67]), (38, [57, 60, 64, 65]),
    (43, [58, 62, 65, 69]), (36, [58, 62, 64, 67]),
    (41, [57, 60, 64, 67]), (45, [55, 60, 64, 67]),
    (43, [58, 62, 65, 69]), (36, [58, 62, 64, 67]),
]
melody = [
    [(0, 72), (0.67, 69), (1.5, 67), (2.67, 69)],
    [(0.5, 65), (1.67, 64), (2.5, 65)],
    [(0, 67), (0.67, 70), (1.5, 69), (3, 65)],
    [(0.67, 64), (1.5, 62), (2.67, 60)],
    [(0, 72), (0.67, 69), (1.5, 67), (2.67, 74)],
    [(0.5, 72), (1.67, 71), (2.5, 69)],
    [(0, 70), (1, 69), (1.67, 67), (2.67, 65)],
    [(0.5, 64), (1.67, 62), (3, 67)],
]
for bar in range(BARS):
    section, local = divmod(bar, 8)
    root, chord = progression[local]
    if section == 2:
        root, chord = [(46, [57, 60, 62, 65]), (46, [57, 60, 62, 65]),
                       (45, [55, 60, 64, 67]), (38, [57, 60, 64, 65]),
                       (43, [58, 62, 65, 69]), (43, [58, 62, 65, 69]),
                       (36, [58, 62, 64, 67]), (36, [58, 61, 64, 67])][local]
    b = bar * 4
    for offset, pitch in [(0, root), (1.67, root+12), (2.5, root+7), (3.67, root+12)]:
        note(b+offset, pitch, 0.55, 'bass', 0.19, -0.08)
    for offset in [0.67, 2, 3.33]:
        for i, pitch in enumerate(chord):
            note(b+offset+i*0.014, pitch, 0.45, 'keys', 0.044, -0.33)
    for offset in [0, 2]:
        note(b+offset, 36, 0.2, 'kick', 0.105)
    for offset in [1, 3]:
        note(b+offset, 36, 0.13, 'rim', 0.095, 0.24)
    for offset in [0, 0.67, 1, 1.67, 2, 2.67, 3, 3.67]:
        note(b+offset, 36, 0.1, 'hat', 0.040 if offset % 1 else 0.025, 0.42)
    phrase = melody[local]
    if section == 2:
        phrase = [[(0.5, 77), (2, 74)], [(1, 72), (2.67, 69)],
                  [(0, 76), (1.67, 72), (3, 67)], [(0.5, 69), (2.5, 65)],
                  [(0, 74), (1.67, 70)], [(0.67, 69), (2.67, 67)],
                  [(0.5, 64), (2, 62)], [(1, 61), (2.67, 64), (3.67, 67)]][local]
    for offset, pitch in phrase:
        note(b+offset, pitch, 0.65, 'mallet', 0.105, 0.18)
    if section in [1, 3] and local in [1, 3, 5]:
        note(b+3.33, chord[-1]+12, 0.28, 'keys', 0.055, -0.2)

# Circular delay retains the previous cycle's tails at the loop start.
dry = mix.copy()
for delay, gain in [(0.091, 0.12), (0.173, 0.09), (0.293, 0.055)]:
    mix += np.roll(dry[:, ::-1], round(delay*SR), axis=0) * gain
mix -= mix.mean(axis=0)
mix = np.tanh(mix * 1.4)
mix *= 10 ** (-3 / 20) / np.max(np.abs(mix))
pcm = np.round(mix * 32767).astype('<i2')
with wave.open(str(OUT / 'please_take_a_number.wav'), 'wb') as wav:
    wav.setnchannels(2)
    wav.setsampwidth(2)
    wav.setframerate(SR)
    wav.writeframes(pcm.tobytes())
report = dict(title='Please Take a Number', bpm=BPM, bars=BARS,
              seconds=N/SR, sample_rate=SR, frames=N,
              peak_dbfs=float(20*np.log10(np.max(np.abs(mix)))),
              rms_dbfs=float(20*np.log10(np.sqrt(np.mean(mix**2)))),
              boundary_step=float(np.max(np.abs(mix[0]-mix[-1]))), events=events)
(OUT / 'composition.json').write_text(json.dumps(report, indent=2) + '\n')
print({k: v for k, v in report.items() if k != 'events'})
