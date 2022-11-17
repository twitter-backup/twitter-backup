#/bin/bash

# works only when gh is installed and `gh auth login` was performed 
# sudo apt install gh

SOURCE_ORG=twitter
TARGET_ORG=twitter-backup
SLEEP_TIME_IN_SECONDS=30

# TODO: result from this command are broken
# gh repo list ${TARGET_ORG} --fork --json name -q '.[] | [.name][0]'


list_repos() {
    gh api orgs/$1/repos --paginate \
    | jq '.[] | [.url][0] ' \
    | sed -e's,"https://api.github.com/repos/,,' -e's,",,' -e"s,$1/,," \
    | sort \
    | grep -v ".github"
    
} 

wait_some_time() {
    echo "sleeping for ${SLEEP_TIME_IN_SECONDS} seconds in order to avoid getting killed by GitHub API restrictions ..."
    sleep ${SLEEP_TIME_IN_SECONDS}
}

echo "==> Checking for repositories that are already forked"

forked_repos=$(list_repos ${TARGET_ORG})
echo ${forked_repos}

echo
echo "==> Fetching list of repositories"

source_repos=$(list_repos ${SOURCE_ORG})
echo ${source_repos}

echo
echo "==> starting forking"
missing_repos=$(echo ${source_repos[@]} ${forked_repos[@]} | sed 's/ /\n/g' | sort | uniq -u)

for repo in ${missing_repos}; do 
    echo "--> forking ${repo}"
    gh repo fork ${SOURCE_ORG}/${repo} --clone --org ${TARGET_ORG} && wait_some_time
    rm -rf $(basename ${repo})    
done
