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

// ── Config from Bazel-forwarded environment ──────────────────────────────────
fun env(name: String): String? = System.getenv(name)

val swiftlyPath: String? = env("SWIFTLY_PATH")
val swiftSdkRoot: String? = env("SWIFT_SDK_PATH")
val swiftVersion: String? = env("SWIFT_VERSION")
val androidSdkVersion: String? = env("SWIFT_ANDROID_SDK_VERSION")
val sdkBundlePath = "$swiftSdkRoot/swift-$androidSdkVersion.artifactbundle"
val minSdk = android.defaultConfig.minSdk ?: 30
val repoRoot = project.projectDir.resolve("../../..")

// ── Swift packages to bridge ──────────────────────────────────────────────────
// Just add the name and relative path here.
val swiftPackages = listOf(
    mapOf("target" to "Gateway", "dir" to "packages/gateway", "sourcePath" to "Core/Sources/Gateway"),
)
val swiftRuntimePackage = swiftPackages.first()
val swiftRuntimeTarget = swiftRuntimePackage["target"] ?: error("Swift runtime package target is required")
val swiftRuntimePackageDir = repoRoot.resolve(
    swiftRuntimePackage["dir"] ?: error("Swift runtime package dir is required"),
)

// ── ABI Configuration ────────────────────────────────────────────────────────
val isCi = System.getenv("CI") == "true"

val abiList = if (isCi) {
    mapOf(
        "arm64-v8a" to mapOf(
            "triple" to "aarch64-unknown-linux-android$minSdk",
            "libDir" to "swift-aarch64",
            "ndkDir" to "aarch64-linux-android",
        ),
    )
} else {
    mapOf(
        "arm64-v8a" to mapOf(
            "triple" to "aarch64-unknown-linux-android$minSdk",
            "libDir" to "swift-aarch64",
            "ndkDir" to "aarch64-linux-android",
        ),
        "armeabi-v7a" to mapOf(
            "triple" to "armv7-unknown-linux-android$minSdk",
            "libDir" to "swift-armv7",
            "ndkDir" to "arm-linux-androideabi",
        ),
        "x86_64" to mapOf(
            "triple" to "x86_64-unknown-linux-android$minSdk",
            "libDir" to "swift-x86_64",
            "ndkDir" to "x86_64-linux-android",
        ),
    )
}

// Add this outside the forEach, at the top of the file
abstract class SyncSwiftJavaTask : DefaultTask() {
    @get:Inject
    abstract val fileSystemOperations: FileSystemOperations

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
        fileSystemOperations.sync {
            from(src)
            into(javaOutput)
        }
    }
}

fun requiredFile(description: String, vararg candidates: File): File = candidates.firstOrNull { it.isFile }
    ?: error("$description not found. Checked: ${candidates.joinToString { it.absolutePath }}")

fun requiredDirectory(description: String, vararg candidates: File): File = candidates.firstOrNull { it.isDirectory }
    ?: error("$description not found. Checked: ${candidates.joinToString { it.absolutePath }}")

