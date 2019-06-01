#!/usr/bin/env groovy

import jenkins.model.Jenkins

Jenkins.instance.setNoUsageStatistics(true)
Jenkins.instance.save()
