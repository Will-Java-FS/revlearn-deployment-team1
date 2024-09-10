import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.*

def createOrUpdatePipelineJob(
    String jobName,
    String repoUrl,
    String gitCredentialsId,
    String jenkinsfilePath,
    String branchName,
    boolean autoBuild
    ) {
    Jenkins jenkins = Jenkins.instance

    WorkflowJob job = jenkins.getItem(jobName)
    if (job == null) {
        job = jenkins.createProject(WorkflowJob, jobName)
        println("Created job: ${jobName}")
    } else {
        println("Job already exists: ${jobName}")
    }

    UserRemoteConfig config = new UserRemoteConfig(repoUrl, 'origin', null, gitCredentialsId)
    println(config.getCredentialsId())
    // Create GitSCM object
    GitSCM gitSCM = new GitSCM(
        [config], // Pass the UserRemoteConfig object as a single-element list
        [new BranchSpec("*/${branchName}")], // Pass the BranchSpec object as a single-element list
        null, // We're not specifying a GitRepositoryBrowser in this case, so we pass null
        null, // We're not specifying a gitTool in this case, so we pass null
        [] // We're not specifying any GitSCMExtension objects in this case, so we pass an empty list
    )

    CpsScmFlowDefinition scmFlow = new CpsScmFlowDefinition(gitSCM, jenkinsfilePath)

    String description = "Pipeline job for ${jobName}"
    job.setDefinition(scmFlow)
    job.setDisplayName(jobName)
    job.setDescription(description)

    if (autoBuild) {
        // Schedule the job to run immediately
        job.scheduleBuild2(0)
        println("Auto-build triggered for job: ${jobName}")
    }

    job.save()

    println('Job configuration updated successfully.')
}
String baseRepo = 'https://github.com/Will-Java-FS/'
String gitCredentialsId = 'github-api-token'
String jenkinsfilePath = 'Jenkinsfile'
String branchName = 'main'

def jobConfigurations = [
    [
        jobName: 'frontend-pipeline',
        repoUrl: "${baseRepo}/revlearn-frontend-team1.git"
    ],
    [
        jobName: 'backend-pipeline',
        repoUrl: "${baseRepo}/revlearn-backend-team1.git"
    ],
    [
        jobName: 'terraform-pipeline',
        repoUrl: "${baseRepo}/revlearn-deployment-team1.git",
        // autoBuild: true
    ]
]

jobConfigurations.each { config ->
    if (!config.containsKey('autoBuild')) {
        config.autoBuild = false
    }

    createOrUpdatePipelineJob(
        config.jobName,
        config.repoUrl,
        gitCredentialsId,
        jenkinsfilePath,
        branchName,
        config.autoBuild
    )
}
