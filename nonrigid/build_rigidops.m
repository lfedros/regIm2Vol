function regOps = build_rigidops(target)

regOps.type = 'rigid';
regOps.targetFrame = target;
regOps.useGPU = true;
regOps.subPixel = 1;
regOps.phaseCorrelation = true;
regOps.maxregshift = 50;
regOps.kriging = 1;
[regOps.Ly, regOps.Lx]  = size(target);

end