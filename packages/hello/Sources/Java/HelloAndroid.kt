package com.variance.nearby.hello

class HelloAndroid : HelloShared {
    override fun greeting(name: String): String {
        return "Typed hello, $name"
    }

    override fun timesTwo(value: Int): Int {
        return value * 2
    }
}
