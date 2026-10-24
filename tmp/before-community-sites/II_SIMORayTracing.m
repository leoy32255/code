%% 实验1基础代码问题：相邻接收位置CIR与带宽影响
% 文件要求：与I_SISORayTracing.m、multipath_channel_simple.m、bupt_map.osm放在同一目录。
% 操作1：首次按F5。默认运行初始化、两位置射线计算及20MHz的两组CIR图。
%        生成CIR_position_rayphase.png（几何相位）和CIR_position_random.png（原随机模型）。
%        两图、两个位置的逐径CSV、接收功率和完整MAT自动保存到results_school。
% 操作2：F5现在也自动完成带宽对比，无需另行取消注释；不重复计算射线。
%        得到20/40/80MHz的CIR_bandwidth.png、bandwidth_summary.csv与MAT。
% 操作3：若MATLAB已清空工作区，先运行“从存档恢复”注释块，再运行带宽对比。
%        请不要先运行初始化节再加载另一场景的结果；同名结果均仅用于学校。
% 操作4：把两个位置的功率和射线数、不同带宽的占用时延格数用于报告；
%        几何射线数与离散时延格数分别记录，不要把两者都称作“径数”。
%
% 两位置仍沿用原代码坐标：相距约22.2cm，在28GHz下约20.8波长，并非半波长。
% 文档没有要求改为5.35mm；本文件不擅自改动原接收坐标，也不声称两位置强相关。
% 先画几何相位CIR，用于观察传播路径本身随位置的变化；另外保留原函数的独立
% 复高斯随机CIR。随机图中的全部差异不能归因于位置，且这里没有模拟空间相关。
% 每个位置都按其逐径功率之和归一化（不是把每次瞬时CIR强行归一化到单位能量）。
% CIR纵轴是归一化复系数的模值，不是dBm；真实接收功率另由sigstrength计算。

%% 1：初始化（默认启用）
clc;
clear;
close all;
scriptDir = fileparts(mfilename('fullpath'));
addpath(scriptDir);
building_osm = fullfile(scriptDir,'home.osm');
assert(isfile(building_osm),'未找到学校地图：%s',building_osm);
outDir = fullfile(scriptDir,'results_school');
if ~isfolder(outDir), mkdir(outDir); end
Bw = 20; % MHz；带宽对比在下方单独运行，不要每改一次Bw就重新生成随机路径系数。
viewer = siteviewer("Buildings",building_osm);
tx = txsite("Name","School Tx","Latitude",39.96243,"Longitude",116.35141, ...
    "AntennaHeight",10,"TransmitterPower",5,"TransmitterFrequency",28e9);
rx1 = rxsite("Name","School Rx1","Latitude",39.96215,"Longitude",116.35205,"AntennaHeight",1);
rx2 = rxsite("Name","School Rx2","Latitude",39.962152,"Longitude",116.35205,"AntennaHeight",1);
% 与原SIMO基础代码相同：混凝土、2反射/1衍射、low，不叠加天气损耗。
rtpm = propagationModel("raytracing","Method","sbr", ...
    "MaxNumReflections",2,"MaxNumDiffractions",1,"AngularSeparation","low", ...
    "BuildingsMaterial","concrete","TerrainMaterial","concrete");
show(tx,"Map",viewer); show(rx1,"Map",viewer); show(rx2,"Map",viewer);

%% 2：计算两位置的射线及功率（默认启用）
% raytrace有输出时不自动绘图，完整射线保存在rays1/rays2中。
rays1 = raytrace(tx,rx1,rtpm,"Map",viewer);
rays2 = raytrace(tx,rx2,rtpm,"Map",viewer);
[pathLoss1,delay1,phase1] = sortedPathData(rays1);
[pathLoss2,delay2,phase2] = sortedPathData(rays2);
RxStrength1 = sigstrength(rx1,tx,rtpm,"Map",viewer);
RxStrength2 = sigstrength(rx2,tx,rtpm,"Map",viewer);
dme2 = distance(rx2,rx1);
lambda = physconst('lightspeed')/tx.TransmitterFrequency;
fprintf('接收点间距 %.6f m = %.3f 波长；半波长 %.6f m。\n',dme2,dme2/lambda,lambda/2);
positionSummary = table(["Rx1";"Rx2"],[RxStrength1;RxStrength2], ...
    [numel(delay1);numel(delay2)],'VariableNames',{'Receiver','ReceivedPower_dBm','NumRays'});
