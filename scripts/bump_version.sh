#!/usr/bin/env bash
# ============================================================
# bump_version.sh — 自动更新 module.prop 版本并创建 Git 标签
#
# 用法:
#   ./scripts/bump_version.sh [patch|minor|major]
#   ./scripts/bump_version.sh v2.1.0          # 指定版本
#
# 功能:
#   1. 读取 module.prop 中的 version / versionCode
#   2. 按语义化版本递增（或指定版本号）
#   3. 更新 module.prop 并 commit
#   4. 创建带注释的 Git 标签（包含自上一标签以来的提交信息）
#   5. 推送到远程（含标签）
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROP_FILE="$REPO_ROOT/drcom-wlan-login/module.prop"

# ---------- 颜色 ----------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------- 检查环境 ----------
if [[ ! -f "$PROP_FILE" ]]; then
    err "找不到 $PROP_FILE"
    exit 1
fi

cd "$REPO_ROOT"

# ---------- 读取当前版本 ----------
CURRENT_VERSION=$(grep '^version=' "$PROP_FILE" | cut -d= -f2)
CURRENT_CODE=$(grep '^versionCode=' "$PROP_FILE" | cut -d= -f2)

if [[ -z "$CURRENT_VERSION" ]]; then
    err "无法从 module.prop 读取 version"
    exit 1
fi

# 去掉 v 前缀用于语义版本解析
VER="${CURRENT_VERSION#v}"
IFS='.' read -r MAJOR MINOR PATCH <<< "$VER"
MAJOR=${MAJOR:-0}; MINOR=${MINOR:-0}; PATCH=${PATCH:-0}
CURRENT_CODE=${CURRENT_CODE:-0}

info "当前版本: ${CYAN}$CURRENT_VERSION${NC} (versionCode=$CURRENT_CODE)"

# ---------- 确定新版本 ----------
BUMP_TYPE="${1:-patch}"

case "$BUMP_TYPE" in
    patch)
        PATCH=$((PATCH + 1))
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    v*|V*)
        # 用户指定了完整版本号
        VER="${BUMP_TYPE#v}"
        VER="${VER#V}"
        IFS='.' read -r MAJOR MINOR PATCH <<< "$VER"
        ;;
    *)
        err "用法: $0 [patch|minor|major|vX.Y.Z]"
        exit 1
        ;;
esac

NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
NEW_CODE=$((CURRENT_CODE + 1))

info "新版本: ${GREEN}$NEW_VERSION${NC} (versionCode=$NEW_CODE)"

# ---------- 更新 module.prop ----------
sed -i.bak "s/^version=.*/version=$NEW_VERSION/" "$PROP_FILE"
sed -i.bak "s/^versionCode=.*/versionCode=$NEW_CODE/" "$PROP_FILE"
rm -f "${PROP_FILE}.bak"

ok "已更新 module.prop"

# ---------- 收集自上一标签以来的提交 ----------
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [[ -n "$LAST_TAG" ]]; then
    COMMITS=$(git log "${LAST_TAG}..HEAD" --pretty=format:"- %s (%h)" --no-merges)
else
    COMMITS=$(git log --pretty=format:"- %s (%h)" --no-merges -20)
fi

if [[ -z "$COMMITS" ]]; then
    COMMITS="- 初始版本"
fi

TAG_MSG="$NEW_VERSION

变更内容:
$COMMITS"

# ---------- Git 提交 ----------
git add "$PROP_FILE"
git commit -m "chore: bump version to $NEW_VERSION" --no-verify

ok "已提交 module.prop"

# ---------- 创建标签 ----------
git tag -a "$NEW_VERSION" -m "$TAG_MSG"

ok "已创建标签 $NEW_VERSION"
echo ""
echo -e "${CYAN}── 标签信息 ──${NC}"
echo "$TAG_MSG"
echo -e "${CYAN}──────────────${NC}"
echo ""

# ---------- 推送 ----------
read -p "是否推送到远程？(y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    BRANCH=$(git branch --show-current)
    info "推送 $BRANCH 和标签 $NEW_VERSION ..."
    git push origin "$BRANCH" --tags
    ok "推送完成！GitHub Actions 将自动构建 Release。"
else
    warn "未推送。你可以稍后手动执行:"
    echo "  git push origin $BRANCH --tags"
fi
