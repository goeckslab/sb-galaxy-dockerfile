#!/usr/bin/env bash

# mapping of env vars to galaxy config
# "galaxy:something" gets inserted into galaxy.yml as
# galaxy:
#   something: '<literal value of env var>'
declare -A env_var_to_conf_entry=( \
  ["PROXY_PREFIX"]="galaxy:galaxy_url_prefix" \
)

# where we keep our headings
declare -A hashmap

# for each env var in our mapping:
# - get the value
# - split it by ':'
# - add it to appropriate heading section
for env_var in "${!env_var_to_conf_entry[@]}"
do
  env_var_val=${!env_var}
  if [ -n "$env_var_val" ]; then
    conf_entry=${env_var_to_conf_entry[$env_var]}
    heading="$(echo $conf_entry | awk -F':' '{print $1}')"
    key="$(echo $conf_entry | awk -F':' '{print $2}')"

    #ensure heading variable exists
    if [ -z ${!heading} ] && [ -n $key ]; then
      declare -a $heading
    fi
    hashmap[$heading]+="$key: '$env_var_val'\n"
  fi
done

# create the string that will be put into the galaxy config
yaml_string="\n"
for key in ${!hashmap[@]}
do
  yaml_string+="$key:\n"
  readarray -t <<<$(echo -e ${hashmap[$key]}) array
  IFS=$'\n' sorted=($(sort <<<"${array[*]}"))
  unset IFS
  for entry in "${sorted[@]}"
  do
    yaml_string+="  $entry\n"
  done
  yaml_string+="\n"
done
# map env vars to galaxy config parameters
if [ -n "$yaml_string" ]; then
  echo -e "$yaml_string" >> /galaxy/config/galaxy.yml
fi

# actually start galaxy server
source .venv/bin/activate && galaxyctl start && galaxyctl follow