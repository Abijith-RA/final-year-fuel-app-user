allprojects {
    repositories {
        google() // ✅ Required for Firebase services
        mavenCentral()
    }
}

// ✅ Ensure proper build directory structure
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Ensure Firebase plugin is applied correctly
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// ✅ Apply Google Services (Required for Firebase Authentication)
apply(plugin = "com.google.gms.google-services")
