plugins {
    id("com.android.application") version "8.7.0" apply false
    id("com.google.gms.google-services") version "4.3.15" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Force consistent versions for AGP and Google Services
subprojects {
    afterEvaluate {
        configurations.all {
            resolutionStrategy {
                force("com.android.tools.build:gradle:8.7.0") // Force AGP 8.7.0
                force("com.google.gms:google-services:4.3.15") // Force Google Services 4.3.15
            }
        }
    }
}

// Custom build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}