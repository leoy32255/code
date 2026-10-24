%% 实验1：学校场景（对应实验文档步骤1—11；不含选作波束控制）
% 操作流程就在本文件中，不需要另查报告：
% 1. 将本文件、II_SIMORayTracing.m、multipath_channel_simple.m、bupt_map.osm 放在同一目录。
% 2. 在 MATLAB 编辑器打开本文件。初始版本只有“步骤1—2”和“步骤5”启用；
%    首次按 F5，建立学校场景并得到完美反射、单反射的路径和接收功率。
% 3. 完整文档顺序为：1—2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11A。
%    第3、4节可在首次运行后补做；若要严格顺序，先注释第5节再运行初始化。
% 4. 后续每次只处理一节：选中该节 BEGIN CODE 与 END CODE 之间的代码，
%    按 Ctrl+T 取消行注释，再将光标放在该节，按 Ctrl+Enter“运行节”。
%    完成后选中这些代码按 Ctrl+R 注释回来。不要选中中文操作说明一起取消注释。
%    这样不用重跑已经算过的覆盖图；不要每次都按 F5，否则会从初始化重新运行。
% 5. 若关闭了 Site Viewer 或 clear 了工作区，先重新运行步骤1—2，再运行目标节。
%    每个目标节都会重建所需模型，不依赖上一步留下的材质、天气或反射次数。
% 6. 结果自动写到本目录的 results_school。MAT 和 CSV 保存真实数值、配置及计时；
%    Site Viewer 路径/覆盖图请在每节完成时截图，文件名见相应注释。
%    截图保留功率色标、Tx/Rx、相同视角和缩放；不要把单条射线颜色当总接收功率。
% 7. 相邻位置 CIR 和带宽影响在 II_SIMORayTracing.m；本文件完成后再运行它。
%    文档示例中的 dBm 数值没有写死到代码中，结果以当前地图实际运行为准。
%
% 已核查：原文件不能仅按原注释顺序复现。原来存在材质提前改变、同一模型的
% 输出标签不同、没有生成 rays、加载旧覆盖结果后误作当前计算结果等问题。
% 本版通过每节独立设置模型、输出真实结果及保存条件，消除这些状态依赖。

%% 步骤1—2：初始化学校地图、发射机和接收机（本节保持启用）
clc;
clear;
close all;
scriptDir = fileparts(mfilename('fullpath'));
addpath(scriptDir);
building_osm = fullfile(scriptDir, 'home.osm');
assert(isfile(building_osm), '未找到学校地图：%s', building_osm);
outDir = fullfile(scriptDir, 'results_school');
if ~isfolder(outDir), mkdir(outDir); end

% 与文档一致，保留默认底图和地形；不要为加速而悄悄改成 Terrain="none"。
viewer = siteviewer("Buildings", building_osm);
tx = txsite("Name","School Tx", ...
    "Latitude",39.96243,"Longitude",116.35141, ...
    "AntennaHeight",10,"TransmitterPower",5,"TransmitterFrequency",28e9);
rx = rxsite("Name","School Rx", ...
    "Latitude",39.96215,"Longitude",116.35205,"AntennaHeight",1);
% rxLOS 仅用于步骤4的视线检查，避免与 SIMO 文件的 rx1 混淆。
rxLOS = rxsite("Name","LoS check", ...
    "Latitude",39.96243,"Longitude",116.35148,"AntennaHeight",1);
show(tx,"Map",viewer);
show(rx,"Map",viewer);
commonMeta = struct('MatlabVersion',version, 'MapFile',building_osm, ...
    'MapText',fileread(building_osm), 'Frequency_Hz',tx.TransmitterFrequency, ...
    'TxPower_W',tx.TransmitterPower, 'TxLLH',[tx.Latitude tx.Longitude tx.AntennaHeight], ...
    'RxLLH',[rx.Latitude rx.Longitude rx.AntennaHeight], ...
    'Terrain',string(viewer.Terrain));
fprintf('初始化完成。学校图像及数值统一保存至：%s\n', outDir);