disp(positionSummary);
writetable(positionSummary,fullfile(outDir,'position_summary.csv'));
writetable(table(delay1(:)*1e9,pathLoss1(:),phase1(:), ...
    'VariableNames',{'Delay_ns','PathLoss_dB','Phase_rad'}),fullfile(outDir,'Rx1_paths.csv'));
writetable(table(delay2(:)*1e9,pathLoss2(:),phase2(:), ...
    'VariableNames',{'Delay_ns','PathLoss_dB','Phase_rad'}),fullfile(outDir,'Rx2_paths.csv'));
% 相对功率线性比例；最小路损作参考，之后由基础函数统一除以总功率。
power1 = 10.^(-(pathLoss1-min(pathLoss1))/10);
power2 = 10.^(-(pathLoss2-min(pathLoss2))/10);
Ts = 1/(2*Bw*1e6);
tauRef = min([delay1 delay2]); % 两位置共用最早到达时刻，保留相对到达差异。
bins1 = round((delay1-tauRef)/Ts);
bins2 = round((delay2-tauRef)/Ts);

%% 3：相邻位置CIR（默认启用）
% 第三参数是逐径复系数。本图使用射线几何相位，不额外抽取独立随机相位。
CIR1_geometry = multipath_channel_simple(bins1,power1,exp(1i*phase1));
CIR2_geometry = multipath_channel_simple(bins2,power2,exp(1i*phase2));
fGeometry = figure('Name','相邻接收位置：几何相位CIR','Color','w','Position',[100 100 1100 650]);
stem((0:numel(CIR1_geometry)-1)*Ts*1e9,abs(CIR1_geometry),'o'); hold on;
stem((0:numel(CIR2_geometry)-1)*Ts*1e9,abs(CIR2_geometry),'x');
grid on; xlabel('相对共同最早到达时刻的时延 (ns)'); ylabel('归一化CIR幅度 |h[n]|');
legend('Rx1','Rx2','Location','best'); title('20 MHz，射线几何相位，无额外随机衰落');
exportgraphics(fGeometry,fullfile(outDir,'CIR_position_rayphase.png'),'Resolution',200);

% 原基础代码对应独立复高斯随机系数：固定随机种子方便重复运行复核。
% 两接收点的随机系数仍独立；固定种子只保证可重复，不表示空间相关。
rng(20261024,'twister');
coeff1 = (randn(size(power1))+1i*randn(size(power1)))/sqrt(2);
coeff2 = (randn(size(power2))+1i*randn(size(power2)))/sqrt(2);
[CIR1,fadingWeight1] = multipath_channel_simple(bins1,power1,coeff1);
[CIR2,fadingWeight2] = multipath_channel_simple(bins2,power2,coeff2);
fRandom = figure('Name','相邻接收位置：原随机模型CIR','Color','w','Position',[100 100 1100 650]);
stem((0:numel(CIR1)-1)*Ts*1e9,abs(CIR1),'o'); hold on;
stem((0:numel(CIR2)-1)*Ts*1e9,abs(CIR2),'x');
grid on; xlabel('相对共同最早到达时刻的时延 (ns)'); ylabel('归一化CIR幅度 |h[n]|');
legend('Rx1：独立随机实现','Rx2：独立随机实现','Location','best');
title('20 MHz，独立复高斯随机衰落（不含空间相关模型）');
exportgraphics(fRandom,fullfile(outDir,'CIR_position_random.png'),'Resolution',200);
metadata = struct('MatlabVersion',version,'MapFile',building_osm, ...
    'MapText',fileread(building_osm),'Timestamp',char(datetime('now')), ...
    'Terrain',string(viewer.Terrain),'Bandwidth_MHz',Bw,'DelayOrigin_s',tauRef, ...
    'TxLLH',[tx.Latitude tx.Longitude tx.AntennaHeight], ...
    'Rx1LLH',[rx1.Latitude rx1.Longitude rx1.AntennaHeight], ...
    'Rx2LLH',[rx2.Latitude rx2.Longitude rx2.AntennaHeight], ...
    'Frequency_Hz',tx.TransmitterFrequency,'TxPower_W',tx.TransmitterPower);
save(fullfile(outDir,'school_CIR_positions.mat'), ...
    'metadata','rtpm','tx','rx1','rx2','rays1','rays2', ...
    'pathLoss1','pathLoss2','delay1','delay2','phase1','phase2', ...
    'power1','power2','coeff1','coeff2','fadingWeight1','fadingWeight2', ...
    'CIR1','CIR2','CIR1_geometry','CIR2_geometry','tauRef','positionSummary','dme2');
