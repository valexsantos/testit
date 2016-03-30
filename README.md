# TestIt
TestIt - Redmine Test Management plugin

## Introduction

TODO

## Installation and Setup

**This plugin is for Redmine 3.2 and up.**

* Follow the Redmine plugin installation steps at: www.redmine.org/wiki/redmine/Plugins
* Clone the plugin into the plugins directory
```
  cd #{RAILS_ROOT}/plugins
  git clone https://github.com/valexsantos/testit
```
* Run the migrations
```
rake redmine:plugins:migrate
```
* Restart your Redmine web server
* Enable the 'Test suite', 'Test case', 'Test plan' and 'Test run' trackers and the plugin on project settings tab
* Configure the TestIt trackers map on project -> settings -> testit

## User guide

TODO

## About

This plugin is licensed under the GNU GPL v3. See [LICENSE](https://github.com/valexsantos/testit/blob/master/LICENSE) for details.

