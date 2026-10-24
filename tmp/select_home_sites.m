p='D:/Users/21449/Downloads/1-Channel/1-Channel';
viewer=siteviewer('Buildings',fullfile(p,'home.osm'));
pm1=propagationModel('raytracing','Method','sbr','MaxNumReflections',1,'MaxNumDiffractions',0,'AngularSeparation','medium','BuildingsMaterial','concrete','TerrainMaterial','concrete');
pm2=propagationModel('raytracing','Method','sbr','MaxNumReflections',2,'MaxNumDiffractions',0,'AngularSeparation','low','BuildingsMaterial','concrete','TerrainMaterial','concrete');
pairs=[39.92225 116.24508 39.92254 116.24470;39.92228 116.24502 39.92252 116.24480;39.92220 116.24505 39.92255 116.24470;39.92170 116.24518 39.92202 116.24485];
records=struct([]);
for k=1:size(pairs,1)
    tx=txsite('Latitude',pairs(k,1),'Longitude',pairs(k,2),'AntennaHeight',10,'TransmitterPower',5,'TransmitterFrequency',28e9);
    rx=rxsite('Latitude',pairs(k,3),'Longitude',pairs(k,4),'AntennaHeight',1);
    direct=los(tx,rx,'Map',viewer);
    a=raytrace(tx,rx,pm1,'Map',viewer); b=raytrace(tx,rx,pm2,'Map',viewer);
    fprintf('CANDIDATE %d: LOS=%d 1R=%d 2R=%d\n',k,direct,numel(a{1}),numel(b{1}));
    records(k).Coordinates=pairs(k,:); records(k).LOS=direct;records(k).rays1=a;records(k).rays2=b;
end
save('D:/Repository/code/tmp/home_site_candidates.mat','records','pm1','pm2');
disp('CANDIDATES_DONE');
