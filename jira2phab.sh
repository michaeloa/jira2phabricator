## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## 
## JIRA to Phabricator migration script
##
## Copyright (C) 2014 met.no
##
##  Contact information:
##  Norwegian Meteorological Institute
##  Box 43 Blindern
##  0313 OSLO
##  NORWAY
##  E-mail: @met.no
##
##  This is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#!/bin/bash

CERT="ENTER-CONDUIT-CERTIFICATE"
PHAB="ENTER-PHAB-URL"
USER="ENTER-USER-NAME"
PROJ="ENTER-PROJECT-NAME"
lbls="BORA Requirements: "

read_dom () {
  local IFS=\>
  read -d \< ENTITY CONTENT
  local ret=$?
  TAG_NAME=${ENTITY%% *}
  ATTRIBUTES=${ENTITY#* }
  return $ret
}

parse_dom () {
  if [[ $TAG_NAME = "title" ]] ; then
    eval local $ATTRIBUTES
    #echo "Title: $CONTENT"
   TID=`arcyon task-create --uri $PHAB --user $USER --cert $CERT --projects "$PROJ" --format-id "$CONTENT"`
    echo $TID
  elif [[ $TAG_NAME = "description" ]] ; then
    eval local $ATTRIBUTES
    desc=$(echo $CONTENT | sed 's/&lt;br\/&gt;/\\n/g' | sed 's/&lt;\/p&gt;/\\n\\n/g' | sed 's/&lt;p&gt;//g' )
  elif [[ $TAG_NAME = "customfieldname" ]] ; then
    # This is used to grab a custom field Requirement
    eval local $ATTRIBUTES
    if [[ $CONTENT = "Requirement" ]] ; then
	    REQ="req"
    fi
  elif [[ $TAG_NAME = "label" ]] ; then
    eval local $ATTRIBUTES
    if [[ $REQ = "req" ]] ; then
	    lbls="$lbls $CONTENT,"
    fi
  elif [[ $TAG_NAME = "/customfieldvalues" ]] ; then
	  REQ="false"
  elif [[ $TAG_NAME = "comment" ]] ; then
    eval local $ATTRIBUTES
    ENTRY="On $created, @$author wrote:\n\n$CONTENT"
    com=$(echo $ENTRY | sed 's/&lt;br\/&gt;/\\n/g' | sed 's/&lt;\/p&gt;/\\n\\n/g' | sed 's/&lt;p&gt;//g' | sed 's/&lt;[^>]\+&quot;&gt;//g' | sed 's/&lt;\/a&gt;//g' | sed 's/&apos;/\"/g' )
    #echo -e $com
    arcyon task-update --uri $PHAB --user $USER --cert $CERT $TID --comment "$(echo -e $com)"
  elif [[ $TAG_NAME = "/item" ]] ; then
	  if [[ $lbls != "BORA Requirements: " ]] ; then
      desc=$(echo "$desc$lbls" | sed 's/,\+$//' )
    fi
	  #echo -e "Description:\n$desc"
    arcyon task-update --uri $PHAB --user $USER --cert $CERT $TID --description "$(echo -e $desc)"
  fi
}

while read_dom; do
  parse_dom
done