%% 步骤3：仅直射覆盖（0反射、0衍射；网格3 m）
% 操作：取消下面3行注释，运行本节；完成后截图并注释回来。
% 保存截图：school_step03_coverage_los.png。
% 必须明确设为0/0；不能拿已修改为混凝土/多反射的旧模型充当直射模型。
% BEGIN CODE
% pm = schoolModel("perfect-reflector",0,0,"medium",false);
% coverageLOS = recordCoverage(tx,viewer,pm,3,outDir,"step03_coverage_los",commonMeta);
% END CODE

%% 步骤4：检查主接收点及直射检查点的遮挡
% 操作：运行本节后查看两条视线路径；记录实际是否遮挡，不预设结果。
% 保存截图：school_step04_los.png。红色表示遮挡，绿色表示可见。
% BEGIN CODE
% clearMap(viewer);
% show(tx,"Map",viewer); show(rx,"Map",viewer); show(rxLOS,"Map",viewer);
% mainLOS = los(tx,rx,"Map",viewer);
% checkLOS = los(tx,rxLOS,"Map",viewer);
% los(tx,rx,"Map",viewer); los(tx,rxLOS,"Map",viewer);
% fprintf('主接收点LoS=%d，检查点LoS=%d\n',mainLOS,checkLOS);
% save(fullfile(outDir,'step04_los.mat'),'mainLOS','checkLOS','commonMeta');
% END CODE

%% 步骤5及步骤6前半：完美反射材质、最大一次反射（默认启用）
% 首次F5运行到本节即可得到基准结果。截图后，后续无需重复运行。
% 保存截图：school_step05_perfect_1R.png。
% 路径图表示最多一次反射（包含可能存在的低阶路径），不是只有一条射线。
% 如需注释本节，只选中下面两行代码按 Ctrl+R。
% pm = schoolModel("perfect-reflector",1,0,"medium",false);
% result05 = recordLink(tx,rx,viewer,pm,outDir,"step05_perfect_1R",commonMeta);

%% 步骤6后半：混凝土、最大一次反射（与步骤5比较材质）
% 操作：取消下面两行注释并运行本节；截图后注释回来。
% 保存截图：school_step06_concrete_1R.png。
% 在 link_summary.csv 中比较 step05 与 step06 的 ReceivedPower_dBm；
% 两者角间隔均为medium、均无天气损耗，材质是本次比较的变化项。
% BEGIN CODE
% pm = schoolModel("concrete",1,0,"medium",false);
% result06 = recordLink(tx,rx,viewer,pm,outDir,"step06_concrete_1R",commonMeta);
% END CODE

%% 步骤7：混凝土、一次反射，加气体和降雨损耗
% 操作：取消下面两行注释并运行本节；截图后注释回来。
% 保存截图：school_step07_weather_1R.png。
% 与step06比较接收功率；weather=true时保存的pm包含实际gas/rain默认参数。
% 不能只重新绘图而不重新计算功率，也不能把step09的输出贴到此条件下。
% BEGIN CODE
% pm = schoolModel("concrete",1,0,"medium",true);
% result07 = recordLink(tx,rx,viewer,pm,outDir,"step07_weather_1R",commonMeta);
% END CODE

%% 步骤8：混凝土、天气、最大两次反射（角间隔low）
% 操作：取消下面两行注释并运行本节；截图后注释回来。
% 保存截图：school_step08_weather_2R.png。
% 注意：文档从本节起同时把角间隔medium改为low；step07→08不是只改反射阶数。
% 报告可按文档比较实际结果，但不要把全部变化严格归因于新增一次反射。
% BEGIN CODE
% pm = schoolModel("concrete",2,0,"low",true);
% result08 = recordLink(tx,rx,viewer,pm,outDir,"step08_weather_2R",commonMeta);
% END CODE

%% 步骤9：混凝土、天气、最大两次反射及一次衍射
% 操作：取消下面两行注释并运行本节；截图后注释回来。
% 保存截图：school_step09_weather_2R1D.png。
% 与step08相比，保持角间隔low，仅把最大衍射数从0改为1。
% 判断哪些射线发生衍射时查看MAT中的rays交互信息，不单凭线条颜色判断。
% BEGIN CODE
% pm = schoolModel("concrete",2,1,"low",true);
% result09 = recordLink(tx,rx,viewer,pm,outDir,"step09_weather_2R1D",commonMeta);
% END CODE

