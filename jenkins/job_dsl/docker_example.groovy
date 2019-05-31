pipelineJob("docker-example") {
    description "Build and deploy go-http-sample"
    keepDependencies false
    disabled false
    concurrentBuild false

    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url("https://github.com/danielpoonwj/go-http-sample.git")
                    }
                    branch("master")
                }
            }
            scriptPath "Jenkinsfile"
        }
    }
}
