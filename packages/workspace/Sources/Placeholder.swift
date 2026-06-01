// This is am empty workspace package that is used to centralized all the dependencies for each indiviadual package.

// bazel build reads from here and automatically resolves the required dependencies of each individual package during build time.

// when any new package and package dependency is added, it should be added to this file as well.
// this is to ensure that all the dependencies are resolved and built before the package is built.
//