%% 步骤10：单反射加天气的覆盖图（网格2 m、角间隔low）
% 操作：运行本节；结果保存后截图，不必再次从头运行整个脚本。
% 保存截图：school_step10_coverage_1R.png。
% 本节重新设为1反射/0衍射/low，避免沿用step09的2/1设置。
% BEGIN CODE
% pm = schoolModel("concrete",1,0,"low",true);
% coverageOneRef = recordCoverage(tx,viewer,pm,2,outDir,"step10_coverage_1R",commonMeta);
% END CODE

%% 步骤11A：新算两反射一衍射覆盖（网格10 m、角间隔high）
% 操作：本节可能耗时很长，确认本节是当前节后再按Ctrl+Enter，等待计算结束。
% 保存截图：school_step11_coverage_2R1D.png。
% 输出结果另存results_school，不覆盖老师提供的coverageResultsTwoRefOneDiff.mat。
% 与步骤3/10的网格和角间隔不同，不能直接据截图计算覆盖率或比较纯阶数耗时。
% BEGIN CODE
% pm = schoolModel("concrete",2,1,"high",true);
% coverageResultsTwoRefOneDiff = recordCoverage(tx,viewer,pm,10,outDir,"step11_coverage_2R1D",commonMeta);
% END CODE

%% 步骤11B：只加载已有覆盖结果（不运行11A、不重新计算覆盖）
% 操作：运行初始化后，执行下面一行；也可直接在命令窗口调用该函数。
% 优先读取自己存档；不存在时读取本目录原有coverageResultsTwoRefOneDiff.mat。
% 原有文件只有功率表，不能据文件名补造材质、天气、网格、计时等元数据。
% 仅修改当前工作区pm再load旧MAT不会改变MAT数据，不能当成新模型的仿真。
% 本节核对存档地图正文、收发位置、地形和固定的11A模型条件，避免加载错场景。
% BEGIN CODE
% redrawSchoolSaved("coverage11");
% END CODE

%% 步骤8可选重画：只加载已保存的5条射线，不重新计算
% 现有截图可用于展示传播效果；路径数量以存档为准，无需为展示全部路径补图。
% redrawSchoolSaved("paths08");

%% 收集结果及下一步（本节只有操作说明）
% 材质/天气/阶数：link_summary.csv应有step05—09共5行，填写每行实际接收功率。
% 每组MAT同时包含模型、站点、地图正文、完整射线和逐径CSV，可交叉核对图像。
% 计时：表中LinkCalculation_s是射线数据+sigstrength计算总耗时（不含绘图）；
% coverage_summary.csv中CoverageCalculation_s仅为coverage计算耗时，不含重画。
% 路径与覆盖截图保留本节条件，不使用文档中的截图或示例功率代替本人结果。
% 完成后打开II_SIMORayTracing.m，按其中注释生成相邻接收点CIR和带宽对比。
% 本次不换home.osm，不做波束控制；社区以后另行设置经纬度和输出目录。

%% 本地辅助函数（保持原样，不需要取消注释）
function pm = schoolModel(material,nRef,nDiff,angular,weather)
    pm = propagationModel("raytracing","Method","sbr", ...
        "MaxNumReflections",nRef,"MaxNumDiffractions",nDiff, ...
        "AngularSeparation",angular, ...
        "BuildingsMaterial",material,"TerrainMaterial",material);
    if weather
        pm = pm + propagationModel("gas") + propagationModel("rain");
    end
end

function metadata = modelMetadata(pm,commonMeta)
    metadata = commonMeta;
    metadata.Timestamp = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
    metadata.Weather = isprop(pm,'PropagationModels');
    rt = pm;
    if metadata.Weather, rt = pm.PropagationModels(1); end
    metadata.Material = string(rt.BuildingsMaterial);
    metadata.MaxReflections = rt.MaxNumReflections;
    metadata.MaxDiffractions = rt.MaxNumDiffractions;
    metadata.AngularSeparation = string(rt.AngularSeparation);
