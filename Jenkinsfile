pipeline {
    agent none

    options {
        timestamps()
        timeout(time: 8, unit: 'HOURS')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '1'))
    }

    environment {
        VCPKG_ROOT = 'vcpkg'
        VCPKG_DISABLE_METRICS = '1'
    }

    stages {
        stage('Build') {
            parallel {
                stage('Windows') {
                    agent {
                        label 'windows11'
                    }

                    tools {
                        git 'Default'
                    }

                    environment {
                        VCPKG_TRIPLET = 'x64-windows'
                        VCPKG_EXPORT_DIR = 'windows-x64'
                    }

                    stages {
                        stage('Windows: Clean') {
                            steps {
                                bat '''
                                    if exist "%VCPKG_ROOT%" rmdir /s /q "%VCPKG_ROOT%"
                                    if exist "vcpkg_installed" rmdir /s /q "vcpkg_installed"
                                    if exist "%VCPKG_EXPORT_DIR%" rmdir /s /q "%VCPKG_EXPORT_DIR%"
                                '''
                            }
                        }

                        stage('Windows: Bootstrap vcpkg') {
                            steps {
                                dir('vcpkg'){
                                    checkout scmGit(branches: [[name: '*/master']], extensions: [cloneOption(depth: 1, noTags: true, reference: '', shallow: true)], gitTool: 'Default', userRemoteConfigs: [[url: 'https://github.com/microsoft/vcpkg.git']])
                                }
                                bat '"%VCPKG_ROOT%\\bootstrap-vcpkg.bat" -disableMetrics'
                            }
                        }

                        stage('Windows: Install packages') {
                            steps {
                                bat '"%VCPKG_ROOT%\\vcpkg.exe" install --triplet %VCPKG_TRIPLET% --x-install-root=vcpkg_installed --keep-going'
                            }
                        }

                        stage('Windows: Export packages') {
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

                stage('Linux') {
                    agent {
                        label 'built-in'
                    }

                    tools {
                        git 'Default'
                    }

                    environment {
                        VCPKG_TRIPLET = 'x64-linux'
                        VCPKG_EXPORT_DIR = 'linux-x64'
                        PBUILDER_BASETGZ = '/var/cache/pbuilder/base-trixie-amd64.tgz'
                        // The pbuilder chroot is thrown away after every build, so keep the
                        // vcpkg binary cache outside of it (and outside of the workspace).
                        VCPKG_BINARY_CACHE = "${env.WORKSPACE}@vcpkg-cache"
                    }

                    stages {
                        stage('Linux: Clean') {
                            steps {
                                sh 'rm -rf "$VCPKG_ROOT" vcpkg_installed "$VCPKG_EXPORT_DIR"'
                            }
                        }

                        stage('Linux: Checkout vcpkg') {
                            steps {
                                dir('vcpkg'){
                                    checkout scmGit(branches: [[name: '*/master']], extensions: [cloneOption(depth: 1, noTags: true, reference: '', shallow: true)], gitTool: 'Default', userRemoteConfigs: [[url: 'https://github.com/microsoft/vcpkg.git']])
                                }
                            }
                        }

                        stage('Linux: Build in pbuilder') {
                            steps {
                                sh '''
                                    mkdir -p "$VCPKG_BINARY_CACHE"
                                    sudo -n pbuilder execute \\
                                        --basetgz "$PBUILDER_BASETGZ" \\
                                        --use-network yes \\
                                        --bindmounts "$WORKSPACE $VCPKG_BINARY_CACHE" \\
                                        -- "$WORKSPACE/linux-build.sh" \\
                                            "$WORKSPACE" "$VCPKG_BINARY_CACHE" \\
                                            "$VCPKG_TRIPLET" "$VCPKG_EXPORT_DIR" \\
                                            "$(id -u)" "$(id -g)"
                                '''
                            }
                        }
                    }

                    post {
                        success {
                            archiveArtifacts artifacts: "${VCPKG_EXPORT_DIR}/*.zip", fingerprint: true
                        }
                    }
                }
            }
        }
    }
}
