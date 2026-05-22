pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        val nearbyMavenUrl = providers.gradleProperty("nearby.maven.url")
            .get()

        maven {
            url = uri(nearbyMavenUrl)
            content {
                includeGroup("org.swift.swiftkit")
            }
        }
        google()
        mavenCentral()
    }
}

rootProject.name = "nearby"
include(":app")
include(":bridge")
