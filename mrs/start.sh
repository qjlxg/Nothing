# 修改时区
sudo timedatectl set-timezone 'Asia/Shanghai'

# # 清理提交历史
# pip install -q git-filter-repo
# git filter-repo --commit-callback '
# import subprocess
# # 设置用户的邮箱
# target_email = "actions@github.com"
# # 获取用户的最后一次提交哈希值
# last_commit_hash = subprocess.run(
#     ["git", "log", "--author=" + target_email, "--pretty=format:%H", "-n", "1"],
#     text=True, capture_output=True).stdout.strip()

# # 如果作者邮箱是目标用户，且不是最后一次提交
# if commit.author_email == target_email and commit.original_id != last_commit_hash:
#     commit.skip_commit = True
# '
# git reflog expire --expire=now --all
# # git gc --prune=now --aggressive
# # git push origin --force --all

cd ..
mkdir tmp && cd tmp
# 下载最新 mihomo
wget -q -O mihomo.gz "$(curl -s https://api.github.com/repos/MetaCubeX/mihomo/releases | jq -r '.[] | select(.tag_name | test("Prerelease-Alpha")) | .assets[] | select(.name | test("mihomo-linux-amd64-alpha-.*\\.gz")) | .browser_download_url')"
gunzip mihomo.gz
chmod +x mihomo

# ** ad.mrs **
# antiAD
#去除注释和空行
#保证结尾有换行符
wget -q -O - https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-clash.yaml |
    sed '/^#/d; /^$/d;' |
    sed -e '$a\' >>ad

# AdRules
#转为yaml格式
wget -q -O - https://raw.githubusercontent.com/Cats-Team/AdRules/main/adrules_domainset.txt |
    sed "/^#/d; /^$/d;" |
    sed "s/^/  - '/; s/$/'/" |
    sed -e '$a\' >>ad

# hagezi pro.mini
#转为yaml格式,添加 +.
wget -q -O - https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.mini-onlydomains.txt |
    sed "/^#/d; /^$/d;" |
    sed "s/^/  - '+./; s/$/'/" >>ad
# Xiaomi 跟踪器
wget -q -O - https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.xiaomi.txt |
    sed "/^#/d; /^$/d;" |
    sed "s/^/  - '+./; s/$/'/" >>ad

#合并并去重
cat ad | awk '!seen[$0]++' | sed "/^$/d" >ad.yaml
# 转换为 mrs
./mihomo convert-ruleset domain yaml ad.yaml ad.mrs
# 移动覆盖结果至仓库
mv -f ad.yaml ad.mrs ../nothing/mrs/

# ** DoHdomains.mrs **
wget -q -O - https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/doh-onlydomains.txt |
    sed "/^#/d; /^$/d;" |
    sed "s/^/+./" >>DoHdomains.text
./mihomo convert-ruleset domain text DoHdomains.text DoHdomains.mrs
mv -f DoHdomains.text DoHdomains.mrs ../nothing/mrs/

# ** tif.mrs **
wget -q -O - https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/tif-onlydomains.txt |
    sed "/^#/d; /^$/d;" |
    sed "s/^/+./" >>tif.text
./mihomo convert-ruleset domain text tif.text tif.mrs
mv -f tif.text tif.mrs ../nothing/mrs/

# ** cn.mrs **
for url in \
    https://github.com/MetaCubeX/meta-rules-dat/raw/meta/geo/geosite/cn.list \
    https://github.com/MetaCubeX/meta-rules-dat/raw/meta/geo/geosite/steam@cn.list \
    https://github.com/MetaCubeX/meta-rules-dat/raw/meta/geo/geosite/microsoft@cn.list \
    https://github.com/MetaCubeX/meta-rules-dat/raw/meta/geo/geosite/google@cn.list \
    https://github.com/MetaCubeX/meta-rules-dat/raw/meta/geo/geosite/win-update.list \
    https://github.com/MetaCubeX/meta-rules-dat/raw/meta/geo/geosite/private.list; do
    wget -q -O - "$url" | sed -e '$a\' >>cn
