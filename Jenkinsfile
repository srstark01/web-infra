pipeline {
  agent { label 'infra' } // node with terraform, tflint, (optional) checkov
  options {
    timestamps(); disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '30')); ansiColor('xterm')
  }

  // ---------- Adjust these for your repo/OCI ----------
  environment {
    TERRAFORM_DIR       = 'terraform'
    TF_IN_AUTOMATION    = 'true'
    TF_PLUGIN_CACHE_DIR = "${WORKSPACE}/.terraform.d/plugin-cache"
    TF_WORKSPACE        = 'dev' // set via job defaults or branch mapping
    // files/paths considered "infra" changes
    INFRA_PATHS         = '^terraform/|\\.tf$|\\.tfvars$|^modules/|^env/|^scripts/terraform/'
    // Backend (OCI Object Storage)
    OCI_REGION          = 'us-phoenix-1'
    TFSTATE_BUCKET      = 'web-infra-tfstate'     // OCI bucket name
    TFSTATE_NAMESPACE   = 'mytenancynamespace'    // OCI tenancy namespace
    TFSTATE_PREFIX      = 'web-infra'             // folder/prefix inside bucket
  }

  parameters {
    choice(name: 'TF_ACTION', choices: ['auto','plan','apply','destroy'],
           description: 'auto => PR=plan, main=apply. Use to override.')
    booleanParam(name: 'AUTO_APPROVE_APPLY', defaultValue: true,
                 description: 'Skip manual approval on main')
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        sh 'mkdir -p "$TF_PLUGIN_CACHE_DIR"'
        sh 'git log -1 --pretty=oneline'
      }
    }

    stage('Prep OCI Auth & Backend Config') {
      steps {
        withCredentials([
          file(credentialsId: 'oci-config', variable: 'OCI_CONFIG_FILE') // your ~/.oci/config
        ]) {
          sh '''
            mkdir -p ~/.oci
            cp "$OCI_CONFIG_FILE" ~/.oci/config
            chmod 600 ~/.oci/config
          '''
        }
        script {
          // Compose a unique state key per workspace (and branch if you prefer)
          env.TFSTATE_KEY = "${TFSTATE_PREFIX}/${TF_WORKSPACE}/terraform.tfstate"
          echo "OCI tfstate key: ${env.TFSTATE_KEY}"
        }
      }
    }

//     stage('Detect Infra Changes') {
//       steps {
//         script {
//           def diffRange = env.CHANGE_ID ? "origin/${env.CHANGE_TARGET}...HEAD" : "HEAD~1..HEAD"
//           echo "Diff range: ${diffRange}"
//           def changed = sh(
//             returnStdout: true,
//             script: """git diff --name-only ${diffRange} | tr -d '\\r' | grep -E '${INFRA_PATHS}' || true"""
//           ).trim()
//           env.INFRA_CHANGED = changed ? 'true' : 'false'
//           echo changed ? "Infra changes detected:\\n${changed}" : 'No infra changes detected.'
//         }
//       }
//     }

//     stage('Lint: Terraform') {
//       when { environment name: 'INFRA_CHANGED', value: 'true' }
//       steps {
//         dir("${TERRAFORM_DIR}") {
//           sh '''
//             terraform fmt -recursive -check
//             if command -v tflint >/dev/null 2>&1; then
//               tflint --init
//               tflint
//             fi
//             if command -v checkov >/dev/null 2>&1; then
//               checkov -d .
//             fi
//           '''
//         }
//       }
//     }

//     stage('Init & Validate (Remote State: OCI)') {
//       when { environment name: 'INFRA_CHANGED', value: 'true' }
//       steps {
//         dir("${TERRAFORM_DIR}") {
//           sh '''
//             terraform --version
//             # Reconfigure backend every run to ensure OCI remote state is used
//             terraform init -reconfigure \
//               -backend-config="region=${OCI_REGION}" \
//               -backend-config="bucket=${TFSTATE_BUCKET}" \
//               -backend-config="namespace=${TFSTATE_NAMESPACE}" \
//               -backend-config="key=${TFSTATE_KEY}"

//             # Workspaces map to per-env state folders (key includes TF_WORKSPACE)
//             terraform workspace list >/dev/null 2>&1 || true
//             if terraform workspace list | grep -q "^\\* ${TF_WORKSPACE}\\b\\| ${TF_WORKSPACE}\\b"; then
//               terraform workspace select "${TF_WORKSPACE}"
//             else
//               terraform workspace new "${TF_WORKSPACE}"
//               terraform workspace select "${TF_WORKSPACE}"
//             fi

//             terraform validate
//           '''
//         }
//       }
//     }

//     stage('Plan') {
//       when {
//         allOf {
//           environment name: 'INFRA_CHANGED', value: 'true'
//           anyOf {
//             expression { params.TF_ACTION in ['auto','plan','apply','destroy'] }
//           }
//         }
//       }
//       steps {
//         dir("${TERRAFORM_DIR}") {
//           sh '''
//             set -e
//             if [ "${TF_ACTION}" = "destroy" ]; then
//               terraform plan -destroy -out=terraform.plan
//             else
//               terraform plan -out=terraform.plan
//             fi
//           '''
//         }
//       }
//       post {
//         always {
//           archiveArtifacts artifacts: "${TERRAFORM_DIR}/terraform.plan", fingerprint: true, onlyIfSuccessful: false
//           sh 'terraform -chdir="${TERRAFORM_DIR}" show -no-color terraform.plan || true'
//         }
//       }
//     }

//     stage('Approval (main apply)') {
//       when {
//         allOf {
//           environment name: 'INFRA_CHANGED', value: 'true'
//           branch 'main'
//           anyOf {
//             expression { params.TF_ACTION in ['auto','apply','destroy'] }
//           }
//           expression { !params.AUTO_APPROVE_APPLY }
//         }
//       }
//       steps {
//         timeout(time: 30, unit: 'MINUTES') {
//           input message: "Approve Terraform ${params.TF_ACTION == 'destroy' ? 'DESTROY' : 'APPLY'} to '${env.TF_WORKSPACE}'?"
//         }
//       }
//     }

//     stage('Apply/Destroy') {
//       when {
//         allOf {
//           environment name: 'INFRA_CHANGED', value: 'true'
//           anyOf {
//             expression { params.TF_ACTION == 'apply' }
//             allOf { branch 'main'; expression { params.TF_ACTION == 'auto' } }
//             expression { params.TF_ACTION == 'destroy' }
//           }
//         }
//       }
//       steps {
//         dir("${TERRAFORM_DIR}") {
//           sh '''
//             set -e
//             if [ "${TF_ACTION}" = "destroy" ]; then
//               terraform destroy -auto-approve
//             else
//               terraform apply -auto-approve terraform.plan
//             fi
//           '''
//         }
//       }
//     }

//     stage('No-Op Notice') {
//       when { environment name: 'INFRA_CHANGED', value: 'false' }
//       steps { echo 'Skipping Terraform: no infra-related changes in this commit/PR.' }
//     }
//   }

  post {
    success { echo "Done. Mode=${params.TF_ACTION}, Workspace=${env.TF_WORKSPACE}, Branch=${env.BRANCH_NAME}" }
    failure { echo "Failed. See stages above." }
    always {
      archiveArtifacts allowEmptyArchive: true, artifacts: '''
        **/terraform.tfstate*
        **/.terraform.lock.hcl
        **/*.log
      '''
    }
  }
}