end

function result = recordLink(tx,rx,viewer,pm,outDir,tag,commonMeta)
    timer = tic;
    rays = raytrace(tx,rx,pm,"Map",viewer);
    receivedPower_dBm = sigstrength(rx,tx,pm,"Map",viewer);
    elapsed_s = toc(timer);
    rayList = rays{1};
    pathTable = table((1:numel(rayList))',reshape([rayList.PathLoss],[],1), ...
        reshape([rayList.PropagationDelay],[],1)*1e9,reshape([rayList.PhaseShift],[],1), ...
        'VariableNames',{'PathIndex','PathLoss_dB','Delay_ns','Phase_rad'});
    metadata = modelMetadata(pm,commonMeta);
    save(fullfile(outDir,tag+".mat"),'rays','receivedPower_dBm','elapsed_s', ...
        'pm','metadata','tx','rx','pathTable');
    writetable(pathTable,fullfile(outDir,tag+"_paths.csv"));
    row = table(string(tag),receivedPower_dBm,numel(rayList),elapsed_s, ...
        metadata.Material,metadata.MaxReflections,metadata.MaxDiffractions, ...
        metadata.AngularSeparation,metadata.Weather,'VariableNames', ...
        {'Condition','ReceivedPower_dBm','NumRays','LinkCalculation_s', ...
        'Material','MaxReflections','MaxDiffractions','AngularSeparation','Weather'});
    updateSummary(fullfile(outDir,'link_summary.csv'),row);
    disp(row);
    if isempty(rayList), warning('本条件未找到有效射线；请核对地图、站点及模型，不要填写示例数值。'); end
    clearMap(viewer);
    show(tx,"Map",viewer); show(rx,"Map",viewer);
    % 带输出的raytrace只返回数据；这里显式再调用一次无输出版本以显示路径。
    raytrace(tx,rx,pm,"Map",viewer,"Type","power","ColorLimits",[-120 -5]);
    result = struct('rays',{rays},'ReceivedPower_dBm',receivedPower_dBm, ...
        'PathTable',pathTable,'Metadata',metadata,'Elapsed_s',elapsed_s);
end

function coverageData = recordCoverage(tx,viewer,pm,resolution,outDir,tag,commonMeta)
    timer = tic;
    % 保留文档coverage(tx,pm,...)的接收端默认增益2.1dB、高度1m；
    % 覆盖图移动接收机与链路rx不是同一对象，不能直接拿像素读数替代sigstrength。
    coverageData = coverage(tx,pm,"SignalStrengths",-120:-5, ...
        "MaxRange",250,"Resolution",resolution,"Map",viewer);
    elapsed_s = toc(timer);
    metadata = modelMetadata(pm,commonMeta);
    metadata.Resolution_m = resolution;
    metadata.MaxRange_m = 250;
    metadata.ReceiverGain_dB = 2.1;
    metadata.ReceiverHeight_m = 1;
    metadata.SignalStrengths_dBm = -120:-5;
    save(fullfile(outDir,tag+".mat"),'coverageData','pm','metadata','elapsed_s','tx');
    row = table(string(tag),elapsed_s,resolution,metadata.MaxReflections, ...
        metadata.MaxDiffractions,metadata.AngularSeparation, ...
        'VariableNames',{'Condition','CoverageCalculation_s','Resolution_m', ...
        'MaxReflections','MaxDiffractions','AngularSeparation'});
    updateSummary(fullfile(outDir,'coverage_summary.csv'),row);
    disp(row);
    % 有输出的coverage不会显示地图，需显式contour重画，使用相同功率范围。
    clearMap(viewer); show(tx,"Map",viewer);
    contour(coverageData,"Type","power","Levels",-120:-5, ...
        "ColorLimits",[-120 -5],"Transparency",0.6,"Map",viewer);
end

function updateSummary(file,row)
    if isfile(file)
        previous = readtable(file,'TextType','string');
        previous(previous.Condition==row.Condition,:) = [];
        row = [previous; row];
    end
    writetable(row,file);
end
