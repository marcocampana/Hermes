#!/usr/bin/env bash
INSTALL_DIR=`pwd`
TIMESTAMP=`date +%Y%m%d%H%M%S`
LOGFILE=$INSTALL_DIR/install-$TIMESTAMP.log
TEMP_MANIFEST=/tmp/$USER-hermes_custom_manifest
touch $TEMP_MANIFEST

function log () {
  echo -e $@ >> $LOGFILE
}

function handle_error () {
  if [ "$?" != "0" ]; then
    echo -e "$2 $1"
    exit 1
  fi
}

function customise_manifest () {
  CONTENT=`cat $INSTALL_DIR/dotfile_manifest`
  for file in $CONTENT; do
    if [ -e $HOME/.$file ]
      then
        echo "$HOME/.$file" >> $TEMP_MANIFEST
    fi
  done
}

}

function check_command_dependency () {
  $1 --version &> /dev/null
  handle_error $1 'There was a problem with:'
}

function install_dependency () {
  log "Checking for the presence of $1"
  HOMEBREW_OUTPUT=`brew install $1 2>&1`
  handle_error $1 "Homebrew had a problem\n($HOMEBREW_OUTPUT):"
}

function backup_dotfiles () {
  customise_manifest
  cd $HOME
  tar zcvf $INSTALL_DIR/dotfile_backup-$TIMESTAMP.tar.gz -I $TEMP_MANIFEST >> $LOGFILE 2>&1
  handle_error "($?)" "Backup failed, please see the install log for details"
}

function homebrew_dependencies () {
  while read recipe; do
    echo "Installing recipe $recipe"
    install_dependency $recipe
  done < "$INSTALL_DIR/homebrew_dependencies"
}

log "Starting Hermes installation"

backup_dotfiles

# Check for dependencies
check_command_dependency brew
check_command_dependency rvm

homebrew_dependencies
