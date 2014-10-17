function [L,NL] = filterSona(V,f1,f2)
essparam;
L = (bpFilter(V, fSam, f1, 0.100E9));
NL = (bpFilter(V, fSam, f2, 0.100E9));
end