fprintf('相邻位置CIR已保存；接着运行下方带宽对比节。\n');

%% 4：带宽对比——固定Rx1射线及逐径随机复系数（默认启用）
% 操作：本节已启用，随F5执行；也可在恢复存档后单独运行本节。
% 不改地图/位置/模型，不再调用raytrace，不重新抽取coeff1。
% 三个子图横轴均为相对首径的时延/ns，使用相同坐标范围和纵轴范围。
% NumRays是几何射线数；OccupiedDelayBins是量化后被射线占据的时延格数量。
% occupied bins通常随网格细化增多；本次是否变化以实际结果为准。
% 这里沿用基础函数的round量化模型，不是完整的带限脉冲成形接收机；
% Ts=1/(2B)是采样间隔，不能直接宣称所有相邻Ts的路径都可物理分辨。
% BEGIN CODE
bandwidths_MHz = [20 40 80];
cirByBandwidth = cell(1,3);
binByBandwidth = cell(1,3);
occupiedBins = zeros(3,1);
for k = 1:3
    sampleTime_s = 1/(2*bandwidths_MHz(k)*1e6);
    binByBandwidth{k} = round((delay1-delay1(1))/sampleTime_s);
    cirByBandwidth{k} = multipath_channel_simple(binByBandwidth{k},power1,coeff1);
    occupiedBins(k) = numel(unique(binByBandwidth{k}));
end
gridIntervals_ns = 1./(2*bandwidths_MHz(:)*1e6)*1e9;
bandwidthSummary = table(bandwidths_MHz(:),gridIntervals_ns, ...
    repmat(numel(delay1),3,1),occupiedBins, ...
    'VariableNames',{'Bandwidth_MHz','SamplingInterval_ns','NumRays','OccupiedDelayBins'});
disp(bandwidthSummary);
fBandwidth = figure('Name','固定逐径系数的带宽对比','Color','w','Position',[100 100 1100 650]);
tiledlayout(3,1);
maxAmplitude = max(cellfun(@(h) max(abs(h)),cirByBandwidth));
maxDelay_ns = max((delay1-delay1(1))*1e9) + max(gridIntervals_ns);
for k = 1:3
    nexttile;
    stem((0:numel(cirByBandwidth{k})-1)*gridIntervals_ns(k),abs(cirByBandwidth{k}),'filled');
    grid on; xlim([0 maxDelay_ns]); ylim([0 max(1e-12,1.1*maxAmplitude)]);
    xlabel('相对Rx1首径的时延 (ns)'); ylabel('|h[n]|');
    title(sprintf('%g MHz：几何射线%d条，占用时延格%d个', ...
        bandwidths_MHz(k),numel(delay1),occupiedBins(k)));
end
exportgraphics(fBandwidth,fullfile(outDir,'CIR_bandwidth.png'),'Resolution',200);
writetable(bandwidthSummary,fullfile(outDir,'bandwidth_summary.csv'));
save(fullfile(outDir,'school_CIR_bandwidth.mat'),'metadata','bandwidths_MHz', ...
    'delay1','power1','coeff1','binByBandwidth','cirByBandwidth','bandwidthSummary');
% END CODE

%% 5：从存档恢复后只做带宽对比（可选，不需重算射线）
% 工作区清空后：运行下面3行，再回到第4节运行，不需要先运行第1—3节。
% 仅加载本文件自己保存的学校结果；不会重新改变地图或生成随机衰落。
% BEGIN CODE
% scriptDir = fileparts(mfilename('fullpath'));
% outDir = fullfile(scriptDir,'results_school'); addpath(scriptDir);
% load(fullfile(outDir,'school_CIR_positions.mat'),'metadata','delay1','power1','coeff1');
% END CODE

%% 本地辅助函数（保持原样）
function [pathLoss,delay,phase] = sortedPathData(rays)
    assert(~isempty(rays) && ~isempty(rays{1}), ...
        '当前接收点没有有效射线。请检查学校地图、收发位置和2反射/1衍射设置。');
    list = rays{1};
    [delay,order] = sort([list.PropagationDelay]);
    pathLoss = [list.PathLoss]; pathLoss = pathLoss(order);
    phase = [list.PhaseShift]; phase = phase(order);
end
