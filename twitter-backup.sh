#/bin/bash

# works only when gh is installed and `gh auth login` was performed 
# sudo apt install gh

SOURCE=https://api.github.com/orgs/twitter/repos
TARGET_ORG=twitter-backup
SLEEP_TIME_IN_SECONDS=30

# echo "==> Fetching list of repositories"

# curl ${SOURCE} \
#     | jq '.[] | [.url][0] ' \
#     | sed -e's,"https://api.github.com/repos/,,' -e's,",,' > twitter_repos.txt

# gh api orgs/twitter/repos --paginate \ 
#     | jq '.[] | [.url][0] ' \
#     | sed -e's,"https://api.github.com/repos/,,' -e's,",,' 2>&1 | tee twitter_repos.txt

echo "==> starting forking"

wait_some_time() {
    echo "sleeping for ${SLEEP_TIME_IN_SECONDS} seconds in order to avoid getting killed by GitHub API restrictions ..."
    sleep ${SLEEP_TIME_IN_SECONDS}
}

cat twitter_repos.txt | while read repo; do
    echo "forking ${repo}"
    gh repo fork ${repo} --clone --org ${TARGET_ORG} && wait_some_time
    rm -rf $(basename ${repo})    
done