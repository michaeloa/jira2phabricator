jira2phabricator
================

Basic shell script to convert Jira XML to Phabricator tasks.

Script needs access to arcyon (github.com/bloomberg/phabricator-tools) to run.

It takes an XML file, as exported from Jira, and puts the contents into Phabricaotr through conduit/arcyon. The header of the XML file should be removed first (it contains a title entry which will confuse the script).

Usage:

  cat jira.xml | jira2phab.sh

Known issues:

- apostrophe &apos; should be converted in title and description/comments.
- Doesn't work with æ, ø, å
