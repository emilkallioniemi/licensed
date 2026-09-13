"""Deterministic original procedural vehicle Foley; Python standard library only.
22,050 Hz mono PCM, conservative peaks, seamless integer-period engine loops.
"""
from pathlib import Path
import math, random, wave, struct, json
OUT=Path(__file__).resolve().parent.parent/'audio'; OUT.mkdir(exist_ok=True)
RATE=22050; rng=random.Random(707)
def save(name,seconds,signal):
    samples=[max(-.92,min(.92,signal(i/RATE,i))) for i in range(int(RATE*seconds))]
    data=b''.join(struct.pack('<h',round(v*32767)) for v in samples)
    with wave.open(str(OUT/(name+'.wav')),'wb') as f: f.setparams((1,2,RATE,len(samples),'NONE','not compressed')); f.writeframes(data)
    return {'frames':len(samples),'seconds':seconds,'peak':max(abs(v) for v in samples),'rms':math.sqrt(sum(v*v for v in samples)/len(samples))}
sin=lambda f,t: math.sin(math.tau*f*t)
report={}
report['engine_idle']=save('engine_idle',2,lambda t,i: (.23*sin(42,t)+.13*sin(84,t)+.06*sin(126,t))*(.8+.2*sin(8,t)))
report['engine_load']=save('engine_load',2,lambda t,i: (.18*sin(63,t)+.10*sin(126,t)+.06*sin(189,t)+.035*sin(315,t))*(.83+.17*sin(21,t)))
# Loops use periodic colored noise: softened tyre scrub and loose cabin fittings.
noise=[rng.uniform(-1,1) for _ in range(RATE*2)]
soft=[sum(noise[(i-j)%len(noise)] for j in range(12))/12 for i in range(len(noise))]
report['tyre_scrub']=save('tyre_scrub',2,lambda t,i:soft[i]*.45*(.7+.3*sin(7,t)))
report['cabin_rattle']=save('cabin_rattle',2,lambda t,i:.075*(sin(173,t)+.4*sin(347,t))*max(0,sin(11,t))**12)
report['suspension']=save('suspension',.48,lambda t,i:(.21*sin(94-45*t,t)+.10*sin(212,t)+soft[i]*.15)*math.exp(-t*10)*min(1,t*120))
report['impact']=save('impact',.6,lambda t,i:(.4*sin(58,t)+.16*sin(139,t)+noise[i]*.24)*math.exp(-t*12)*min(1,t*350))
(OUT/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
assert all(v['frames']>0 and v['rms']>.002 for v in report.values())
print(json.dumps(report,indent=2))
