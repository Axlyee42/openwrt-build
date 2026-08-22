# 将 ImageBuilder 默认 repositories 切换到镜像源 避免下载失败
#OFFICIAL="https://downloads.openwrt.org"
#MIRROR="https://mirrors.cernet.edu.cn/openwrt"
#echo ">>> official failed, switching to mirror"
#BASE_URL="$MIRROR"
#echo "Using BASE_URL = $BASE_URL"
echo "========================================"
echo "Updating repositories.conf"
echo "========================================"
# 恢复默认 repositories
#sed -i "s#${OFFICIAL}#${BASE_URL}#g" repositories.conf
cat repositories.conf
