#!/usr/bin/env groovy

// https://groups.google.com/forum/#!topic/job-dsl-plugin/BT8nEeLoBps

import jenkins.model.GlobalConfiguration
import javaposse.jobdsl.plugin.GlobalJobDslSecurityConfiguration

config = GlobalConfiguration.all().get(GlobalJobDslSecurityConfiguration.class)
config.useScriptSecurity=false
config.save()
