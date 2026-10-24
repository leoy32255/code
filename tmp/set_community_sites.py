from pathlib import Path
import shutil
root=Path(r'D:\Users\21449\Downloads\1-Channel\1-Channel')
backup=Path(r'D:\Repository\code\tmp\before-community-sites')
backup.mkdir(exist_ok=True)
for name in ['I_SISORayTracing.m','II_SIMORayTracing.m']:
    p=root/name
    shutil.copy2(p,backup/name)
    s=p.read_text(encoding='utf-8-sig')
    for a,b in [('results_school','results_community'),('bupt_map.osm','home.osm'),('School','Community'),('school_','community_'),('学校','社区'),('39.962152','39.922542'),('39.96215','39.922540'),('39.96243','39.922250'),('116.35141','116.245080'),('116.35205','116.244700'),('116.35148','116.245150')]:
        s=s.replace(a,b)
    s=s.replace('两位置仍沿用原代码坐标','两位置采用社区坐标，保留原代码的纬度间隔')
    s=s.replace('本文件不擅自改动原接收坐标','本文件保留约22.2cm的接收间距')
    s=s.replace('只加载已保存的5条射线','只加载已保存的射线')
    s=s.replace('本次不换home.osm，不做波束控制；社区以后另行设置经纬度和输出目录。','本次使用home.osm及results_community；不做波束控制，学校存档保持不变。')
    if name.startswith('I_'):
        a=s.index('%% 步骤11B：'); b=s.index('%% 步骤8可选重画',a)
        s=s[:a]+'''%% 步骤11B：只重画本社区已计算的覆盖结果
% 必须先完成本社区11A；不存在社区存档时停止，不加载学校预计算文件。
% BEGIN CODE
% redrawCommunitySaved("coverage11");
% END CODE

'''+s[b:]
    note='% 选点核查：Tx=(39.922250,116.245080)，Rx1=(39.922540,116.244700)。\n% home.osm、10m/1m、混凝土：LoS=0；1R/0D/medium有2条，2R/0D/low有6条。\n'
    s=note+s
    p.write_text(s,encoding='utf-8')
(root/'results_community').mkdir(exist_ok=True)
print('Updated both scripts; school results preserved.')
