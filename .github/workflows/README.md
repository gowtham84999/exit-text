# AzureDevops Pipeline Documentation
**Resources required details**
| Tasks | Tools |
| ----------- | ----------- |
| CI Orchestrator | [Azure DevOps Organisation and Project](https://mnscorp.sharepoint.com/sites/CloudHub/SitePages/Azure-Devops.aspx#how-to-consume) |
| Source code version control | [GitHub](https://github.com/DigitalInnovation/cloud-brokerage/blob/development/README.md#github) |
| Secret Management | [Azure Key Vault](https://github.com/DigitalInnovation/cloud-brokerage/blob/development/README.md#azure-keyvault-integration) |
| Artifacts | [Nexus - Artifacts](https://github.com/DigitalInnovation/cloud-brokerage/blob/development/README.md#nexus-integration---maven-artifact-push) |
| Docker Registry | [Nexus - Docker](https://github.com/DigitalInnovation/cloud-brokerage/blob/development/README.md#nexus-integration---docker-image-push) |
| Code analysis and coverage| [Sonarqube](https://github.com/DigitalInnovation/cloud-brokerage/blob/development/README.md#sonarqube-integration---maven) |
| Build infra template | [cloud-platform-automation-asset](https://github.com/DigitalInnovation/cloud-brokerage/blob/development/README.md#build-infra---load-balancer-creation) |
| Deployment | [Kubernetes](https://github.com/DigitalInnovation/cloud-brokerage/blob/development/README.md#kubernetes-deployment) |


## GitHub
#### Pre-Requisites
1. GitHub Service Connection should be created in Azure Devops. Refer [here](https://mnscorp.sharepoint.com/sites/CloudHub/SitePages/GitHub-Integration.aspx#azure-devops-github) for steps.
#### Steps to be followed
To use mulitiple repositories in a single pipeline, use below code.
```
resources:
  repositories:
  - repository: MyGitHubRepo # The name used to reference this repository in the checkout step
    type: github
    endpoint: MyGitHubServiceConnection  
    name: MyGitHubOrgOrUser/MyGitHubRepo  # Organization / Repository
    ref : branch  # specify Branch to checkout
steps:
- checkout: MyGitHubRepo 
```
## Azure KeyVault Integration
#### Pre-Requisites
1. Key vault 
    - Azure Resource Manager Service connection should be created in Azure Devops. Refer [here](https://mnscorp.sharepoint.com/sites/CloudHub/SitePages/Azure-KeyVault-Integration.aspx#integration-of-azure-key-vault-with-azure-devops) for steps.
    - Y Account should have access to KeyVault with required access(Read and Write)
2. Nexus and SonarQube creds should be created in Azure KeyVault
#### Steps to be followed
In AzureDevops, Azure KeyVault can be integrated by two ways </br>
     1. Using Azure KeyVault task </br>
     2. Using Variable Groups </br>
 In this pipeline we are using Azure KeyVault Task to integrate with Azure Devops.
 ```
 - task: AzureKeyVault@1
      displayName: "Azurekeyvault"
      inputs:
        azureSubscription: '<Service_connection_Name>'
        KeyVaultName: '<KeyVault_Name>'
        SecretsFilter: '<Secrets_you_want_to_use>'
```
#### sed-commands
sed command is used to replace the text in a GitHub file from Azure KeyVault Secret.
Example:
```
steps:
- script: |
    sed -i 's|SonarQube-url|$(SonarQube-url)|g' settings.xml
```
## SonarQube Integration - Maven
#### Pre-Requisites
1. If you are using self-hosting build agents, make sure you have at least the minimum SonarQube-supported version of Java installed.
2. SonarQube Account with Required Access
#### Steps to be followed
Add sonarscanner plugin in your pom.xml file like below,
```
      <plugin>
        <groupId>org.sonarsource.scanner.maven</groupId>
        <artifactId>sonar-maven-plugin</artifactId>
        <version>3.7.0.1746</version>
      </plugin>
```
Configure the settings.xml file like below,
```
    <pluginGroups>
        <pluginGroup>org.sonarsource.scanner.maven</pluginGroup>
    </pluginGroups>
    <profiles>
        <profile>
            <id>sonar</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <sonar.host.url>
                  SonarQube-url
                </sonar.host.url>
                <sonar.username>SonarQube-user</sonar.username>
                <sonar.password>SonarQube-pass</sonar.password>
            </properties>
        </profile>
     </profiles>
```
## Nexus Integration - Maven Artifact push
#### Pre-Requisites
1. Nexus Repository Account with Edit Permission 
2. Nexus creds should be created in Azure KeyVault 
#### Steps to be followed
Add your repository in distributionmanagement of your pom.xml file like below,
```
  <distributionManagement>
    <snapshotRepository>
      <id>maven-snapshots</id>
      <url>Nexus-url</url>
    </snapshotRepository>
  </distributionManagement>
```
Configure the settings.xml file like below,
```
    <server>
      <id>maven-snapshots</id>
      <username>Nexus-user</username>
      <password>Nexus-pass</password>
    </server>
```
## Nexus Integration - Docker Image push
#### Pre-Requisites
1. Nexus Repository Account with Edit Permission 
2. DockerRegistry Service connection should be created with Nexus Creds in Azure Devops
#### Step to be followed
In this pipeline, we have created a Dockerfile and used that in Docker Task like below.
```
    - task: Docker@2
      displayName: "Docker_Build_Push"
      inputs:
        containerRegistry: '<service_connection_name>'
        repository: '<Nexus_Repository>'
        command: 'buildAndPush'
        Dockerfile: '<Dockerfile_path>'
        tags: '<Tag>'
```

## Build infra - Load Balancer Creation
ARM Templates to create a loadbalancer are maintained in the GitHub Repo : [cloud-platform-automation-asset](https://github.com/DigitalInnovation/cloud-platform-automation-assets).
#### Pre-Requisites
1. Azure Resource Manager Service connection should be created in Azure Devops.
2. Virtual Network and Storage Account should be created in your Azure Subscription
3. Input Details needs to maintain in wrapper script.
#### Steps to be followed
- Create a wrapper script with required inputs to execute ARM Templates.
- Clone cloud-platform-automaiton-asset Repo in your Azure Devops pipeline. Refer [here](https://github.com/DigitalInnovation/cloud-brokerage/blob/development/README.md#github) for steps.
## Build infra - Virtual Machine Creation
ARM Templates to create a Virtual Machine are maintained in the GitHub Repo : [cloud-platform-automation-asset](https://github.com/DigitalInnovation/cloud-platform-automation-assets).
#### Resources to be created as part of Virtual Machine Creation
- Storage Account
- Application Security Group
- Network Security group Rules 
- Network Interface
- Virtual Machine
- Data Disks 
- Extensions Installation
- Post Provision Tasks 
#### Pre-Requisites
1. Azure Resource Manager Service connection should be created in Azure Devops.
2. Virtual Network and Subnet should be created in your Azure Subscription
3. Azure Key vault should be in same subscription (Access policies should be created Get,list,Write) 
4. Service Principal added with AD Group (Security recommendation to have service principal included in AD and not to be assigned directly in any Azure resources) should have following permission. 
   - Infrastructure Admins at subscription level (or) Infrastructure Admin at RG, Network ReadWrite at Subscription level 
   - User Access Administrator at subscription level (If Lock needs to be enabled for Storage Account) 
5. NSG should be created already and added in subnet.
6. Azure Recovery Vault should be created already.
#### Steps to be followed
- Clone ARM Templates and Wrapper Scripts in the cloud-platform-automation-asset Repository.
- Prepare inputs for storage account creation and Virtual machine and other resources.
- In this pipeline, to execute powershell and ARM Templates we have used Azure Powershell task like below.
```
- task: AzurePowerShell@5 
  inputs: 
        azureSubscription: 'Non-Prod1' 
        ScriptType: 'FilePath' 
        ScriptPath: '<Wrapper-script>' 
        ScriptArguments:  ‘<Arguments to be passed to Wrapper>’ 
        azurePowerShellVersion: 'LatestVersion' 
```
- Execute Azure pipeline

## Kubernetes Deployment
#### Pre-Requisites
1. [Kubernetes Service connection](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#sep-kuber) should be created in Azure Devops
#### Steps to be followed
In this pipeline, we have created related files to deploy our Docker Image in AKS and used that in kubernetes Task like below,
```
    - task: Kubernetes@1
      inputs:
        connectionType: 'Kubernetes Service Connection'
        kubernetesServiceEndpoint: '<Service_connection_Name>'
        command: 'apply'
        useConfigurationFile: true
        configuration: '<File_path>'
```
