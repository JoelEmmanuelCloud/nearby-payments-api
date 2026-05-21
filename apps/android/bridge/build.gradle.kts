plugins {
    alias(libs.plugins.android.library)
}

android {
    namespace = "com.variance.nearby.bridge"
    compileSdk = 36

    defaultConfig {
        minSdk = 30
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    implementation(libs.swiftkit.core)
}

// ── Config from gradle.properties (with Environment Variable fallback) ────────
val swiftlyPath =
    project.findProperty("swift.swiftly.path")?.toString() ?: System.getenv("SWIFTLY_PATH")
    ?: throw GradleException("swift.swiftly.path not set")
val swiftSdkRoot =
    project.findProperty("swift.sdk.path")?.toString() ?: System.getenv("SWIFT_SDK_PATH")
    ?: throw GradleException("swift.sdk.path not set")
val swiftVersion = project.findProperty("swift.version")?.toString() ?: "6.3"
val androidSdkVersion = project.findProperty("swift.android.sdk.version")?.toString()
    ?: "${swiftVersion}-RELEASE_android"
val sdkBundlePath = "${swiftSdkRoot}/swift-${androidSdkVersion}.artifactbundle"
val minSdk = android.defaultConfig.minSdk ?: 30

val repoRoot = project.projectDir.resolve(
    project.findProperty("repo.root")?.toString() ?: throw GradleException("repo.root not set")
)

// ── Swift packages to bridge ──────────────────────────────────────────────────
// Just add the name and relative path here.
val swiftPackages = listOf(
    mapOf("target" to "SwiftHello", "dir" to "packages/hello", "sourcePath" to "Sources/Java")
)

// ── ABI Configuration ────────────────────────────────────────────────────────
val abiList = mapOf(
    "arm64-v8a" to mapOf(
        "triple" to "aarch64-unknown-linux-android${minSdk}",
        "libDir" to "swift-aarch64",
        "ndkDir" to "aarch64-linux-android"
    ),
    "armeabi-v7a" to mapOf(
        "triple" to "armv7-unknown-linux-android${minSdk}",
        "libDir" to "swift-armv7",
        "ndkDir" to "arm-linux-androideabi"
    ),
    "x86_64" to mapOf(
        "triple" to "x86_64-unknown-linux-android${minSdk}",
        "libDir" to "swift-x86_64",
        "ndkDir" to "x86_64-linux-android"
    )
)

// Add this outside the forEach, at the top of the file
abstract class SyncSwiftJavaTask : DefaultTask() {
    @get:InputDirectory
    @get:Optional
    abstract val extractOutput: DirectoryProperty

    @get:OutputDirectory
    abstract val javaOutput: DirectoryProperty

    @TaskAction
    fun sync() {
        val src = extractOutput.orNull?.asFile
        if (src == null || !src.exists()) {
            javaOutput.get().asFile.mkdirs()
            return
        }
        project.sync {
            from(src)
            into(javaOutput)
        }
    }
}

// ── Build & Wire Logic ───────────────────────────────────────────────────────
swiftPackages.forEach { pkg ->
    val target = pkg["target"] ?: return@forEach
    val packageDir = repoRoot.resolve(pkg["dir"] ?: return@forEach)
    val sourcePath = pkg["sourcePath"] ?: "Sources/${target}"
    if (!packageDir.resolve("Package.swift").isFile) {
        throw GradleException("Package.swift not found at ${packageDir.absolutePath}")
    }
    val targetLow = target.lowercase()
    val packageIdentity = packageDir.name.lowercase()

    val jniOutDir = layout.buildDirectory.dir("generated/jniLibs/${targetLow}")
    val extractOutputDir =
        file("${packageDir}/.build/plugins/outputs/${packageIdentity}/${target}/destination/JExtractSwiftPlugin/src/generated/java")


    // Task to build for all ABIs
    val buildAll = tasks.register("buildSwiftAll_${target}") {
        group = "bridge"
        description = "Orchestrates Swift builds and Java generation for $target"
        inputs.file(File(packageDir, "Package.swift"))
        inputs.dir(File(packageDir, sourcePath))
        outputs.dir(extractOutputDir)
    }


    abiList.forEach { (abi, info) ->
        val triple = info["triple"] ?: ""
        val abiTask = tasks.register<Exec>("buildSwift_${target}_${abi}") {
            group = "bridge"
            workingDir = packageDir
            executable = swiftlyPath
            args(
                "run",
                "swift",
                "build",
                "+${swiftVersion}",
                "--swift-sdk",
                triple,
                "--build-system",
                "native"
            )

            outputs.dir(file("${packageDir}/.build/${triple}/debug"))
        }
        buildAll.configure { dependsOn(abiTask) }
    }

    fun requiredFile(description: String, vararg candidates: File): File {
        return candidates.firstOrNull { it.isFile }
            ?: error("$description not found. Checked: ${candidates.joinToString { it.absolutePath }}")
    }

    fun requiredDirectory(description: String, vararg candidates: File): File {
        return candidates.firstOrNull { it.isDirectory }
            ?: error("$description not found. Checked: ${candidates.joinToString { it.absolutePath }}")
    }

    val copyLibs = tasks.register<Copy>("copyJniLibs_${target}") {
        group = "bridge"
        dependsOn(buildAll)

        abiList.forEach { (abi, info) ->
            val triple = info["triple"] ?: ""
            val ndkDir = info["ndkDir"] ?: ""
            val libDir = info["libDir"] ?: ""

            // 1. Built Swift binaries
            from(file("${packageDir}/.build/${triple}/debug")) {
                include("*.so")
                into(abi)
            }

            // 2. NDK C++ shared library
            from(
                requiredFile(
                    "Swift Android C++ runtime",
                    file("${sdkBundlePath}/swift-android/ndk-sysroot/usr/lib/${ndkDir}/libc++_shared.so"),
                    file("${sdkBundlePath}/swift-android/ndk-sysroot/usr/lib/${ndkDir}/${minSdk}/libc++_shared.so"),
                )
            ) {
                into(abi)
            }

            // 3. Swift runtime libraries
            from(
                requiredDirectory(
                    "Swift Android runtime",
                    file("${sdkBundlePath}/swift-android/swift-resources/usr/lib/${libDir}/android")
                )
            ) {
                include("*.so")
                into(abi)
            }
        }
        into(jniOutDir)
    }

    val syncJava = tasks.register<SyncSwiftJavaTask>("syncSwiftJava_${target}") {
        dependsOn(buildAll)
        extractOutput.set(extractOutputDir)
        javaOutput.set(layout.buildDirectory.dir("generated/java/${targetLow}"))
    }

    android.sourceSets.getByName("main") {
        java.srcDir(layout.buildDirectory.dir("generated/java/${targetLow}").get().asFile)
        jniLibs.srcDir(jniOutDir.get().asFile)
    }

    tasks.named("preBuild").configure { dependsOn(syncJava, copyLibs) }
}
