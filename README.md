# Moonshine Java

### A plugin for [Moonshine](http://github.com/railsmachine/moonshine)

A plugin for installing and managing java. Currently installs the `openjdk-6-jdk` package by default.

### Instructions

* <tt>script/plugin install git://github.com/railsmachine/moonshine_java.git</tt>
* Configure settings if needed
    configure(:java => {:package => 'openjdk-6-jre'})

* Invoke the recipe(s) in your Moonshine manifest
    recipe :java
    
***
Unless otherwise specified, all content copyright &copy; 2014, [Rails Machine, LLC](http://railsmachine.com)
