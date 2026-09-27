pipeline {
    agent {
        label 'windows10'
    }

    options {
        timestamps()
        timeout(time: 8, unit: 'HOURS')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '1'))
    }

    tools{
        git 'Default'
    }

    environment {
        VCPKG_ROOT = 'vcpkg'
        VCPKG_TRIPLET = 'x64-windows'
        VCPKG_EXPORT_DIR = 'windows-x64'
        VCPKG_DISABLE_METRICS = '1'
    }

    stages {
        stage('Clean') {
            steps {
                bat '''
                    if exist "%VCPKG_ROOT%" rmdir /s /q "%VCPKG_ROOT%"
                    if exist "vcpkg_installed" rmdir /s /q "vcpkg_installed"
                    if exist "%VCPKG_EXPORT_DIR%" rmdir /s /q "%VCPKG_EXPORT_DIR%"
                '''
            }
        }

        stage('Bootstrap vcpkg') {
            steps {
                bat 'git clone --depth 1 https://github.com/microsoft/vcpkg.git "%VCPKG_ROOT%"'
                bat '"%VCPKG_ROOT%\\bootstrap-vcpkg.bat" -disableMetrics'
            }
        }

        stage('Install packages') {
            steps {
                bat '"%VCPKG_ROOT%\\vcpkg.exe" install --triplet %VCPKG_TRIPLET% --x-install-root=vcpkg_installed --keep-going'
            }
        }

        stage('Export packages') {
            steps {
                bat 'mkdir "%VCPKG_EXPORT_DIR%"'
                bat '"%VCPKG_ROOT%\\vcpkg.exe" export --triplet %VCPKG_TRIPLET% --x-install-root=vcpkg_installed --zip --output-dir=%VCPKG_EXPORT_DIR%'
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: "${VCPKG_EXPORT_DIR}/*.zip", fingerprint: true
        }
    }
}