done
cat cn | awk '!seen[$0]++' | sed "/^$/d" >cn.text
./mihomo convert-ruleset domain text cn.text cn.mrs
mv -f cn.text cn.mrs ../nothing/mrs/

# ** cnIP.mrs **
for url in \
    https://github.com/MetaCubeX/meta-rules-dat/raw/meta/geo/geoip/cn.list \
    https://github.com/MetaCubeX/meta-rules-dat/raw/meta/geo/geoip/private.list; do
    wget -q -O - "$url" | sed -e '$a\' >>cnIP
done
cat cnIP | awk '!seen[$0]++' | sed "/^$/d" >cnIP.text
./mihomo convert-ruleset ipcidr text cnIP.text cnIP.mrs
mv -f cnIP.text cnIP.mrs ../nothing/mrs/

# ** hijacking.yaml **
for url in \
    https://github.com/blackmatrix7/ios_rule_script/raw/master/rule/Clash/Hijacking/Hijacking_No_Resolve.yaml; do
    wget -q -O - "$url" | sed '/^#/d; /^$/d;' | sed -e '$a\' >>hijacking
done
# 追加yaml列表内容至hijacking末尾
cat <<EOF >>hijacking
  - PROCESS-NAME-REGEX,(?i)(antifraud|hicore)
  - DOMAIN-KEYWORD,96110
  - DOMAIN-KEYWORD,fqzpt
  - DOMAIN-KEYWORD,fzlmn
  - DOMAIN-KEYWORD,chanct
  - DOMAIN-KEYWORD,fanzha
  - DOMAIN-KEYWORD,gjfzpt
  - DOMAIN-KEYWORD,ifcert
  - DOMAIN-KEYWORD,hicore
  - DOMAIN-KEYWORD,bestmind
  - DOMAIN-KEYWORD,hei-tong
  - DOMAIN-KEYWORD,appbushou
  - DOMAIN-KEYWORD,loongteam
  - DOMAIN-KEYWORD,himindtech
  - DOMAIN-KEYWORD,tendyron
  - DOMAIN-SUFFIX,f3322.net
  - DOMAIN-SUFFIX,cert.org.cn
  - DOMAIN-SUFFIX,cnvd.org.cn
  - DOMAIN-SUFFIX,certlab.org
  - DOMAIN-SUFFIX,anva.org.cn
  - DOMAIN-SUFFIX,fhss.com.cn
  - DOMAIN-SUFFIX,hailiangyun.cn
  - DOMAIN-SUFFIX,ics-cert.org.cn
  - IP-CIDR,36.135.82.110/32,no-resolve
  - IP-CIDR,39.102.194.95/32,no-resolve
  - IP-CIDR,61.135.15.244/32,no-resolve
  - IP-CIDR,61.160.148.90/32,no-resolve
  - IP-CIDR,101.35.177.86/32,no-resolve
  - IP-CIDR,106.74.25.198/32,no-resolve
  - IP-CIDR,112.15.232.43/32,no-resolve
  - IP-CIDR,124.236.16.201/32,no-resolve
  - IP-CIDR,157.148.47.204/32,no-resolve
  - IP-CIDR,182.43.124.6/32,no-resolve
  - IP-CIDR,211.137.117.149/32,no-resolve
  - IP-CIDR,211.139.145.129/32,no-resolve
  - IP-CIDR,219.143.187.136/32,no-resolve
  - IP-CIDR,221.180.160.221/32,no-resolve
  - IP-CIDR,221.228.32.13/32,no-resolve
  - IP-CIDR,223.75.236.241/32,no-resolve
EOF
cat hijacking | awk '!seen[$0]++' | sed "/^$/d" >hijacking.yaml
mv -f hijacking.yaml ../nothing/mrs/

# ** 完事提交修改 **
cd ../nothing/
git config --local user.email "actions@github.com"
git config --local user.name "GitHub Actions"
git pull origin main
git add ./mrs/*
git commit -m "$(date '+%Y-%m-%d %H:%M:%S') 更新mrs规则" || true
