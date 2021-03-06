asdf_version() {
  echo "0.1"
}


asdf_dir() {
  if [ -z $ASDF_DIR ]; then
    local current_script_path=${BASH_SOURCE[0]}
    export ASDF_DIR=$(cd $(dirname $(dirname $current_script_path)); echo $(pwd))
  fi

  echo $ASDF_DIR
}


get_install_path() {
  local plugin=$1
  local install_type=$2
  local version=$3
  mkdir -p $(asdf_dir)/installs/${plugin}

  if [ $install_type = "version" ]
  then
    echo $(asdf_dir)/installs/${plugin}/${version}
  else
    echo $(asdf_dir)/installs/${plugin}/${install_type}-${version}
  fi
}


check_if_plugin_exists() {
  if [ ! -d $1 ]
    then
    display_error "No such plugin"
    exit 1
  fi
}


get_version_part() {
  IFS='@' read -a version_info <<< "$1"
  echo ${version_info[$2]}
}


get_plugin_path() {
  echo $(asdf_dir)/plugins/$1
}


display_error() {
  echo $1
}


get_asdf_versions_file_path() {
  local asdf_tool_versions_path=""
  local search_path=$(pwd)

  while [ "$search_path" != "/" ]; do
    if [ -f "$search_path/.tool-versions" ]; then
      asdf_tool_versions_path="$search_path/.tool-versions"
      break
    fi
    search_path=$(dirname "$search_path")
  done

  echo $asdf_tool_versions_path
}


get_preset_version_for() {
  local tool_name=$1
  local asdf_versions_path=$(get_asdf_versions_file_path)
  local matching_tool_version=""

  if [ "$asdf_versions_path" != "" ]; then
    matching_tool_version=$(get_tool_version_from_file $asdf_versions_path $tool_name)
  fi


  # If there's no global .tool-versions file
  # then we create it and return blank
  if [ "$matching_tool_version" = "" ]; then
    local global_tool_versions_path=$HOME/.tool-versions
    if [ ! -f $global_tool_versions_path ]; then
      touch $global_tool_versions_path
    else
      matching_tool_version=$(get_tool_version_from_file $global_tool_versions_path $tool_name)
    fi
  fi


  echo $matching_tool_version
}


get_tool_version_from_file() {
  local asdf_versions_path=$1
  local tool_name=$2
  local matching_tool_version=""

  local read_done=false
  until $read_done; do
    read tool_line || read_done=true

    if $read_done ; then
      break;
    fi

    IFS=' ' read -a tool_info <<< $tool_line
    local t_name=$(echo "${tool_info[0]}" | xargs)
    local t_version=$(echo "${tool_info[1]}" | xargs)

    if [ "$t_name" = "$tool_name" ]
    then
      matching_tool_version=$t_version
      break;
    fi
  done < $asdf_versions_path

  echo $matching_tool_version
}
