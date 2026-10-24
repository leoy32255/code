p='D:/Users/21449/Downloads/1-Channel/1-Channel';
addpath(p);
a=load(fullfile(p,'results_school/school_CIR_positions.mat'));
b=load(fullfile(p,'results_school/school_CIR_bandwidth.mat'));
assert(strcmp(a.metadata.MapText,fileread(fullfile(p,'bupt_map.osm'))));
assert(isequal(a.coeff1,b.coeff1) && isequal(a.delay1,b.delay1));
fprintf('spacing=%.9f m; origin=%.9f ns\n',a.dme2,a.tauRef*1e9);
for k=1:3
    bins=round((a.delay1-a.delay1(1))/(1/(2*b.bandwidths_MHz(k)*1e6)));
    h=multipath_channel_simple(bins,a.power1,a.coeff1);
    assert(isequal(bins,b.binByBandwidth{k}));
    assert(max(abs(h-b.cirByBandwidth{k}))<1e-12);
    fprintf('B=%g MHz; rays=%d; bins=%d\n',b.bandwidths_MHz(k),numel(bins),numel(unique(bins)));
end
for k=1:2
    delay=a.(['delay' num2str(k)]); power=a.(['power' num2str(k)]); phase=a.(['phase' num2str(k)]);
    bins=round((delay-a.tauRef)/(1/(40e6)));
    h=multipath_channel_simple(bins,power,exp(1i*phase));
    assert(max(abs(h-a.(['CIR' num2str(k) '_geometry'])))<1e-12);
    fprintf('Rx%d geometry abs: ',k); fprintf('%.6f ',abs(h)); fprintf('\n');
end
disp(a.rtpm); disp('SAVED_CIR_CHECK_OK');
