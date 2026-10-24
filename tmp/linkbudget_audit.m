p = 'D:/Users/21449/Downloads/1-Channel/1-Channel';
o = 'D:/Repository/code/tmp';
tags = ["step05_perfect_1R","step06_concrete_1R","step07_weather_1R","step08_weather_2R","step09_weather_2R1D"];
for tag=tags
    a=load(fullfile(p,'results_school',tag+'.mat'));
    assert(strcmp(a.metadata.MapText,fileread(fullfile(p,'bupt_map.osm'))));
    rs=a.rays{1}; counts=zeros(numel(rs),2);
    for k=1:numel(rs)
        types=string({rs(k).Interactions.Type});
        counts(k,:)=[sum(types=="Reflection"),sum(types=="Diffraction")];
    end
    fprintf('%s: no diffraction=%d; diffraction=%d; maxR=%d; maxD=%d\n',tag,sum(counts(:,2)==0),sum(counts(:,2)>0),max(counts(:,1)),max(counts(:,2)));
    disp(rmfield(a.metadata,'MapText'));
end
for tag=["step03_coverage_los","step10_coverage_1R"]
    a=load(fullfile(p,'results_school',tag+'.mat'));
    assert(strcmp(a.metadata.MapText,fileread(fullfile(p,'bupt_map.osm'))));
    disp(rmfield(a.metadata,'MapText'));
    writetable(a.coverageData.Data,fullfile(o,tag+'.csv'));
end
a=load(fullfile(p,'coverageResultsTwoRefOneDiff.mat'));
writetable(a.coverageResultsTwoRefOneDiff.Data,fullfile(o,'legacy_coverage.csv'));
d=a.coverageResultsTwoRefOneDiff.Data;
fprintf('Legacy: %d points; lat %.8f..%.8f; lon %.8f..%.8f; power %.3f..%.3f\n',height(d),min(d.Latitude),max(d.Latitude),min(d.Longitude),max(d.Longitude),min(d.Power),max(d.Power));
disp('READ_ONLY_AUDIT_OK');
