# TestIt
TestIt - Redmine Test Management plugin

## Introduction

This is a Test Management plugin for Redmine.

It uses the generic Redmine issue to provide the support for Test cases, grouping then in Test suites and to keep track of the execution status in a Test run.

It also adds the Test plan issue allowing you to manage the test executions in a smaller set.

Mainly, it consists on customized views to simplify the management of the project's Tests.

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

## User manual

TODO

## About

This plugin has Redmine core code inside.

Licensed under the GNU GPL v3. See [LICENSE](https://github.com/valexsantos/testit/blob/master/LICENSE) for details.

Enjoy!

(C) 2016 By Vasco Santos

