pipeline {
  agent any
  options { timestamps() }
  environment {
    AWS_REGION      = 'ap-northeast-2'
    TF_STATE_BUCKET = "${TF_STATE_BUCKET}"
    TF_LOCK_TABLE   = "${TF_LOCK_TABLE}"
  }
  parameters {
    choice(name: 'ENV', choices: ['dev','stage','prod'], description: '배포 환경 선택')
    booleanParam(name: 'APPLY', defaultValue: false, description: '실제 반영(Apply) 실행 여부')
    string(name: 'TF_STATE_BUCKET', defaultValue: 'my-tfstate-bucket', description: 'S3 버킷 이름')
    string(name: 'TF_LOCK_TABLE',  defaultValue: 'terraform-lock',     description: 'DynamoDB 락 테이블')
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Terraform Fmt & Validate') {
      steps {
        sh '''
          cd live/${ENV}/network
          terraform fmt -check -recursive || true
          terraform init -input=false -reconfigure \
            -backend-config="bucket=${TF_STATE_BUCKET}" \
            -backend-config="key=network/${ENV}/terraform.tfstate" \
            -backend-config="region=${AWS_REGION}" \
            -backend-config="dynamodb_table=${TF_LOCK_TABLE}" \
            -backend-config="encrypt=true"
          terraform validate
        '''
      }
    }
    stage('Plan') {
      steps {
        sh '''
          cd live/${ENV}/network
          terraform plan \
            -var-file="${ENV}.tfvars" \
            -out=tfplan
        '''
      }
    }
    stage('Apply (manual)') {
      when { expression { return params.APPLY == true } }
      steps {
        sh '''
          cd live/${ENV}/network
          terraform apply -auto-approve tfplan
        '''
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: "live/**/network/tfplan", fingerprint: true, onlyIfSuccessful: false
    }
  }
}
