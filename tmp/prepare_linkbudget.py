from pathlib import Path
import shutil
root=Path(r'D:\Users\21449\Downloads\1-Channel\1-Channel')
p=root/'II_SIMORayTracing.m'
s=p.read_text(encoding='utf-8-sig')
start=s.index('% bandwidths_MHz ='); end=s.index('% END CODE',start)
s=s[:start]+''.join(line[2:] if line.startswith('% ') else line for line in s[start:end].splitlines(True))+s[end:]
s=s.replace('%% 4：带宽对比——固定Rx1射线及逐径随机复系数（默认注释）','%% 4：带宽对比——固定Rx1射线及逐径随机复系数（默认启用）')
s=s.replace('% 操作2：再做带宽实验：仅选择“带宽对比”BEGIN CODE/END CODE之间的代码，\n%        Ctrl+T取消行注释，光标放该节按Ctrl+Enter。不必重算射线。','% 操作2：F5现在也自动完成带宽对比，无需另行取消注释；不重复计算射线。')
s=s.replace('% 操作：仅对BEGIN/END之间的代码按Ctrl+T，随后Ctrl+Enter运行本节。','% 操作：本节已启用，随F5执行；也可在恢复存档后单独运行本节。')
s=s.replace("'Color','w');","'Color','w','Position',[100 100 1100 650]);")
p.write_text(s,encoding='utf-8')
report=Path(r'D:\Repository\code\LATEX\Conmmunication\LinkBudget')
for n in [3,5,6,7,9,10]:
    shutil.copy2(root/'results_school'/f'学校-{n}',report/'figures'/f'school_step{n:02}.png')