// ── Build & Wire Logic ───────────────────────────────────────────────────────
swiftPackages.forEach { pkg ->
    val target = pkg["target"] ?: return@forEach
    val packageDir = repoRoot.resolve(pkg["dir"] ?: return@forEach)
    val sourcePath = pkg["sourcePath"] ?: "Sources/$target"
    if (!packageDir.resolve("Package.swift").isFile) {
        throw GradleException("Package.swift not found at ${packageDir.absolutePath}")
    }
    val targetLow = target.lowercase()
    val packageIdentity = packageDir.name.lowercase()

    val jniOutDir = layout.buildDirectory.dir("generated/jniLibs/$targetLow")
    val extractOutputDir =
        file("$packageDir/.build/plugins/outputs/$packageIdentity/$target/destination/JExtractSwiftPlugin/src/generated/java")

    // Task to build for all ABIs
    val buildAll = tasks.register("buildSwiftAll_$target") {
        group = "bridge"
        description = "Orchestrates Swift builds and Java generation for $target"
        inputs.file(File(packageDir, "Package.swift"))
        inputs.dir(File(packageDir, sourcePath))
        outputs.dir(extractOutputDir)
    }

    abiList.forEach { (abi, info) ->
        val triple = info["triple"] ?: ""
        val abiTask = tasks.register<Exec>("buildSwift_${target}_$abi") {
            group = "bridge"
            workingDir = packageDir
            executable = swiftlyPath
            inputs.file(File(packageDir, "Package.swift"))
            inputs.dir(File(packageDir, sourcePath))
            args(
                "run",
                "swift",
                "build",
                "+$swiftVersion",
                "--product",
                target,
                "--swift-sdk",
                triple,
                "--build-system",
                "native",
            )

            outputs.dir(file("$packageDir/.build/$triple/debug"))
        }
        buildAll.configure { dependsOn(abiTask) }
    }

    val copyLibs = tasks.register<Sync>("copyJniLibs_$target") {
        group = "bridge"
        dependsOn(buildAll)

        abiList.forEach { (abi, info) ->
            val triple = info["triple"] ?: ""
            val ndkDir = info["ndkDir"] ?: ""
            val libDir = info["libDir"] ?: ""

            // 1. Built Swift binaries
            from(file("$packageDir/.build/$triple/debug")) {
                include("lib$target.so")
                into(abi)
            }
        }
        into(jniOutDir)
    }

    val syncJava = tasks.register<SyncSwiftJavaTask>("syncSwiftJava_$target") {
        dependsOn(buildAll)
        extractOutput.set(extractOutputDir)
        javaOutput.set(layout.buildDirectory.dir("generated/java/$targetLow"))
    }

    android.sourceSets.getByName("main") {
        java.srcDir(layout.buildDirectory.dir("generated/java/$targetLow").get().asFile)
        jniLibs.srcDir(jniOutDir.get().asFile)
    }

    tasks.named("preBuild").configure {
        dependsOn(syncJava, copyLibs)
        doFirst {
            listOf("SWIFTLY_PATH", "SWIFT_SDK_PATH", "SWIFT_VERSION", "SWIFT_ANDROID_SDK_VERSION")
                .forEach { System.getenv(it) ?: throw GradleException("$it is required") }
        }
    }
}

val swiftRuntimeJniOutDir = layout.buildDirectory.dir("generated/jniLibs/swiftruntime")
val copySwiftRuntimeLibs = tasks.register<Sync>("copySwiftRuntimeLibs") {
    group = "bridge"
    description = "Copies shared Swift Android runtime libraries once for all bridged packages"
    dependsOn("buildSwiftAll_$swiftRuntimeTarget")

    abiList.forEach { (abi, info) ->
        val triple = info["triple"] ?: ""
        val ndkDir = info["ndkDir"] ?: ""
        val libDir = info["libDir"] ?: ""

        from(file("$swiftRuntimePackageDir/.build/$triple/debug")) {
            include("libSwiftJava.so")
            into(abi)
        }

        from(
            requiredFile(
                "Swift Android C++ runtime",
                file("$sdkBundlePath/swift-android/ndk-sysroot/usr/lib/$ndkDir/libc++_shared.so"),
                file("$sdkBundlePath/swift-android/ndk-sysroot/usr/lib/$ndkDir/$minSdk/libc++_shared.so"),
            ),
        ) {
            into(abi)
        }

        from(
            requiredDirectory(
                "Swift Android runtime",
                file("$sdkBundlePath/swift-android/swift-resources/usr/lib/$libDir/android"),
            ),
        ) {
            include("*.so")
            into(abi)
        }
    }

    into(swiftRuntimeJniOutDir)
}

android.sourceSets.getByName("main") {
    jniLibs.srcDir(swiftRuntimeJniOutDir.get().asFile)
}

tasks.named("preBuild").configure {
    dependsOn(copySwiftRuntimeLibs)
}
