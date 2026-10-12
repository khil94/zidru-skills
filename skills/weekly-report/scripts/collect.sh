#!/usr/bin/env bash
# 주간보고 원자료를 찍는다. 네 묶음: [PR] [ORPHAN] [DOCS] [TAG]
# 사용법: collect.sh <시작 YYYY-MM-DD> <끝 YYYY-MM-DD> [repos.tsv 경로]
# 의존: git, gh (gh 내장 --jq 를 쓴다. 외부 jq 는 필요 없다)
set -uo pipefail

START=${1:-}
END=${2:-}
REPOS=${3:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/repos.tsv"}
BODY_MAX=15
# commits 를 함께 요청하면 PR 하나가 GraphQL 노드 1만 개를 쓴다. 상한 50만이라 50이 한계다.
PR_LIMIT=40

if [ -z "$START" ] || [ -z "$END" ]; then
  echo "사용법: collect.sh <시작 YYYY-MM-DD> <끝 YYYY-MM-DD> [repos.tsv]" >&2
  exit 2
fi
[ -f "$REPOS" ] || { echo "repos.tsv 없음: $REPOS" >&2; exit 2; }
END_EXCL=$(date -d "$END + 1 day" +%Y-%m-%d) || { echo "날짜 형식 오류: $END" >&2; exit 2; }
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

ME=$(gh api user --jq .login 2>/dev/null) || ME=""
if [ -z "$ME" ]; then
  echo "[WARN] gh 로그인 계정을 읽지 못했다. [PR] 이 비고 기간 내 커밋 전부가 [ORPHAN] 으로 내려온다."
else
  echo "[WHO] $ME"
fi
echo "[WINDOW] $START .. $END"
echo

while IFS=$'\t' read -r raw_path label || [ -n "${raw_path:-}" ]; do
  case "${raw_path:-}" in ''|'#'*) continue ;; esac
  dir="${raw_path/#\~/$HOME}"
  if ! git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
    echo "[SKIP] $label ($raw_path) 경로가 없거나 git 저장소가 아니다"; echo; continue
  fi

  echo "===== $label  ($raw_path)"
  git -C "$dir" fetch --all --quiet 2>/dev/null

  search="merged:$START..$END"
  [ -n "$ME" ] && search="$search author:$ME"
  fields=number,title,body,author,baseRefName,mergedAt,mergeCommit,commits

  # ---- [PR] 작성자가 본인이고 기간 내 머지된 PR. 머지일로 창을 직접 지정한다.
  # gh 내장 --jq 는 --arg 를 받지 않는다. 구분 이름은 awk 로 끼운다.
  if [ -n "$ME" ]; then
    ( cd "$dir" && gh pr list --state merged --limit "$PR_LIMIT" --search "$search" --json "$fields" \
        --jq '
          if length == 0 then "[PR] (없음)" else
          (sort_by(.number) | .[] |
            "[PR] #\(.number) \(.author.login) ->\(.baseRefName) merged=\(.mergedAt[0:10])",
            "     제목: \(.title)",
            ( (.body // "") | gsub("\r";"") | split("\n")
              | map(select(test("[^[:space:]]"))) as $b
              | if ($b|length) == 0 then ["     본문: (없음)"]
                else ["     본문:"] + ($b[0:'"$BODY_MAX"'] | map("       | " + .))
                     + (if ($b|length) > '"$BODY_MAX"' then ["       | ...(\($b|length - '"$BODY_MAX"')줄 더)"] else [] end)
                end
              | .[] ),
            "     커밋:",
            ( .commits[]? | "       - " + (.messageHeadline // "") )
          ) end' 2>/dev/null \
      | awk -v L="$label" '{ sub(/^\[PR\]/, "[PR] " L); print }' > "$tmp" ) \
      || echo "[PR] (조회 실패)"
    cat "$tmp"
    n=$(grep -c '^\[PR\].* #' "$tmp" || true)
    [ "${n:-0}" -ge "$PR_LIMIT" ] && \
      echo "[WARN] PR 이 상한 $PR_LIMIT 건에 닿았다. 창이 잘렸을 수 있으니 기간을 쪼개 다시 돌린다."
  else
    echo "[PR] (gh 미로그인)"
  fi
  echo

  # ---- [ORPHAN] 기간 내 본인 커밋 중 위 PR 들에 속하지 않는 것
  known=""
  if [ -n "$ME" ]; then
    known=$( cd "$dir" && gh pr list --state merged --limit "$PR_LIMIT" --search "$search" \
      --json commits,mergeCommit --jq '.[] | (.commits[]?.oid), (.mergeCommit.oid // empty)' 2>/dev/null )
  fi
  email=$(git -C "$dir" config user.email 2>/dev/null)
  orphan=0
  while IFS=$'\t' read -r sha rest; do
    [ -z "${sha:-}" ] && continue
    if [ -z "$known" ] || ! grep -qx -- "$sha" <<<"$known"; then
      [ "$orphan" -eq 0 ] && echo "[ORPHAN] $label"
      echo "     $rest  ($(cut -c1-7 <<<"$sha"))"
      orphan=$((orphan + 1))
    fi
  done < <(git -C "$dir" log --all --no-merges \
            ${email:+--author="$email"} \
            --since="${START}T00:00:00+09:00" --until="${END_EXCL}T00:00:00+09:00" \
            --pretty='%H%x09%ad %an%x09%s' --date=format:'%m-%d %H:%M' 2>/dev/null)
  [ "$orphan" -eq 0 ] && echo "[ORPHAN] (없음)"
  echo

  # ---- [DOCS] 기간 내 수정된 docs/ qa/ 파일. 추적 여부는 따지지 않는다.
  docs=0
  for sub in docs qa; do
    [ -d "$dir/$sub" ] || continue
    while IFS= read -r f; do
      [ "$docs" -eq 0 ] && echo "[DOCS] $label"
      echo "     ${f#"$dir"/}  ($(date -r "$f" +'%m-%d %H:%M'))"
      docs=$((docs + 1))
    done < <(find "$dir/$sub" -type f -newermt "$START" ! -newermt "$END_EXCL" 2>/dev/null | sort)
  done
  [ "$docs" -eq 0 ] && echo "[DOCS] (없음)"
  echo

  # ---- [TAG] 기간 내 배포 태그. 태그를 쓰지 않는 저장소는 조용히 빈다.
  tags=$(git -C "$dir" for-each-ref --sort=creatordate \
          --format='%(refname:short)%09%(creatordate:format:%Y-%m-%d %H:%M)' refs/tags 2>/dev/null \
          | awk -F'\t' -v s="$START" -v e="$END" '{d=substr($2,1,10); if (d>=s && d<=e) printf "     %s  %s\n", $1, $2}')
  if [ -n "$tags" ]; then echo "[TAG] $label"; echo "$tags"; else echo "[TAG] (없음)"; fi
  echo
done < "$REPOS"
