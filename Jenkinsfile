pipeline {
  agent any
  options { timestamps() }

  environment {
    AWS_REGION = 'ap-northeast-2'
    // ❌ 여기에 TF_STATE_BUCKET/TF_LOCK_TABLE 넣지 마세요 (파라미터를 덮어씀)
  }

  parameters {
    // 원하시는 순서대로
    choice(name: 'ENV', choices: ['prod','dev','stage'], description: '배포 환경 선택')
    booleanParam(name: 'APPLY', defaultValue: false, description: '실제 반영(Apply) 실행 여부')
    // 기본값은 실제 버킷으로 두면 더 안전
    string(name: 'TF_STATE_BUCKET', defaultValue: 'tfstate-363714837532-apne2', description: 'S3 버킷 이름')
    string(name: 'TF_LOCK_TABLE',  defaultValue: 'terraform-lock',              description: 'DynamoDB 락 테이블')
  }

  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Terraform Fmt & Validate') {
      steps {
        sh '''
          set -e
          # ENV -> 디렉터리 매핑 (폴더명을 01/02/03으로 바꿨을 때만 필요)
          case "${ENV}" in
            prod)  ENV_DIR=01-prod ;;
            dev)   ENV_DIR=02-dev  ;;
            stage) ENV_DIR=03-stage ;;
            *)     echo "Unknown ENV=${ENV}" ; exit 1 ;;
          esac

          cd "live/${ENV_DIR}/network"

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
          set -e
          case "${ENV}" in
            prod)  ENV_DIR=01-prod ;;
            dev)   ENV_DIR=02-dev  ;;
            stage) ENV_DIR=03-stage ;;
          esac

          cd "live/${ENV_DIR}/network"

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
          set -e
          case "${ENV}" in
            prod)  ENV_DIR=01-prod ;;
            dev)   ENV_DIR=02-dev  ;;
            stage) ENV_DIR=03-stage ;;
          esac

          cd "live/${ENV_DIR}/network"
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
